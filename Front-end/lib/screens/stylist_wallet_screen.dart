import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/localization/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../providers/styling_request_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/brutalist_badge.dart';
import '../widgets/cyber_black_card.dart';
import '../widgets/technical_grid_background.dart';
import 'auth/login_screen.dart';

/// Screen 08: Stylist Wallet & Escrow Ledger (Ví Doanh thu & Sổ cái Giải ngân)
/// Selective Dark Mode cho Thẻ Đen WALLET (#0D0F0E) trên nền Neo-Mint
class StylistWalletScreen extends StatefulWidget {
  final bool embeddedInShell;

  const StylistWalletScreen({
    super.key,
    this.embeddedInShell = false,
  });

  @override
  State<StylistWalletScreen> createState() => _StylistWalletScreenState();
}

class _StylistWalletScreenState extends State<StylistWalletScreen> {
  @override
  void initState() {
    super.initState();
    WalletProvider.instance.fetchWallet();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: WalletProvider.instance,
      builder: (context, _) {
        final walletProvider = WalletProvider.instance;
        final embeddedInShell = widget.embeddedInShell;
        final isEn = LocaleController.instance.isEnglish;
        final cleanCode = StylingRequestProvider.instance.activeOrderCode.replaceAll('#', '').replaceAll('REQ-', '');

        return Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: embeddedInShell
              ? null
              : AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    isEn ? 'Stylist Wallet' : 'Ví Stylist',
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
                        label: isEn ? 'Ledger Audited' : 'Đã Đối Soát',
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
                // Thẻ Ví WALLET Luxurious Sunset Rose-to-Gold
                CyberBlackCard(
                  balanceVnd: walletProvider.availableBalanceVnd,
                  escrowLockedVnd: walletProvider.escrowLockedVnd,
                  walletId: cleanCode.isNotEmpty ? 'WAL-STY-$cleanCode' : 'WAL-STY-ACTIVE',
                  onWithdraw: () async {
                    final success = await walletProvider.withdrawAll();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.ink,
                        content: Text(
                          success
                              ? (isEn
                                  ? 'Withdrawn all available balance to linked bank account (MBBank • 0829100286)!'
                                  : 'Đã rút toàn bộ số dư khả dụng về tài khoản ngân hàng liên kết (MBBank • 0829100286)!')
                              : (isEn ? 'Current available balance is 0₫.' : 'Số dư khả dụng hiện tại là 0₫.'),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
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
                              isEn ? 'Escrow Reconciliation Ledger' : 'Sổ Cái Đối Soát Ký Quỹ',
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
                      isEn ? 'Fee: 15%' : 'Phí sàn: 15%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.coralOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Hiển thị danh sách Giao dịch ĐỘNG từ WalletProvider (Không bao giờ hardcode)
                if (walletProvider.ledger.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.hairlineBorder),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Chưa có giao dịch giải ngân nào.',
                      style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted),
                    ),
                  )
                else
                  ...walletProvider.ledger.map((entry) {
                    final bool isDeposit = entry.title.contains('Escrow Deposit');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: _buildLedgerItem(
                        amountText: entry.amountText,
                        title: entry.title,
                        subtitle: entry.subtitle,
                        timeText: entry.timestamp,
                        isSuccess: true,
                        isDepositInflow: isDeposit,
                      ),
                    );
                  }),

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
                      border: Border.all(
                        color: AppColors.hairlineBorder,
                        width: AppColors.cardBorderWidth,
                      ),
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
      },
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
                      label: isDepositInflow
                          ? (LocaleController.instance.isEnglish ? 'Locked' : 'Đang giữ')
                          : (LocaleController.instance.isEnglish ? 'Released' : 'Đã giải ngân'),
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
                    color: AppColors.petrol.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  timeText,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9.5,
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
