import { Router } from 'express';
import { EscrowWalletController } from './escrow-wallet.controller';
import { authenticate } from '../../common/middlewares/auth.middleware';
import { validateBody } from '../../common/middlewares/validate.middleware';
import {
  updateBankAccountBodySchema,
  withdrawFundsBodySchema,
} from './escrow-wallet.schema';

export const escrowWalletRouter = Router();

// TSK-19: Retrieve Cyber Wallet balances, reconciliation formula proof, and immutable ledger
escrowWalletRouter.get('/me', authenticate, EscrowWalletController.getMyWallet);

// TSK-19: Withdraw available earnings to bank account
escrowWalletRouter.post(
  '/withdraw',
  authenticate,
  validateBody(withdrawFundsBodySchema),
  EscrowWalletController.withdraw,
);

// Update linked bank account metadata
escrowWalletRouter.put(
  '/bank-account',
  authenticate,
  validateBody(updateBankAccountBodySchema),
  EscrowWalletController.updateBankAccount,
);

export default escrowWalletRouter;

