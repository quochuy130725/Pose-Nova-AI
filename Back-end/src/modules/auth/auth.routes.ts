import { Router } from 'express';
import { AuthController } from './auth.controller';
import { authenticate } from '../../common/middlewares/auth.middleware';
import { validateBody } from '../../common/middlewares/validate.middleware';
import { demoLoginSchema, loginSchema, registerSchema } from './auth.schema';

export const authRouter = Router();

// 1-Tap Persona Switcher (Alex Đỗ <-> Maya Trần)
authRouter.post('/demo-login', validateBody(demoLoginSchema), AuthController.demoLogin);

// Standard Commercial Auth Flows
authRouter.post('/register', validateBody(registerSchema), AuthController.register);
authRouter.post('/login', validateBody(loginSchema), AuthController.login);

// Authenticated Current Profile + Wallet Balances
authRouter.get('/me', authenticate, AuthController.getMe);

export default authRouter;

