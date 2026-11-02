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
  const maya = await prisma.user.create({
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
  const linhDan = await prisma.user.create({
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

  // ==========================================
  // 2. TẠO DATA LOOKBOOK DÁNG ĐỨNG CHUẨN DỄ TEST
  // ==========================================
  console.log('📸 Đang tạo bộ Lookbook dáng đứng chuẩn test cho Camera AI...');

  // 1. Dáng đứng thẳng tự nhiên (Natural Straight Standing)
  await prisma.lookbook.create({
    data: {
      stylistId: maya.id,
      title: 'Minimal Trench • SS26',
      description: 'Dáng đứng thẳng thanh lịch, 2 tay buông thả lỏng dọc theo thân người.',
      styleCategory: 'MINIMAL',
      imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=800&q=80',
      likesCount: 142,
      poseTryCount: 96,
      poseLandmarksJson: {
        poseType: 'NATURAL_STANDING',
        leftElbow: 158.0,
        rightElbow: 158.0,
        leftShoulder: 28.0,
        rightShoulder: 28.0,
        leftHip: 174.0,
        rightHip: 175.0,
      },
      productTags: {
        create: [
          {
            productName: 'Oversized Wool Trench Coat',
            brandName: 'Lemaire',
            price: 1450000,
            affiliateUrl: 'https://shopee.vn/lemaire-wool-trench',
            posX: 0.45,
            posY: 0.35,
          },
          {
            productName: 'Minimalist Silk Knit',
            brandName: 'Jil Sander',
            price: 520000,
            affiliateUrl: 'https://shopee.vn/jil-sander-knit',
            posX: 0.50,
            posY: 0.48,
          },
          {
            productName: 'Wide Leg Pleated Trousers',
            brandName: 'Cos',
            price: 680000,
            affiliateUrl: 'https://shopee.vn/cos-pleated-trousers',
            posX: 0.48,
            posY: 0.75,
          },
        ],
      },
    },
  });

  // 2. Dáng đứng 1 tay đút túi (One-Hand Pocket Stance)
  await prisma.lookbook.create({
    data: {
      stylistId: linhDan.id,
      title: 'Urban Casual Denim • AW26',
      description: 'Dáng đứng 1 tay đút túi quần, 1 tay buông tự nhiên, vai mở rộng tự tin.',
      styleCategory: 'STREETWEAR',
      imageUrl: 'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?auto=format&fit=crop&w=800&q=80',
      likesCount: 168,
      poseTryCount: 112,
      poseLandmarksJson: {
        poseType: 'ONE_HAND_POCKET',
        leftElbow: 95.0,
        rightElbow: 155.0,
        leftShoulder: 45.0,
        rightShoulder: 30.0,
        leftHip: 174.0,
        rightHip: 175.0,
      },
      productTags: {
        create: [
          {
            productName: 'Washed Denim Oversize Jacket',
            brandName: 'Diesel',
            price: 920000,
            affiliateUrl: 'https://shopee.vn/diesel-washed-denim',
            posX: 0.46,
            posY: 0.38,
          },
          {
            productName: 'Heavyweight Cotton Cargo Pants',
            brandName: 'Stussy',
            price: 580000,
            affiliateUrl: 'https://shopee.vn/stussy-cargo',
            posX: 0.52,
            posY: 0.68,
          },
        ],
      },
    },
  });

  // 3. Dáng đứng thẳng Blazer (Classic Straight Stance)
  await prisma.lookbook.create({
    data: {
      stylistId: maya.id,
      title: 'Clean Tailoring Blazer • Minimal',
      description: 'Dáng đứng thẳng chuẩn thời trang Editorial, hai vai ngang cân bằng tự nhiên.',
      styleCategory: 'EDITORIAL',
      imageUrl: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=800&q=80',
      likesCount: 115,
      poseTryCount: 78,
      poseLandmarksJson: {
        poseType: 'EDITORIAL_STRAIGHT',
        leftElbow: 155.0,
        rightElbow: 155.0,
        leftShoulder: 32.0,
        rightShoulder: 32.0,
        leftHip: 174.0,
        rightHip: 175.0,
      },
      productTags: {
        create: [
          {
            productName: 'Double-Breasted Beige Blazer',
            brandName: 'Zara',
            price: 890000,
            affiliateUrl: 'https://shopee.vn/zara-beige-blazer',
            posX: 0.48,
            posY: 0.36,
          },
          {
            productName: 'Straight-Fit Ivory Trousers',
            brandName: 'Mango',
            price: 490000,
            affiliateUrl: 'https://shopee.vn/mango-ivory-trousers',
            posX: 0.50,
            posY: 0.72,
          },
        ],
      },
    },
  });

  // 4. Dáng đứng dạo biển đón nắng (Sunlit Beach Resort Stance)
  await prisma.lookbook.create({
    data: {
      stylistId: maya.id,
      title: 'Summer Resort Linen • Sunlit Breeze',
      description: 'Dáng đứng dạo biển thư thái, 1 tay chạm nhẹ vành nón/vuốt tóc, 1 tay buông tự nhiên.',
      styleCategory: 'EDITORIAL',
      imageUrl: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=800&q=80',
      likesCount: 195,
      poseTryCount: 130,
      poseLandmarksJson: {
        poseType: 'RESORT_BEACH',
        leftElbow: 85.0,
        rightElbow: 150.0,
        leftShoulder: 70.0,
        rightShoulder: 32.0,
        leftHip: 172.0,
        rightHip: 174.0,
      },
      productTags: {
        create: [
          {
            productName: 'Camp Collar Linen Shirt',
            brandName: 'Massimo Dutti',
            price: 750000,
            affiliateUrl: 'https://shopee.vn/massimo-linen-shirt',
            posX: 0.48,
            posY: 0.35,
          },
          {
            productName: 'Tailored Drawstring Linen Shorts',
            brandName: 'Uniqlo',
            price: 390000,
            affiliateUrl: 'https://shopee.vn/uniqlo-linen-shorts',
            posX: 0.50,
            posY: 0.62,
          },
          {
            productName: 'Polarized Acetate Sunglasses',
            brandName: 'Ray-Ban',
            price: 1250000,
            affiliateUrl: 'https://shopee.vn/rayban-sunglasses',
            posX: 0.52,
            posY: 0.18,
          },
        ],
      },
    },
  });

  // 5. Dáng đứng Streetwear tối giản (Monochrome Casual Stance)
  await prisma.lookbook.create({
    data: {
      stylistId: linhDan.id,
      title: 'Monochrome Street Minimalist',
      description: 'Dáng đứng thẳng đường phố hiện đại, 2 tay thả lỏng nhẹ bên hông.',
      styleCategory: 'STREETWEAR',
      imageUrl: 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=800&q=80',
      likesCount: 210,
      poseTryCount: 154,
      poseLandmarksJson: {
        poseType: 'MONOCHROME_STREET',
        leftElbow: 152.0,
        rightElbow: 150.0,
        leftShoulder: 34.0,
        rightShoulder: 34.0,
        leftHip: 172.0,
        rightHip: 174.0,
      },
      productTags: {
        create: [
          {
            productName: 'Boxy Heavyweight Tee',
            brandName: 'Fear of God Essentials',
            price: 650000,
            affiliateUrl: 'https://shopee.vn/fog-essentials-tee',
            posX: 0.50,
            posY: 0.38,
          },
          {
            productName: 'Wide-Leg Parachute Pants',
            brandName: 'Zara Man',
            price: 520000,
            affiliateUrl: 'https://shopee.vn/zara-parachute-pants',
            posX: 0.48,
            posY: 0.70,
          },
        ],
      },
    },
  });

  // 6. Dáng đứng Y2K Pop Cargo (Y2K Casual Pocket Stance)
  await prisma.lookbook.create({
    data: {
      stylistId: linhDan.id,
      title: 'Y2K Pop Cargo Flare • 2026',
      description: 'Dáng đứng trẻ trung năng động, 1 tay chạm túi áo, 1 tay buông tự nhiên.',
      styleCategory: 'Y2K POP',
      imageUrl: 'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=800&q=80',
      likesCount: 175,
      poseTryCount: 120,
      poseLandmarksJson: {
        poseType: 'Y2K_POCKET',
        leftElbow: 100.0,
        rightElbow: 155.0,
        leftShoulder: 40.0,
        rightShoulder: 28.0,
        leftHip: 172.0,
        rightHip: 174.0,
      },
      productTags: {
        create: [
          {
            productName: 'Cropped Zip-Up Hoodie',
            brandName: 'Bershka',
            price: 450000,
            affiliateUrl: 'https://shopee.vn/bershka-hoodie',
            posX: 0.50,
            posY: 0.35,
          },
          {
            productName: 'Low-Rise Cargo Flare Pants',
            brandName: 'Diesel',
            price: 880000,
            affiliateUrl: 'https://shopee.vn/diesel-cargo-flare',
            posX: 0.48,
            posY: 0.65,
          },
        ],
      },
    },
  });

  console.log('✅ Đã nạp thành công 6 bộ Lookbook dáng đứng chuẩn test cho Camera AI.');

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
