import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported application languages
enum AppLanguage {
  vi,
  en,
}

/// Abstract contract of all translatable strings in PoseNova AI
abstract class AppStrings {
  static AppStrings of(BuildContext context) {
    return LocaleController.instance.strings;
  }

  static AppStrings get current => LocaleController.instance.strings;

  bool get isVi;
  String get langCode;

  // --- 1. Shell & Navigation ---
  String get appTitle;
  String get brandAtelier;
  String get navDiscovery;
  String get navPoseCamera;
  String get navEscrowWorkspace;
  String get navInbox;
  String get navWallet;
  String get navClient;
  String get navStylist;
  String get headerSwitchToStylist;
  String get headerSwitchToClient;
  String get languageName;
  String get switchLanguage;
  String get langVi;
  String get langEn;

  // --- 2. Discovery Feed ---
  String get discoveryHeroTitle;
  String get discoveryHeroSubtitle;
  String get discoveryCustomStylingTitle;
  String get discoveryCustomStylingSubtitle;
  String get discoveryTryAiCameraBtn;
  String get discoveryRequestStylingBtn;
  String get discoveryCuratedOutfits;
  String get discoveryAllLooks;
  String get discoveryLooksReady;
  String get recreatePoseBtn;
  String get bookStylistBtn;
  String get aiPoseReadyBadge;
  String get verifiedAtelier;
  String itemsCount(int count);

  // --- 3. Camera AI & Pose Coach ---
  String get cameraDetectingPose;
  String get cameraStepBackShoulders;
  String get cameraRaiseElbow;
  String get cameraAlignArms;
  String get cameraBalanceShoulders;
  String get cameraPerfectPose;
  String get cameraPoseMatched;
  String get cameraTakePhoto;
  String get cameraCapturingHold;
  String get cameraOnDevicePrivacy;
  String get cameraRetake;
  String get cameraSavePhoto;
  String get cameraSavedSuccess;
  String get cameraExpand;
  String get cameraCollapse;
  String get cameraGuideSkeleton;
  String get cameraUserSkeleton;
  String get cameraMatchScore;

  // --- 4. Styling Brief & Request ---
  String get stylingBriefTitle;
  String get conceptAndOccasion;
  String get geminiEnhanceBtn;
  String get colorPaletteTitle;
  String get totalEscrowBudget;
  String get escrowSecured100;
  String get stageConcept;
  String get stageAiTryOn;
  String get stageFinalDelivery;
  String get recommendedStylist;
  String get submitStylingRequestBtn;
  String get quickBudgetTestSePay;
  String get confirmEscrowDepositBtn;
  String get customBudgetDialogTitle;
  String get customBudgetHint;
  String get applyBtn;
  String get cancelBtn;

  // --- 5. Escrow Milestone Workspace ---
  String get milestoneContract;
  String get totalEscrow;
  String get stage;
  String get statusApproved;
  String get statusInReview;
  String get statusActive;
  String get statusLocked;
  String get statusRevisionRequested;
  String get statusDisputed;
  String get uploadLookbookHeader;
  String get uploadLookbookSubtitle;
  String get pickPhotoGallery;
  String get landmarksReadyBadge;
  String get toggleSkeletonBtn;
  String get changePhotoBtn;
  String get affiliateProductLink;
  String get attachPurchaseLink;
  String get stylistNotes;
  String publishAndSubmitStage(int stage);
  String get stylistSubmittedAwaitingReview;
  String get stageAlreadyApproved;
  String approveAndReleaseBtn(String amount);
  String get requestRevisionBtn;
  String get freezeEscrowDisputeBtn;
  String revisionCountText(int count, int max);

  // --- 6. Stylist Wallet & Ledger ---
  String get walletScreenTitle;
  String get availableBalanceLabel;
  String get escrowLockedLabel;
  String get readyToWithdrawDesc;
  String get heldInMilestonesDesc;
  String get withdrawToBankBtn;
  String get reconciliationLedgerTitle;
  String get platformFee;
  String get milestoneRelease;
  String get escrowDeposit;
  String get badgeReleased;
  String get badgeLocked;
  String get today;
  String get justNow;
  String get withdrawSuccessMsg;

  // --- 7. Stylist Inbox ---
  String get stylistInboxTitle;
  String get stylistInboxSubtitle;
  String get escrowDetailsBtn;
  String submitStage1Btn(String amount);

  // --- 8. Auth & Profiles ---
  String get authLogin;
  String get authSignUp;
  String get authEmail;
  String get authPassword;
  String get authFullName;
  String get authRoleSelect;
  String get authRoleClient;
  String get authRoleStylist;
  String get authSubmitLogin;
  String get authSubmitSignUp;
  String get authQuickLoginHeader;
  String get authLabelUsername;
  String get authLabelPassword;
  String get authBrandSubtitle;
  String get authCardHeading;
  String get authDividerOrDemo;
  String get authClientLoginBtn;
  String get authStylistLoginBtn;
  String get authFooterSecurity;

