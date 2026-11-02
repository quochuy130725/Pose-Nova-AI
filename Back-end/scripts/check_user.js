const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const prisma = new PrismaClient();

async function main() {
  const user = await prisma.user.findUnique({
    where: { email: 'qhuy8452@gmail.com' }
  });
  console.log('Found user:', user?.id, user?.email, user?.fullName, user?.role);
  console.log('Password hash:', user?.passwordHash);
  if (user?.passwordHash) {
    const match = await bcrypt.compare('huypham2323', user.passwordHash);
    console.log('Matches huypham2323?', match);
    const match123 = await bcrypt.compare('123456', user.passwordHash);
    console.log('Matches 123456?', match123);
    const matchPass123 = await bcrypt.compare('password123', user.passwordHash);
    console.log('Matches password123?', matchPass123);
  }
}

main().catch(console.error).finally(() => prisma.$disconnect());
