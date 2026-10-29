import { app } from './app';
import { env } from './config/env';
import { prisma } from './config/database';
import { startSlaAutoReleaseJob } from './jobs/sla-auto-release.job';

const server = app.listen(env.PORT, () => {
  console.log(`====================================================`);
  console.log(`🚀 PoseNova AI Server running on port ${env.PORT}`);
  console.log(`📡 Health Check: http://localhost:${env.PORT}/api/v1/health`);
  console.log(`📚 Swagger Docs: http://localhost:${env.PORT}/api-docs`);
  console.log(`====================================================`);
  startSlaAutoReleaseJob();
});

const gracefulShutdown = async (signal: string) => {
  console.log(`${signal} received: closing HTTP server and Prisma pool...`);
  server.close(async () => {
    await prisma.$disconnect().catch(() => undefined);
    process.exit(0);
  });
};

process.on('SIGTERM', () => void gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => void gracefulShutdown('SIGINT'));

