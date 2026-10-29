import {
  MilestoneStatus,
  Prisma,
  RequestStatus,
  TransactionStatus,
  TransactionType,
} from '@prisma/client';
import { prisma } from '../../config/database';
import { AppError } from '../../common/middlewares/error.middleware';
import { PLATFORM_FEE_RATE, SLA_HOURS } from '../../common/constants/escrow.constants';
import { AuthUserPayload } from '../../common/middlewares/auth.middleware';
import {
  ApproveMilestoneInput,
  RequestRevisionInput,
  SubmitMilestoneInput,
} from './milestones.schema';

const REQUIRED_POSE_LANDMARKS = 33;

export class MilestonesService {
  /**
   * TSK-15: Stylist submits stage deliverable, records MilestoneSubmission history,
   * attaches optional affiliate ProductTags / 33 Pose Landmarks, and arms 48h SLA timer.
   */
  static async submitMilestone(
    milestoneId: string,
    user: AuthUserPayload,
    input: SubmitMilestoneInput,
  ) {
    const milestone = await prisma.requestMilestone.findUnique({
      where: { id: milestoneId },
      include: {
        request: true,
      },
    });

    if (!milestone) {
      throw new AppError(`Milestone "${milestoneId}" not found`, 404);
    }

    if (user.role !== 'ADMIN' && milestone.request.stylistId !== user.userId) {
      throw new AppError(
        'Forbidden: Only the assigned Stylist of this contract can submit deliverables',
        403,
      );
    }

    if (milestone.request.status !== RequestStatus.IN_PROGRESS) {
      throw new AppError(
        `Cannot submit milestone while contract #${milestone.request.code} is in status ${milestone.request.status}`,
        400,
      );
    }

    if (milestone.status === MilestoneStatus.LOCKED) {
      throw new AppError(
        `Stage ${milestone.stageOrder} is still LOCKED. Previous stage must be approved first.`,
        400,
      );
    }

    if (milestone.status === MilestoneStatus.APPROVED) {
      throw new AppError(
        `Stage ${milestone.stageOrder} has already been APPROVED and settled.`,
        400,
      );
    }

    if (milestone.status === MilestoneStatus.DISPUTED) {
      throw new AppError(
        `Stage ${milestone.stageOrder} is frozen under DISPUTED status.`,
        400,
      );
    }

    let normalizedPoseJson: Prisma.InputJsonValue | undefined;
    if (input.poseLandmarksJson !== undefined) {
      if (input.poseLandmarksJson.length !== REQUIRED_POSE_LANDMARKS) {
        throw new AppError(
          `Pose guide must contain exactly 33 human skeletal landmarks (received ${input.poseLandmarksJson.length})`,
          400,
        );
      }

      normalizedPoseJson = input.poseLandmarksJson.map((node, index) => ({
        landmarkIndex: node.landmarkIndex ?? node.id ?? index,
        x: Number(node.x),
        y: Number(node.y),
        z: Number(node.z ?? 0),
        visibility: Number(node.visibility ?? 0.99),
      })) as unknown as Prisma.InputJsonValue;
    }

    const submittedAt = new Date();
    const autoReleaseAt = new Date(submittedAt.getTime() + SLA_HOURS * 60 * 60 * 1000);

    const result = await prisma.$transaction(async (tx) => {
      // 1. Insert immutable submission history row in `milestone_submissions`
      const submission = await tx.milestoneSubmission.create({
        data: {
          milestoneId: milestone.id,
          revisionNumber: milestone.revisionCount,
          deliverableUrl: input.deliverableUrl,
          stylistNotes: input.stylistNotes ?? null,
          poseLandmarksJson: normalizedPoseJson ?? Prisma.JsonNull,
          submittedAt,
        },
      });

      // 2. Replace shoppable affiliate product tags on this milestone if provided
      if (input.productTags !== undefined) {
        await tx.productTag.deleteMany({
          where: { milestoneId: milestone.id },
        });

        if (input.productTags.length > 0) {
          await tx.productTag.createMany({
            data: input.productTags.map((tag) => ({
              milestoneId: milestone.id,
              productName: tag.productName,
              brandName: tag.brandName ?? null,
              price: tag.price,
              thumbnailUrl: tag.thumbnailUrl ?? null,
              affiliateUrl: tag.affiliateUrl,
              posX: tag.posX,
              posY: tag.posY,
            })),
          });
        }
      }

      // 3. Transition milestone -> IN_REVIEW and arm 48-hour SLA auto-release timer
      const updatedMilestone = await tx.requestMilestone.update({
        where: { id: milestone.id },
        data: {
          status: MilestoneStatus.IN_REVIEW,
          deliverableTitle: input.deliverableTitle ?? milestone.deliverableTitle,
          deliverableUrl: input.deliverableUrl,
          stylistNotes: input.stylistNotes ?? milestone.stylistNotes,
          ...(normalizedPoseJson !== undefined ? { poseLandmarksJson: normalizedPoseJson } : {}),
          submittedAt,
          autoReleaseAt,
        },
        include: {
          submissions: { orderBy: { submittedAt: 'asc' } },
          productTags: true,
        },
      });

      return { submission, updatedMilestone };
    });

    const grossAmount = Number(result.updatedMilestone.grossAmount);
    const netPayout = Number(result.updatedMilestone.netPayout);

    return {
      id: result.updatedMilestone.id,
      requestId: result.updatedMilestone.requestId,
      requestCode: milestone.request.code,
      stageOrder: result.updatedMilestone.stageOrder,
      title: result.updatedMilestone.title,
      percentage: result.updatedMilestone.percentage,
      grossAmount,
      platformFeeRate: PLATFORM_FEE_RATE,
      platformFeeAmount: grossAmount - netPayout,
      netPayout,
      status: result.updatedMilestone.status,
      revisionCount: result.updatedMilestone.revisionCount,
      maxRevisions: result.updatedMilestone.maxRevisions,
      deliverableTitle: result.updatedMilestone.deliverableTitle,
      deliverableUrl: result.updatedMilestone.deliverableUrl,
      stylistNotes: result.updatedMilestone.stylistNotes,
      poseLandmarksJson: result.updatedMilestone.poseLandmarksJson,
      slaHours: SLA_HOURS,
      submittedAt: result.updatedMilestone.submittedAt,
      autoReleaseAt: result.updatedMilestone.autoReleaseAt,
      latestSubmission: result.submission,
      submissions: result.updatedMilestone.submissions,
      productTags: result.updatedMilestone.productTags.map((tag) => ({
        ...tag,
        price: Number(tag.price),
      })),
    };
  }

