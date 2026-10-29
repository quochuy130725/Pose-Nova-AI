import {
  DisputeStatus,
  MilestoneStatus,
  RequestStatus,
  TransactionStatus,
  TransactionType,
} from '@prisma/client';
import { prisma } from '../../config/database';
import { AppError } from '../../common/middlewares/error.middleware';
import { AuthUserPayload } from '../../common/middlewares/auth.middleware';
import { CreateDisputeInput } from './disputes.schema';

export class DisputesService {
  /**
   * TSK-18: Opens a Dispute, freezes contract escrow (`ESCROW_FROZEN`), preserves 100%
   * of payouts from already-APPROVED stages for the Stylist, and automatically refunds
   * the remaining unapproved stages (e.g. 70% or 40% Gross) back to the Client's Wallet.
   */
  static async openDisputeAndRefund(user: AuthUserPayload, input: CreateDisputeInput) {
    let requestIdToLoad = input.requestId?.replace(/^#/, '').trim();
    let targetMilestoneId = input.milestoneId?.trim();

    if (targetMilestoneId && !requestIdToLoad) {
      const m = await prisma.requestMilestone.findUnique({
        where: { id: targetMilestoneId },
      });
      if (!m) {
        throw new AppError(`Milestone "${targetMilestoneId}" not found`, 404);
      }
      requestIdToLoad = m.requestId;
    }

    const request = await prisma.stylingRequest.findFirst({
      where: {
        OR: [
          ...(requestIdToLoad ? [{ id: requestIdToLoad }, { code: requestIdToLoad.toUpperCase() }] : []),
        ],
      },
      include: {
        milestones: { orderBy: { stageOrder: 'asc' } },
        dispute: true,
      },
    });

    if (!request) {
      throw new AppError('Styling contract not found for dispute', 404);
    }

    if (user.role !== 'ADMIN' && request.clientId !== user.userId) {
      throw new AppError(
        'Forbidden: Only the Client of this styling contract can open a Dispute',
        403,
      );
    }

    if (request.dispute || request.status === RequestStatus.ESCROW_FROZEN) {
      throw new AppError(
        `Contract #${request.code} is already frozen under an active/settled Dispute`,
        409,
      );
    }

    if (request.status !== RequestStatus.IN_PROGRESS) {
      throw new AppError(
        `Cannot open Dispute while contract #${request.code} is in status ${request.status}`,
        400,
      );
    }

    const targetMilestone = targetMilestoneId
      ? request.milestones.find((m) => m.id === targetMilestoneId)
      : request.milestones.find(
          (m) =>
            m.status === MilestoneStatus.IN_REVIEW ||
            m.status === MilestoneStatus.REVISION_REQUESTED ||
            m.status === MilestoneStatus.ACTIVE,
        );

    if (!targetMilestone) {
      throw new AppError('No unapproved milestone found on this contract to dispute', 400);
    }

    if (targetMilestone.status === MilestoneStatus.APPROVED) {
      throw new AppError(
        `Stage ${targetMilestone.stageOrder} has already been APPROVED and its payout is final (non-refundable).`,
        400,
      );
    }

    // Stylist Fairness Rule: Client must exhaust the 2 free revisions on the contested stage first
    if (
      user.role !== 'ADMIN' &&
      targetMilestone.revisionCount < targetMilestone.maxRevisions
    ) {
      throw new AppError(
        `Please utilize the ${targetMilestone.maxRevisions} free revisions on Stage ${targetMilestone.stageOrder} before opening a Dispute (current revisions used: ${targetMilestone.revisionCount}/${targetMilestone.maxRevisions}).`,
        400,
      );
    }

    const now = new Date();

    const settlement = await prisma.$transaction(async (tx) => {
      // Atomic contract freeze prevents duplicate dispute / double refund
      const freezeClaim = await tx.stylingRequest.updateMany({
        where: {
          id: request.id,
          status: RequestStatus.IN_PROGRESS,
        },
        data: {
          status: RequestStatus.ESCROW_FROZEN,
        },
      });

      if (freezeClaim.count === 0) {
        throw new AppError(
          `Contract #${request.code} escrow was already frozen or settled concurrently`,
          409,
        );
      }

      const freshMilestones = await tx.requestMilestone.findMany({
        where: { requestId: request.id },
        orderBy: { stageOrder: 'asc' },
      });

      const approvedStages = freshMilestones.filter(
        (m) => m.status === MilestoneStatus.APPROVED,
      );
      const unapprovedStages = freshMilestones.filter(
        (m) => m.status !== MilestoneStatus.APPROVED,
      );

      if (unapprovedStages.length === 0) {
        throw new AppError('All stages are already approved — nothing left in escrow to refund', 400);
      }

      const totalBudget = Number(request.totalBudget);
      const stylistRetainedGross = approvedStages.reduce(
        (sum, m) => sum + Number(m.grossAmount),
        0,
      );
      const stylistRetainedNet = approvedStages.reduce(
        (sum, m) => sum + Number(m.netPayout),
        0,
      );
      const platformRetainedFee = stylistRetainedGross - stylistRetainedNet;

      const refundPercentage = unapprovedStages.reduce((sum, m) => sum + m.percentage, 0);
      const remainingRefundAmount = unapprovedStages.reduce(
        (sum, m) => sum + Number(m.grossAmount),
        0,
      );
      const stylistLockedNetToUnfreeze = unapprovedStages.reduce(
        (sum, m) => sum + Number(m.netPayout),
        0,
      );

      // 1. Mark all unapproved stages as DISPUTED & cancel any pending 48h SLA timers
      await tx.requestMilestone.updateMany({
        where: {
          requestId: request.id,
          status: { not: MilestoneStatus.APPROVED },
        },
        data: {
          status: MilestoneStatus.DISPUTED,
          autoReleaseAt: null,
        },
      });

      // 2. Create Dispute record
      const dispute = await tx.dispute.create({
        data: {
          requestId: request.id,
          milestoneId: targetMilestone.id,
          reason: input.reason,
          remainingRefundAmount,
          status: DisputeStatus.REFUNDED,
          resolvedAt: now,
        },
      });

      // 3. Ensure Client & Stylist Wallets exist
      const clientWallet = await tx.wallet.upsert({
        where: { userId: request.clientId },
        update: {},
        create: {
          userId: request.clientId,
          availableBalance: 0,
          escrowLockedBalance: 0,
          totalWithdrawn: 0,
        },
      });

      const stylistWallet = await tx.wallet.upsert({
        where: { userId: request.stylistId },
        update: {},
        create: {
          userId: request.stylistId,
          availableBalance: 0,
          escrowLockedBalance: 0,
          totalWithdrawn: 0,
        },
      });

      // 4. Unfreeze unapproved Net from Stylist's Escrow Locked Balance (Stylist's availableBalance from approved stages stays 100% intact!)
      const updatedStylistWallet = await tx.wallet.update({
        where: { id: stylistWallet.id },
        data: {
          escrowLockedBalance: { decrement: stylistLockedNetToUnfreeze },
        },
      });

      // 5. Refund 100% of unapproved Gross (e.g. 70% or 40%) back to Client's Available Balance
      const updatedClientWallet = await tx.wallet.update({
        where: { id: clientWallet.id },
        data: {
          availableBalance: { increment: remainingRefundAmount },
        },
      });

      // 6. Log immutable REFUND transaction in ledger
      const refundTx = await tx.paymentTransaction.create({
        data: {
          requestId: request.id,
          milestoneId: targetMilestone.id,
          walletId: clientWallet.id,
          type: TransactionType.REFUND,
          grossAmount: remainingRefundAmount,
          feeAmount: 0,
          netAmount: remainingRefundAmount,
          status: TransactionStatus.COMPLETED,
          description: `Dispute Partial Refund (${refundPercentage}% unapproved stages) returned to Client for Order #${request.code}`,
        },
      });

      return {
        dispute,
        totalBudget,
        approvedStagesCount: approvedStages.length,
        unapprovedStagesCount: unapprovedStages.length,
        stylistRetainedGross,
        stylistRetainedNet,
        platformRetainedFee,
        refundPercentage,
        remainingRefundAmount,
        stylistLockedNetToUnfreeze,
        updatedStylistWallet,
        updatedClientWallet,
        refundTx,
      };
    });

    return {
      dispute: {
        id: settlement.dispute.id,
        requestId: settlement.dispute.requestId,
        requestCode: request.code,
        milestoneId: settlement.dispute.milestoneId,
        disputedStageOrder: targetMilestone.stageOrder,
        reason: settlement.dispute.reason,
        status: settlement.dispute.status,
        remainingRefundAmount: Number(settlement.dispute.remainingRefundAmount),
        createdAt: settlement.dispute.createdAt,
        resolvedAt: settlement.dispute.resolvedAt,
      },
      contractStatus: RequestStatus.ESCROW_FROZEN,
      resolutionBreakdown: {
        totalDepositedGross: settlement.totalBudget,
        approvedStagesKeptByStylistCount: settlement.approvedStagesCount,
        stylistRetainedNet: settlement.stylistRetainedNet,
        platformRetainedFee: settlement.platformRetainedFee,
        refundedStagesCount: settlement.unapprovedStagesCount,
        refundPercentage: settlement.refundPercentage,
        clientRefundedGross: settlement.remainingRefundAmount,
        reconciledSumCheck:
          settlement.stylistRetainedNet +
          settlement.platformRetainedFee +
          settlement.remainingRefundAmount,
      },
      transaction: {
        id: settlement.refundTx.id,
        type: settlement.refundTx.type,
        grossAmount: Number(settlement.refundTx.grossAmount),
        netAmount: Number(settlement.refundTx.netAmount),
        description: settlement.refundTx.description,
      },
      clientWallet: {
        id: settlement.updatedClientWallet.id,
        availableBalance: Number(settlement.updatedClientWallet.availableBalance),
      },
      stylistWallet: {
        id: settlement.updatedStylistWallet.id,
        availableBalance: Number(settlement.updatedStylistWallet.availableBalance),
        escrowLockedBalance: Number(settlement.updatedStylistWallet.escrowLockedBalance),
      },
    };
  }

  static async listDisputes(user: AuthUserPayload) {
    const disputes = await prisma.dispute.findMany({
      where:
        user.role === 'ADMIN'
          ? {}
          : user.role === 'CLIENT'
            ? { request: { clientId: user.userId } }
            : { request: { stylistId: user.userId } },
      orderBy: { createdAt: 'desc' },
      include: {
        request: {
          select: {
            id: true,
            code: true,
            title: true,
            totalBudget: true,
            status: true,
          },
        },
        milestone: {
          select: {
            id: true,
            stageOrder: true,
            title: true,
            percentage: true,
            revisionCount: true,
          },
        },
      },
    });

    return disputes.map((d) => ({
      ...d,
      remainingRefundAmount: Number(d.remainingRefundAmount),
      request: {
        ...d.request,
        totalBudget: Number(d.request.totalBudget),
      },
    }));
  }
}

