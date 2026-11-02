const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const users = await prisma.user.findMany({
    select: { id: true, email: true, fullName: true, role: true, createdAt: true, passwordHash: true }
  });
  console.log('Total users:', users.length);
  for (const u of users) {
    console.log(`- ${u.email} | ${u.fullName} | Role: ${u.role} | HasPassword: ${!!u.passwordHash} | Created: ${u.createdAt}`);
  }
  await prisma.$disconnect();
}

main().catch(console.error);

