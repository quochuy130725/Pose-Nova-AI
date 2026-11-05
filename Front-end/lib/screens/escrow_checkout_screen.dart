import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/localization/app_language.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency_formatter.dart';
import '../providers/styling_request_provider.dart';
import '../widgets/brutalist_badge.dart';
import '../widgets/brutalist_button.dart';
import '../widgets/fashion_dock_button.dart';
import '../widgets/technical_grid_background.dart';
import 'client_main_shell.dart';

/// Screen 05: SePay VietQR Escrow Checkout (Neo-Brutalist Street Ticket)
class EscrowCheckoutScreen extends StatefulWidget {
  const EscrowCheckoutScreen({super.key});

  @override
  State<EscrowCheckoutScreen> createState() => _EscrowCheckoutScreenState();
}

class _EscrowCheckoutScreenState extends State<EscrowCheckoutScreen> {
  bool _isProcessingWebhook = false;

  Future<void> _simulateWebhookSuccess() async {
    setState(() => _isProcessingWebhook = true);

    await StylingRequestProvider.instance.simulateEscrowDeposit();

    if (mounted) {
      setState(() => _isProcessingWebhook = false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.cardRadius),
            side: const BorderSide(color: AppColors.hairlineBorder, width: AppColors.cardBorderWidth),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: AppColors.warmAmber,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.chipShadow,
                ),
                child: const Icon(Icons.verified_user, color: AppColors.petrol, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                AppLanguageController.instance.isEnglish
                    ? 'SePay Webhook Verified!'
                    : 'Đã Xác Thực SePay Webhook!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.petrol,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLanguageController.instance.isEnglish
                    ? '${CurrencyFormatter.formatVnd(StylingRequestProvider.instance.activeTotalBudget)} locked in Frozen Escrow (${StylingRequestProvider.instance.activeRequestDisplayCode}).\n85% Net secured & 30-30-40 milestones activated!'
                    : '${CurrencyFormatter.formatVnd(StylingRequestProvider.instance.activeTotalBudget)} đã vào Quỹ Ký Quỹ Đóng Băng (${StylingRequestProvider.instance.activeRequestDisplayCode}).\nTự động khóa 85% Net & kích hoạt 3 chặng 30-30-40!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: AppColors.petrol.withValues(alpha: 0.7),
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              BrutalistButton(
                text: AppLanguageController.instance.isEnglish
                    ? 'Open Escrow Workspace →'
                    : 'Vào Workspace Tiến Độ →',
                backgroundColor: AppColors.warmAmber,
                textColor: AppColors.petrol,
                height: 48,
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ClientMainShell(initialTabIndex: 2),
                    ),
                    (route) => route.isFirst,
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLanguageController.instance,
      builder: (context, _) {
        final isEn = AppLanguageController.instance.isEnglish;
        final cleanOrderCode = StylingRequestProvider.instance.activeOrderCode.replaceAll('#', '').trim();

        return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEn ? 'Escrow Checkout' : 'Thanh Toán Ký Quỹ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.petrol,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: BrutalistBadge(
              label: isEn ? '100% Escrow' : 'Bảo Vệ Ký Quỹ 100%',
              backgroundColor: AppColors.warmAmber,
              isMonospace: false,
            ),
          ),
        ],
      ),
      body: TechnicalGridBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            children: [
              // Thiết kế Phiếu Ký Quỹ Editorial Atelier Ticket
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppColors.cardRadius),
                  border: Border.all(color: AppColors.hairlineBorder, width: AppColors.cardBorderWidth),
                  boxShadow: AppColors.softDribbbleShadow,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Thanh ngang trên cùng [● 100% SePay Escrow Protection]
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.warmAmber,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isEn ? '100% SePay Escrow Protection' : 'Bảo Vệ Ký Quỹ 100% SePay',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Column(
                        children: [
                          Text(
                            isEn ? 'Total Frozen Escrow Deposit' : 'Tổng Tiền Ký Quỹ Đóng Băng',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.petrol.withValues(alpha: 0.65),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            CurrencyFormatter.formatVnd(StylingRequestProvider.instance.activeTotalBudget),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: AppColors.petrol,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.porcelainSmoke,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
                            ),
                            child: Text(
                              'TXN-SEPAY-$cleanOrderCode-DEP',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.petrol,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),
                          const Divider(color: AppColors.hairlineBorder, thickness: 1.0),
                          const SizedBox(height: 14),

                          // Sơ đồ Chia nhỏ Dòng tiền (3-Stage Escrow Bar)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isEn ? '3-Stage Milestone Breakdown' : 'Sơ Đồ Giải Ngân 3 Giai Đoạn',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.petrol,
                                ),
                              ),
                              Text(
                                '30 / 30 / 40',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.petrol.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          _buildEscrowBarItem(
                            '01',
                            'Moodboard & Concept',
                            '30%',
                            CurrencyFormatter.formatVnd(StylingRequestProvider.instance.stageGrossAmount(1)),
                            AppColors.petrol,
                            Colors.white,
                          ),
                          const SizedBox(height: 8),
                          _buildEscrowBarItem(
                            '02',
                            isEn ? 'Outfit Selection & Tags' : 'Phối Đồ & Gắn Thẻ',
                            '30%',
                            CurrencyFormatter.formatVnd(StylingRequestProvider.instance.stageGrossAmount(2)),
                            AppColors.warmAmber,
                            AppColors.petrol,
                          ),
                          const SizedBox(height: 8),
                          _buildEscrowBarItem(
                            '03',
                            isEn ? 'Final Lookbook & Pose' : 'Hoàn Thiện & Dáng Mẫu',
                            '40%',
                            CurrencyFormatter.formatVnd(StylingRequestProvider.instance.stageGrossAmount(3)),
                            AppColors.porcelainSmoke,
                            AppColors.petrol,
                          ),

                          const SizedBox(height: 20),

                          // Khung mã Dynamic VietQR
                          Builder(
                            builder: (context) {
                              final req = StylingRequestProvider.instance.activeRequest;
                              final vietQr = req?['vietQr'] as Map<String, dynamic>?;
                              final qrUrl = vietQr?['qrImageUrl']?.toString();
                              final transferContent = vietQr?['transferContent']?.toString() ??
                                  '${StylingRequestProvider.instance.activeRequestIdOrCode} ESCROW';

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.hairlineBorder,
                                    width: AppColors.cardBorderWidth,
                                  ),
                                  boxShadow: AppColors.chipShadow,
                                ),
                                child: Column(
                                  children: [
                                    if (qrUrl != null && qrUrl.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          qrUrl,
                                          width: 160,
                                          height: 160,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, _, _) => const Icon(
                                            Icons.qr_code_2,
                                            size: 160,
                                            color: AppColors.petrol,
                                          ),
                                        ),
                                      )
                                    else
                                      const Icon(Icons.qr_code_2, size: 160, color: AppColors.petrol),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.warmAmber,
                                        borderRadius: BorderRadius.circular(999),
                                        boxShadow: AppColors.chipShadow,
                                      ),
                                      child: Text(
                                        isEn ? 'Transfer Note: $transferContent' : 'Nội dung CK: $transferContent',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.petrol,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          Text(
                            isEn
                                ? 'SePay gateway automatically detects real-time bank transactions via Webhook.'
                                : 'Cổng SePay tự động phát hiện biến động tài khoản qua Webhook thời gian thực.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: AppColors.petrol.withValues(alpha: 0.7),
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Golden Path Step 3 CTA Button: Signature FashionDockButton
              FashionDockButton(
                text: _isProcessingWebhook
                    ? AppLanguageController.instance.t.verifyingWebhook
                    : AppLanguageController.instance.t.simulateWebhookBtn,
                icon: Icons.bolt,
                onPressed: _isProcessingWebhook ? null : _simulateWebhookSuccess,
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  static Widget _buildEscrowBarItem(String num, String name, String percent, String amount, Color badgeBg, Color badgeText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
        boxShadow: AppColors.chipShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$num · $percent',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: badgeText,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.petrol,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.petrol,
            ),
          ),
        ],
      ),
    );
  }
}
