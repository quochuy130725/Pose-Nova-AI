import { Router } from 'express';
import { DisputesController } from './disputes.controller';
import { authenticate, requireRole } from '../../common/middlewares/auth.middleware';
import { validateBody } from '../../common/middlewares/validate.middleware';
import { createDisputeBodySchema } from './disputes.schema';

export const disputesRouter = Router();

// List disputes for Client / Stylist / Admin
disputesRouter.get('/', authenticate, DisputesController.listDisputes);

// TSK-18: Open Dispute -> Freeze Escrow (ESCROW_FROZEN) & Auto-Refund remaining 70% or 40% unapproved funds
disputesRouter.post(
  '/',
  authenticate,
  requireRole('CLIENT', 'ADMIN'),
  validateBody(createDisputeBodySchema),
  DisputesController.createDispute,
);

export default disputesRouter;