  // --- 9. Role Selection & Legacy Backwards Compatibility ---
  String get selectPersonaTitle;
  String get selectPersonaSubtitle;
  String get clientViewBadge;
  String get clientName;
  String get clientRole;
  String get clientDesc;
  String get pillLookbookFeed;
  String get pillAiPoseCamera;
  String get pillEscrowApproval;
  String get enterAsClient;
  String get stylistStudioBadge;
  String get stylistName;
  String get stylistRole;
  String get stylistDesc;
  String get pillGeminiCopilot;
  String get pillDeliverableUpload;
  String get pillCyberWallet;
  String get enterAsStylist;
  String get stage2ReviewTag;
  String get openDebugDirectory;
  String get switchToStylist;
  String get switchToClient;
  String get navAtelier;
  String get navMilestones;
  String get navWorkspace;
  String get titleDiscovery;
  String get titleCamera;
  String get titleMilestone;
  String get titleStylistInbox;
  String get titleStylistWorkspace;
  String get titleStylistWallet;
  String get collectionTitle;
  String get lookbookDesc;
  String get stylistBadge;
  String get topEscrowBanner;
  String get escrowContractCode;
  String get stage01Approved;
  String get stage02Active;
  String get stage03Review;
  String get nodeStage01;
  String get nodeStage02;
  String get nodeStage03;
  String nodeQuota(int count, int max);
  String get approveStage2Btn;
  String get stage2ApprovedContinueBtn;
  String get openDisputeBtn;
  String get walletTitle;
  String get availableBalance;
  String get escrowLocked;
  String get readyToPayout;
  String get pendingMilestones;
  String get withdrawToBank;
  String get escrowLedgerTitle;
  String get escrowCheckoutTitle;
  String get simulateWebhookBtn;
  String get verifyingWebhook;
  String get disputeTitle;
}

/// Vietnamese translation implementation
class AppStringsVi extends AppStrings {
  @override
  bool get isVi => true;

  @override
  String get langCode => 'VI';

  @override
  String get appTitle => 'PoseNova AI';

  @override
  String get brandAtelier => "PoseNova • Fashion Atelier '26";

  @override
  String get navDiscovery => 'Khám phá';

  @override
  String get navPoseCamera => 'Camera AI';

  @override
  String get navEscrowWorkspace => 'Ký quỹ / Dự án';

  @override
  String get navInbox => 'Hộp thư';

  @override
  String get navWallet => 'Ví tiền';

  @override
  String get navClient => 'Khách hàng';

  @override
  String get navStylist => 'Chuyên viên phối đồ';

  @override
  String get headerSwitchToStylist => 'Góc Stylist ↗';

  @override
  String get headerSwitchToClient => 'Góc Khách ↗';

  @override
  String get languageName => 'Tiếng Việt';

  @override
  String get switchLanguage => 'Ngôn ngữ';

  @override
  String get langVi => 'VI';

  @override
  String get langEn => 'EN';

  @override
  String get discoveryHeroTitle => 'Định hình phong cách thường ngày';

  @override
  String get discoveryHeroSubtitle => 'Khám phá & Khớp dáng thời trang chuẩn AI';

  @override
  String get discoveryCustomStylingTitle => 'Cần Phối Đồ Riêng Theo Vóc Dáng?';

  @override
  String get discoveryCustomStylingSubtitle => 'Gửi yêu cầu cho Stylist · Bảo vệ 100% qua Ký quỹ Escrow';

  @override
  String get discoveryTryAiCameraBtn => 'Chụp Dáng AI →';

  @override
  String get discoveryRequestStylingBtn => 'Gửi Yêu Cầu Phối Đồ →';

  @override
  String get discoveryCuratedOutfits => 'Đồ Phối Tuyển Chọn';

  @override
  String get discoveryAllLooks => 'Tất cả';

  @override
  String get discoveryLooksReady => 'Trang phục sẵn sàng';

  @override
  String get recreatePoseBtn => 'Khớp Dáng AI';

  @override
  String get bookStylistBtn => 'Đặt Stylist';

  @override
  String get aiPoseReadyBadge => 'SẴN SÀNG KHỚP DÁNG';

  @override
  String get verifiedAtelier => 'Xưởng Thời Trang Xác Thực';

  @override
  String itemsCount(int count) => '$count món đồ';

  @override
  String get cameraDetectingPose => 'Đang tìm dáng người...';

  @override
  String get cameraStepBackShoulders => 'Lùi lại để thấy rõ hai vai';

  @override
  String get cameraRaiseElbow => 'Nâng khuỷu tay lên theo khung nét đứt';

  @override
  String get cameraAlignArms => 'Đưa cánh tay khớp vào đường nét đứt';

  @override
  String get cameraBalanceShoulders => 'Giữ cân bằng hai vai đối diện ống kính';

  @override
  String get cameraPerfectPose => 'Tư thế hoàn hảo! Giữ yên để chụp...';

  @override
  String get cameraPoseMatched => 'Đã khớp dáng';

  @override
  String get cameraTakePhoto => 'Chụp ảnh';

