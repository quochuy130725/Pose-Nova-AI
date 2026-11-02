import { PrismaClient, Role } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🔄 Bắt đầu nạp dữ liệu mẫu sạch (Seeding Database - Clean)...');

  // Xóa toàn bộ dữ liệu hợp đồng cũ và reset ví về 0
  await prisma.review.deleteMany({});
  await prisma.dispute.deleteMany({});
  await prisma.paymentTransaction.deleteMany({});
  await prisma.milestoneSubmission.deleteMany({});
  await prisma.requestMilestone.deleteMany({});
  await prisma.stylingRequest.deleteMany({});
  await prisma.productTag.deleteMany({});
  await prisma.lookbookLike.deleteMany({});
  await prisma.lookbook.deleteMany({});
  await prisma.wallet.deleteMany({
    where: { user: { email: { in: ['alex.do@gmail.com', 'maya.tran@posenova.com', 'linh.dan@posenova.com'] } } },
  });
  await prisma.user.deleteMany({
    where: { email: { in: ['alex.do@gmail.com', 'maya.tran@posenova.com', 'linh.dan@posenova.com'] } },
  });

  // ==========================================
  // 1. TẠO NGƯỜI DÙNG DEMO (USERS) VỚI VÍ 0Đ
  // ==========================================

  // Khách hàng (Client) - Alex Đỗ
  await prisma.user.create({
    data: {
      email: 'alex.do@gmail.com',
      fullName: 'Alex Đỗ',
      role: Role.CLIENT,
      avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=150&q=80',
      heightCm: 175,
      weightKg: 68,
      ratingAvg: 5.0,
      wallet: {
        create: {
          availableBalance: 0.00,
          escrowLockedBalance: 0.00,
          totalWithdrawn: 0.00,
        },
      },
    },
  });

  // Stylist - Maya Trần
  await prisma.user.create({
    data: {
      email: 'maya.tran@posenova.com',
      fullName: 'Maya Trần',
      role: Role.STYLIST,
      bio: 'Fashion designer & Stylist with 5+ years in Streetwear & Cyberpunk aesthetic.',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
      ratingAvg: 4.95,
      totalReviews: 12,
      wallet: {
        create: {
          availableBalance: 0.00,
          escrowLockedBalance: 0.00,
          totalWithdrawn: 0.00,
          bankName: 'MBBank',
          bankAccountNo: '0829100286',
          bankAccountHolder: 'PHAM HUYNH QUOC HUY',
        },
      },
    },
  });

  // Stylist 2 - Linh Đan
  await prisma.user.create({
    data: {
      email: 'linh.dan@posenova.com',
      fullName: 'Linh Đan',
      role: Role.STYLIST,
      bio: 'Minimalist & Y2K Stylist from Saigon Atelier.',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
      ratingAvg: 4.88,
      totalReviews: 8,
      wallet: {
        create: {
          availableBalance: 0.00,
          escrowLockedBalance: 0.00,
          totalWithdrawn: 0.00,
        },
      },
    },
  });

  console.log('✅ Đã nạp xong tài khoản người dùng demo sạch (Ví 0đ).');

  // Đảm bảo toàn bộ ví khác trong hệ thống cũng ở mức 0đ
  await prisma.wallet.updateMany({
    data: {
      availableBalance: 0.00,
      escrowLockedBalance: 0.00,
      totalWithdrawn: 0.00,
    },
  });

  console.log('🎉 Toàn bộ dữ liệu sạch đã được cập nhật thành công (0 đơn hàng rác trong DB).');
}

main()
  .catch((e) => {
    console.error('❌ Lỗi khi chạy Seeding DB:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
