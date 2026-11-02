require('dotenv').config();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function clean() {
  console.log('Running SQL cleanup on Supabase...');
  await prisma.$executeRawUnsafe(`
    TRUNCATE TABLE 
      public.disputes,
      public.reviews,
      public.payment_transactions,
      public.milestone_submissions,
      public.request_milestones,
      public.styling_requests
    RESTART IDENTITY CASCADE;
  `);

  await prisma.$executeRawUnsafe(`
    DELETE FROM public.product_tags WHERE milestone_id IS NOT NULL;
  `);

  await prisma.$executeRawUnsafe(`
    UPDATE public.wallets
    SET 
      available_balance = 0,
      escrow_locked_balance = 0,
      total_withdrawn = 0,
      updated_at = NOW();
  `);

  console.log('CLEANUP SUCCESSFUL IN SUPABASE!');
}

clean()
  .then(() => prisma.$disconnect())
  .catch(err => {
    console.error('Error during cleanup:', err);
    process.exit(1);
  });