  @override
  String get cameraCapturingHold => 'Đang chụp 1.2s (Giữ yên dáng)...';

  @override
  String get cameraOnDevicePrivacy => 'Ảnh chỉ lưu trên máy, không tải lên cloud';

  @override
  String get cameraRetake => 'Chụp lại';

  @override
  String get cameraSavePhoto => 'Hoàn tất & Lưu ảnh';

  @override
  String get cameraSavedSuccess => 'Đã lưu ảnh vào Thư viện PoseNova AI!';

  @override
  String get cameraExpand => 'Phóng to';

  @override
  String get cameraCollapse => 'Thu nhỏ';

  @override
  String get cameraGuideSkeleton => 'Khung Mẫu Nét Đứt';

  @override
  String get cameraUserSkeleton => 'Khung Xương AI';

  @override
  String get cameraMatchScore => 'Độ khớp';

  @override
  String get stylingBriefTitle => 'Bản Đặc Tả Yêu Cầu';

  @override
  String get conceptAndOccasion => 'Khái niệm & Dịp mặc';

  @override
  String get geminiEnhanceBtn => 'Tối ưu Brief cùng Gemini';

  @override
  String get colorPaletteTitle => 'Bảng màu AI';

  @override
  String get totalEscrowBudget => 'Tổng Ngân Sách Ký Quỹ';

  @override
  String get escrowSecured100 => 'Được bảo vệ 100% qua Escrow';

  @override
  String get stageConcept => 'Khái niệm';

  @override
  String get stageAiTryOn => 'Thử đồ AI';

  @override
  String get stageFinalDelivery => 'Bàn giao';

  @override
  String get recommendedStylist => 'Gợi ý Stylist';

  @override
  String get submitStylingRequestBtn => 'Gửi Yêu Cầu Phối Đồ →';

  @override
  String get quickBudgetTestSePay => '2.000₫ (Test SePay)';

  @override
  String get confirmEscrowDepositBtn => 'Xác nhận đã đặt cọc (Kích hoạt Escrow)';

  @override
  String get customBudgetDialogTitle => 'Nhập Ngân Sách Tùy Chỉnh';

  @override
  String get customBudgetHint => 'Nhập số tiền (VND, tối thiểu 2.000₫)';

  @override
  String get applyBtn => 'ÁP DỤNG';

  @override
  String get cancelBtn => 'HỦY';

  @override
  String get milestoneContract => 'Hợp đồng Ký quỹ';

  @override
  String get totalEscrow => 'Tổng cọc';

  @override
  String get stage => 'Chặng';

  @override
  String get statusApproved => 'Đã duyệt & Giải ngân';

  @override
  String get statusInReview => 'Đang thực hiện · Chờ duyệt';

  @override
  String get statusActive => 'Đang thực hiện';

  @override
  String get statusLocked => 'Đã khóa';

  @override
  String get statusRevisionRequested => 'Yêu cầu chỉnh sửa';

  @override
  String get statusDisputed => 'Đang khiếu nại';

  @override
  String get uploadLookbookHeader => 'Tải ảnh sản phẩm & Dáng mẫu';

  @override
  String get uploadLookbookSubtitle => 'Hỗ trợ JPG, PNG · Tự động trích xuất 33 điểm mốc AI';

  @override
  String get pickPhotoGallery => 'Chọn ảnh từ thư viện';

  @override
  String get landmarksReadyBadge => 'Khung xương 33 điểm AI đã sẵn sàng';

  @override
  String get toggleSkeletonBtn => 'Bật/Tắt khung xương';

  @override
  String get changePhotoBtn => 'Đổi ảnh';

  @override
  String get affiliateProductLink => 'Link sản phẩm Affiliate';

  @override
  String get attachPurchaseLink => 'Gắn link mua hàng';

  @override
  String get stylistNotes => 'Ghi chú từ Stylist';

  @override
  String publishAndSubmitStage(int stage) => 'Xuất bản & Gửi duyệt (Stage 0$stage) →';

  @override
  String get stylistSubmittedAwaitingReview => 'ĐÃ GỬI DUYỆT · CHỜ KHÁCH HÀNG NGHIỆM THU';

  @override
  String get stageAlreadyApproved => 'Chặng này đã hoàn tất và giải ngân';

  @override
  String approveAndReleaseBtn(String amount) => 'DUYỆT & GIẢI NGÂN $amount →';

  @override
  String get requestRevisionBtn => 'Yêu cầu chỉnh sửa';

  @override
  String get freezeEscrowDisputeBtn => 'Đóng băng Ký quỹ & Khiếu nại';

  @override
  String revisionCountText(int count, int max) => 'Lần sửa: $count / $max (Miễn phí)';

  @override
  String get walletScreenTitle => 'Ví Điện Tử Stylist';

  @override
  String get availableBalanceLabel => 'Số dư khả dụng';

  @override
  String get escrowLockedLabel => 'Đang khóa ký quỹ';

  @override
  String get readyToWithdrawDesc => 'Sẵn sàng rút về tài khoản ngân hàng';

