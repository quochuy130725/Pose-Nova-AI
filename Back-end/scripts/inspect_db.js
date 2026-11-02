const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function inspect() {
  const reqs = await prisma.stylingRequest.findMany({
    include: { milestones: true, transactions: true }
  });
  console.log('Styling Requests count:', reqs.length);
  for (const r of reqs) {
    console.log(`- Request ${r.code} | ${r.title} | Budget: ${r.totalBudget} | Status: ${r.status}`);
    for (const m of r.milestones) {
      console.log(`   * M${m.stageOrder}: ${m.title} | Gross: ${m.grossAmount} | Net: ${m.netPayout} | Status: ${m.status}`);
    }
    for (const t of r.transactions) {
      console.log(`   # Txn: ${t.type} | Gross: ${t.grossAmount} | Status: ${t.status}`);
    }
  }
  const wallets = await prisma.wallet.findMany({ include: { user: true } });
  console.log('Wallets:');
  for (const w of wallets) {
    console.log(`- User: ${w.user.email} (${w.user.role}) | Available: ${w.availableBalance} | Locked: ${w.escrowLockedBalance}`);
  }
  await prisma.$disconnect();
}

inspect().catch(console.error);

