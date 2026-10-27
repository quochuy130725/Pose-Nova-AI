import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import 'fashion_dock_button.dart';

/// Sunset Rose-to-Gold Hero Wallet Card:
/// Luxurious Sunset Rose-Pink & Golden-Yellow gradient card with bold #1E1B18 typography,
/// hairline white border, soft ambient shadow, and glossy Coral-Orange [WITHDRAW TO BANK →] button.
class CyberBlackCard extends StatelessWidget {
  final int balanceVnd;
  final int escrowLockedVnd;
  final String walletId;
  final VoidCallback? onWithdraw;

  const CyberBlackCard({
    super.key,
    required this.balanceVnd,
    required this.escrowLockedVnd,
    this.walletId = 'WAL-STY-8452',
    this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLanguageController.instance,
      builder: (context, _) {
        final t = AppLanguageController.instance.t;

        return Container(
          decoration: BoxDecoration(
            gradient: AppColors.heroPayoutGradient, // #F9A8D4 -> #FB923C
            borderRadius: BorderRadius.circular(AppColors.cardRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.7),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33F43F5E),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.coralOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            t.walletTitle,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF1E1B18),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: AppColors.chipShadow,
                    ),
                    child: Text(
                      walletId,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF1E1B18),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2 Cột Số Liệu Minh Bạch
              Row(
                children: [
                  // Cột 1: Số dư khả dụng
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.availableBalance,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF1E1B18).withValues(alpha: 0.75),
                            fontSize: 10.5,
                            letterSpacing: -0.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          CurrencyFormatter.formatVnd(balanceVnd),
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF1E1B18),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.readyToPayout,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF1E1B18).withValues(alpha: 0.65),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Vạch ngăn cách dọc
                  Container(
                    height: 52,
                    width: 1.0,
                    color: Colors.white.withValues(alpha: 0.4),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),

                  // Cột 2: Tiền đang khóa trong Ký quỹ
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.escrowLocked,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF1E1B18).withValues(alpha: 0.75),
                            fontSize: 10.5,
                            letterSpacing: -0.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          CurrencyFormatter.formatVnd(escrowLockedVnd),
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF1E1B18),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.pendingMilestones,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF1E1B18).withValues(alpha: 0.65),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Glossy Coral-Orange [WITHDRAW TO BANK →] Button
              FashionDockButton(
                text: t.withdrawToBank,
                icon: Icons.account_balance,
                gradient: AppColors.primaryGradient,
                textColor: Colors.white,
                arrowBadgeColor: Colors.white,
                arrowIconColor: AppColors.coralOrange,
                onPressed: onWithdraw ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.ink,
                          content: Text(
                            AppLanguageController.instance.isVietnamese
                                ? 'Yêu cầu rút tiền về tài khoản ngân hàng liên kết đã được ghi nhận!'
                                : 'Withdrawal request to linked bank account submitted!',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
              ),
            ],
          ),
        );
      },
    );
  }
}
