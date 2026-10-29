import { Prisma, RequestStatus, Role } from '@prisma/client';
import { prisma } from '../../config/database';
import { AppError } from '../../common/middlewares/error.middleware';
import { PLATFORM_FEE_RATE, STYLIST_NET_RATE } from '../../common/constants/escrow.constants';
import { calculateMilestoneBreakdown } from '../../common/utils/money.util';
import { GeminiService } from '../../integrations/gemini/gemini.service';
import { SepayService } from '../../integrations/sepay/sepay.service';
import {
  AiEnhanceBriefBody,
  CreateReviewBody,
  CreateStylingRequestBody,
} from './styling-requests.schema';
import { AuthUserPayload } from '../../common/middlewares/auth.middleware';

const USER_SUMMARY_SELECT = {
  id: true,
  email: true,
  fullName: true,
  avatarUrl: true,
  role: true,
  heightCm: true,
  weightKg: true,
  ratingAvg: true,
  totalReviews: true,
  verifiedBadge: true,
} as const;

export class StylingRequestsService {
  private static async generateUniqueOrderCode(): Promise<string> {
    for (let attempt = 0; attempt < 15; attempt++) {
      const randomDigits = Math.floor(1000 + Math.random() * 9000);
      const code = `REQ-${randomDigits}`;
      const existing = await prisma.stylingRequest.findUnique({ where: { code } });
      if (!existing) return code;
    }
    return `REQ-${Date.now().toString().slice(-6)}`;
  }

  private static formatMilestone(milestone: {
    id: string;
    requestId: string;
    stageOrder: number;
    title: string;
    description: string | null;
    percentage: number;
    grossAmount: Prisma.Decimal;
    netPayout: Prisma.Decimal;
    revisionCount: number;
    maxRevisions: number;
    stylistNotes: string | null;
    clientFeedback: string | null;
    deliverableTitle: string | null;
    deliverableUrl: string | null;
    poseLandmarksJson: Prisma.JsonValue;
    status: string;
    autoReleaseAt: Date | null;
    submittedAt: Date | null;
    approvedAt: Date | null;
    submissions?: Array<{
      id: string;
      revisionNumber: number;
      deliverableUrl: string;
      stylistNotes: string | null;
      clientFeedback: string | null;
      poseLandmarksJson: Prisma.JsonValue;
      submittedAt: Date;
    }>;
    productTags?: Array<{
      id: string;
      productName: string;
      brandName: string | null;
      price: Prisma.Decimal;
      thumbnailUrl: string | null;
      affiliateUrl: string;
      posX: number;
      posY: number;
      clickCount: number;
    }>;
  }) {
    const grossAmount = Number(milestone.grossAmount);
    const netPayout = Number(milestone.netPayout);
    const platformFeeAmount = grossAmount - netPayout;

    return {
      id: milestone.id,
      requestId: milestone.requestId,
      stageOrder: milestone.stageOrder,
      title: milestone.title,
      description: milestone.description,
      percentage: milestone.percentage,
      grossAmount,
      platformFeeRate: PLATFORM_FEE_RATE,
      platformFeeAmount,
      netPayout,
      revisionCount: milestone.revisionCount,
      maxRevisions: milestone.maxRevisions,
      remainingRevisions: Math.max(0, milestone.maxRevisions - milestone.revisionCount),
      stylistNotes: milestone.stylistNotes,
      clientFeedback: milestone.clientFeedback,
      deliverableTitle: milestone.deliverableTitle,
      deliverableUrl: milestone.deliverableUrl,
      poseLandmarksJson: milestone.poseLandmarksJson,
      status: milestone.status,
      autoReleaseAt: milestone.autoReleaseAt,
      submittedAt: milestone.submittedAt,
      approvedAt: milestone.approvedAt,
      ...(milestone.submissions
        ? {
            submissions: milestone.submissions,
          }
        : {}),
      ...(milestone.productTags
        ? {
            productTags: milestone.productTags.map((tag) => ({
              ...tag,
              price: Number(tag.price),
            })),
          }
        : {}),
    };
  }

