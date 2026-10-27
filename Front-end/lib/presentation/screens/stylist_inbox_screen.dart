import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/brutalist_badge.dart';
import '../widgets/fashion_dock_button.dart';
import '../widgets/technical_grid_background.dart';
import 'milestone_workspace_screen.dart';

/// Screen 04: Stylist Inbox & Gemini AI Co-pilot
/// Fully overhauled to "Street-Zine Neo-Pop" aesthetic
class StylistInboxScreen extends StatelessWidget {
  final bool embeddedInShell;
  final ValueChanged<int>? onNavigateToTab;

  const StylistInboxScreen({
    super.key,
    this.embeddedInShell = false,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLanguageController.instance,
      builder: (context, _) {
        final t = AppLanguageController.instance.t;

        return Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: embeddedInShell
              ? null
              : AppBar(
                  automaticallyImplyLeading: true,
                  titleSpacing: 0,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    'Stylist Studio',
                    style: AppTheme.titleStyle.copyWith(fontSize: 18),
                  ),
                  actions: const [
                    Padding(
                      padding: EdgeInsets.only(right: 14.0),
                      child: BrutalistBadge(
                        label: 'INBOX · ACTIVE',
                        backgroundColor: AppColors.cyber,
                        isMonospace: true,
                      ),
                    ),
                  ],
                ),
          body: TechnicalGridBackground(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 12, 16, embeddedInShell ? 96 : 32),
              children: [
                // Top Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: AppColors.buttonShadow,
                          ),
                          child: Text(
                            'New Styling Request',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Client Order',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.petrol,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ],
                    ),
                    const BrutalistBadge(
                      label: 'Req #8452',
                      backgroundColor: AppColors.butterAmber,
                      isMonospace: false,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // STYLOFY FANNED OVERLAPPING CARD STACK
                _buildStylofyFannedCardStack(context, t),

                const SizedBox(height: 22),

                if (embeddedInShell) ...[
                  _buildActionButtons(context, t),
                ],
              ],
            ),
          ),
          bottomNavigationBar: embeddedInShell
              ? null
              : Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: _buildActionButtons(context, t),
                    ),
                  ),
                ),
        );
      },
    );
  }

  /// Stylofy Upright Clean Card Stack:
  /// - Card 1: Top White Card with Client Specifications
  /// - Card 2: Center Hero Deep Petrol Card with 2.125.000₫ Net Payout
  /// - Card 3: Bottom White Card with Gemini AI Co-pilot
  Widget _buildStylofyFannedCardStack(BuildContext context, AppTranslations t) {
    return Column(
      children: [
        // 1. TOP CARD: Editorial Client Profile Card (Clean White with Hairline Border)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
            boxShadow: AppColors.hardShadow,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar + Typographic Specs (Left) & Subtle Rose Pill (Right)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&auto=format&fit=crop&q=80',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.rosePinkSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Color(0xFFF43F5E), size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alex Đỗ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF18181B),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '175 cm  •  65 kg  •  Streetwear AW26',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF71717A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFFFE4E6), width: 1.0),
                    ),
                    child: Text(
                      '#REQ-8452',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE11D48),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF4F4F5), height: 1, thickness: 1),
              const SizedBox(height: 14),
              Text(
                '“Cần phối outfit Cyberpunk form rộng cho sự kiện ra mắt BST Thu Đông, tông đen kết hợp phụ kiện kim loại.”',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF3F3F46),
                  fontStyle: FontStyle.italic,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. CENTER HERO CARD (Rich Rose-Pink to Sunset-Orange Mesh Gradient #F9A8D4 -> #FB923C)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColors.heroPayoutGradient, // #F9A8D4 -> #FB923C
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33F43F5E),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Guaranteed Net Payout (Expanded) + Compact Fee Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Guaranteed Net Payout',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E1B18),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: AppColors.chipShadow,
                    ),
                    child: Text(
                      '-15% Fee • Escrow',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E1B18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '2.125.000 ₫',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E1B18),
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Gross: 2.500.000₫',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF1E1B18).withValues(alpha: 0.75),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• Platform fee: -375.000₫',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFFD9381E),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 3-Stage Escrow Milestones Strip (3 equal Expanded pills)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStagePill('Stage 1 • 637K', AppColors.coralOrange),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildStagePill('Stage 2 • 637K', AppColors.coralOrange),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildStagePill('Stage 3 • 850K', const Color(0xFF7A7067)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 3. BOTTOM CARD (Clean White with Hairline Border)
        _buildGeminiCopilotStrip(t),
      ],
    );
  }

  static Widget _buildStagePill(String title, Color dotColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppColors.chipShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E1B18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Gemini AI Co-pilot Strip (Clean White Card)
  Widget _buildGeminiCopilotStrip(AppTranslations t) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
        boxShadow: AppColors.hardShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Deep Petrol Pill "✨ Gemini Co-pilot" + Pill "3 Looks Ready"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: AppColors.buttonShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Gemini Co-pilot',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.rosePinkSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '3 Looks Ready',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.coralOrange,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 4 OVERLAPPING CIRCULAR COLOR SWATCHES + TRACK
          Row(
            children: [
              // Overlapping Swatches
              SizedBox(
                width: 100,
                height: 28,
                child: Stack(
                  children: [
                    Positioned(left: 0, child: _buildColorSwatch(AppColors.coralOrange)),
                    Positioned(left: 20, child: _buildColorSwatch(AppColors.sunshineYellow)),
                    Positioned(left: 40, child: _buildColorSwatch(AppColors.rosePink)),
                    Positioned(left: 60, child: _buildColorSwatch(AppColors.vermilion)),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Visual Slider Bar
              Expanded(
                child: Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.canvasGlow,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.ink,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 3,
                          color: AppColors.ink,
                        ),
                      ),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.electricYellow,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.ink, width: 2.0),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 3,
                          color: AppColors.ink.withValues(alpha: 0.25),
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.ink.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 2 LOOKBOOK THUMBNAIL CARDS (with tilted #TECH and #ACID stickers)
          Row(
            children: [
              Expanded(
                child: _buildVisualPreviewCard(
                  imageUrl: 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=400&q=80',
                  stickerLabel: '#TECH',
                  stickerBgColor: AppColors.electricYellow,
                  title: 'Tech Bomber',
                  pose: 'Low Stride Pose',
                  stickerAngle: -0.05,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVisualPreviewCard(
                  imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=400&q=80',
                  stickerLabel: '#ACID',
                  stickerBgColor: AppColors.cyber,
                  title: 'Mesh Layer',
                  pose: 'Lean Pose',
                  stickerAngle: 0.05,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 3 Mini Metadata Pills
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniMetaPill('3 Items', bgColor: AppColors.cardBackground, textColor: AppColors.ink),
              _buildMiniMetaPill('Style: Cyber Tech', bgColor: AppColors.electricYellow, textColor: AppColors.ink, isHighlighted: true),
              _buildMiniMetaPill('Quota: 2 Revs', bgColor: AppColors.cardBackground, textColor: AppColors.ink),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildColorSwatch(Color color) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.0),
        boxShadow: AppColors.chipShadow,
      ),
    );
  }

  Widget _buildVisualPreviewCard({
    required String imageUrl,
    required String stickerLabel,
    required Color stickerBgColor,
    required String title,
    required String pose,
    double stickerAngle = 0.0,
  }) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
        boxShadow: AppColors.chipShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.obsidian,
              alignment: Alignment.center,
              child: const Icon(Icons.checkroom, color: AppColors.electricYellow),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.obsidian.withValues(alpha: 0.9),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: stickerBgColor == AppColors.cyber || stickerBgColor == AppColors.acid || stickerBgColor == AppColors.electricYellow
                    ? AppColors.warmAmber
                    : stickerBgColor,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white24, width: 1.0),
                boxShadow: AppColors.chipShadow,
              ),
              child: Text(
                stickerLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.petrol,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 10,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.titleStyle.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  pose,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warmAmber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetaPill(
    String label, {
    required Color bgColor,
    required Color textColor,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
        boxShadow: AppColors.chipShadow,
      ),
      child: Text(
        label,
        style: AppTheme.headingStyle.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppTranslations t) {
    return Row(
      children: [
        // Left Primary Action: FashionDockButton "NHẬN ĐƠN & TẠO 3 MỐC →"
        Expanded(
          flex: 7,
          child: FashionDockButton(
            height: 50,
            text: t.isVi ? 'Nhận Đơn & Tạo 3 Mốc →' : 'Accept & Setup 3 Stages →',
            onPressed: () {
              if (onNavigateToTab != null) {
                onNavigateToTab!(1);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MilestoneWorkspaceScreen(
                      isStylistView: true,
                    ),
                  ),
                );
              }
            },
          ),
        ),

        const SizedBox(width: 10),

        // Right Secondary Action: Minimal Pill "Từ Chối"
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
                boxShadow: AppColors.buttonShadow,
              ),
              alignment: Alignment.center,
              child: Text(
                t.isVi ? 'Từ Chối' : 'Decline',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.petrol,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
