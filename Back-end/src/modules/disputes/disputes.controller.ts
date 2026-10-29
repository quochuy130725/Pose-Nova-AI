import { Request, Response, NextFunction } from 'express';
import { DisputesService } from './disputes.service';
import { sendSuccess } from '../../common/utils/response.util';
import { AppError } from '../../common/middlewares/error.middleware';

export class DisputesController {
  static async createDispute(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        throw new AppError('Unauthorized', 401);
      }
      const result = await DisputesService.openDisputeAndRefund(req.user, req.body);
      sendSuccess(
        res,
        result,
        `Escrow frozen & refunded ${result.resolutionBreakdown.refundPercentage}% (${result.resolutionBreakdown.clientRefundedGross} VND) of unapproved stages to Client`,
        201,
      );
    } catch (err) {
      next(err);
    }
  }

  static async listDisputes(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        throw new AppError('Unauthorized', 401);
      }
      const disputes = await DisputesService.listDisputes(req.user);
      sendSuccess(res, disputes, 'Fetched disputes list', 200);
    } catch (err) {
      next(err);
    }
  }
}