  private static buildFinancialSummary(
    totalBudget: number,
    milestones: Array<{
      stageOrder: number;
      title: string;
      percentage: number;
      grossAmount: Prisma.Decimal | number;
      netPayout: Prisma.Decimal | number;
      status?: string;
    }>,
  ) {
    const stageBreakdown =
      milestones.length > 0
        ? milestones.map((m) => {
            const grossAmount = Number(m.grossAmount);
            const netPayout = Number(m.netPayout);
            return {
              stageOrder: m.stageOrder,
              title: m.title,
              percentage: m.percentage,
              grossAmount,
              platformFeeAmount: grossAmount - netPayout,
              netPayout,
              status: m.status ?? 'PENDING_DEPOSIT',
            };
          })
        : calculateMilestoneBreakdown(totalBudget).map((s) => ({
            stageOrder: s.stageOrder,
            title: s.title,
            percentage: s.percentage,
            grossAmount: s.grossAmount,
            platformFeeAmount: s.feeAmount,
            netPayout: s.netPayout,
            status: 'PENDING_DEPOSIT',
          }));

    const totalStylistNetPayout = stageBreakdown.reduce((sum, s) => sum + s.netPayout, 0);
    const totalPlatformFeeAmount = totalBudget - totalStylistNetPayout;

    const releasedNetAmount = stageBreakdown
      .filter((s) => s.status === 'APPROVED')
      .reduce((sum, s) => sum + s.netPayout, 0);

    const lockedEscrowNetAmount =
      milestones.length > 0
        ? stageBreakdown
            .filter((s) => s.status !== 'APPROVED' && s.status !== 'DISPUTED')
            .reduce((sum, s) => sum + s.netPayout, 0)
        : 0;

    return {
      totalBudgetGross: totalBudget,
      platformFeeRate: PLATFORM_FEE_RATE,
      platformFeePercentage: 15,
      stylistNetPercentage: 85,
      stylistNetRate: STYLIST_NET_RATE,
      totalPlatformFeeAmount,
      totalStylistNetPayout,
      releasedNetAmount,
      lockedEscrowNetAmount,
      stages: stageBreakdown,
    };
  }

  static async enhanceBrief(input: AiEnhanceBriefBody) {
    return GeminiService.enhanceStylingBrief(input);
  }

  static async createStylingRequest(clientId: string, input: CreateStylingRequestBody) {
    const stylist = input.stylistId
      ? await prisma.user.findUnique({ where: { id: input.stylistId } })
      : (await prisma.user.findUnique({ where: { email: 'maya.tran@posenova.com' } })) ??
        (await prisma.user.findFirst({ where: { role: Role.STYLIST } }));

    if (!stylist || stylist.role !== Role.STYLIST) {
      throw new AppError('Selected stylist not found or does not hold STYLIST role', 404);
    }

    if (stylist.id === clientId) {
      throw new AppError('Client cannot create a styling contract with themselves', 400);
    }

    const code = await this.generateUniqueOrderCode();
    const derivedTitle =
      input.title ||
      (input.occasion ? `${input.vibe ? input.vibe + ' — ' : ''}${input.occasion}` : `Custom Styling #${code}`);

    const created = await prisma.stylingRequest.create({
      data: {
        code,
        clientId,
        stylistId: stylist.id,
        title: derivedTitle,
        briefText: input.briefText,
        occasion: input.occasion ?? null,
        vibe: input.vibe ?? null,
        bodyType: input.bodyType ?? null,
        aiPaletteJson: input.aiPaletteJson
          ? (input.aiPaletteJson as Prisma.InputJsonValue)
          : Prisma.JsonNull,
        totalBudget: input.totalBudget,
        platformFeeRate: PLATFORM_FEE_RATE,
        status: RequestStatus.PENDING_DEPOSIT,
      },
      include: {
        client: { select: USER_SUMMARY_SELECT },
        stylist: { select: USER_SUMMARY_SELECT },
      },
    });

    const totalBudget = Number(created.totalBudget);
    const vietQr = SepayService.buildVietQrPayload(created.code, totalBudget);
    const financialSummary = this.buildFinancialSummary(totalBudget, []);

    return {
      id: created.id,
      code: created.code,
      displayCode: `#${created.code}`,
      status: created.status,
      title: created.title,
      briefText: created.briefText,
      occasion: created.occasion,
      vibe: created.vibe,
      bodyType: created.bodyType,
      aiPaletteJson: created.aiPaletteJson,
      totalBudget,
      platformFeeRate: Number(created.platformFeeRate),
      client: created.client,
      stylist: created.stylist,
      vietQr,
      financialSummary,
      createdAt: created.createdAt,
      updatedAt: created.updatedAt,
    };
  }

