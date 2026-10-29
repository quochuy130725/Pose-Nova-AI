import { Router } from 'express';
import { LookbooksController } from './lookbooks.controller';
import {
  authenticate,
  optionalAuthenticate,
  requireRole,
} from '../../common/middlewares/auth.middleware';
import { validateBody, validateQuery } from '../../common/middlewares/validate.middleware';
import {
  createLookbookBodySchema,
  listLookbooksQuerySchema,
  scrapeAffiliateBodySchema,
} from './lookbooks.schema';

export const lookbooksRouter = Router();

// Public Discovery Feed (Computes personalized `isLiked` if Bearer token is provided)
lookbooksRouter.get(
  '/',
  optionalAuthenticate,
  validateQuery(listLookbooksQuerySchema),
  LookbooksController.listLookbooks,
);

// Stylist Supply-Side Tooling: OpenGraph Affiliate Metadata Scraper
lookbooksRouter.post(
  '/scrape-affiliate',
  authenticate,
  requireRole('STYLIST', 'ADMIN'),
  validateBody(scrapeAffiliateBodySchema),
  LookbooksController.scrapeAffiliate,
);

// Stylist Supply-Side Tooling: Publish Lookbook + 33 Pose Landmarks + Product Tags
lookbooksRouter.post(
  '/',
  authenticate,
  requireRole('STYLIST', 'ADMIN'),
  validateBody(createLookbookBodySchema),
  LookbooksController.createLookbook,
);

// Affiliate Click Tracking
lookbooksRouter.post('/tags/:tagId/click', LookbooksController.trackTagClick);

// Toggle Like on Lookbook
lookbooksRouter.post('/:id/like', authenticate, LookbooksController.toggleLike);

export default lookbooksRouter;

