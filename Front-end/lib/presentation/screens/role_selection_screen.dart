import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart';
import '../widgets/fashion_dock_button.dart';
import '../widgets/language_switch_pill.dart';
import '../widgets/technical_grid_background.dart';
import 'client_main_shell.dart';
import 'stylist_main_shell.dart';

/// Role Selection Screen (Production Demo Persona Portal)
///
/// Features:
/// - Zero-overflow layout: All rows and columns use Flexible/Expanded with TextOverflow.ellipsis.
/// - Bilingual support: Instant reactive switching between Vietnamese (VI) and English (EN).
/// - High-fashion editorial contrast: 70/30 Crisp White and Obsidian Dark Cards.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLanguageController.instance,
      builder: (context, _) {
        final t = AppLanguageController.instance.t;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: TechnicalGridBackground(
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
                children: [
                  const SizedBox(height: 6),

                  // --- 1. Top Header Section with Language Switcher ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: Brand Pill Badge + Neo-Brutalist Language Switcher
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Pill badge "POSENOVA · ATELIER"
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.paper,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
                              boxShadow: AppColors.chipShadow,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
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
                                Text(
                                  t.brandAtelier,
                                  style: AppTheme.monoStyle.copyWith(
                                    color: AppColors.ink,
                                    fontSize: 10,
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Signature Language Switcher Pill (🇻🇳 VI | 🇬🇧 EN)
                          const LanguageSwitchPill(),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Main Title
                      Text(
                        t.selectPersonaTitle,
                        style: AppTheme.displayStyle.copyWith(
                          fontSize: 26,
                          height: 1.15,
                          letterSpacing: -0.6,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Subtitle
                      Text(
                        t.selectPersonaSubtitle,
                        style: AppTheme.bodyStyle.copyWith(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // --- 2. Card 1: CLIENT PORTAL ---
                  _buildClientCard(context, t),

                  const SizedBox(height: 20),

                  // --- 3. Card 2: STYLIST STUDIO PORTAL ---
                  _buildStylistCard(context, t),

                  const SizedBox(height: 22),

                  // --- 4. Footer link to 8-Screen SRS Directory ---
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DemoHubScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.developer_mode, size: 14, color: AppColors.ink),
                      label: Text(
                        t.openDebugDirectory,
                        textAlign: TextAlign.center,
                        style: AppTheme.monoStyle.copyWith(
                          fontSize: 11,
                          color: AppColors.ink,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Card 1: CLIENT PORTAL (Pure Frosted White, Soft Ambient Shadow)
  Widget _buildClientCard(BuildContext context, AppTranslations t) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with Upright Pill Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFBCFE8), Color(0xFFFED7AA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: AppColors.ink, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.clientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.headingStyle.copyWith(fontSize: 16),
                          ),
                          Text(
                            t.clientRole,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.monoStyle.copyWith(fontSize: 10, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Top-right upright pill badge in Warm Sunset Amber
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: AppColors.goldenSunlightSoft,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
                  boxShadow: AppColors.chipShadow,
                ),
                child: Text(
                  t.clientViewBadge,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.ink,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            t.clientDesc,
            style: AppTheme.bodyStyle.copyWith(fontSize: 12, color: AppColors.textMuted, height: 1.35),
          ),

          const SizedBox(height: 14),

          // Feature Pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeaturePill(t.pillLookbookFeed, Colors.white, AppColors.ink),
              _buildFeaturePill(t.pillAiPoseCamera, AppColors.goldenSunlightSoft, AppColors.ink),
              _buildFeaturePill(t.pillEscrowApproval, AppColors.rosePinkSoft, AppColors.ink),
            ],
          ),

          const SizedBox(height: 18),

          // Signature FashionDockButton CTA Button
          FashionDockButton(
            text: t.enterAsClient,
            icon: Icons.arrow_forward,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ClientMainShell(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Card 2: STYLIST STUDIO PORTAL (Obsidian Luxury Card with Sunset Accent)
  Widget _buildStylistCard(BuildContext context, AppTranslations t) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.obsidianCard,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.style, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      t.stylistName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTheme.headingStyle.copyWith(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, color: AppColors.coralOrange, size: 14),
                                ],
                              ),
                              Text(
                                t.stylistRole,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.monoStyle.copyWith(fontSize: 10, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Top-right upright pill badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white24, width: 1.0),
                    ),
                    child: Text(
                      t.stylistStudioBadge,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                t.stylistDesc,
                style: AppTheme.bodyStyle.copyWith(fontSize: 12, color: Colors.white70, height: 1.35),
              ),

              const SizedBox(height: 14),

              // Feature Pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDarkFeaturePill(t.pillGeminiCopilot, const Color(0xFF282522), Colors.white),
                  _buildDarkFeaturePill(t.pillDeliverableUpload, const Color(0xFF33261F), AppColors.coralOrange),
                  _buildDarkFeaturePill(t.pillCyberWallet, const Color(0xFF30222A), AppColors.rosePinkSoft),
                ],
              ),

              const SizedBox(height: 18),

              // Signature FashionDockButton CTA
              FashionDockButton(
                text: t.enterAsStylist,
                icon: Icons.palette,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StylistMainShell(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // Upright Sunset Rose sticker badge
        Positioned(
          top: -8,
          right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: AppColors.heroPayoutGradient, // #F9A8D4 -> #FB923C
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: AppColors.chipShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.stage2ReviewTag,
                  style: AppTheme.monoStyle.copyWith(
                    color: AppColors.ink,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildFeaturePill(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
        boxShadow: AppColors.chipShadow,
      ),
      child: Text(
        text,
        style: AppTheme.headingStyle.copyWith(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static Widget _buildDarkFeaturePill(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white12, width: 1.0),
      ),
      child: Text(
        text,
        style: AppTheme.headingStyle.copyWith(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