  static async listStylingRequests(
    user: AuthUserPayload,
    options: { status?: RequestStatus } = {},
  ) {
    const where: Prisma.StylingRequestWhereInput = {};

    if (user.role === 'CLIENT') {
      where.clientId = user.userId;
    } else if (user.role === 'STYLIST') {
      where.stylistId = user.userId;
    }

    if (options.status) {
      where.status = options.status;
    }

    const orders = await prisma.stylingRequest.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      include: {
        client: { select: USER_SUMMARY_SELECT },
        stylist: { select: USER_SUMMARY_SELECT },
        milestones: {
          orderBy: { stageOrder: 'asc' },
        },
      },
    });

    return orders.map((order) => {
      const totalBudget = Number(order.totalBudget);
      const formattedMilestones = order.milestones.map((m) => this.formatMilestone(m));
      const financialSummary = this.buildFinancialSummary(totalBudget, order.milestones);

      return {
        id: order.id,
        code: order.code,
        displayCode: `#${order.code}`,
        status: order.status,
        title: order.title,
        briefText: order.briefText,
        occasion: order.occasion,
        vibe: order.vibe,
        bodyType: order.bodyType,
        aiPaletteJson: order.aiPaletteJson,
        totalBudget,
        platformFeeRate: Number(order.platformFeeRate),
        client: order.client,
        stylist: order.stylist,
        milestones: formattedMilestones,
        financialSummary,
        ...(order.status === RequestStatus.PENDING_DEPOSIT
          ? { vietQr: SepayService.buildVietQrPayload(order.code, totalBudget) }
          : {}),
        createdAt: order.createdAt,
        updatedAt: order.updatedAt,
      };
    });
  }

  static async getStylingRequestDetail(idOrCode: string, user: AuthUserPayload) {
    const cleanParam = idOrCode.replace(/^#/, '').trim();
    const normalizedCode = cleanParam.toUpperCase();

    const order = await prisma.stylingRequest.findFirst({
      where: {
        OR: [{ id: cleanParam }, { code: normalizedCode }],
      },
      include: {
        client: { select: USER_SUMMARY_SELECT },
        stylist: { select: USER_SUMMARY_SELECT },
        milestones: {
          orderBy: { stageOrder: 'asc' },
          include: {
            submissions: { orderBy: { submittedAt: 'asc' } },
            productTags: true,
          },
        },
        transactions: {
          orderBy: { createdAt: 'desc' },
        },
        dispute: true,
        review: true,
      },
    });

    if (!order) {
      throw new AppError(`Styling order "${idOrCode}" not found`, 404);
    }

    if (
      user.role !== 'ADMIN' &&
      order.clientId !== user.userId &&
      order.stylistId !== user.userId
    ) {
      throw new AppError('Forbidden: You do not have access to this styling contract', 403);
    }

    const totalBudget = Number(order.totalBudget);
    const formattedMilestones = order.milestones.map((m) => this.formatMilestone(m));
    const financialSummary = this.buildFinancialSummary(totalBudget, order.milestones);

    return {
      id: order.id,
      code: order.code,
      displayCode: `#${order.code}`,
      status: order.status,
      title: order.title,
      briefText: order.briefText,
      occasion: order.occasion,
      vibe: order.vibe,
      bodyType: order.bodyType,
      aiPaletteJson: order.aiPaletteJson,
      totalBudget,
      platformFeeRate: Number(order.platformFeeRate),
      client: order.client,
      stylist: order.stylist,
      milestones: formattedMilestones,
      financialSummary,
      transactions: order.transactions.map((tx) => ({
        ...tx,
        grossAmount: Number(tx.grossAmount),
        feeAmount: Number(tx.feeAmount),
        netAmount: Number(tx.netAmount),
      })),
      dispute: order.dispute
        ? {
            ...order.dispute,
            remainingRefundAmount: Number(order.dispute.remainingRefundAmount),
          }
        : null,
      review: order.review,
      ...(order.status === RequestStatus.PENDING_DEPOSIT
        ? { vietQr: SepayService.buildVietQrPayload(order.code, totalBudget) }
        : {}),
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
    };
  }

  static async simulateDeposit(idOrCode: string, user: AuthUserPayload) {
    const detail = await this.getStylingRequestDetail(idOrCode, user);
    const refCode = `SIM-SEPAY-${detail.code}-${Date.now()}`;

    return SepayService.processEscrowDeposit({
      requestId: detail.id,
      requestCode: detail.code,
      content: `POSENOVA ${detail.code}`,
      transferType: 'in',
      transferAmount: detail.totalBudget,
      sepayRefCode: refCode,
    });
  }

  static async createReview(idOrCode: string, user: AuthUserPayload, input: CreateReviewBody) {
    const cleanParam = idOrCode.replace(/^#/, '').trim();
    const order = await prisma.stylingRequest.findFirst({
      where: {
        OR: [{ id: cleanParam }, { code: cleanParam.toUpperCase() }],
      },
      include: { review: true },
    });

    if (!order) {
      throw new AppError(`Styling order "${idOrCode}" not found`, 404);
    }

    if (user.role !== 'ADMIN' && order.clientId !== user.userId) {
      throw new AppError('Only the Client of this styling contract can submit a review', 403);
    }

    if (order.status !== RequestStatus.COMPLETED) {
      throw new AppError(
        `Reviews can only be submitted after all 3 stages are COMPLETED (current: ${order.status})`,
        400,
      );
    }

    if (order.review) {
      throw new AppError('A review has already been submitted for this styling contract', 409);
    }

    return prisma.$transaction(async (tx) => {
      const review = await tx.review.create({
        data: {
          requestId: order.id,
          clientId: order.clientId,
          stylistId: order.stylistId,
          rating: input.rating,
          comment: input.comment ?? null,
          capturedImageUrl: input.capturedImageUrl ?? null,
          poseMatchScore: input.poseMatchScore ?? null,
        },
      });

      const agg = await tx.review.aggregate({
        where: { stylistId: order.stylistId },
        _avg: { rating: true },
        _count: { rating: true },
      });

      await tx.user.update({
        where: { id: order.stylistId },
        data: {
          ratingAvg: Number((agg._avg.rating ?? input.rating).toFixed(2)),
          totalReviews: agg._count.rating,
        },
      });

      return review;
    });
  }
}
