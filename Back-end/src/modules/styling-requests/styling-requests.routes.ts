import { Router } from 'express';
import { StylingRequestsController } from './styling-requests.controller';
import { authenticate, requireRole } from '../../common/middlewares/auth.middleware';
import { validateBody, validateQuery } from '../../common/middlewares/validate.middleware';
import {
  aiEnhanceBriefBodySchema,
  createReviewBodySchema,
  createStylingRequestBodySchema,
  listStylingRequestsQuerySchema,
} from './styling-requests.schema';

export const stylingRequestsRouter = Router();

// TSK-11: Gemini 1.5 Flash AI Co-pilot (Brief & 4 Hex Color Palette)
stylingRequestsRouter.post(
  '/ai-enhance',
  authenticate,
  validateBody(aiEnhanceBriefBodySchema),
  StylingRequestsController.aiEnhanceBrief,
);

// TSK-14: List Styling Orders for Client / Stylist Inbox with 30-30-40 Gross/Fee/Net Breakdown
stylingRequestsRouter.get(
  '/',
  authenticate,
  validateQuery(listStylingRequestsQuerySchema),
  StylingRequestsController.listStylingRequests,
);

// TSK-12: Create Styling Order (#REQ-XXXX) + Dynamic SePay VietQR
stylingRequestsRouter.post(
  '/',
  authenticate,
  requireRole('CLIENT', 'ADMIN'),
  validateBody(createStylingRequestBodySchema),
  StylingRequestsController.createStylingRequest,
);

// Demo convenience endpoint: Simulate SePay VietQR deposit for instant mobile demo testing
stylingRequestsRouter.post(
  '/:id/simulate-deposit',
  authenticate,
  StylingRequestsController.simulateDeposit,
);

// Submit 5-star review + AI Pose Match Score for COMPLETED styling contract
stylingRequestsRouter.post(
  '/:id/reviews',
  authenticate,
  requireRole('CLIENT', 'ADMIN'),
  validateBody(createReviewBodySchema),
  StylingRequestsController.createReview,
);

// TSK-14: Get Styling Order Detail (supports UUID or REQ-XXXX)
stylingRequestsRouter.get('/:id', authenticate, StylingRequestsController.getStylingRequestDetail);

export default stylingRequestsRouter;