  @override
  String get heldInMilestonesDesc => 'Đang giữ theo các mốc hợp đồng';

  @override
  String get withdrawToBankBtn => 'Rút tiền về ngân hàng →';

  @override
  String get reconciliationLedgerTitle => 'Sổ Cái Đối Soát Ký Quỹ';

  @override
  String get platformFee => 'Phí sàn';

  @override
  String get milestoneRelease => 'Giải ngân mốc';

  @override
  String get escrowDeposit => 'Nạp tiền cọc ký quỹ';

  @override
  String get badgeReleased => 'Đã giải ngân';

  @override
  String get badgeLocked => 'Đang đóng băng';

  @override
  String get today => 'Hôm nay';

  @override
  String get justNow => 'Vừa xong';

  @override
  String get withdrawSuccessMsg => 'Yêu cầu rút tiền thành công!';

  @override
  String get stylistInboxTitle => 'Đơn Phối Đồ Khách Đặt';

  @override
  String get stylistInboxSubtitle => 'Thực nhận 85% Net · Nộp bàn giao 3 chặng';

  @override
  String get escrowDetailsBtn => 'Chi tiết Ký quỹ';

  @override
  String submitStage1Btn(String amount) => 'Nộp Chặng 1 ($amount) →';

  @override
  String get authLogin => 'Đăng Nhập';

  @override
  String get authSignUp => 'Tạo Tài Khoản';

  @override
  String get authEmail => 'Tên đăng nhập / Email';

  @override
  String get authPassword => 'Mật khẩu';

  @override
  String get authFullName => 'Họ và Tên';

  @override
  String get authRoleSelect => 'Vai Trò Tài Khoản';

  @override
  String get authRoleClient => 'Khách Hàng (Client)';

  @override
  String get authRoleStylist => 'Stylist Studio';

  @override
  String get authSubmitLogin => 'Đăng Nhập Vào Hệ Thống →';

  @override
  String get authSubmitSignUp => 'Tạo Tài Khoản Mới →';

  @override
  String get authQuickLoginHeader => 'HOẶC ĐĂNG NHẬP NHANH';

  @override
  String get authLabelUsername => 'Tên đăng nhập / Email';

  @override
  String get authLabelPassword => 'Mật khẩu';

  @override
  String get authBrandSubtitle => 'Virtual Try-On & Managed Escrow Styling Atelier';

  @override
  String get authCardHeading => 'Đăng Nhập Tài Khoản';

  @override
  String get authDividerOrDemo => 'HOẶC CHỌN VAI TRÒ DEMO';

  @override
  String get authClientLoginBtn => 'ĐĂNG NHẬP KHÁCH HÀNG (USER) →';

  @override
  String get authStylistLoginBtn => 'ĐĂNG NHẬP STYLIST (MAYA TRẦN) →';

  @override
  String get authFooterSecurity => 'Bảo mật bởi PoseNova AI & Giao thức Ký quỹ SePay';

  @override
  String get selectPersonaTitle => 'Chọn Nhân Vật Trải Nghiệm';

  @override
  String get selectPersonaSubtitle => 'Trải nghiệm quy trình Tư vấn Styling & Bảo chứng Ký quỹ Đa mốc từ cả hai vai trò.';

  @override
  String get clientViewBadge => 'KHÁCH HÀNG';

  @override
  String get clientName => 'Quốc Huy';

  @override
  String get clientRole => 'Người Dùng · Khách Mua Thời Trang';

  @override
  String get clientDesc => 'Khám phá Lookbook xu hướng, tạo dáng chuẩn mẫu với Camera AI 30 FPS, và nghiệm thu giải ngân ký quỹ 3 giai đoạn bảo chứng.';

  @override
  String get pillLookbookFeed => 'Bảng Tin Lookbook';

  @override
  String get pillAiPoseCamera => 'Camera AI 30 FPS';

  @override
  String get pillEscrowApproval => 'Nghiệm Thu Ký Quỹ 3 Mốc';

  @override
  String get enterAsClient => 'VÀO VAI KHÁCH HÀNG →';

  @override
  String get stylistStudioBadge => 'STYLIST';

  @override
  String get stylistName => 'Maya Trần';

  @override
  String get stylistRole => 'Stylist Xác Thực · 4.9★ (128 đánh giá)';

  @override
  String get stylistDesc => 'Nhận yêu cầu tư vấn, phối đồ cùng Gemini AI Co-pilot, bàn giao sản phẩm từng giai đoạn và rút doanh thu 85% Net về tài khoản ngân hàng.';

  @override
  String get pillGeminiCopilot => 'Trợ Lý Phối Đồ Gemini AI';

  @override
  String get pillDeliverableUpload => 'Bàn Giao Theo Mốc';

  @override
  String get pillCyberWallet => 'Ví Số & Sổ Cái Minh Bạch';

  @override
  String get enterAsStylist => 'VÀO STUDIO STYLIST →';

  @override
  String get stage2ReviewTag => 'DUYỆT GIAI ĐOẠN 02';

  @override
  String get openDebugDirectory => 'PoseNova AI · Mở Danh Mục 8 Màn Hình SRS (Chế độ Debug)';

