import { Request, Response, NextFunction } from 'express';
import { MilestonesService } from './milestones.service';
import { sendSuccess } from '../../common/utils/response.util';
import { AppError } from '../../common/middlewares/error.middleware';

export class MilestonesController {
  static async submitMilestone(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        throw new AppError('Unauthorized', 401);
      }
      const milestoneId = String(req.params.id);
      const result = await MilestonesService.submitMilestone(milestoneId, req.user, req.body);
      sendSuccess(
        res,
        result,
        `Submitted Stage ${result.stageOrder} for review (48h SLA auto-release armed)`,
        200,
      );
    } catch (err) {
      next(err);
    }
  }

  static async approveMilestone(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        throw new AppError('Unauthorized', 401);
      }
      const milestoneId = String(req.params.id);
      const result = await MilestonesService.approveMilestone(
        milestoneId,
        req.user,
        req.body ?? {},
      );
      sendSuccess(
        res,
        result,
        `Approved Stage ${result.approvedMilestone.stageOrder} and released ${result.approvedMilestone.netPayout} VND net payout`,
        200,
      );
    } catch (err) {
      next(err);
    }
  }

  static async requestRevision(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        throw new AppError('Unauthorized', 401);
      }
      const milestoneId = String(req.params.id);
      const result = await MilestonesService.requestRevision(milestoneId, req.user, req.body);
      sendSuccess(
        res,
        result,
        `Requested revision (${result.revisionCount}/${result.maxRevisions}) for Stage ${result.stageOrder}`,
        200,
      );
    } catch (err) {
      next(err);
    }
  }
}
