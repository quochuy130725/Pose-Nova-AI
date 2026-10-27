import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/brutalist_badge.dart';
import '../widgets/cyber_black_card.dart';
import '../widgets/technical_grid_background.dart';
import 'auth/login_screen.dart';

/// Screen 08: Stylist Wallet & Escrow Ledger (Ví Doanh thu & Sổ cái Giải ngân)
/// Selective Dark Mode cho Thẻ Đen WALLET (#0D0F0E) trên nền Neo-Mint
class StylistWalletScreen extends StatelessWidget {
  final bool embeddedInShell;

  const StylistWalletScreen({
    super.key,
    this.embeddedInShell = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: embeddedInShell
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Stylist Wallet',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.petrol,
                ),
              ),
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: BrutalistBadge(
                    label: 'Ledger Audited',
                    backgroundColor: AppColors.warmAmber,
                    isMonospace: false,
                  ),
                ),
              ],
            ),
      body: TechnicalGridBackground(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, embeddedInShell ? 88.0 : 32.0),
          children: [
            // Component 3: Thẻ Ví WALLET Luxurious Sunset Rose-to-Gold
            const CyberBlackCard(
              balanceVnd: 765000, // 2 đợt giải ngân (Stage 1 + Stage 2: 382,500 x 2)
              escrowLockedVnd: 850000, // 40% Stage 3 đang khóa (1,000,000 - 15%)
              walletId: 'WAL-STY-8452 (Maya Trần)',
            ),

            const SizedBox(height: 22),

            // Sổ cái Giao dịch (PAYMENT_TRANSACTION Ledger)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long, size: 18, color: AppColors.coralOrange),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Escrow Reconciliation Ledger',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Fee: 15%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.coralOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dòng Giao dịch 1: Stage 02 Release (+382,500 VND)
            _buildLedgerItem(
              amountText: '+382.500₫',
              title: 'Milestone Release (30% Stage 02 · #REQ-8452)',
              subtitle: 'Nghiệm thu: Outfit Selection & Tags • Phí sàn -67.500₫',
              timeText: 'Hôm nay, 10:25 AM',
              isSuccess: true,
            ),

            const SizedBox(height: 10),

            // Dòng Giao dịch 2: Stage 01 Release (+382,500 VND)
            _buildLedgerItem(
              amountText: '+382.500₫',
              title: 'Milestone Release (30% Stage 01 · #REQ-8452)',
              subtitle: 'Nghiệm thu: Moodboard & Concept • Phí sàn -67.500₫',
              timeText: '19/10/2026, 09:15 AM',
              isSuccess: true,
            ),

            const SizedBox(height: 10),

            // Dòng Giao dịch 3: Initial 100% Escrow Deposit (+2,500,000 VND locked)
            _buildLedgerItem(
              amountText: '+2.500.000₫',
              title: 'Escrow Deposit (#REQ-8452)',
              subtitle: 'SePay VietQR 100% Escrow Inflow • Đóng băng quỹ trung gian',
              timeText: '18/10/2026, 10:20 AM',
              isSuccess: true,
              isDepositInflow: true,
            ),

            const SizedBox(height: 24),

            // Nút Đăng Xuất Tài Khoản Stylist
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (r) => false,
                );
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.hairlineBorder, width: AppColors.cardBorderWidth),
                  boxShadow: AppColors.chipShadow,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, size: 18, color: AppColors.coralOrange),
                    const SizedBox(width: 8),
                    Text(
                      'Đăng Xuất Tài Khoản (Logout)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildLedgerItem({
    required String amountText,
    required String title,
    required String subtitle,
    required String timeText,
    required bool isSuccess,
    bool isDepositInflow = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.hairlineBorder, width: AppColors.cardBorderWidth),
        boxShadow: AppColors.chipShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDepositInflow ? AppColors.sunshineYellow : AppColors.rosePinkSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDepositInflow ? Icons.lock : Icons.arrow_downward,
              color: isDepositInflow ? AppColors.ink : AppColors.coralOrange,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        amountText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.petrol,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    BrutalistBadge(
                      label: isDepositInflow ? 'Locked' : 'Released',
                      backgroundColor: isDepositInflow ? AppColors.warmAmber : AppColors.porcelainSmoke,
                      textColor: AppColors.petrol,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      isMonospace: false,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.petrol,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
