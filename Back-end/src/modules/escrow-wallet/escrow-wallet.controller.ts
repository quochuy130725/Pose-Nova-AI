import { Request, Response, NextFunction } from 'express';
import { EscrowWalletService } from './escrow-wallet.service';
import { sendSuccess } from '../../common/utils/response.util';
import { AppError } from '../../common/middlewares/error.middleware';

export class EscrowWalletController {
  static async getMyWallet(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        throw new AppError('Unauthorized', 401);
      }
      const data = await EscrowWalletService.getMyWalletAndLedger(req.user);
      sendSuccess(res, data, 'Fetched Cyber Wallet balances and reconciliation ledger', 200);
    } catch (err) {
      next(err);
    }
  }

  static async withdraw(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        throw new AppError('Unauthorized', 401);
      }
      const result = await EscrowWalletService.withdrawToBank(req.user, req.body);
      sendSuccess(
        res,
        result,
        `Withdrew ${result.transaction.netAmount} VND to ${result.wallet.bankName}`,
        200,
      );
    } catch (err) {
      next(err);
    }
  }

  static async updateBankAccount(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        throw new AppError('Unauthorized', 401);
      }
      const wallet = await EscrowWalletService.updateBankAccount(req.user, req.body);
      sendSuccess(res, wallet, 'Updated linked bank account successfully', 200);
    } catch (err) {
      next(err);
    }
  }
}