  @override
  String get switchToStylist => 'Góc Stylist ↗';

  @override
  String get switchToClient => 'Góc Khách ↗';

  @override
  String get navAtelier => 'Khám Phá';

  @override
  String get navMilestones => 'Ký Quỹ Mốc';

  @override
  String get navWorkspace => 'Dự Án';

  @override
  String get titleDiscovery => 'PoseNova Atelier';

  @override
  String get titleCamera => 'Camera AI Khớp Dáng 30 FPS';

  @override
  String get titleMilestone => 'Theo Dõi Tiến Độ Ký Quỹ (30/30/40)';

  @override
  String get titleStylistInbox => 'Hộp Thư Khách Hàng';

  @override
  String get titleStylistWorkspace => 'Bàn Giao Sản Phẩm Dự Án';

  @override
  String get titleStylistWallet => 'Ví Doanh Thu & Sổ Cái';

  @override
  String get collectionTitle => 'Áo Khoác Urban Tech';

  @override
  String get lookbookDesc => 'Form dáng oversize phối bảng màu tương phản cao, kết hợp tư thế đứng nghiêng góc thấp phóng khoáng.';

  @override
  String get stylistBadge => 'STYLIST';

  @override
  String get topEscrowBanner => '100% BẢO CHỨNG KÝ QUỸ';

  @override
  String get escrowContractCode => 'Hợp Đồng Ký Quỹ';

  @override
  String get stage01Approved => '01 Đã Duyệt';

  @override
  String get stage02Active => '02 Đang Làm';

  @override
  String get stage03Review => '03 Nghiệm Thu';

  @override
  String get nodeStage01 => 'Mốc 01 · Đã Duyệt';

  @override
  String get nodeStage02 => 'Mốc 02 · Đang Duyệt';

  @override
  String get nodeStage03 => 'Mốc 03 · Khóa 40%';

  @override
  String nodeQuota(int count, int max) => 'Lượt sửa $count/$max';

  @override
  String get approveStage2Btn => 'DUYỆT & GIẢI NGÂN CHẶNG 02 →';

  @override
  String get stage2ApprovedContinueBtn => 'STAGE 02 APPROVED · CONTINUE →';

  @override
  String get openDisputeBtn => 'Mở Khiếu Nại Hoàn Tiền';

  @override
  String get walletTitle => 'Ví Điện Tử Stylist';

  @override
  String get availableBalance => 'SỐ DƯ KHẢ DỤNG';

  @override
  String get escrowLocked => 'ĐANG KHÓA KÝ QUỸ';

  @override
  String get readyToPayout => '85% Net · Sẵn sàng rút về ngân hàng';

  @override
  String get pendingMilestones => 'Đang giữ theo các mốc';

  @override
  String get withdrawToBank => 'RÚT TIỀN VỀ NGÂN HÀNG →';

  @override
  String get escrowLedgerTitle => 'Sổ Cái Đối Soát Ký Quỹ';

  @override
  String get escrowCheckoutTitle => 'Phiếu Ký Quỹ SePay VietQR';

  @override
  String get simulateWebhookBtn => 'XÁC NHẬN ĐÃ CHUYỂN KHOẢN (KÍCH HOẠT ESCROW)';

  @override
  String get verifyingWebhook => 'ĐANG XÁC THỰC THANH TOÁN...';

  @override
  String get disputeTitle => 'Đơn Khiếu Nại Ký Quỹ';
}

/// English translation implementation
class AppStringsEn extends AppStrings {
  @override
  bool get isVi => false;

  @override
  String get langCode => 'EN';

  @override
  String get appTitle => 'PoseNova AI';

  @override
  String get brandAtelier => "PoseNova • Fashion Atelier '26";

  @override
  String get navDiscovery => 'Discovery';

  @override
  String get navPoseCamera => 'Pose Camera';

  @override
  String get navEscrowWorkspace => 'Escrow Workspace';

  @override
  String get navInbox => 'Inbox';

  @override
  String get navWallet => 'Wallet';

  @override
  String get navClient => 'Client';

  @override
  String get navStylist => 'Stylist';

  @override
  String get headerSwitchToStylist => 'Stylist View ↗';

  @override
  String get headerSwitchToClient => 'Client View ↗';

  @override
  String get languageName => 'English';

  @override
  String get switchLanguage => 'Language';

  @override
  String get langVi => 'VI';

  @override
  String get langEn => 'EN';

  @override
  String get discoveryHeroTitle => 'Elevate Your Everyday Style';

  @override
  String get discoveryHeroSubtitle => 'Explore & Match Your Next Iconic Pose';

  @override
  String get discoveryCustomStylingTitle => 'Need Custom Personal Styling?';

  @override
  String get discoveryCustomStylingSubtitle => 'Send brief to Stylist · 100% Escrow Protected';

  @override
  String get discoveryTryAiCameraBtn => 'Try AI Camera →';

  @override
  String get discoveryRequestStylingBtn => 'Request Styling →';

