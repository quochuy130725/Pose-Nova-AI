import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../controllers/escrow_state_controller.dart';
import '../core/localization/app_language.dart';
import '../core/utils/currency_formatter.dart';
import '../providers/styling_request_provider.dart';
import '../widgets/brutalist_badge.dart';
import '../widgets/language_switch_pill.dart';
import '../widgets/technical_grid_background.dart';
import 'escrow_checkout_screen.dart';
import 'milestone_workspace_screen.dart';

class StylistInboxScreen extends StatefulWidget {
  final bool embeddedInShell;
  final void Function(int)? onNavigateToTab;

  const StylistInboxScreen({
    super.key,
    this.embeddedInShell = false,
    this.onNavigateToTab,
  });

  @override
  State<StylistInboxScreen> createState() => _StylistInboxScreenState();
}

class _StylistInboxScreenState extends State<StylistInboxScreen> {
  LocaleController get l => LocaleController.instance;

  final TextEditingController _stage1NotesController = TextEditingController();
  String? _lastLoadedBrief;
  final bool _isOrderAccepted = true;

  Map<String, String> _resolveContextualSuggestions(String brief, {String? vibe, List<String>? palette}) {
    final lower = brief.toLowerCase();
    final isEn = l.isEnglish;

    if (lower.contains('biển') ||
        lower.contains('beach') ||
        lower.contains('mùa hè') ||
        lower.contains('summer') ||
        lower.contains('resort') ||
        lower.contains('nghỉ dưỡng')) {
      return {
        'upperTag': isEn ? 'Upper' : 'Áo khoác/Thân trên',
        'upperText': isEn
            ? 'Breathable oversized linen shirt in cream white or oceanic pastel.'
            : 'Sơ mi Linen form rộng thoáng mát màu trắng kem hoặc xanh biển pastel.',
        'innerTag': isEn ? 'Inner/Acc' : 'Lớp trong/Phụ kiện',
        'innerText': isEn
            ? 'High-waisted tailored shorts paired with UV sunglasses and straw sun hat.'
            : 'Quần short cạp cao kết hợp kính râm và mũ cói rộng vành.',
        'poseTag': isEn ? 'Pose' : 'Tạo dáng',
        'poseText': isEn
            ? 'Natural shoulder-lean breeze pose with hand in hair to accentuate natural posture.'
            : 'Dáng nghiêng vai tự nhiên đón nắng giúp tôn dáng thanh thoát.',
        'defaultDraft': isEn
            ? 'Stage 1 Draft (30%): Summer beach vacation moodboard featuring breathable oversized linen shirt, high-waisted shorts, straw hat, and polarized sunglasses.'
            : 'Bản thảo Chặng 1 (30%): Concept Nghỉ dưỡng Đi biển mùa hè với Sơ mi Linen form rộng thoáng mát khoác ngoài, kết hợp quần short cạp cao, kính râm và mũ cói rộng vành.',
      };
    }

    if (lower.contains('tiệc') ||
        lower.contains('party') ||
        lower.contains('gala') ||
        lower.contains('prom') ||
        lower.contains('dạ hội') ||
        lower.contains('sang trọng')) {
      return {
        'upperTag': isEn ? 'Upper' : 'Áo khoác/Thân trên',
        'upperText': isEn
            ? 'Tailored satin waist-cinching blazer or minimalist evening dress.'
            : 'Áo Blazer chiết eo satin cao cấp hoặc đầm dạ tiệc tối giản tôn đường cong.',
        'innerTag': isEn ? 'Inner/Acc' : 'Lớp trong/Phụ kiện',
        'innerText': isEn
            ? 'Metallic accent jewelry, elegant evening clutch, and pointed stilettos.'
            : 'Phụ kiện ánh kim metallic, clutch cầm tay và giày cao gót mũi nhọn.',
        'poseTag': isEn ? 'Pose' : 'Tạo dáng',
        'poseText': isEn
            ? 'Upright 45-degree angle posture with hand on hip for refined elegance.'
            : 'Đứng thẳng chân trước chân sau góc 45°, tay đặt hông tạo cảm giác sang trọng, quý phái.',
        'defaultDraft': isEn
            ? 'Stage 1 Draft (30%): High-glam evening party concept featuring premium satin tailoring and metallic accents for nighttime spotlight.'
            : 'Bản thảo Chặng 1 (30%): Concept Sang Trọng & Dạ Tiệc, điểm nhấn vải lụa satin cao cấp phối cùng phụ kiện ánh kim, tạo visual thanh lịch và nổi bật ánh đèn đêm.',
      };
    }

    if (lower.contains('công sở') ||
        lower.contains('office') ||
        lower.contains('work') ||
        lower.contains('đi làm') ||
        lower.contains('formal')) {
      return {
        'upperTag': isEn ? 'Upper' : 'Áo khoác/Thân trên',
        'upperText': isEn
            ? 'Relaxed unstructured blazer paired with silk V-neck blouse.'
            : 'Áo Blazer phom suông mềm kết hợp sơ mi lụa cổ V thanh lịch.',
        'innerTag': isEn ? 'Inner/Acc' : 'Lớp trong/Phụ kiện',
        'innerText': isEn
            ? 'High-rise straight trousers and a minimalist leather tote.'
            : 'Quần âu ống đứng cạp cao hoặc chân váy midi cùng túi tote da tối giản.',
        'poseTag': isEn ? 'Pose' : 'Tạo dáng',
        'poseText': isEn
            ? 'Confident subtle cross-leg stance with briefcase or tablet in hand.'
            : 'Đứng tự tin bắt chéo chân nhẹ, một tay cầm tài liệu hoặc túi xách toát lên phong thái chuyên nghiệp.',
        'defaultDraft': isEn
            ? 'Stage 1 Draft (30%): Modern office smart-casual concept with relaxed blazer and high-waisted trousers.'
            : 'Bản thảo Chặng 1 (30%): Concept Smart Casual Công Sở hiện đại, tối ưu form dáng chỉn chu thoải mái với Blazer suông nhẹ và quần âu cạp cao tôn dáng.',
      };
    }

    // Default: Streetwear / Cyberpunk / Tech Fashion
    return {
      'upperTag': isEn ? 'Upper' : 'Áo khoác/Thân trên',
      'upperText': isEn
          ? 'Matte charcoal oversized blazer to soften square shoulders.'
          : 'Áo Blazer Oversized Đen nhám giúp làm mềm bờ vai ngang.',
      'innerTag': isEn ? 'Inner/Acc' : 'Lớp trong/Phụ kiện',
      'innerText': isEn
          ? 'Silver metallic corset/crop top creating a focused focal point at the waist.'
          : 'Corset Metallic Bạc tạo điểm nhấn thị giác vào vùng eo.',
      'poseTag': isEn ? 'Pose' : 'Tạo dáng',
      'poseText': isEn
          ? '"Low-Angle Power Lean" shot from a 15-degree low angle to elongate legs.'
          : 'Dáng "Low-Angle Power Lean" chụp từ góc thấp 15° giúp kéo dài chân.',
      'defaultDraft': isEn
          ? 'Stage 1 Draft (30%): Proposed matte black oversized blazer over silver corset, combined with wide-leg high-waisted pants for urban editorial.'
          : 'Bản thảo Chặng 1 (30%): Đề xuất áo Blazer Oversized Đen nhám khoác ngoài Corset Lụa Bạc tạo đường eo thon gọn, kết hợp quần suông cạp cao kéo dài chân. Phù hợp sự kiện Tech Fashion Show.',
    };
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StylingRequestProvider.instance.fetchRequests();
    });
  }

  @override
  void dispose() {
    _stage1NotesController.dispose();
    super.dispose();
  }

  Color _parseHexColor(String hex) {
    final cleaned = hex.replaceAll('#', '').trim();
    if (cleaned.length == 6) {
      return Color(int.parse('FF$cleaned', radix: 16));
    }
    return const Color(0xFF1A1A1A);
  }

  void _acceptAndDeliverStage1() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.ink,
        content: Text(
          AppLanguageController.instance.isEnglish
              ? 'Submitted Stage 1 (30%) Deliverable to Escrow Workspace!'
              : 'Đã nộp sản phẩm Chặng 1 (30%) lên Không gian Ký quỹ!',
          style: AppTheme.monoStyle.copyWith(color: AppColors.acid, fontSize: 12),
        ),
      ),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MilestoneWorkspaceScreen(isStylistView: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLanguageController.instance;
    return ListenableBuilder(
      listenable: Listenable.merge([
        StylingRequestProvider.instance,
        EscrowStateController.instance,
        AppLanguageController.instance,
      ]),
      builder: (context, _) {
        final requestProvider = StylingRequestProvider.instance;
        final String activeCode = requestProvider.activeOrderCode;
        final int totalBudget = requestProvider.activeTotalBudget;
        final int netTotal = requestProvider.activeNetPayout;
        final int feeTotal = requestProvider.activePlatformFee;
        final int stage1Net = requestProvider.stageNetAmount(1);
        final int stage2Net = requestProvider.stageNetAmount(2);
        final int stage3Net = requestProvider.stageNetAmount(3);
        final String briefText = requestProvider.activeBriefText;
        final String vibeText = requestProvider.activeVibe;
        final List<String> paletteHex = requestProvider.activePaletteHex;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: widget.embeddedInShell
              ? null
              : AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.isEnglish ? 'Client Styling Orders' : 'Đơn Phối Đồ Khách Đặt',
                        style: AppTheme.headingStyle.copyWith(fontSize: 17),
                      ),
                      Text(
                        l.isEnglish
                            ? '85% Net Payout · 3-Stage Deliverable Submission'
                            : 'Thực nhận 85% Net · Nộp bàn giao 3 chặng',
                        style: AppTheme.monoStyle.copyWith(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    const Padding(
                      padding: EdgeInsets.only(right: 6.0),
                      child: LanguageSwitchPill(compact: true),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 14.0),
                      child: BrutalistBadge(
                        label: requestProvider.hasActiveOrder
                            ? activeCode
                            : (l.isEnglish ? 'ONLINE' : 'TRỰC TUYẾN'),
                        backgroundColor: requestProvider.hasActiveOrder
                            ? AppColors.sunshineYellowLight
                            : const Color(0xFFECFDF5),
                        textColor: requestProvider.hasActiveOrder
                            ? AppColors.ink
                            : const Color(0xFF059669),
                        isMonospace: requestProvider.hasActiveOrder,
                      ),
                    ),
                  ],
                ),
          body: TechnicalGridBackground(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      if (widget.embeddedInShell)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0, top: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l.isEnglish ? 'Client Order' : 'Đơn Hàng Khách Đặt',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.ink,
                                        letterSpacing: -0.6,
                                      ),
                                    ),
                                    Text(
                                      l.isEnglish
                                          ? 'Manage client briefs & Gemini Co-pilot'
                                          : 'Quản lý yêu cầu phối đồ & Gemini Co-pilot',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              BrutalistBadge(
                                label: requestProvider.hasActiveOrder
                                    ? activeCode
                                    : (l.isEnglish ? 'ONLINE' : 'TRỰC TUYẾN'),
                                backgroundColor: requestProvider.hasActiveOrder
                                    ? AppColors.sunshineYellowLight
                                    : const Color(0xFFECFDF5),
                                textColor: requestProvider.hasActiveOrder
                                    ? AppColors.ink
                                    : const Color(0xFF059669),
                                isMonospace: requestProvider.hasActiveOrder,
                              ),
                            ],
                          ),
                        ),

                      if (!requestProvider.hasActiveOrder)
                        _buildEmptyInboxState()
                      else ...[
                        // --- 1. Hero Incoming Order Summary Card ---
                        _buildIncomingOrderHeroCard(
                          orderCode: activeCode,
                          totalBudget: totalBudget,
                          netTotal: netTotal,
                          feeTotal: feeTotal,
                          stage1Net: stage1Net,
                          stage2Net: stage2Net,
                          stage3Net: stage3Net,
                          vibeText: vibeText,
                        ),
                        const SizedBox(height: 16),

                        // --- 2. Structured Client Brief & Body Metrics ---
                        _buildClientBriefCard(
                          briefText: briefText,
                          paletteHex: paletteHex,
                        ),
                        const SizedBox(height: 16),

                        // --- 3. Gemini Co-pilot Stylist Assistant ---
                        _buildGeminiCopilotCard(briefText: briefText, vibeText: vibeText, paletteHex: paletteHex),
                        const SizedBox(height: 16),

                        // --- 4. Stage 1 (30%) Deliverable Submission Form ---
                        _buildStage1SubmissionCard(stage1Net: stage1Net),
                      ],
                    ],
                  ),
                ),
                if (requestProvider.hasActiveOrder)
                  _buildStickyOrderActions(stage1Net: stage1Net),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyInboxState() {
    final isEn = l.isEnglish;
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.hairlineBorder, width: AppColors.cardBorderWidth),
        boxShadow: AppColors.softDribbbleShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.rosePinkSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 32,
              color: AppColors.coralOrange,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isEn ? 'No Client Orders Yet' : 'Hộp Thư Đang Trống',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isEn
                ? 'You currently do not have any incoming styling orders. When a client creates a brief and completes VietQR escrow deposit, the order details will automatically appear here!'
                : 'Hiện tại chưa có khách hàng nào đặt yêu cầu phối đồ. Khi khách tạo đơn mới và nạp cọc ký quỹ VietQR, thông tin yêu cầu sẽ tự động xuất hiện tại đây!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: AppColors.textMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF059669),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isEn ? 'Stylist Studio is Active & Ready' : 'Stylist Studio Sẵn Sàng Nhận Đơn',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingOrderHeroCard({
    required String orderCode,
    required int totalBudget,
    required int netTotal,
    required int feeTotal,
    required int stage1Net,
    required int stage2Net,
    required int stage3Net,
    required String vibeText,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.obsidianCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x241F1A17),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 21,
                      backgroundColor: AppColors.rosePinkSoft,
                      backgroundImage: const NetworkImage(
                        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=200&auto=format&fit=crop&q=80',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            StylingRequestProvider.instance.hasActiveOrder
                                ? (StylingRequestProvider.instance.activeRequest?['client']?['fullName']?.toString() ??
                                   StylingRequestProvider.instance.activeRequest?['clientName']?.toString() ??
                                   (l.isEnglish ? 'Client Order' : 'Quý Khách (Client)'))
                                : (l.isEnglish ? 'Client Order' : 'Quý Khách (Client)'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '168cm • 56kg • $vibeText',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _isOrderAccepted
                      ? const Color(0xFFDCFCE7)
                      : AppColors.sunshineYellowLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _isOrderAccepted
                      ? (l.isEnglish ? 'Escrow Funded 100%' : 'Đã Ký Quỹ 100%')
                      : (l.isEnglish ? 'Pending' : 'Chờ Nhận Đơn'),
                  style: GoogleFonts.plusJakartaSans(
                    color: _isOrderAccepted
                        ? const Color(0xFF15803D)
                        : AppColors.ink,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12, width: 1.0),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.isEnglish ? 'STYLIST NET PAYOUT (85%)' : 'THỰC NHẬN STYLIST (85% NET)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white60,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              CurrencyFormatter.formatVnd(netTotal),
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.sunshineYellow,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              l.isEnglish
                                  ? 'Total Escrow: ${CurrencyFormatter.formatVnd(totalBudget)}'
                                  : 'Tổng Ký Quỹ: ${CurrencyFormatter.formatVnd(totalBudget)}',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              l.isEnglish
                                  ? 'Fee (15%): -${CurrencyFormatter.formatVnd(feeTotal)}'
                                  : 'Phí sàn (15%): -${CurrencyFormatter.formatVnd(feeTotal)}',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildNetStagePill(
                        l.isEnglish ? 'Stage 1 (30%)' : 'Chặng 1 (30%)',
                        '+${CurrencyFormatter.formatVnd(stage1Net)}',
                        true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildNetStagePill(
                        l.isEnglish ? 'Stage 2 (30%)' : 'Chặng 2 (30%)',
                        '+${CurrencyFormatter.formatVnd(stage2Net)}',
                        false,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildNetStagePill(
                        l.isEnglish ? 'Stage 3 (40%)' : 'Chặng 3 (40%)',
                        '+${CurrencyFormatter.formatVnd(stage3Net)}',
                        false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetStagePill(String stage, String netAmount, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.sunshineYellow.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.sunshineYellow : Colors.white12,
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Text(
            stage,
            style: GoogleFonts.plusJakartaSans(
              color: isActive ? AppColors.sunshineYellow : Colors.white60,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            netAmount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientBriefCard({
    required String briefText,
    required List<String> paletteHex,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.assignment_ind_outlined, size: 18, color: AppColors.ink),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.isEnglish ? 'Client Styling Brief' : 'Yêu Cầu Của Khách',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EscrowCheckoutScreen()),
                  );
                },
                child: Text(
                  l.isEnglish ? 'View VietQR Bill →' : 'Xem Bill VietQR →',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: AppColors.rosePink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.alabaster,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '"$briefText"',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: AppColors.ink,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l.isEnglish ? 'Selected Palette:' : 'Tone màu khách chọn:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              ...paletteHex.map(
                (hex) => _buildColorDot(_parseHexColor(hex), hex),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorDot(Color color, String hex) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.alabaster,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black26, width: 0.8),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            hex,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeminiCopilotCard({
    required String briefText,
    String? vibeText,
    List<String>? paletteHex,
  }) {
    final advice = _resolveContextualSuggestions(briefText, vibe: vibeText, palette: paletteHex);

    // Auto-update default draft notes if not yet modified or order brief changed
    if (_lastLoadedBrief != briefText) {
      _lastLoadedBrief = briefText;
      _stage1NotesController.text = advice['defaultDraft'] ?? '';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E7), Color(0xFFFFEFE6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.coralOrange.withValues(alpha: 0.35), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.psychology_outlined,
                        size: 15,
                        color: AppColors.sunshineYellow,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.isEnglish ? 'Gemini Co-pilot Styling AI' : 'Gemini Co-pilot Gợi Ý Phối Đồ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l.isEnglish ? '96% Fit Match' : 'Độ hợp: 96%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.coralOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• ${l.isEnglish ? 'Tip 1' : 'Gợi ý 1'} (${advice['upperTag']}): ${advice['upperText']}\n'
            '• ${l.isEnglish ? 'Tip 2' : 'Gợi ý 2'} (${advice['innerTag']}): ${advice['innerText']}\n'
            '• ${l.isEnglish ? 'Tip 3' : 'Gợi ý 3'} (${advice['poseTag']}): ${advice['poseText']}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.5,
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStage1SubmissionCard({required int stage1Net}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l.isEnglish
                      ? 'Stage 1 Deliverable (30% Moodboard)'
                      : 'Bàn Giao Chặng 1 (30% Moodboard)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.sunshineYellowLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '+${CurrencyFormatter.formatVnd(stage1Net)} Net',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l.isEnglish
                ? 'After submitting, client has 48 hours to approve or system will auto-release 30% to wallet.'
                : 'Sau khi nộp bản thảo, khách hàng có 48h để nghiệm thu hoặc hệ thống sẽ tự động giải ngân 30% về ví.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              color: AppColors.textMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _stage1NotesController,
            maxLines: 3,
            style: GoogleFonts.plusJakartaSans(fontSize: 12.5, height: 1.4),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.alabaster,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border, width: 1.0),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyOrderActions({required int stage1Net}) {
    final t = AppStrings.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.hairlineBorder, width: 1.0)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 46,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    if (widget.onNavigateToTab != null) {
                      widget.onNavigateToTab!(1);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MilestoneWorkspaceScreen(isStylistView: true),
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.alabaster,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border, width: 1.0),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      t.escrowDetailsBtn,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _acceptAndDeliverStage1,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: AppColors.chipShadow,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      t.submitStage1Btn('+${CurrencyFormatter.formatVnd(stage1Net)}'),
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
