import { Request, Response, NextFunction } from 'express';
import { RequestStatus } from '@prisma/client';
import { StylingRequestsService } from './styling-requests.service';
import { sendSuccess } from '../../common/utils/response.util';
import { AppError } from '../../common/middlewares/error.middleware';

export class StylingRequestsController {
  static async aiEnhanceBrief(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const result = await StylingRequestsService.enhanceBrief(req.body);
      sendSuccess(res, result, 'Enhanced styling brief and 4-color Hex palette generated', 200);
    } catch (err) {
      next(err);
    }
  }

  static async createStylingRequest(
    req: Request,
    res: Response,
    next: NextFunction,
  ): Promise<void> {
    try {
      if (!req.user) {
        throw new AppError('Unauthorized', 401);
      }
      const created = await StylingRequestsService.createStylingRequest(req.user.userId, req.body);
      sendSuccess(
        res,
        created,
        `Created styling request #${created.code} with dynamic SePay VietQR`,
        201,
      );
    } catch (err) {
      next(err);
    }
  }

  static async listStylingRequests(
    req: Request,
    res: Response,
    next: NextFunction,
  ): Promise<void> {
    try {
      if (!req.user) {
        throw new AppError('Unauthorized', 401);
      }
      const status =
        typeof req.query.status === 'string' ? (req.query.status as RequestStatus) : undefined;
      const orders = await StylingRequestsService.listStylingRequests(req.user, { status });
      sendSuccess(res, orders, 'Fetched styling orders and net payout breakdown', 200);
    } catch (err) {
      next(err);
    }
  }

  static async getStylingRequestDetail(
    req: Request,
    res: Response,
    next: NextFunction,
  ): Promise<void> {
    try {
      if (!req.user) {
        throw new AppError('Unauthorized', 401);
      }
      const idOrCode = String(req.params.id);
      const detail = await StylingRequestsService.getStylingRequestDetail(idOrCode, req.user);
      sendSuccess(res, detail, `Fetched styling order #${detail.code} detail`, 200);
    } catch (err) {
      next(err);
    }
  }

  static async simulateDeposit(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        throw new AppError('Unauthorized', 401);
      }
      const idOrCode = String(req.params.id);
      const settlement = await StylingRequestsService.simulateDeposit(idOrCode, req.user);
      sendSuccess(
        res,
        settlement,
        'Simulated SePay VietQR deposit and initialized 30-30-40 milestones',
        200,
      );
    } catch (err) {
      next(err);
    }
  }

  static async createReview(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        throw new AppError('Unauthorized', 401);
      }
      const idOrCode = String(req.params.id);
      const review = await StylingRequestsService.createReview(idOrCode, req.user, req.body);
      sendSuccess(res, review, 'Submitted styling review and AI Pose Match Score', 201);
    } catch (err) {
      next(err);
    }
  }
}