  /**
   * TSK-16: Client approves stage deliverable -> ACID release of 85% Net Payout from
   * Stylist's `escrowLockedBalance` to `availableBalance`, logs `MILESTONE_RELEASE`,
   * prevents double-click payouts, and unlocks the next stage (or marks contract COMPLETED).
   */
  static async approveMilestone(
    milestoneId: string,
    user: AuthUserPayload,
    input: ApproveMilestoneInput = {},
  ) {
    const milestone = await prisma.requestMilestone.findUnique({
      where: { id: milestoneId },
      include: { request: true },
    });

    if (!milestone) {
      throw new AppError(`Milestone "${milestoneId}" not found`, 404);
    }

    if (user.role !== 'ADMIN' && milestone.request.clientId !== user.userId) {
      throw new AppError(
        'Forbidden: Only the Client who created this styling contract can approve stages',
        403,
      );
    }

    const feedback = input.feedback ?? input.clientFeedback;
    return this.executeAcidMilestoneRelease(milestone.id, 'CLIENT_APPROVAL', feedback);
  }

  /**
   * Used by the 48-hour SLA background cronjob to auto-release overdue `IN_REVIEW` stages.
   */
  static async autoReleaseExpiredMilestone(milestoneId: string) {
    return this.executeAcidMilestoneRelease(
      milestoneId,
      'SLA_48H_AUTO_RELEASE',
      'Auto-approved after 48-hour SLA review window elapsed without objection.',
    );
  }

