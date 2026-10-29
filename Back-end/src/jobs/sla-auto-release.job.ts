import cron, { ScheduledTask } from 'node-cron';
import { MilestoneStatus, RequestStatus } from '@prisma/client';
import { prisma } from '../config/database';
import { MilestonesService } from '../modules/milestones/milestones.service';

let scheduledTask: ScheduledTask | null = null;
let isSweepRunning = false;

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function isTransientDbConnectionError(err: unknown): boolean {
  const code = (err as { code?: string })?.code ?? '';
  const msg = err instanceof Error ? err.message : String(err);
  return (
    code === 'P1001' ||
    code === 'P1002' ||
    code === 'P1008' ||
    code === 'P1017' ||
    msg.includes("Can't reach database server") ||
    msg.includes('ConnectionReset') ||
    msg.includes('Server has closed the connection')
  );
}

/**
 * TSK-19: Sweeps all `IN_REVIEW` milestones whose 48-hour `autoReleaseAt` deadline
 * has passed on active `IN_PROGRESS` contracts, releasing the 85% Net payout to Stylists
 * and unlocking the next stage automatically.
 */
export async function runSlaAutoReleaseSweep(referenceNow: Date = new Date()): Promise<{
  scannedCount: number;
  releasedMilestoneIds: string[];
}> {
  if (isSweepRunning) {
    return { scannedCount: 0, releasedMilestoneIds: [] };
  }

  isSweepRunning = true;
  try {
    const queryExpired = () =>
      prisma.requestMilestone.findMany({
        where: {
          status: MilestoneStatus.IN_REVIEW,
          autoReleaseAt: {
            not: null,
            lte: referenceNow,
          },
          request: {
            status: RequestStatus.IN_PROGRESS,
          },
        },
        select: {
          id: true,
          stageOrder: true,
          request: { select: { code: true } },
        },
      });

    let expiredMilestones: Awaited<ReturnType<typeof queryExpired>>;
    try {
      expiredMilestones = await queryExpired();
    } catch (firstErr) {
      if (!isTransientDbConnectionError(firstErr)) {
        throw firstErr;
      }
      // Laptop wake / Wi-Fi reconnect recovery: flush stale sockets, wait 4s, reconnect once
      await prisma.$disconnect().catch(() => undefined);
      await sleep(4000);
      await prisma.$connect();
      expiredMilestones = await queryExpired();
    }

    const releasedMilestoneIds: string[] = [];

    for (const item of expiredMilestones) {
      try {
        await MilestonesService.autoReleaseExpiredMilestone(item.id);
        releasedMilestoneIds.push(item.id);
        console.log(
          `⏰ [SLA 48h Auto-Release] Released Stage ${item.stageOrder} for Order #${item.request.code}`,
        );
      } catch (err) {
        console.warn(
          `⚠️ [SLA 48h Auto-Release] Skipped milestone ${item.id}:`,
          err instanceof Error ? err.message : err,
        );
      }
    }

    return {
      scannedCount: expiredMilestones.length,
      releasedMilestoneIds,
    };
  } finally {
    isSweepRunning = false;
  }
}

/**
 * Starts the recurring background cronjob (runs every 5 minutes) to enforce the 48h SLA.
 */
export function startSlaAutoReleaseJob(): ScheduledTask {
  if (scheduledTask) {
    return scheduledTask;
  }

  scheduledTask = cron.schedule('*/5 * * * *', () => {
    void runSlaAutoReleaseSweep().catch((err) => {
      if (isTransientDbConnectionError(err)) {
        console.warn(
          '⚠️  [SLA 48h Job] Network/Supabase temporarily unreachable (offline or waking from sleep) — will retry next cycle.',
        );
        return;
      }
      console.error('[SLA 48h Job Error]:', err);
    });
  });

  console.log('⏱️  SLA 48-hour Escrow Auto-Release Cronjob registered (every 5 minutes)');
  return scheduledTask;
}