  @override
  String get discoveryCuratedOutfits => 'Curated Outfits';

  @override
  String get discoveryAllLooks => 'All Looks';

  @override
  String get discoveryLooksReady => 'Looks Ready';

  @override
  String get recreatePoseBtn => 'Recreate AI Pose';

  @override
  String get bookStylistBtn => 'Book Stylist';

  @override
  String get aiPoseReadyBadge => 'AI POSE READY';

  @override
  String get verifiedAtelier => 'Verified Fashion Atelier';

  @override
  String itemsCount(int count) => '$count Items';

  @override
  String get cameraDetectingPose => 'Detecting pose...';

  @override
  String get cameraStepBackShoulders => 'Step back to show both shoulders';

  @override
  String get cameraRaiseElbow => 'Raise elbow to match guide';

  @override
  String get cameraAlignArms => 'Align arms with target outline';

  @override
  String get cameraBalanceShoulders => 'Keep shoulders level and facing camera';

  @override
  String get cameraPerfectPose => 'Perfect pose! Hold still to capture...';

  @override
  String get cameraPoseMatched => 'Pose Matched';

  @override
  String get cameraTakePhoto => 'Take a Picture';

  @override
  String get cameraCapturingHold => 'Capturing in 1.2s (Hold still)...';

  @override
  String get cameraOnDevicePrivacy => 'Processed on-device only';

  @override
  String get cameraRetake => 'Retake';

  @override
  String get cameraSavePhoto => 'Save Photo';

  @override
  String get cameraSavedSuccess => 'Saved photo to PoseNova AI Gallery!';

  @override
  String get cameraExpand => 'Expand';

  @override
  String get cameraCollapse => 'Collapse';

  @override
  String get cameraGuideSkeleton => 'Ghost Skeleton';

  @override
  String get cameraUserSkeleton => 'AI Skeleton';

  @override
  String get cameraMatchScore => 'Match Score';

  @override
  String get stylingBriefTitle => 'Styling Brief';

  @override
  String get conceptAndOccasion => 'Concept & Occasion';

  @override
  String get geminiEnhanceBtn => 'Gemini Co-pilot Enhance';

  @override
  String get colorPaletteTitle => 'AI Color Palette';

  @override
  String get totalEscrowBudget => 'Total Escrow Budget';

  @override
  String get escrowSecured100 => '100% Escrow Protected';

  @override
  String get stageConcept => 'Concept';

  @override
  String get stageAiTryOn => 'AI Try-On';

  @override
  String get stageFinalDelivery => 'Final Delivery';

  @override
  String get recommendedStylist => 'Recommended Stylist';

  @override
  String get submitStylingRequestBtn => 'Submit Styling Request →';

  @override
  String get quickBudgetTestSePay => '2,000₫ (Test SePay)';

  @override
  String get confirmEscrowDepositBtn => 'Confirm Deposit (Activate Escrow)';

  @override
  String get customBudgetDialogTitle => 'Enter Custom Budget';

  @override
  String get customBudgetHint => 'Enter amount (VND, min 2,000₫)';

  @override
  String get applyBtn => 'APPLY';

  @override
  String get cancelBtn => 'CANCEL';

  @override
  String get milestoneContract => 'Milestone Contract';

  @override
  String get totalEscrow => 'Total Escrow';

  @override
  String get stage => 'Stage';

  @override
  String get statusApproved => 'Approved & Released';

  @override
  String get statusInReview => 'Active · Ready to Review';

  @override
  String get statusActive => 'Active';

  @override
  String get statusLocked => 'Locked';

  @override
  String get statusRevisionRequested => 'Revision Requested';

  @override
  String get statusDisputed => 'Disputed';

  @override
  String get uploadLookbookHeader => 'Upload Lookbook Photo & Pose';

  @override
  String get uploadLookbookSubtitle => 'Supports JPG, PNG · Auto-extracts 33 AI Pose Landmarks';

  @override
  String get pickPhotoGallery => 'Pick Photo from Gallery';

  @override
  String get landmarksReadyBadge => '33 AI Pose Landmarks Ready';

  @override
  String get toggleSkeletonBtn => 'Skeleton';

  @override
  String get changePhotoBtn => 'Change';

  @override
  String get affiliateProductLink => 'Affiliate Product Link';

  @override
  String get attachPurchaseLink => 'Attach Purchase Link';

  @override
  String get stylistNotes => 'Stylist Notes';

  @override
  String publishAndSubmitStage(int stage) => 'Publish & Submit (Stage 0$stage) →';

  @override
  String get stylistSubmittedAwaitingReview => 'SUBMITTED · AWAITING CLIENT REVIEW';

  @override
  String get stageAlreadyApproved => 'This stage is completed and paid out';

  @override
  String approveAndReleaseBtn(String amount) => 'APPROVE & RELEASE $amount →';

  @override
  String get requestRevisionBtn => 'Request Revision';

  @override
  String get freezeEscrowDisputeBtn => 'Freeze Escrow & Open Dispute';

  @override
  String revisionCountText(int count, int max) => 'Revisions: $count / $max (Free)';

