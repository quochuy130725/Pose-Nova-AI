import { Router } from 'express';
import { authRouter } from '../modules/auth/auth.routes';
import { lookbooksRouter } from '../modules/lookbooks/lookbooks.routes';
import { LookbooksController } from '../modules/lookbooks/lookbooks.controller';
import { stylingRequestsRouter } from '../modules/styling-requests/styling-requests.routes';
import { webhooksRouter } from '../integrations/sepay/sepay.webhook';
import { milestonesRouter } from '../modules/milestones/milestones.routes';
import { disputesRouter } from '../modules/disputes/disputes.routes';
import { escrowWalletRouter } from '../modules/escrow-wallet/escrow-wallet.routes';
import { EscrowWalletController } from '../modules/escrow-wallet/escrow-wallet.controller';
import { withdrawFundsBodySchema } from '../modules/escrow-wallet/escrow-wallet.schema';
import { authenticate } from '../common/middlewares/auth.middleware';
import { validateBody } from '../common/middlewares/validate.middleware';

export const apiV1Router = Router();

// Phase 2: Auth Switcher & Lookbook + Affiliate Feed (Workflows 1 & 2)
apiV1Router.use('/auth', authRouter);
apiV1Router.use('/lookbooks', lookbooksRouter);
apiV1Router.post('/tags/:id/click', LookbooksController.trackTagClick);

// Phase 3: Styling Request, Gemini Co-pilot & SePay VietQR Escrow (Workflow 3)
apiV1Router.use('/styling-requests', stylingRequestsRouter);
apiV1Router.use('/webhooks', webhooksRouter);

// Phase 4: Milestone Execution, Disputes & Cyber Wallet Ledger (Workflows 3 & 4)
apiV1Router.use('/milestones', milestonesRouter);
apiV1Router.use('/disputes', disputesRouter);
apiV1Router.use('/wallets', escrowWalletRouter);
apiV1Router.post(
  '/withdraw',
  authenticate,
  validateBody(withdrawFundsBodySchema),
  EscrowWalletController.withdraw,
);

export default apiV1Router;
