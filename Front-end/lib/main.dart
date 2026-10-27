import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/create_styling_request_screen.dart';
import 'presentation/screens/discovery_feed_screen.dart';
import 'presentation/screens/dispute_review_screen.dart';
import 'presentation/screens/escrow_checkout_screen.dart';
import 'presentation/screens/milestone_workspace_screen.dart';
import 'presentation/screens/pose_camera_screen.dart';
import 'presentation/screens/stylist_inbox_screen.dart';
import 'presentation/screens/stylist_wallet_screen.dart';
import 'core/localization/app_language.dart';
import 'presentation/widgets/brutalist_badge.dart';
import 'presentation/widgets/brutalist_card.dart';
import 'presentation/widgets/fashion_dock_button.dart';
import 'presentation/widgets/language_switch_pill.dart';
import 'presentation/widgets/technical_grid_background.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PoseNovaApp());
}

class PoseNovaApp extends StatelessWidget {
  const PoseNovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLanguageController.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'PoseNova AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.neoBrutalistTheme,
          home: const LoginScreen(),
        );
      },
    );
  }
}

/// Interactive Demo Hub providing immediate navigation to all 8 core Lean SRS screens
class DemoHubScreen extends StatelessWidget {
  const DemoHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = [
      {
        'id': '06',
        'title': 'Milestone Tracking Workspace',
        'badge': 'MÀN HÌNH ĐINH',
        'badgeColor': AppColors.primaryAction,
        'workflow': 'Workflow 3 & 4 (Escrow & Milestones)',
        'screen': const MilestoneWorkspaceScreen(),
        'isHero': true,
      },
      {
        'id': '01',
        'title': 'Discovery Feed & Lookbook Detail',
        'badge': 'WF 1 & 2',
        'badgeColor': AppColors.cyber,
        'workflow': 'Explore Lookbooks & Product Tags',
        'screen': const DiscoveryFeedScreen(),
        'isHero': false,
      },
      {
        'id': '02',
        'title': 'AI Pose Camera (30 FPS Overlay)',
        'badge': 'WF 1 (AI)',
        'badgeColor': AppColors.acid,
        'workflow': '33 Landmarks • Real-time Pose Matching',
        'screen': const PoseCameraScreen(),
        'isHero': false,
      },
      {
        'id': '03',
        'title': 'Create Styling Request & AI Match',
        'badge': 'WF 3 (Start)',
        'badgeColor': AppColors.paper,
        'workflow': 'Brief Submission & Gemini AI Enhance',
        'screen': const CreateStylingRequestScreen(),
        'isHero': false,
      },
      {
        'id': '04',
        'title': 'Stylist Inbox & Gemini AI Co-pilot',
        'badge': 'WF 3 (Middle)',
        'badgeColor': AppColors.acid,
        'workflow': 'Accept/Decline & Gemini Draft Recommendation',
        'screen': const StylistInboxScreen(),
        'isHero': false,
      },
      {
        'id': '05',
        'title': 'SePay VietQR Escrow Checkout',
        'badge': 'WF 4 (Start)',
        'badgeColor': AppColors.cyber,
        'workflow': '100% Escrow Deposit via Dynamic VietQR',
        'screen': const EscrowCheckoutScreen(),
        'isHero': false,
      },
      {
        'id': '07',
        'title': 'Dispute & Review/Rating Modal',
        'badge': 'WF 3 & 4 (End)',
        'badgeColor': AppColors.disputeCrimson,
        'badgeTextColor': Colors.white,
        'workflow': '5-Star Quality Review or Escrow Dispute',
        'screen': const DisputeReviewScreen(),
        'isHero': false,
      },
      {
        'id': '08',
        'title': 'Stylist Wallet & Escrow Ledger',
        'badge': 'WF 4 (End)',
        'badgeColor': AppColors.primaryAction,
        'workflow': 'Reconcile 85% Net & Escrow Stage History',
        'screen': const StylistWalletScreen(),
        'isHero': false,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PoseNova AI',
              style: AppTheme.headingStyle.copyWith(fontSize: 20),
            ),
            Text(
              'Neo-Brutalist Street Pop Atelier',
              style: AppTheme.subheadingStyle.copyWith(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 6.0),
            child: LanguageSwitchPill(compact: true),
          ),
          Padding(
            padding: EdgeInsets.only(right: 14.0),
            child: BrutalistBadge(
              label: 'v1.0 LIVE DEMO',
              backgroundColor: AppColors.cyber,
              isMonospace: true,
            ),
          ),
        ],
      ),
      body: TechnicalGridBackground(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- Design System Tokens Banner ---
            BrutalistCard(
              backgroundColor: AppColors.paper,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Misteline AI Design Tokens',
                        style: AppTheme.headingStyle.copyWith(fontSize: 13),
                      ),
                      Text(
                        'OKLCH / HEX',
                        style: AppTheme.monoStyle.copyWith(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTokenChip(
                        'Neo-Mint',
                        AppColors.background,
                        AppColors.ink,
                      ),
                      _buildTokenChip('Pitch Ink', AppColors.ink, Colors.white),
                      _buildTokenChip(
                        'Electric Yellow',
                        AppColors.electricYellow,
                        AppColors.ink,
                      ),
                      _buildTokenChip(
                        'Cyber Escrow',
                        AppColors.cyber,
                        AppColors.ink,
                      ),
                      _buildTokenChip(
                        'Vermilion CTA',
                        AppColors.vermilion,
                        Colors.white,
                      ),
                      _buildTokenChip(
                        'Dispute',
                        AppColors.disputeCrimson,
                        Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Fonts: Plus Jakarta Sans (Headings/Body) • JetBrains Mono (Codes/Metrics) • 2px Hard Borders',
                    style: AppTheme.monoStyle.copyWith(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- Section Title ---
            Row(
              children: [
                const Icon(Icons.apps, size: 18, color: AppColors.ink),
                const SizedBox(width: 6),
                Text(
                  '8-Screen SRS Directory',
                  style: AppTheme.headingStyle.copyWith(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // --- List of 8 Core Screens (70/30 Crisp White & Obsidian Contrast) ---
            ...screens.map((item) {
              final isHero = item['isHero'] as bool;
              final screen = item['screen'] as Widget;

              if (isHero) {
                // OBSIDIAN EDITORIAL CARD (#111312) FOR SCREEN 06
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.obsidianCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12, width: 1.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
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
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.acid,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          'SCREEN ${item['id']}',
                                          style: AppTheme.monoStyle.copyWith(
                                            color: AppColors.pitchBlack,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: BrutalistBadge(
                                          label: item['badge'] as String,
                                          backgroundColor: AppColors.cyber,
                                          textColor: AppColors.ink,
                                          isMonospace: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white24,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_outward,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item['title'] as String,
                              style: AppTheme.headingStyle.copyWith(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['workflow'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FashionDockButton(
                              text: 'Open Workspace (30% - 30% - 40%) ⚡',
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => screen),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Upright Warm Sunset Amber sticker badge
                      Positioned(
                        top: -8,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warmAmber,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: AppColors.chipShadow,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⚡', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 4),
                              Text(
                                'Featured Flow',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.ink,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Standard Crisp White Card
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: BrutalistCard(
                  backgroundColor: AppColors.paper,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => screen),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.ink,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'SCREEN ${item['id']}',
                                    style: AppTheme.monoStyle.copyWith(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: BrutalistBadge(
                                    label: item['badge'] as String,
                                    backgroundColor: item['badgeColor'] as Color,
                                    textColor:
                                        item['badgeTextColor'] as Color? ??
                                        AppColors.ink,
                                    isMonospace: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: AppColors.ink,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item['title'] as String,
                        style: AppTheme.headingStyle.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['workflow'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  static Widget _buildTokenChip(String name, Color color, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
      ),
      child: Text(
        name,
        style: AppTheme.monoStyle.copyWith(
          fontSize: 10,
          color: text,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