  @override
  String get walletScreenTitle => 'Stylist Digital Wallet';

  @override
  String get availableBalanceLabel => 'Available Balance';

  @override
  String get escrowLockedLabel => 'Escrow Locked Balance';

  @override
  String get readyToWithdrawDesc => 'Ready to withdraw to bank';

  @override
  String get heldInMilestonesDesc => 'Held across contract milestones';

  @override
  String get withdrawToBankBtn => 'Withdraw to Bank →';

  @override
  String get reconciliationLedgerTitle => 'Escrow Reconciliation Ledger';

  @override
  String get platformFee => 'Platform Fee';

  @override
  String get milestoneRelease => 'Milestone Release';

  @override
  String get escrowDeposit => 'Escrow Deposit';

  @override
  String get badgeReleased => 'Released';

  @override
  String get badgeLocked => 'Locked';

  @override
  String get today => 'Today';

  @override
  String get justNow => 'Just now';

  @override
  String get withdrawSuccessMsg => 'Withdrawal request successful!';

  @override
  String get stylistInboxTitle => 'Client Styling Orders';

  @override
  String get stylistInboxSubtitle => '85% Net Payout · 3-Stage Deliverables';

  @override
  String get escrowDetailsBtn => 'Escrow Details';

  @override
  String submitStage1Btn(String amount) => 'Submit Stage 1 ($amount) →';

  @override
  String get authLogin => 'Sign In';

  @override
  String get authSignUp => 'Sign Up';

  @override
  String get authEmail => 'Username / Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authFullName => 'Full Name';

  @override
  String get authRoleSelect => 'Account Role';

  @override
  String get authRoleClient => 'Client';

  @override
  String get authRoleStylist => 'Stylist Studio';

  @override
  String get authSubmitLogin => 'Sign In to System →';

  @override
  String get authSubmitSignUp => 'Create Account →';

  @override
  String get authQuickLoginHeader => 'OR QUICK LOGIN';

  @override
  String get authLabelUsername => 'Username / Email';

  @override
  String get authLabelPassword => 'Password';

  @override
  String get authBrandSubtitle => 'Virtual Try-On & Managed Escrow Styling Atelier';

  @override
  String get authCardHeading => 'Account Login';

  @override
  String get authDividerOrDemo => 'OR SELECT DEMO PERSONA';

  @override
  String get authClientLoginBtn => 'CLIENT LOGIN (USER) →';

  @override
  String get authStylistLoginBtn => 'STYLIST LOGIN (MAYA TRẦN) →';

  @override
  String get authFooterSecurity => 'Secured by PoseNova AI & SePay Escrow Protocol';

  @override
  String get selectPersonaTitle => 'Select Demo Persona';

  @override
  String get selectPersonaSubtitle => 'Experience the C2C AI Styling & Milestone Escrow workflow from both perspectives.';

  @override
  String get clientViewBadge => 'CLIENT VIEW';

  @override
  String get clientName => 'Quốc Huy';

  @override
  String get clientRole => 'Regular User · Fashion Buyer';

  @override
  String get clientDesc => 'Explore trending Lookbooks, pose with 30 FPS AI Camera, and approve 3-stage milestone escrow payouts.';

  @override
  String get pillLookbookFeed => 'Lookbook Feed';

  @override
  String get pillAiPoseCamera => '30 FPS AI Pose Camera';

  @override
  String get pillEscrowApproval => '3-Stage Escrow Approval';

  @override
  String get enterAsClient => 'ENTER AS CLIENT →';

  @override
  String get stylistStudioBadge => 'STYLIST STUDIO';

  @override
  String get stylistName => 'Maya Trần';

  @override
  String get stylistRole => 'Verified Stylist · 4.9★ (128 reviews)';

  @override
  String get stylistDesc => 'Receive requests, style with Gemini AI Co-pilot, deliver milestone deliverables, and withdraw 85% Net revenue to your bank.';

  @override
  String get pillGeminiCopilot => 'Gemini AI Co-pilot';

  @override
  String get pillDeliverableUpload => 'Milestone Deliverable Upload';

  @override
  String get pillCyberWallet => 'Cyber Wallet & Ledger';

  @override
  String get enterAsStylist => 'ENTER AS STYLIST →';

  @override
  String get stage2ReviewTag => 'STAGE 02 REVIEW';

  @override
  String get openDebugDirectory => 'PoseNova AI · Open 8-Screen SRS Directory (Debug Mode)';

  @override
  String get switchToStylist => 'Stylist View ↗';

  @override
  String get switchToClient => 'Client View ↗';

  @override
  String get navAtelier => 'Atelier';

  @override
  String get navMilestones => 'Escrow';

  @override
  String get navWorkspace => 'Workspace';

  @override
  String get titleDiscovery => 'PoseNova Atelier';

  @override
  String get titleCamera => '30 FPS AI Pose Camera';

  @override
  String get titleMilestone => 'Milestone Tracking (30/30/40)';

  @override
  String get titleStylistInbox => 'Stylist Client Requests';

