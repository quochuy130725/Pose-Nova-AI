const bcrypt = require('bcryptjs');
const { PrismaClient, Role } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const email = 'qhuy8452@gmail.com';
  const password = 'huypham2323';
  const passwordHash = await bcrypt.hash(password, 10);

  const existing = await prisma.user.findUnique({
    where: { email },
    include: { wallet: true },
  });

  if (existing) {
    console.log('User already exists, updating password...');
    await prisma.user.update({
      where: { email },
      data: { passwordHash },
    });
    console.log('Password updated successfully for', email);
  } else {
    console.log('Creating user', email);
    const user = await prisma.user.create({
      data: {
        email,
        passwordHash,
        fullName: 'Phạm Huỳnh Quốc Huy',
        role: Role.CLIENT,
        heightCm: 175,
        weightKg: 68,
        ratingAvg: 5.0,
        wallet: {
          create: {
            availableBalance: 0,
            escrowLockedBalance: 0,
            totalWithdrawn: 0,
          },
        },
      },
      include: { wallet: true },
    });
    console.log('User created successfully:', user.id, user.email, user.role);
  }

  await prisma.$disconnect();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});