  private static async executeAcidMilestoneRelease(
    milestoneId: string,
    triggerSource: 'CLIENT_APPROVAL' | 'SLA_48H_AUTO_RELEASE',
    feedback?: string,
  ) {
    const now = new Date();

    const releaseResult = await prisma.$transaction(async (tx) => {
      const milestone = await tx.requestMilestone.findUnique({
        where: { id: milestoneId },
        include: { request: true },
      });

      if (!milestone) {
        throw new AppError(`Milestone "${milestoneId}" not found`, 404);
      }

      if (milestone.request.status !== RequestStatus.IN_PROGRESS) {
        throw new AppError(
          `Cannot release escrow while contract #${milestone.request.code} is in status ${milestone.request.status}`,
          400,
        );
      }

      if (milestone.status === MilestoneStatus.APPROVED) {
        throw new AppError(
          `Stage ${milestone.stageOrder} has already been approved and paid out (anti-double-release guard)`,
          409,
        );
      }

      if (milestone.status !== MilestoneStatus.IN_REVIEW) {
        throw new AppError(
          `Stage ${milestone.stageOrder} must be in IN_REVIEW status before approval (current: ${milestone.status})`,
          400,
        );
      }

      // Layer 1 Anti-Double-Click Guard: Atomic PostgreSQL row-locked conditional UPDATE
      const atomicClaim = await tx.requestMilestone.updateMany({
        where: {
          id: milestone.id,
          status: MilestoneStatus.IN_REVIEW,
        },
        data: {
          status: MilestoneStatus.APPROVED,
          approvedAt: now,
          autoReleaseAt: null,
          ...(feedback ? { clientFeedback: feedback } : {}),
        },
      });

      if (atomicClaim.count === 0) {
        throw new AppError(
          `Concurrent approval detected for Stage ${milestone.stageOrder} — duplicate payout blocked`,
          409,
        );
      }

      // Layer 2 Anti-Double-Click Guard: Ledger uniqueness check (+ @@unique([milestoneId, type]) DB constraint)
      const existingReleaseTx = await tx.paymentTransaction.findUnique({
        where: {
          milestoneId_type: {
            milestoneId: milestone.id,
            type: TransactionType.MILESTONE_RELEASE,
          },
        },
      });

      if (existingReleaseTx) {
        throw new AppError(
          `Escrow release ledger entry already exists for Stage ${milestone.stageOrder}`,
          409,
        );
      }

      const stylistWallet = await tx.wallet.upsert({
        where: { userId: milestone.request.stylistId },
        update: {},
        create: {
          userId: milestone.request.stylistId,
          availableBalance: 0,
          escrowLockedBalance: 0,
          totalWithdrawn: 0,
        },
      });

      const grossAmount = Number(milestone.grossAmount);
      const netPayout = Number(milestone.netPayout);
      const feeAmount = grossAmount - netPayout;

      // Transfer 85% Net from Escrow Locked -> Available Balance
      const updatedStylistWallet = await tx.wallet.update({
        where: { id: stylistWallet.id },
        data: {
          escrowLockedBalance: { decrement: netPayout },
          availableBalance: { increment: netPayout },
        },
      });

      // Record immutable MILESTONE_RELEASE transaction
      const descriptionPrefix =
        triggerSource === 'SLA_48H_AUTO_RELEASE'
          ? '[SLA 48h Auto-Release]'
          : '[Client Approved]';

      const releaseTx = await tx.paymentTransaction.create({
        data: {
          requestId: milestone.requestId,
          milestoneId: milestone.id,
          walletId: stylistWallet.id,
          type: TransactionType.MILESTONE_RELEASE,
          grossAmount,
          feeAmount,
          netAmount: netPayout,
          status: TransactionStatus.COMPLETED,
          description: `${descriptionPrefix} Released ${milestone.percentage}% Net payout (Stage ${milestone.stageOrder}) for Order #${milestone.request.code}`,
        },
      });

      // Unlock Next Stage (if LOCKED) OR complete contract if final stage
      let unlockedNextStage: { id: string; stageOrder: number; title: string; status: string } | null =
        null;

      const nextStageCandidate = await tx.requestMilestone.findUnique({
        where: {
          requestId_stageOrder: {
            requestId: milestone.requestId,
            stageOrder: milestone.stageOrder + 1,
          },
        },
      });

      if (nextStageCandidate && nextStageCandidate.status === MilestoneStatus.LOCKED) {
        const unlocked = await tx.requestMilestone.update({
          where: { id: nextStageCandidate.id },
          data: { status: MilestoneStatus.ACTIVE },
        });
        unlockedNextStage = {
          id: unlocked.id,
          stageOrder: unlocked.stageOrder,
          title: unlocked.title,
          status: unlocked.status,
        };
      }

      // Check if all stages of the contract are now APPROVED
      const unapprovedRemaining = await tx.requestMilestone.count({
        where: {
          requestId: milestone.requestId,
          status: { not: MilestoneStatus.APPROVED },
        },
      });

      let contractStatus: RequestStatus = milestone.request.status;
      if (unapprovedRemaining === 0) {
        const completedContract = await tx.stylingRequest.update({
          where: { id: milestone.requestId },
          data: { status: RequestStatus.COMPLETED },
        });
        contractStatus = completedContract.status;
      }

      const approvedMilestone = await tx.requestMilestone.findUniqueOrThrow({
        where: { id: milestone.id },
      });

      return {
        requestCode: milestone.request.code,
        contractStatus,
        approvedMilestone,
        unlockedNextStage,
        releaseTx,
        updatedStylistWallet,
      };
    });

    const grossAmount = Number(releaseResult.approvedMilestone.grossAmount);
    const netPayout = Number(releaseResult.approvedMilestone.netPayout);

    return {
      triggerSource,
      requestCode: releaseResult.requestCode,
      contractStatus: releaseResult.contractStatus,
      approvedMilestone: {
        id: releaseResult.approvedMilestone.id,
        stageOrder: releaseResult.approvedMilestone.stageOrder,
        title: releaseResult.approvedMilestone.title,
        percentage: releaseResult.approvedMilestone.percentage,
        grossAmount,
        platformFeeAmount: grossAmount - netPayout,
        netPayout,
        status: releaseResult.approvedMilestone.status,
        approvedAt: releaseResult.approvedMilestone.approvedAt,
      },
      unlockedNextStage: releaseResult.unlockedNextStage,
      transaction: {
        id: releaseResult.releaseTx.id,
        type: releaseResult.releaseTx.type,
        grossAmount: Number(releaseResult.releaseTx.grossAmount),
        feeAmount: Number(releaseResult.releaseTx.feeAmount),
        netAmount: Number(releaseResult.releaseTx.netAmount),
        description: releaseResult.releaseTx.description,
        createdAt: releaseResult.releaseTx.createdAt,
      },
      stylistWallet: {
        id: releaseResult.updatedStylistWallet.id,
        availableBalance: Number(releaseResult.updatedStylistWallet.availableBalance),
        escrowLockedBalance: Number(releaseResult.updatedStylistWallet.escrowLockedBalance),
      },
    };
  }

