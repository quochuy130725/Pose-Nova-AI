import { PrismaClient } from '@prisma/client';

function buildResilientDatabaseUrl(rawUrl?: string): string | undefined {
  if (!rawUrl) return undefined;
  try {
    const parsed = new URL(rawUrl);
    if (parsed.hostname.includes('pooler.supabase.com')) {
      if (!parsed.searchParams.has('pgbouncer') && parsed.port === '6543') {
        parsed.searchParams.set('pgbouncer', 'true');
      }
      if (!parsed.searchParams.has('connection_limit')) {
        parsed.searchParams.set('connection_limit', '5');
      }
      if (!parsed.searchParams.has('pool_timeout')) {
        parsed.searchParams.set('pool_timeout', '20');
      }
      if (!parsed.searchParams.has('connect_timeout')) {
        parsed.searchParams.set('connect_timeout', '15');
      }
      if (!parsed.searchParams.has('keepalives')) {
        parsed.searchParams.set('keepalives', '1');
      }
      if (!parsed.searchParams.has('keepalives_idle')) {
        parsed.searchParams.set('keepalives_idle', '30');
      }
    }
    return parsed.toString();
  } catch {
    return rawUrl;
  }
}

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
  prismaListenersAttached: boolean | undefined;
};

const resilientUrl = buildResilientDatabaseUrl(process.env.DATABASE_URL);

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    ...(resilientUrl ? { datasources: { db: { url: resilientUrl } } } : {}),
    log: [
      { emit: 'event', level: 'error' },
      { emit: 'event', level: 'warn' },
    ],
  });

if (!globalForPrisma.prismaListenersAttached) {
  prisma.$on('error' as never, (event: { message?: string }) => {
    const msg = event?.message ?? '';
    // Supabase Supavisor (port 6543) periodically recycles idle TCP sockets on Windows (OS error 10054).
    // Prisma's pool automatically establishes a fresh connection on the next query, so suppress idle noise.
    if (
      msg.includes('ConnectionReset') ||
      msg.includes('10054') ||
      msg.includes('forcibly closed by the remote host') ||
      msg.includes("Can't reach database server")
    ) {
      return;
    }
    console.error('[Prisma Error]:', msg);
  });

  prisma.$on('warn' as never, (event: { message?: string }) => {
    if (event?.message) {
      console.warn('[Prisma Warn]:', event.message);
    }
  });

  globalForPrisma.prismaListenersAttached = true;
}

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}

export const db = prisma;
export default prisma;