  @override
  String get titleStylistWorkspace => 'Milestone Project Workspace';

  @override
  String get titleStylistWallet => 'Stylist Wallet & Escrow Ledger';

  @override
  String get collectionTitle => 'Urban Tech Jacket';

  @override
  String get lookbookDesc => 'Oversized silhouette with high-contrast color palette, pairing with a dynamic low-angle standing pose.';

  @override
  String get stylistBadge => 'STYLIST';

  @override
  String get topEscrowBanner => '100% ESCROW SECURED';

  @override
  String get escrowContractCode => 'Escrow Contract';

  @override
  String get stage01Approved => '01 Approved';

  @override
  String get stage02Active => '02 Active';

  @override
  String get stage03Review => '03 Review';

  @override
  String get nodeStage01 => 'Stage 01 · Approved';

  @override
  String get nodeStage02 => 'Stage 02 · Reviewing';

  @override
  String get nodeStage03 => 'Stage 03 · Locked 40%';

  @override
  String nodeQuota(int count, int max) => 'Quota $count/$max';

  @override
  String get approveStage2Btn => 'APPROVE & RELEASE STAGE 02 →';

  @override
  String get stage2ApprovedContinueBtn => 'STAGE 02 APPROVED · CONTINUE →';

  @override
  String get openDisputeBtn => 'Open Dispute Refund';

  @override
  String get walletTitle => 'Stylist Cyber Wallet';

  @override
  String get availableBalance => 'AVAILABLE BALANCE';

  @override
  String get escrowLocked => 'ESCROW LOCKED';

  @override
  String get readyToPayout => '85% Net · Ready to payout';

  @override
  String get pendingMilestones => 'Pending milestones';

  @override
  String get withdrawToBank => 'WITHDRAW TO BANK →';

  @override
  String get escrowLedgerTitle => 'Escrow Reconciliation Ledger';

  @override
  String get escrowCheckoutTitle => 'SePay VietQR Escrow Checkout';

  @override
  String get simulateWebhookBtn => 'CONFIRM DEPOSIT (ACTIVATE ESCROW)';

  @override
  String get verifyingWebhook => 'VERIFYING PAYMENT...';

  @override
  String get disputeTitle => 'Escrow Dispute Center';
}

/// Status enum extension for milestones
enum MilestoneStatus {
  LOCKED,
  ACTIVE,
  IN_REVIEW,
  REVISION_REQUESTED,
  APPROVED,
  DISPUTED,
}

extension MilestoneStatusX on MilestoneStatus {
  String label(BuildContext context) {
    final s = AppStrings.of(context);
    switch (this) {
      case MilestoneStatus.LOCKED:
        return s.statusLocked;
      case MilestoneStatus.ACTIVE:
        return s.statusActive;
      case MilestoneStatus.IN_REVIEW:
        return s.statusInReview;
      case MilestoneStatus.REVISION_REQUESTED:
        return s.statusRevisionRequested;
      case MilestoneStatus.APPROVED:
        return s.statusApproved;
      case MilestoneStatus.DISPUTED:
        return s.statusDisputed;
    }
  }
}

extension StringMilestoneStatusX on String {
  String toMilestoneStatusLabel(BuildContext context) {
    final s = AppStrings.of(context);
    switch (toUpperCase()) {
      case 'APPROVED':
        return s.statusApproved;
      case 'IN_REVIEW':
      case 'SUBMITTED':
        return s.statusInReview;
      case 'ACTIVE':
      case 'IN_PROGRESS':
        return s.statusActive;
      case 'REVISION_REQUESTED':
        return s.statusRevisionRequested;
      case 'DISPUTED':
        return s.statusDisputed;
      case 'LOCKED':
      default:
        return s.statusLocked;
    }
  }
}

/// Reactive LocaleController with SharedPreferences persistence
class LocaleController extends ChangeNotifier {
  static final LocaleController instance = LocaleController._internal();
  LocaleController._internal();

  static const String _prefKey = 'app_language';
  AppLanguage _current = AppLanguage.vi;
  final AppStrings _viStrings = AppStringsVi();
  final AppStrings _enStrings = AppStringsEn();

  AppLanguage get current => _current;
  bool get isVietnamese => _current == AppLanguage.vi;
  bool get isEnglish => _current == AppLanguage.en;
  AppStrings get strings => _current == AppLanguage.vi ? _viStrings : _enStrings;
  AppStrings get t => strings;

  Locale get locale => _current == AppLanguage.vi
      ? const Locale('vi', 'VN')
      : const Locale('en', 'US');

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved == 'en') {
        _current = AppLanguage.en;
      } else if (saved == 'vi') {
        _current = AppLanguage.vi;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setLanguage(AppLanguage lang) async {
    if (_current != lang) {
      _current = lang;
      notifyListeners();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefKey, lang == AppLanguage.en ? 'en' : 'vi');
      } catch (_) {}
    }
  }

  void toggleLanguage() {
    setLanguage(_current == AppLanguage.vi ? AppLanguage.en : AppLanguage.vi);
  }
}
