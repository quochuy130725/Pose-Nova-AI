import {
  MilestoneStatus,
  TransactionStatus,
  TransactionType,
} from '@prisma/client';
import { prisma } from '../../config/database';
import { AppError } from '../../common/middlewares/error.middleware';
import { AuthUserPayload } from '../../common/middlewares/auth.middleware';
import { UpdateBankAccountInput, WithdrawFundsInput } from './escrow-wallet.schema';

export class EscrowWalletService {
  /**
   * TSK-19: Cyber Wallet & Immutable Escrow Reconciliation Ledger.
   * Guarantees the accounting invariant across all escrow-funded contracts:
   * Total Deposited = Released Net + Earned Platform Fee (15%) + Locked Gross + Refunded Excess
   */
  static async getMyWalletAndLedger(user: AuthUserPayload) {
    const wallet = await prisma.wallet.upsert({
      where: { userId: user.userId },
      update: {},
      create: {
        userId: user.userId,
        availableBalance: 0,
        escrowLockedBalance: 0,
        totalWithdrawn: 0,
      },
    });

    // Fetch escrow-funded contracts associated with this user
    const contractFilter =
      user.role === 'ADMIN'
        ? { transactions: { some: { type: TransactionType.ESCROW_DEPOSIT } } }
        : user.role === 'STYLIST'
          ? {
              stylistId: user.userId,
              transactions: { some: { type: TransactionType.ESCROW_DEPOSIT } },
            }
          : {
              clientId: user.userId,
              transactions: { some: { type: TransactionType.ESCROW_DEPOSIT } },
            };

    const fundedContracts = await prisma.stylingRequest.findMany({
      where: contractFilter,
      include: {
        milestones: { orderBy: { stageOrder: 'asc' } },
        transactions: { orderBy: { createdAt: 'desc' } },
      },
      orderBy: { createdAt: 'desc' },
    });

    let totalDeposited = 0;
    let totalReleasedNet = 0;
    let totalEarnedPlatformFee = 0;
    let currentlyLockedGross = 0;
    let currentlyLockedNet = 0;
    let pendingPlatformFee = 0;
    let totalRefunded = 0;

    for (const contract of fundedContracts) {
      for (const tx of contract.transactions) {
        if (tx.status !== TransactionStatus.COMPLETED) continue;
        if (tx.type === TransactionType.ESCROW_DEPOSIT) {
          totalDeposited += Number(tx.grossAmount);
        } else if (tx.type === TransactionType.MILESTONE_RELEASE) {
          totalReleasedNet += Number(tx.netAmount);
          totalEarnedPlatformFee += Number(tx.feeAmount);
        } else if (tx.type === TransactionType.REFUND) {
          totalRefunded += Number(tx.grossAmount);
        }
      }

      for (const m of contract.milestones) {
        if (
          m.status !== MilestoneStatus.APPROVED &&
          m.status !== MilestoneStatus.DISPUTED
        ) {
          const g = Number(m.grossAmount);
          const n = Number(m.netPayout);
          currentlyLockedGross += g;
          currentlyLockedNet += n;
          pendingPlatformFee += g - n;
        }
      }
    }

    const totalAccountedFor =
      totalReleasedNet + totalEarnedPlatformFee + currentlyLockedGross + totalRefunded;
    const discrepancyVnd = totalDeposited - totalAccountedFor;

    // Fetch chronological ledger transactions relevant to this user's wallet & contracts
    const contractIds = fundedContracts.map((c) => c.id);
    const ledgerRows = await prisma.paymentTransaction.findMany({
      where: {
        OR: [
          { walletId: wallet.id },
          ...(contractIds.length > 0 ? [{ requestId: { in: contractIds } }] : []),
        ],
      },
      orderBy: { createdAt: 'desc' },
      include: {
        request: {
          select: {
            id: true,
            code: true,
            title: true,
            status: true,
          },
        },
        milestone: {
          select: {
            id: true,
            stageOrder: true,
            title: true,
            percentage: true,
          },
        },
      },
    });

    return {
      wallet: {
        id: wallet.id,
        userId: wallet.userId,
        availableBalance: Number(wallet.availableBalance),
        escrowLockedBalance: Number(wallet.escrowLockedBalance),
        totalWithdrawn: Number(wallet.totalWithdrawn),
        bankName: wallet.bankName,
        bankAccountNo: wallet.bankAccountNo,
        bankAccountHolder: wallet.bankAccountHolder,
        updatedAt: wallet.updatedAt,
      },
      reconciliation: {
        totalDeposited,
        totalReleasedNet,
        totalEarnedPlatformFee,
        currentlyLockedGross,
        currentlyLockedNet,
        pendingPlatformFee,
        totalRefunded,
        totalAccountedFor,
        discrepancyVnd,
        isBalanced: discrepancyVnd === 0,
        formula:
          'totalDeposited = totalReleasedNet + totalEarnedPlatformFee (15%) + currentlyLockedGross (85% Net + 15% Pending Fee) + totalRefunded',
      },
      ledger: ledgerRows.map((tx) => ({
        id: tx.id,
        type: tx.type,
        status: tx.status,
        grossAmount: Number(tx.grossAmount),
        feeAmount: Number(tx.feeAmount),
        netAmount: Number(tx.netAmount),
        sepayRefCode: tx.sepayRefCode,
        description: tx.description,
        createdAt: tx.createdAt,
        request: tx.request,
        milestone: tx.milestone,
      })),
    };
  }

