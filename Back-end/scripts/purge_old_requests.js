const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function purge() {
  console.log('--- Cleaning old requests & stale data ---');

  // Keep REQ-6022, remove REQ-8452 and REQ-3101
  const staleRequests = await prisma.stylingRequest.findMany({
    where: {
      code: { in: ['REQ-8452', 'REQ-3101'] },
    },
    select: { id: true, code: true },
  });

  console.log(`Found ${staleRequests.length} stale requests to delete:`, staleRequests.map(r => r.code));

  for (const req of staleRequests) {
    await prisma.milestoneSubmission.deleteMany({
      where: { milestone: { requestId: req.id } },
    });
    await prisma.productTag.deleteMany({
      where: { milestone: { requestId: req.id } },
    });
    await prisma.requestMilestone.deleteMany({
      where: { requestId: req.id },
    });
    await prisma.paymentTransaction.deleteMany({
      where: { requestId: req.id },
    });
    await prisma.stylingRequest.delete({
      where: { id: req.id },
    });
    console.log(`Deleted request ${req.code}`);
  }

  // Update REQ-6022 milestone titles to be clean
  const req6022 = await prisma.stylingRequest.findUnique({
    where: { code: 'REQ-6022' },
    include: { milestones: true },
  });

  if (req6022) {
    console.log('Updating REQ-6022 milestones cleanly...');
    for (const m of req6022.milestones) {
      let cleanTitle = m.title;
      if (m.stageOrder === 1) cleanTitle = 'Moodboard & Concept';
      if (m.stageOrder === 2) cleanTitle = 'Outfit Selection & Pose';
      if (m.stageOrder === 3) cleanTitle = 'Final Lookbook & Pose';
      await prisma.requestMilestone.update({
        where: { id: m.id },
        data: { title: cleanTitle },
      });
    }

    // Set Maya's wallet escrow locked balance to exactly 42500 (85% net of 50.000)
    const maya = await prisma.user.findUnique({
      where: { email: 'maya.tran@posenova.com' },
      include: { wallet: true },
    });

    if (maya && maya.wallet) {
      await prisma.wallet.update({
        where: { id: maya.wallet.id },
        data: {
          availableBalance: 0,
          escrowLockedBalance: 42500,
          totalWithdrawn: 0,
        },
      });
      console.log('Maya wallet locked balance set to 42.500 VND');
    }
  }

  // Reset all other wallets
  await prisma.wallet.updateMany({
    where: {
      user: {
        email: { not: 'maya.tran@posenova.com' },
      },
    },
    data: {
      availableBalance: 0,
      escrowLockedBalance: 0,
      totalWithdrawn: 0,
    },
  });

  console.log('--- Cleanup Finished Successfully ---');
  await prisma.$disconnect();
}

purge().catch(console.error);
