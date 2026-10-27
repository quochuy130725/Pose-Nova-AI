import 'package:flutter/material.dart';

/// Supported Languages in PoseNova AI
enum AppLanguage {
  vi, // Tiếng Việt
  en, // English
}

/// Global Reactive Language Controller
class AppLanguageController extends ChangeNotifier {
  static final AppLanguageController instance = AppLanguageController._internal();

  AppLanguageController._internal();

  AppLanguage _current = AppLanguage.vi;

  AppLanguage get current => _current;
  bool get isVietnamese => _current == AppLanguage.vi;
  bool get isEnglish => _current == AppLanguage.en;

  Locale get locale => _current == AppLanguage.vi
      ? const Locale('vi', 'VN')
      : const Locale('en', 'US');

  void setLanguage(AppLanguage language) {
    if (_current != language) {
      _current = language;
      notifyListeners();
    }
  }

  void toggleLanguage() {
    setLanguage(_current == AppLanguage.vi ? AppLanguage.en : AppLanguage.vi);
  }

  AppTranslations get t => AppTranslations.of(_current);
}

/// Comprehensive High-Fashion & Fintech Translations for PoseNova AI
class AppTranslations {
  final AppLanguage language;

  const AppTranslations._(this.language);

  static AppTranslations of(AppLanguage language) => AppTranslations._(language);

  bool get isVi => language == AppLanguage.vi;

  // --- Common & Global ---
  String get appTitle => 'PoseNova AI';
  String get brandAtelier => 'POSENOVA · ATELIER';
  String get switchLanguage => isVi ? 'Ngôn ngữ' : 'Language';
  String get langVi => 'VI';
  String get langEn => 'EN';
  String get authLabelUsername => isVi ? 'Tên đăng nhập / Email' : 'Username / Email';
  String get authLabelPassword => isVi ? 'Mật khẩu' : 'Password';

  // --- Role Selection / Demo Persona ---
  String get selectPersonaTitle => isVi ? 'Chọn Nhân Vật Trải Nghiệm' : 'Select Demo Persona';
  String get selectPersonaSubtitle => isVi
      ? 'Trải nghiệm quy trình Tư vấn Styling & Bảo chứng Ký quỹ Đa mốc từ cả hai vai trò.'
      : 'Experience the C2C AI Styling & Milestone Escrow workflow from both perspectives.';

  // Client Card
  String get clientViewBadge => isVi ? 'KHÁCH HÀNG' : 'CLIENT VIEW';
  String get clientName => 'Quốc Huy';
  String get clientRole => isVi ? 'Người Dùng • Khách Mua Thời Trang' : 'Regular User • Fashion Buyer';
  String get clientDesc => isVi
      ? 'Khám phá Lookbook xu hướng, tạo dáng chuẩn mẫu với Camera AI 30 FPS, và nghiệm thu giải ngân ký quỹ 3 giai đoạn bảo chứng.'
      : 'Explore trending Lookbooks, pose with 30 FPS AI Camera, and approve 3-stage milestone escrow payouts.';
  String get pillLookbookFeed => isVi ? 'Bảng Tin Lookbook' : 'Lookbook Feed';
  String get pillAiPoseCamera => isVi ? 'Camera AI 30 FPS' : '30 FPS AI Pose Camera';
  String get pillEscrowApproval => isVi ? 'Nghiệm Thu Ký Quỹ 3 Mốc' : '3-Stage Escrow Approval';
  String get enterAsClient => isVi ? 'VÀO VAI KHÁCH HÀNG →' : 'ENTER AS CLIENT →';