  /**
   * TSK-19: Withdraw available earnings to linked bank account inside an ACID transaction
   * with atomic overdraft protection (`availableBalance >= amount`).
   */
  static async withdrawToBank(user: AuthUserPayload, input: WithdrawFundsInput) {
    const amount = Math.round(input.amount);

    const result = await prisma.$transaction(async (tx) => {
      const wallet = await tx.wallet.findUnique({
        where: { userId: user.userId },
      });

      if (!wallet) {
        throw new AppError('Wallet not found for current user', 404);
      }

      const bankName = input.bankName ?? wallet.bankName;
      const bankAccountNo = input.bankAccountNo ?? wallet.bankAccountNo;
      const bankAccountHolder = input.bankAccountHolder ?? wallet.bankAccountHolder;

      if (!bankName || !bankAccountNo || !bankAccountHolder) {
        throw new AppError(
          'Bank account details (bankName, bankAccountNo, bankAccountHolder) are required for withdrawal',
          400,
        );
      }

      if (Number(wallet.availableBalance) < amount) {
        throw new AppError(
          `Insufficient available balance: requested ${amount} VND, available ${Number(wallet.availableBalance)} VND`,
          400,
        );
      }

      // Atomic overdraft guard (`availableBalance >= amount`)
      const atomicDebit = await tx.wallet.updateMany({
        where: {
          id: wallet.id,
          availableBalance: { gte: amount },
        },
        data: {
          availableBalance: { decrement: amount },
          totalWithdrawn: { increment: amount },
          bankName,
          bankAccountNo,
          bankAccountHolder,
        },
      });

      if (atomicDebit.count === 0) {
        throw new AppError(
          'Concurrent withdrawal exceeded available wallet balance — overdraft prevented',
          409,
        );
      }

      // Resolve anchor contract ID for ledger traceability
      const anchorContract =
        (await tx.stylingRequest.findFirst({
          where: {
            OR: [{ stylistId: user.userId }, { clientId: user.userId }],
          },
          orderBy: { updatedAt: 'desc' },
        })) ??
        (await tx.stylingRequest.findFirst({
          orderBy: { createdAt: 'desc' },
        }));

      if (!anchorContract) {
        throw new AppError('No styling contract history available to anchor withdrawal ledger', 400);
      }

      const withdrawalTx = await tx.paymentTransaction.create({
        data: {
          requestId: anchorContract.id,
          milestoneId: null,
          walletId: wallet.id,
          type: TransactionType.WITHDRAWAL,
          grossAmount: amount,
          feeAmount: 0,
          netAmount: amount,
          status: TransactionStatus.COMPLETED,
          description:
            input.note ??
            `Bank payout to ${bankName} • ${bankAccountNo} (${bankAccountHolder})`,
        },
      });

      const updatedWallet = await tx.wallet.findUniqueOrThrow({
        where: { id: wallet.id },
      });

      return { updatedWallet, withdrawalTx };
    });

    return {
      wallet: {
        id: result.updatedWallet.id,
        availableBalance: Number(result.updatedWallet.availableBalance),
        escrowLockedBalance: Number(result.updatedWallet.escrowLockedBalance),
        totalWithdrawn: Number(result.updatedWallet.totalWithdrawn),
        bankName: result.updatedWallet.bankName,
        bankAccountNo: result.updatedWallet.bankAccountNo,
        bankAccountHolder: result.updatedWallet.bankAccountHolder,
      },
      transaction: {
        id: result.withdrawalTx.id,
        type: result.withdrawalTx.type,
        status: result.withdrawalTx.status,
        grossAmount: Number(result.withdrawalTx.grossAmount),
        feeAmount: Number(result.withdrawalTx.feeAmount),
        netAmount: Number(result.withdrawalTx.netAmount),
        description: result.withdrawalTx.description,
        createdAt: result.withdrawalTx.createdAt,
      },
    };
  }

  static async updateBankAccount(user: AuthUserPayload, input: UpdateBankAccountInput) {
    const updated = await prisma.wallet.upsert({
      where: { userId: user.userId },
      update: {
        bankName: input.bankName,
        bankAccountNo: input.bankAccountNo,
        bankAccountHolder: input.bankAccountHolder.toUpperCase(),
      },
      create: {
        userId: user.userId,
        availableBalance: 0,
        escrowLockedBalance: 0,
        totalWithdrawn: 0,
        bankName: input.bankName,
        bankAccountNo: input.bankAccountNo,
        bankAccountHolder: input.bankAccountHolder.toUpperCase(),
      },
    });

    return {
      id: updated.id,
      availableBalance: Number(updated.availableBalance),
      escrowLockedBalance: Number(updated.escrowLockedBalance),
      totalWithdrawn: Number(updated.totalWithdrawn),
      bankName: updated.bankName,
      bankAccountNo: updated.bankAccountNo,
      bankAccountHolder: updated.bankAccountHolder,
    };
  }
}

