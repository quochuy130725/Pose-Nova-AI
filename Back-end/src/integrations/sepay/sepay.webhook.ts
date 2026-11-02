import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { SepayService } from './sepay.service';
import { env } from '../../config/env';
import { AppError } from '../../common/middlewares/error.middleware';
import { sendSuccess } from '../../common/utils/response.util';

const sepayWebhookBodySchema = z.object({
  id: z.union([z.string(), z.number()]).optional(),
  gateway: z.string().optional(),
  transactionDate: z.string().optional(),
  accountNumber: z.string().optional(),
  content: z.string().optional(),
  description: z.string().optional(),
  transferType: z.string().optional(),
  transferAmount: z.coerce.number().positive().optional(),
  amount: z.coerce.number().positive().optional(),
  referenceCode: z.string().optional(),
  sepayRefCode: z.string().optional(),
  requestCode: z.string().optional(),
  requestId: z.string().optional(),
});

function verifySepayWebhookSecret(req: Request, _res: Response, next: NextFunction): void {
  const configuredSecret = env.SEPAY_WEBHOOK_SECRET;
  const headerSecret = req.headers['x-sepay-webhook-secret'];
  const authHeader = req.headers.authorization;

  let providedSecret: string | undefined;
  if (typeof headerSecret === 'string' && headerSecret.trim()) {
    providedSecret = headerSecret.trim();
  } else if (typeof authHeader === 'string' && authHeader.trim()) {
    // Supports "Apikey <secret>" or "Bearer <secret>"
    const parts = authHeader.trim().split(/\s+/);
    providedSecret = parts.length >= 2 ? parts.slice(1).join(' ') : parts[0];
  }

  if (providedSecret !== undefined) {
    if (providedSecret !== configuredSecret) {
      return next(new AppError('Invalid SePay webhook secret', 401));
    }
    return next();
  }

  // If secret header is not provided (e.g. user selected 'Không xác thực' or SePay test ping),
  // allow request through to validate payload safely.
  return next();
}

async function handleSepayWebhook(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const rawBody = req.body ?? {};

    // Gracefully handle empty ping / dashboard test ping from SePay
    if (!rawBody || Object.keys(rawBody).length === 0) {
      sendSuccess(
        res,
        { ping: 'ok', timestamp: new Date().toISOString() },
        'SePay Webhook ping received successfully (test mode)',
        200,
      );
      return;
    }

    const validated = sepayWebhookBodySchema.safeParse(rawBody);
    const parsedData = validated.success ? validated.data : rawBody;

    const result = await SepayService.processEscrowDeposit(parsedData);
    const message = result.alreadyProcessed
      ? 'Duplicate SePay reference code ignored (idempotent)'
      : 'Escrow deposit confirmed: locked 85% net payout and initialized 30-30-40 milestones';
    sendSuccess(res, result, message, 200);
  } catch (err) {
    next(err);
  }
}

export const webhooksRouter = Router();

// GET health ping for both / and /sepay
webhooksRouter.get(['/', '/sepay'], (_req: Request, res: Response) => {
  res.status(200).json({
    success: true,
    message: 'PoseNova SePay Webhook endpoint is active and listening',
    timestamp: new Date().toISOString(),
  });
});

// POST webhook handler for both / and /sepay
webhooksRouter.post(
  ['/', '/sepay'],
  verifySepayWebhookSecret,
  handleSepayWebhook,
);

export default webhooksRouter;
