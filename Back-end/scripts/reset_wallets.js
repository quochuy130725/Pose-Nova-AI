const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function resetWallets() {
  await prisma.wallet.updateMany({
    data: {
      availableBalance: 0,
      escrowLockedBalance: 0,
      totalWithdrawn: 0,
    },
  });
  console.log('All wallets reset to 0 VND available and 0 VND locked.');
  await prisma.$disconnect();
}

resetWallets().catch(console.error);

