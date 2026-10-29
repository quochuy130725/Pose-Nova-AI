import { PrismaClient, Role, RequestStatus, MilestoneStatus, TransactionType, TransactionStatus } from '@prisma/client';

const prisma = new PrismaClient();

// Giả lập tọa độ 33 điểm mốc (Pose Landmarks) từ Google ML Kit để Test AI Camera
const mockPoseLandmarks = Array.from({ length: 33 }, (_, i) => ({
  landmarkIndex: i,
  x: parseFloat((0.45 + Math.random() * 0.1).toFixed(4)),
  y: parseFloat((0.3 + Math.random() * 0.2).toFixed(4)),
  z: parseFloat((Math.random() * 0.05).toFixed(4)),
  visibility: parseFloat((0.9 + Math.random() * 0.1).toFixed(4)),
}));

async function main() {
  console.log('🔄 Bắt đầu nạp dữ liệu mẫu (Seeding Database)...');

  // Xóa dữ liệu cũ để tránh lỗi trùng lặp khi chạy lại lệnh seed
  await prisma.review.deleteMany({});
  await prisma.dispute.deleteMany({});
  await prisma.paymentTransaction.deleteMany({});
  await prisma.milestoneSubmission.deleteMany({});
  await prisma.requestMilestone.deleteMany({});
  await prisma.stylingRequest.deleteMany({});
  await prisma.productTag.deleteMany({});
  await prisma.lookbookLike.deleteMany({});
  await prisma.lookbook.deleteMany({});
  await prisma.wallet.deleteMany({});
  await prisma.user.deleteMany({});

  // ==========================================
  // 1. TẠO NGƯỜI DÙNG DEMO (USERS)
  // ==========================================

  // Khách hàng (Client) - Alex Đỗ
  const client = await prisma.user.create({
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
          availableBalance: 500000.00, // Client có sẵn 500k trong ví
          escrowLockedBalance: 0.00,
        },
      },
    },
  });

  // Stylist - Maya Trần
  const stylist = await prisma.user.create({
    data: {
      email: 'maya.tran@posenova.com',
      fullName: 'Maya Trần',
      role: Role.STYLIST,
      bio: 'Fashion designer & Stylist with 5+ years in Streetwear & Cyberpunk aesthetic.',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
      ratingAvg: 4.9,
      totalReviews: 1,
      wallet: {
        create: {
          availableBalance: 1250000.00, // Stylist đã có sẵn 1tr250 từ các đơn trước
          escrowLockedBalance: 0.00,
          bankName: 'Techcombank',
          bankAccountNo: '190345678910',
          bankAccountHolder: 'TRAN THI KHANH MAYA',
        },
      },
    },
  });

  // Stylist phụ - Linh Đan (Để bảng tin có nhiều nội dung)
  const stylist2 = await prisma.user.create({
    data: {
      email: 'linh.dan@posenova.com',
      fullName: 'Linh Đan',
      role: Role.STYLIST,
      bio: 'Vintage & Y2K Aesthetic enthusiast. Let’s collaborate!',
      avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=150&q=80',
      ratingAvg: 4.8,
      totalReviews: 0,
      wallet: {
        create: {
          availableBalance: 0.00,
          escrowLockedBalance: 0.00,
        },
      },
    },
  });

  console.log('✅ Đã nạp xong người dùng & khởi tạo ví cá nhân.');

  // ==========================================
  // 2. TẠO LOOKBOOK FEED MẪU
  // ==========================================
  const lookbook1 = await prisma.lookbook.create({
    data: {
      stylistId: stylist.id,
      title: 'Tokyo Outlaw AW26',
      description: 'The ultimate utility wear concept blending techwear, layered oversized jackets, and punk accents for cold urban climates.',
      styleCategory: 'STREETWEAR',
      imageUrl: 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=600&q=80',
      poseLandmarksJson: mockPoseLandmarks,
      likesCount: 154,
      poseTryCount: 42,
    },
  });

  const lookbook2 = await prisma.lookbook.create({
    data: {
      stylistId: stylist.id,
      title: 'Techwear AW26',
      description: 'Futuristic technical outerwear featuring waterproof jackets, cargo pants, and multi-strap utility gear.',
      styleCategory: 'CYBER_AW26',
      imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=600&q=80',
      poseLandmarksJson: mockPoseLandmarks,
      likesCount: 98,
      poseTryCount: 19,
    },
  });

  const lookbook3 = await prisma.lookbook.create({
    data: {
      stylistId: stylist2.id,
      title: 'Vintage Rave Y2K',
      description: 'Throwback to early 2000s cyber rave culture with baggy tracksuits, tinted shades, and neon layers.',
      styleCategory: 'Y2K_POP',
      imageUrl: 'https://images.unsplash.com/photo-1554412933-514a83d2f3c8?auto=format&fit=crop&w=600&q=80',
      poseLandmarksJson: mockPoseLandmarks,
      likesCount: 76,
      poseTryCount: 28,
    },
  });

  // Tải tag sản phẩm (Affiliate link) cho lookbook Tokyo Outlaw AW26
  await prisma.productTag.createMany({
    data: [
      {
        lookbookId: lookbook1.id,
        productName: 'Tokyo Heavy Oversized Jacket',
        brandName: 'Zara Vietnam',
        price: 1450000.00,
        thumbnailUrl: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?auto=format&fit=crop&w=80&q=80',
        affiliateUrl: 'https://www.zara.com/vn/oversized-heavy-jacket',
        posX: 0.35,
        posY: 0.4,
        clickCount: 14,
      },
      {
        lookbookId: lookbook1.id,
        productName: 'Wide-fit Cargo Pants',
        brandName: 'Uniqlo Vietnam',
        price: 799000.00,
        thumbnailUrl: 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?auto=format&fit=crop&w=80&q=80',
        affiliateUrl: 'https://www.uniqlo.com/vn/en/products/E459600-000',
        posX: 0.45,
        posY: 0.72,
        clickCount: 9,
      },
    ],
  });

  // Ghi nhận lượt yêu thích Lookbook
  await prisma.lookbookLike.create({
    data: {
      userId: client.id,
      lookbookId: lookbook1.id,
    },
  });

  console.log('✅ Đã nạp xong Lookbook, sản phẩm Affiliate và lượt thích.');

  // ==========================================
  // 3. TẠO ĐƠN HÀNG KÝ QUỸ #REQ-8452 (STYLING CONTRACT)
  // ==========================================

  // Tổng ngân sách đơn hàng là 2.500.000 VNĐ
  const totalBudget = 2500000.00;

  const stylingRequest = await prisma.stylingRequest.create({
    data: {
      code: 'REQ-8452',
      clientId: client.id,
      stylistId: stylist.id,
      title: 'Urban Cyberpunk Outfit',
      occasion: 'Cyber Concert Weekend 2026',
      briefText: 'I need a comfortable streetwear-cyberpunk fusion look for an outdoor festival in cold weather. Needs to have metallic or dark neon highlights.',
      aiPaletteJson: ['#09090B', '#F43F5E', '#10B981', '#A855F7'], // Bảng màu từ AI
      totalBudget: totalBudget,
      status: RequestStatus.IN_PROGRESS, // Đơn đã bắt đầu và đã nạp cọc 100%
      createdAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000), // Cách đây 5 ngày
    },
  });

  // Tự động phân tách 3 Chặng Ký quỹ (30% - 30% - 40%)
  const m1 = await prisma.requestMilestone.create({
    data: {
      requestId: stylingRequest.id,
      stageOrder: 1,
      title: 'Stage 1: Moodboard & Concept Study',
      percentage: 30,
      grossAmount: 750000.00,
      netPayout: 637500.00, // Stylist thực nhận 85% Net Payout
      status: MilestoneStatus.APPROVED, // CHẶNG 1 ĐÃ ĐƯỢC DUYỆT & GIẢI NGÂN
      deliverableUrl: 'https://images.unsplash.com/photo-1511556532299-8f662fc26c06?auto=format&fit=crop&w=600&q=80',
      stylistNotes: 'This moodboard explores technical overlays, deep charcoal colors, and cyber-pink accent fabrics.',
      approvedAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
    },
  });

  const m2 = await prisma.requestMilestone.create({
    data: {
      requestId: stylingRequest.id,
      stageOrder: 2,
      title: 'Stage 2: Outfit Selection & Smart Tagging',
      percentage: 30,
      grossAmount: 750000.00,
      netPayout: 637500.00,
      status: MilestoneStatus.IN_REVIEW, // CHẶNG 2 ĐANG CHỜ DUYỆT (SLA 48H)
      deliverableUrl: 'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=600&q=80',
      stylistNotes: 'Check out the tech-layers and custom cargo options. Affiliate product links are attached below.',
      autoReleaseAt: new Date(Date.now() + 1 * 24 * 60 * 60 * 1000), // Tự động duyệt sau 24 giờ tới
    },
  });

  const m3 = await prisma.requestMilestone.create({
    data: {
      requestId: stylingRequest.id,
      stageOrder: 3,
      title: 'Stage 3: Final Custom Lookbook & ML Kit Poses',
      percentage: 40,
      grossAmount: 1000000.00,
      netPayout: 850000.00,
      status: MilestoneStatus.LOCKED, // CHẶNG 3 ĐANG BỊ KHÓA (CHỜ QUA CHẶNG 2)
    },
  });

  // Tải tag sản phẩm (Affiliate) thuộc Chặng 2 (Outfit selection)
  await prisma.productTag.createMany({
    data: [
      {
        milestoneId: m2.id,
        productName: 'Cyber Reflective Bomber',
        brandName: 'Zara',
        price: 1899000.00,
        thumbnailUrl: 'https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?auto=format&fit=crop&w=80&q=80',
        affiliateUrl: 'https://www.zara.com/vn/reflective-bomber',
        posX: 0.35,
        posY: 0.32,
      },
    ],
  });

  // Lưu lịch sử bản sửa bài (Revision submission) ở Chặng 2
  await prisma.milestoneSubmission.create({
    data: {
      milestoneId: m2.id,
      revisionNumber: 0,
      deliverableUrl: 'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=600&q=80',
      stylistNotes: 'First draft upload',
      clientFeedback: 'Add a warmer technical layer, please.',
    },
  });

  // Cập nhật lượt Revision (Đang sửa lần 1)
  await prisma.requestMilestone.update({
    where: { id: m2.id },
    data: { revisionCount: 1 },
  });

  await prisma.milestoneSubmission.create({
    data: {
      milestoneId: m2.id,
      revisionNumber: 1,
      deliverableUrl: 'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=600&q=80',
      stylistNotes: 'Updated with metallic overlay and warm technical layers, specifically including inner thermal underlays.',
    },
  });

  console.log('✅ Đã nạp xong đơn Styling Request #REQ-8452 & Phân chặng 30-30-40.');

  // ==========================================
  // 4. LỊCH SỬ GIAO DỊCH VÀ SỔ CÁI ĐỐI SOÁT (LEDGER)
  // ==========================================

  // Lấy ID Ví của Client và Stylist
  const clientWallet = await prisma.wallet.findUnique({ where: { userId: client.id } });
  const stylistWallet = await prisma.wallet.findUnique({ where: { userId: stylist.id } });

  if (clientWallet && stylistWallet) {
    // 1. Khách hàng nạp đủ 100% (2.5tr) Ký quỹ thông qua VietQR (SePay Webhook)
    await prisma.paymentTransaction.create({
      data: {
        requestId: stylingRequest.id,
        walletId: clientWallet.id,
        type: TransactionType.ESCROW_DEPOSIT,
        grossAmount: totalBudget,
        feeAmount: 0.00,
        netAmount: totalBudget,
        sepayRefCode: 'SPN-SEPAY-8452-9902',
        status: TransactionStatus.COMPLETED,
        description: 'Momo/Bank transfer deposit via SePay for Request Code: REQ-8452',
        createdAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
      },
    });

    // Cập nhật tạm khóa Escrow
    await prisma.wallet.update({
      where: { id: stylistWallet.id },
      data: { escrowLockedBalance: 2125000.00 }, // Khóa 85% Net
    });

    // 2. Chặng 1 đã Duyệt, hệ thống tự động giải ngân 30% Net (637.5K) cho Stylist, thu phí sàn 15% (112.5k)
    await prisma.paymentTransaction.create({
      data: {
        requestId: stylingRequest.id,
        milestoneId: m1.id,
        walletId: stylistWallet.id,
        type: TransactionType.MILESTONE_RELEASE,
        grossAmount: 750000.00, // 30% Gross
        feeAmount: 112500.00,    // 15% Sàn
        netAmount: 637500.00,    // 85% Net Stylist nhận
        status: TransactionStatus.COMPLETED,
        description: 'Auto-released 30% Net Milestone 1 payout from escrow of order #REQ-8452',
        createdAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
      },
    });

    // Cập nhật tài khoản ví Stylist (Nhận được 637k chặng 1, còn khóa 1tr487k)
    await prisma.wallet.update({
      where: { id: stylistWallet.id },
      data: {
        availableBalance: { increment: 637500.00 },
        escrowLockedBalance: { decrement: 637500.00 },
      },
    });
  }

  console.log('✅ Đã nạp xong lịch sử đối soát và giao dịch tài chính.');

  // ==========================================
  // 5. ĐÁNH GIÁ (REVIEW) CŨ CỦA STYLIST (ĐỂ LÀM RÕ ratingAvg)
  // ==========================================

  // Tạo đơn hàng cũ đã hoàn tất
  const oldRequest = await prisma.stylingRequest.create({
    data: {
      code: 'REQ-3101',
      clientId: client.id,
      stylistId: stylist.id,
      title: 'Oversized Streetwear Autumn',
      briefText: 'Casual oversized look for university.',
      totalBudget: 1500000.00,
      status: RequestStatus.COMPLETED,
      createdAt: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000),
    },
  });

  // Đơn cũ đã duyệt xong hết 3 chặng
  await prisma.requestMilestone.createMany({
    data: [
      { id: 'old-m1', requestId: oldRequest.id, stageOrder: 1, title: 'Concept', percentage: 30, grossAmount: 450000.00, netPayout: 382500.00, status: MilestoneStatus.APPROVED },
      { id: 'old-m2', requestId: oldRequest.id, stageOrder: 2, title: 'Outfit', percentage: 30, grossAmount: 450000.00, netPayout: 382500.00, status: MilestoneStatus.APPROVED },
      { id: 'old-m3', requestId: oldRequest.id, stageOrder: 3, title: 'Final', percentage: 40, grossAmount: 600000.00, netPayout: 510000.00, status: MilestoneStatus.APPROVED },
    ],
  });

  // Review & Chụp ảnh thành quả từ đơn hàng cũ
  await prisma.review.create({
    data: {
      requestId: oldRequest.id,
      clientId: client.id,
      stylistId: stylist.id,
      rating: 5,
      comment: 'Super easy to pose with the skeletal guides! Outfits are perfect for my size and look amazing on camera. Maya was very helpful.',
      capturedImageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=600&q=80',
      poseMatchScore: 98.4,
    },
  });

  console.log('🎉 Toàn bộ dữ liệu mẫu (Seeding) đã được nạp thành công!');
}

main()
  .catch((e) => {
    console.error('❌ Lỗi khi chạy Seeding DB:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });