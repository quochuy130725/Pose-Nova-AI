import { Request, Response, NextFunction } from 'express';
import { LookbooksService } from './lookbooks.service';
import { sendSuccess } from '../../common/utils/response.util';
import { AppError } from '../../common/middlewares/error.middleware';

export class LookbooksController {
  static async listLookbooks(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const styleCategory =
        typeof req.query.styleCategory === 'string' ? req.query.styleCategory : undefined;
      const lookbooks = await LookbooksService.listLookbooks({
        styleCategory,
        currentUserId: req.user?.userId,
      });

      sendSuccess(res, lookbooks, 'Fetched lookbook discovery feed successfully', 200);
    } catch (err) {
      next(err);
    }
  }

  static async scrapeAffiliate(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { url } = req.body as { url: string };
      const metadata = await LookbooksService.scrapeAffiliate(url);
      sendSuccess(res, metadata, 'Scraped affiliate product metadata successfully', 200);
    } catch (err) {
      next(err);
    }
  }

  static async createLookbook(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        throw new AppError('Unauthorized', 401);
      }
      const created = await LookbooksService.createLookbook(req.user.userId, req.body);
      sendSuccess(res, created, 'Published new lookbook with 33 pose landmarks', 201);
    } catch (err) {
      next(err);
    }
  }

  static async toggleLike(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        throw new AppError('Unauthorized', 401);
      }
      const lookbookId = String(req.params.id);
      const result = await LookbooksService.toggleLike(lookbookId, req.user.userId);
      sendSuccess(
        res,
        result,
        result.isLiked ? 'Liked lookbook' : 'Unliked lookbook',
        200,
      );
    } catch (err) {
      next(err);
    }
  }

  static async trackTagClick(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const tagId = String(req.params.tagId ?? req.params.id);
      const result = await LookbooksService.trackAffiliateTagClick(tagId);
      sendSuccess(res, result, 'Recorded affiliate product click', 200);
    } catch (err) {
      next(err);
    }
  }
}