  // Stylist Card
  String get stylistStudioBadge => isVi ? 'STYLIST' : 'STYLIST STUDIO';
  String get stylistName => 'Maya Trần';
  String get stylistRole => isVi ? 'Stylist Xác Thực • 4.9★ (128 đánh giá)' : 'Verified Stylist • 4.9★ (128 reviews)';
  String get stylistDesc => isVi
      ? 'Nhận yêu cầu tư vấn, phối đồ cùng Gemini AI Co-pilot, bàn giao sản phẩm từng giai đoạn và rút doanh thu 85% Net về tài khoản ngân hàng.'
      : 'Receive requests, style with Gemini AI Co-pilot, deliver milestone deliverables, and withdraw 85% Net revenue to your bank.';
  String get pillGeminiCopilot => isVi ? 'Trợ Lý Phối Đồ Gemini AI' : 'Gemini AI Co-pilot';
  String get pillDeliverableUpload => isVi ? 'Bàn Giao Theo Mốc' : 'Milestone Deliverable Upload';
  String get pillCyberWallet => isVi ? 'Ví Số & Sổ Cái Minh Bạch' : 'Cyber Wallet & Ledger';
  String get enterAsStylist => isVi ? 'VÀO STUDIO STYLIST →' : 'ENTER AS STYLIST →';
  String get stage2ReviewTag => isVi ? 'DUYỆT GIAI ĐOẠN 02' : 'STAGE 02 REVIEW';

  String get openDebugDirectory => isVi
      ? 'PoseNova AI • Mở Danh Mục 8 Màn Hình SRS (Chế độ Debug)'
      : 'PoseNova AI • Open 8-Screen SRS Directory (Debug Mode)';

  // --- Shell Navigation & Quick Switch ---
  String get switchToStylist => isVi ? 'Góc Stylist ↗' : 'Stylist View ↗';
  String get switchToClient => isVi ? 'Góc Khách ↗' : 'Client View ↗';
  String get navAtelier => isVi ? 'Khám Phá' : 'Atelier';
  String get navPoseCamera => isVi ? 'Camera AI' : 'AI Pose';
  String get navMilestones => isVi ? 'Ký Quỹ Mốc' : 'Escrow';
  String get navInbox => isVi ? 'Hộp Thư' : 'Inbox';
  String get navWorkspace => isVi ? 'Dự Án' : 'Workspace';
  String get navWallet => isVi ? 'Ví Tiền' : 'Wallet';

  // Shell Top Titles
  String get titleDiscovery => isVi ? 'PoseNova Atelier' : 'PoseNova Atelier';
  String get titleCamera => isVi ? 'Camera AI Khớp Dáng 30 FPS' : '30 FPS AI Pose Camera';
  String get titleMilestone => isVi ? 'Theo Dõi Tiến Độ Ký Quỹ (30/30/40)' : 'Milestone Tracking (30/30/40)';
  String get titleStylistInbox => isVi ? 'Hộp Thư Khách Hàng' : 'Stylist Client Requests';
  String get titleStylistWorkspace => isVi ? 'Bàn Giao Sản Phẩm Dự Án' : 'Milestone Project Workspace';
  String get titleStylistWallet => isVi ? 'Ví Doanh Thu & Sổ Cái' : 'Stylist Wallet & Escrow Ledger';

  // --- Discovery Feed (Screen 01) ---
  String get collectionTitle => isVi ? 'Áo Khoác Urban Tech' : 'Urban Tech Jacket';
  String get lookbookDesc => isVi
      ? 'Form dáng oversize phối bảng màu tương phản cao, kết hợp tư thế đứng nghiêng góc thấp phóng khoáng.'
      : 'Oversized silhouette with high-contrast color palette, pairing with a dynamic low-angle standing pose.';
  String get recreatePoseBtn => isVi ? 'Khớp Dáng AI' : 'Recreate AI Pose';
  String get bookStylistBtn => isVi ? 'Đặt Stylist' : 'Book Stylist';
  String get aiPoseReadyBadge => isVi ? '⚡ SẴN SÀNG KHỚP DÁNG' : '⚡ AI POSE READY';
  String get stylistBadge => isVi ? 'STYLIST' : 'STYLIST';
  String get verifiedAtelier => isVi ? 'Xưởng Thời Trang Xác Thực' : 'Verified Atelier';

  // --- Milestone Workspace (Screen 06 - Màn hình đinh) ---
  String get topEscrowBanner => isVi
      ? '100% BẢO CHỨNG KÝ QUỸ • 2.500.000₫'
      : '100% ESCROW SECURED • 2.500.000₫';
  String get escrowContractCode => isVi ? 'Hợp đồng: #REQ-8452' : 'Contract: #REQ-8452';
  String get stage01Approved => isVi ? '01 Đã Duyệt' : '01 Approved';
  String get stage02Active => isVi ? '02 Đang Làm' : '02 Active';
  String get stage03Review => isVi ? '03 Nghiệm Thu' : '03 Review';

