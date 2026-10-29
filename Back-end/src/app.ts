import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import { prisma } from './config/database';
import {
  STAGE_SPLITS,
  PLATFORM_FEE_RATE,
  STYLIST_NET_RATE,
  MAX_REVISIONS,
  SLA_HOURS,
} from './common/constants/escrow.constants';
import { globalErrorHandler, notFoundHandler } from './common/middlewares/error.middleware';
import { sendSuccess, sendError } from './common/utils/response.util';
import { setupSwagger } from './config/swagger';
import { apiV1Router } from './routes';

export const app = express();

// 1. Global Middlewares
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// 2. Swagger API Documentation
setupSwagger(app);

// 3. Health Check Endpoint (Validates Express + Prisma + Supabase PostgreSQL Connectivity)
const healthHandler = async (_req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    const [users, lookbooks, stylingRequests] = await Promise.all([
      prisma.user.count(),
      prisma.lookbook.count(),
      prisma.stylingRequest.count(),
    ]);

    sendSuccess(
      res,
      {
        status: 'OK',
        timestamp: new Date().toISOString(),
        escrowPolicy: {
          stageSplits: STAGE_SPLITS,
          platformFeeRate: PLATFORM_FEE_RATE,
          stylistNetRate: STYLIST_NET_RATE,
          maxRevisions: MAX_REVISIONS,
          slaAutoReleaseHours: SLA_HOURS,
        },
        database: {
          provider: 'Supabase PostgreSQL',
          connected: true,
          counts: {
            users,
            lookbooks,
            stylingRequests,
          },
        },
      },
      'PoseNova AI Back-End is healthy and connected to Prisma OK',
      200,
    );
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Database connection failed';
    sendError(res, 'Database connectivity check failed', 503, { error: message });
  }
};

app.get('/health', healthHandler);
app.get('/api/v1/health', healthHandler);

// 4. Mount Modular API v1 Routes
app.use('/api/v1', apiV1Router);

// 5. 404 & Centralized Error Middlewares
app.use(notFoundHandler);
app.use(globalErrorHandler);

export default app;
