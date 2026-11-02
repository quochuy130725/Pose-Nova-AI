const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function checkAll() {
  console.log('--- Checking all Supabase tables ---');
  const disputes = await prisma.dispute.count();
  const reviews = await prisma.review.count();
  const txns = await prisma.paymentTransaction.count();
  const submissions = await prisma.milestoneSubmission.count();
  const milestones = await prisma.requestMilestone.count();
  const requests = await prisma.stylingRequest.count();
  const tags = await prisma.productTag.count({ where: { milestoneId: { not: null } } });
  const users = await prisma.user.findMany({ select: { email: true, role: true } });
  const wallets = await prisma.wallet.findMany({
    select: { availableBalance: true, escrowLockedBalance: true }
  });

  console.log('Disputes:', disputes);
  console.log('Reviews:', reviews);
  console.log('Transactions:', txns);
  console.log('Milestone Submissions:', submissions);
  console.log('Milestones:', milestones);
  console.log('Styling Requests:', requests);
  console.log('Milestone Product Tags:', tags);
  console.log('Users count:', users.length);
  for (const u of users) {
    console.log(`  - ${u.email} (${u.role})`);
  }
  console.log('Wallets:', wallets);

  await prisma.$disconnect();
}

checkAll().catch(console.error);