  String get nodeStage01 => isVi ? 'Mốc 01 • Đã Duyệt' : 'Stage 01 • Approved';
  String get nodeStage02 => isVi ? 'Mốc 02 • Đang Duyệt' : 'Stage 02 • Reviewing';
  String get nodeStage03 => isVi ? 'Mốc 03 • Khóa 40%' : 'Stage 03 • Locked 40%';
  String nodeQuota(int count, int max) => isVi ? 'Lượt sửa $count/$max' : 'Quota $count/$max';

  String get approveStage2Btn => isVi
      ? 'APPROVE & RELEASE 30% PAYOUT →'
      : 'APPROVE & RELEASE 30% PAYOUT →';
  String get stage2ApprovedContinueBtn => isVi
      ? 'STAGE 02 APPROVED • CONTINUE →'
      : 'STAGE 02 APPROVED • CONTINUE →';
  String requestRevisionBtn(int count, int max) => isVi
      ? 'Yêu cầu chỉnh sửa ($count/$max)'
      : 'Request Revision ($count/$max)';
  String get openDisputeBtn => isVi
      ? '⚠️ Mở Khiếu Nại Hoàn Tiền'
      : '⚠️ Open Dispute Refund';

  // --- Stylist Wallet (Screen 08) ---
  String get walletTitle => isVi ? 'Ví Điện Tử Stylist' : 'Stylist Cyber Wallet';
  String get availableBalance => isVi ? 'SỐ DƯ KHẢ DỤNG' : 'AVAILABLE BALANCE';
  String get escrowLocked => isVi ? 'ĐANG KHÓA KÝ QUỸ' : 'ESCROW LOCKED';
  String get readyToPayout => isVi ? '85% Net • Sẵn sàng rút về ngân hàng' : '85% Net • Ready to payout';
  String get pendingMilestones => isVi ? 'Đang giữ theo các mốc' : 'Pending milestones';
  String get withdrawToBank => isVi ? 'WITHDRAW TO BANK →' : 'WITHDRAW TO BANK →';
  String get escrowLedgerTitle => isVi ? 'Sổ Cái Đối Soát Ký Quỹ' : 'Escrow Reconciliation Ledger';

  // --- Escrow Checkout (Screen 05) ---
  String get escrowCheckoutTitle => isVi ? 'Phiếu Ký Quỹ SePay VietQR' : 'SePay VietQR Escrow Checkout';
  String get simulateWebhookBtn => isVi
      ? 'SIMULATE SEPAY WEBHOOK SUCCESS ⚡'
      : 'SIMULATE SEPAY WEBHOOK SUCCESS ⚡';
  String get verifyingWebhook => isVi ? 'ĐANG XÁC THỰC WEBHOOK...' : 'VERIFYING WEBHOOK...';

  // --- Dispute Review (Screen 07) ---
  String get disputeTitle => isVi ? 'Đơn Khiếu Nại Ký Quỹ' : 'Escrow Dispute Center';

  // --- Auth / Login Screen ---
  String get authBrandSubtitle => 'Managed C2C Fashion Styling & AI Pose Matching';
  String get authCardHeading => isVi ? 'Đăng Nhập Tài Khoản' : 'Account Login';
  String get authDividerOrDemo => isVi ? 'HOẶC CHỌN VAI TRÒ DEMO' : 'OR SELECT DEMO PERSONA';
  String get authClientLoginBtn => isVi ? 'ĐĂNG NHẬP KHÁCH HÀNG (USER) →' : 'CLIENT LOGIN (USER) →';
  String get authStylistLoginBtn => isVi ? 'ĐĂNG NHẬP STYLIST (MAYA TRẦN) →' : 'STYLIST LOGIN (MAYA TRẦN) →';
  String get authFooterSecurity => 'PoseNova Atelier Security • Protected by SePay Escrow Protocol';
}
