import {
  MilestoneStatus,
  RequestStatus,
  TransactionStatus,
  TransactionType,
} from '@prisma/client';
import { prisma } from '../../config/database';
import { env } from '../../config/env';
import { AppError } from '../../common/middlewares/error.middleware';
import { MAX_REVISIONS } from '../../common/constants/escrow.constants';
import { calculateMilestoneBreakdown } from '../../common/utils/money.util';

export interface VietQrPayload {
  bankCode: string;
  accountNo: string;
  accountName: string;
  amount: number;
  transferContent: string;
  qrImageUrl: string;
}

export interface SepayWebhookInput {
  id?: string | number;
  gateway?: string;
  transactionDate?: string;
  accountNumber?: string;
  content?: string;
  description?: string;
  transferType?: string;
  transferAmount?: number;
  amount?: number;
  referenceCode?: string;
  sepayRefCode?: string;
  requestCode?: string;
  requestId?: string;
}

export class SepayService {
  /**
   * Builds dynamic SePay VietQR payment metadata & QR image URL for 100% escrow deposit.
   */
  static buildVietQrPayload(orderCode: string, totalBudgetVnd: number): VietQrPayload {
    const amount = Math.round(totalBudgetVnd);
    const normalizedCode = orderCode.replace(/^#/, '').trim().toUpperCase();
    const compactCode = normalizedCode.replace(/[^A-Z0-9]/g, ''); // e.g. REQ8452
    const transferContent = `POSENOVA ${compactCode}`;

    const bankCode = env.SEPAY_BANK_CODE;
    const accountNo = env.SEPAY_ACCOUNT_NO;
    const accountName = env.SEPAY_ACCOUNT_NAME;

    const qrImageUrl =
      `https://qr.sepay.vn/img?bank=${encodeURIComponent(bankCode)}` +
      `&acc=${encodeURIComponent(accountNo)}` +
      `&template=compact` +
      `&amount=${amount}` +
      `&des=${encodeURIComponent(transferContent)}`;

    return {
      bankCode,
      accountNo,
      accountName,
      amount,
      transferContent,
      qrImageUrl,
    };
  }

  /**
   * Extracts normalized order code (e.g. "REQ-8452") from bank transfer content.
   */
  static extractOrderCode(rawText?: string): string | null {
    if (!rawText) return null;
    const match = rawText.match(/REQ[-_\s]?(\d{3,8})/i);
    if (!match) return null;
    return `REQ-${match[1]}`;
  }

  /**
   * Processes incoming SePay VietQR transfer confirmation inside an ACID transaction:
   * 1. Enforces strict idempotency on `sepayRefCode`.
   * 2. Verifies 100% escrow deposit amount.
   * 3. Locks 85% Net Payout into Stylist's `escrowLockedBalance`.
   * 4. Splits contract into 3 `RequestMilestone` rows (30% ACTIVE, 30% LOCKED, 40% LOCKED).
   */
  static async processEscrowDeposit(input: SepayWebhookInput) {
    if (input.transferType && input.transferType.toLowerCase() !== 'in') {
      throw new AppError('Only incoming bank transfers ("in") are processed for escrow', 400);
    }

    const sepayRefCode = String(
      input.sepayRefCode ??
        input.referenceCode ??
        (input.id !== undefined ? `SEPAY-${input.id}` : ''),
    ).trim();

    if (!sepayRefCode) {
      throw new AppError('Missing SePay reference code (referenceCode / sepayRefCode)', 400);
    }

    // Fast-path Idempotency Check: prevent double-crediting if SePay retries webhook
    const existingTx = await prisma.paymentTransaction.findUnique({
      where: { sepayRefCode },
      include: {
        request: {
          include: {
            milestones: { orderBy: { stageOrder: 'asc' } },
          },
        },
      },
    });

    if (existingTx) {
      return {
        alreadyProcessed: true,
        idempotent: true,
        sepayRefCode,
        transactionId: existingTx.id,
        requestId: existingTx.requestId,
        code: existingTx.request.code,
        status: existingTx.request.status,
        milestonesCount: existingTx.request.milestones.length,
        milestones: existingTx.request.milestones.map((m) => {
          const gross = Number(m.grossAmount);
          const net = Number(m.netPayout);
          return {
            id: m.id,
            stageOrder: m.stageOrder,
            title: m.title,
            percentage: m.percentage,
            grossAmount: gross,
            platformFeeAmount: gross - net,
            netPayout: net,
            status: m.status,
          };
        }),
      };
    }

    const extractedCode =
      this.extractOrderCode(input.requestCode) ??
      this.extractOrderCode(input.content) ??
      this.extractOrderCode(input.description);

    const stylingRequest = input.requestId
      ? await prisma.stylingRequest.findUnique({ where: { id: input.requestId } })
      : extractedCode
        ? await prisma.stylingRequest.findUnique({ where: { code: extractedCode } })
        : null;

    if (!stylingRequest) {
      throw new AppError(
        `Matching StylingRequest not found for transfer content "${input.content ?? input.requestCode ?? ''}"`,
        404,
      );
    }

    if (
      stylingRequest.status !== RequestStatus.PENDING_DEPOSIT &&
      stylingRequest.status !== RequestStatus.PENDING_ACCEPTANCE
    ) {
      throw new AppError(
        `Order #${stylingRequest.code} cannot accept deposit in status ${stylingRequest.status}`,
        400,
      );
    }

    const totalBudget = Math.round(Number(stylingRequest.totalBudget));
    const receivedAmount = Math.round(
      Number(input.transferAmount ?? input.amount ?? totalBudget),
    );

    if (receivedAmount < totalBudget) {
      throw new AppError(
        `Insufficient deposit amount: received ${receivedAmount} VND, required ${totalBudget} VND`,
        400,
      );
    }

    const breakdown = calculateMilestoneBreakdown(totalBudget);
    const stylistNetTotal = breakdown.reduce((sum, item) => sum + item.netPayout, 0);
    const platformFeeTotal = totalBudget - stylistNetTotal;

    // ACID Database Transaction
    const settlement = await prisma.$transaction(async (tx) => {
      // Double-check idempotency inside transaction boundary
      const duplicateInsideTx = await tx.paymentTransaction.findUnique({
        where: { sepayRefCode },
      });
      if (duplicateInsideTx) {
        throw new AppError(`Duplicate sepayRefCode "${sepayRefCode}" already settled`, 409);
      }

      const freshRequest = await tx.stylingRequest.findUnique({
        where: { id: stylingRequest.id },
        include: { milestones: true },
      });

      if (
        !freshRequest ||
        (freshRequest.status !== RequestStatus.PENDING_DEPOSIT &&
          freshRequest.status !== RequestStatus.PENDING_ACCEPTANCE)
      ) {
        throw new AppError(`Order #${stylingRequest.code} deposit was already processed`, 409);
      }

      const clientWallet = await tx.wallet.upsert({
        where: { userId: freshRequest.clientId },
        update: {},
        create: {
          userId: freshRequest.clientId,
          availableBalance: 0,
          escrowLockedBalance: 0,
          totalWithdrawn: 0,
        },
      });

      const stylistWallet = await tx.wallet.upsert({
        where: { userId: freshRequest.stylistId },
        update: {},
        create: {
          userId: freshRequest.stylistId,
          availableBalance: 0,
          escrowLockedBalance: 0,
          totalWithdrawn: 0,
        },
      });

      // 1. Activate Styling Contract -> IN_PROGRESS
      const updatedRequest = await tx.stylingRequest.update({
        where: { id: freshRequest.id },
        data: { status: RequestStatus.IN_PROGRESS },
      });

      // 2. Record immutable ESCROW_DEPOSIT ledger entry (100% Gross)
      const depositTx = await tx.paymentTransaction.create({
        data: {
          requestId: freshRequest.id,
          walletId: clientWallet.id,
          type: TransactionType.ESCROW_DEPOSIT,
          grossAmount: totalBudget,
          feeAmount: 0,
          netAmount: totalBudget,
          sepayRefCode,
          status: TransactionStatus.COMPLETED,
          description: `100% VietQR Escrow Deposit via SePay for Order #${freshRequest.code}`,
        },
      });

      // 3. Lock 85% Stylist Net Payout in Stylist's Escrow Wallet
      const updatedStylistWallet = await tx.wallet.update({
        where: { id: stylistWallet.id },
        data: {
          escrowLockedBalance: { increment: stylistNetTotal },
        },
      });

      // 4. Create 3 Milestone Stages (30% ACTIVE - 30% LOCKED - 40% LOCKED)
      if (freshRequest.milestones.length === 0) {
        await tx.requestMilestone.createMany({
          data: breakdown.map((stage) => ({
            requestId: freshRequest.id,
            stageOrder: stage.stageOrder,
            title: stage.title,
            description: stage.description,
            percentage: stage.percentage,
            grossAmount: stage.grossAmount,
            netPayout: stage.netPayout,
            revisionCount: 0,
            maxRevisions: MAX_REVISIONS,
            status:
              stage.stageOrder === 1 ? MilestoneStatus.ACTIVE : MilestoneStatus.LOCKED,
          })),
        });
      }

      const createdMilestones = await tx.requestMilestone.findMany({
        where: { requestId: freshRequest.id },
        orderBy: { stageOrder: 'asc' },
      });

      return {
        updatedRequest,
        depositTx,
        updatedStylistWallet,
        createdMilestones,
      };
    });

    return {
      alreadyProcessed: false,
      idempotent: true,
      sepayRefCode,
      transactionId: settlement.depositTx.id,
      requestId: settlement.updatedRequest.id,
      code: settlement.updatedRequest.code,
      status: settlement.updatedRequest.status,
      escrowSummary: {
        totalBudgetGross: totalBudget,
        platformFeeRate: 0.15,
        platformFeeAmount: platformFeeTotal,
        stylistNetLocked: stylistNetTotal,
        stylistWalletEscrowLockedBalance: Number(
          settlement.updatedStylistWallet.escrowLockedBalance,
        ),
      },
      milestonesCount: settlement.createdMilestones.length,
      milestones: settlement.createdMilestones.map((m) => {
        const gross = Number(m.grossAmount);
        const net = Number(m.netPayout);
        return {
          id: m.id,
          stageOrder: m.stageOrder,
          title: m.title,
          percentage: m.percentage,
          grossAmount: gross,
          platformFeeAmount: gross - net,
          netPayout: net,
          maxRevisions: m.maxRevisions,
          status: m.status,
        };
      }),
    };
  }
}

