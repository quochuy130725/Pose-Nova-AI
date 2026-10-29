import { PrismaClient } from '@prisma/client';
import { prisma } from './src/config/database';
import dotenv from 'dotenv';
dotenv.config();

async function main() {
  console.log('1) Testing src/config/database.ts (port 6543 + params)...');
  try {
    const c1 = await prisma.user.count();
    console.log('   -> SUCCESS on 6543! users =', c1);
  } catch (e: unknown) {
    console.error('   -> FAILED on 6543:', e instanceof Error ? e.message : e);
  } finally {
    await prisma.$disconnect();
  }

  console.log('2) Testing clean port 6543 (?pgbouncer=true&connection_limit=3)...');
  const clean6543 = new PrismaClient({
    datasources: {
      db: {
        url: 'postgresql://postgres.mzrypxpkhfgcblndinlu:Huypham2323%40@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres?pgbouncer=true&connection_limit=3',
      },
    },
  });
  try {
    const c2 = await clean6543.user.count();
    console.log('   -> SUCCESS on clean 6543! users =', c2);
  } catch (e: unknown) {
    console.error('   -> FAILED on clean 6543:', e instanceof Error ? e.message : e);
  } finally {
    await clean6543.$disconnect();
  }

  console.log('3) Testing session pooler port 5432...');
  const p5432 = new PrismaClient({
    datasources: {
      db: {
        url: process.env.DIRECT_URL,
      },
    },
  });
  try {
    const c3 = await p5432.user.count();
    console.log('   -> SUCCESS on 5432! users =', c3);
  } catch (e: unknown) {
    console.error('   -> FAILED on 5432:', e instanceof Error ? e.message : e);
  } finally {
    await p5432.$disconnect();
  }
}

void main();

