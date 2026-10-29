import { Router } from 'express';
import { MilestonesController } from './milestones.controller';
import { authenticate, requireRole } from '../../common/middlewares/auth.middleware';
import { validateBody } from '../../common/middlewares/validate.middleware';
import {
  approveMilestoneBodySchema,
  requestRevisionBodySchema,
  submitMilestoneBodySchema,
} from './milestones.schema';

export const milestonesRouter = Router();

// TSK-15: Stylist submits stage deliverable, logs MilestoneSubmission & starts 48h SLA timer
milestonesRouter.post(
  '/:id/submit',
  authenticate,
  requireRole('STYLIST', 'ADMIN'),
  validateBody(submitMilestoneBodySchema),
  MilestonesController.submitMilestone,
);

// TSK-16: Client approves stage -> ACID release of 85% Net Payout & unlocks next stage
milestonesRouter.post(
  '/:id/approve',
  authenticate,
  requireRole('CLIENT', 'ADMIN'),
  validateBody(approveMilestoneBodySchema),
  MilestonesController.approveMilestone,
);

// TSK-17: Client requests revision (enforces max 2 free revisions per stage)
milestonesRouter.post(
  '/:id/request-revision',
  authenticate,
  requireRole('CLIENT', 'ADMIN'),
  validateBody(requestRevisionBodySchema),
  MilestonesController.requestRevision,
);

export default milestonesRouter;