  /**
   * TSK-17: Client requests revision on an `IN_REVIEW` stage, strictly enforcing
   * `maxRevisions = 2` free revisions per stage. If `revisionCount >= 2`, blocks and
   * instructs Client to either Approve or open a Dispute for partial refund.
   */
  static async requestRevision(
    milestoneId: string,
    user: AuthUserPayload,
    input: RequestRevisionInput,
  ) {
    const milestone = await prisma.requestMilestone.findUnique({
      where: { id: milestoneId },
      include: { request: true },
    });

    if (!milestone) {
      throw new AppError(`Milestone "${milestoneId}" not found`, 404);
    }

    if (user.role !== 'ADMIN' && milestone.request.clientId !== user.userId) {
      throw new AppError(
        'Forbidden: Only the Client of this styling contract can request revisions',
        403,
      );
    }

    if (milestone.request.status !== RequestStatus.IN_PROGRESS) {
      throw new AppError(
        `Cannot request revision while contract #${milestone.request.code} is in status ${milestone.request.status}`,
        400,
      );
    }

    if (milestone.status !== MilestoneStatus.IN_REVIEW) {
      throw new AppError(
        `Revisions can only be requested when stage status is IN_REVIEW (current: ${milestone.status})`,
        400,
      );
    }

    // Strict Revision Quota Cap (2 free revisions per stage)
    if (milestone.revisionCount >= milestone.maxRevisions) {
      throw new AppError(
        `Maximum revision quota (${milestone.revisionCount}/${milestone.maxRevisions}) reached for Stage ${milestone.stageOrder}. Please approve the stage or open a Dispute (POST /api/v1/disputes) for an automatic partial refund.`,
        400,
      );
    }

    const updated = await prisma.$transaction(async (tx) => {
      const atomicRev = await tx.requestMilestone.updateMany({
        where: {
          id: milestone.id,
          status: MilestoneStatus.IN_REVIEW,
          revisionCount: { lt: milestone.maxRevisions },
        },
        data: {
          revisionCount: { increment: 1 },
          status: MilestoneStatus.REVISION_REQUESTED,
          clientFeedback: input.feedback,
          autoReleaseAt: null, // Pause 48h SLA timer while Stylist works on revision
        },
      });

      if (atomicRev.count === 0) {
        throw new AppError(
          `Maximum revision quota (${milestone.maxRevisions}/${milestone.maxRevisions}) reached or stage is no longer in IN_REVIEW status.`,
          400,
        );
      }

      // Attach feedback onto the latest submission record for audit timeline clarity
      const latestSubmission = await tx.milestoneSubmission.findFirst({
        where: { milestoneId: milestone.id },
        orderBy: { submittedAt: 'desc' },
      });

      if (latestSubmission) {
        await tx.milestoneSubmission.update({
          where: { id: latestSubmission.id },
          data: { clientFeedback: input.feedback },
        });
      }

      return tx.requestMilestone.findUniqueOrThrow({
        where: { id: milestone.id },
        include: {
          submissions: { orderBy: { submittedAt: 'asc' } },
        },
      });
    });

    const remainingRevisions = Math.max(0, updated.maxRevisions - updated.revisionCount);

    return {
      id: updated.id,
      requestId: updated.requestId,
      requestCode: milestone.request.code,
      stageOrder: updated.stageOrder,
      title: updated.title,
      status: updated.status,
      revisionCount: updated.revisionCount,
      maxRevisions: updated.maxRevisions,
      remainingRevisions,
      canOpenDisputeAfterNextSubmit: remainingRevisions === 0,
      clientFeedback: updated.clientFeedback,
      autoReleaseAt: updated.autoReleaseAt,
      submissions: updated.submissions,
    };
  }
}
