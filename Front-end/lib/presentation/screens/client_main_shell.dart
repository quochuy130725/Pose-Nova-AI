import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/language_switch_pill.dart';
import 'auth/login_screen.dart';
import 'discovery_feed_screen.dart';
import 'milestone_workspace_screen.dart';
import 'pose_camera_screen.dart';
import 'stylist_main_shell.dart';

/// Client Role Main Shell
/// - Sunset Rose-Pink & Golden-Yellow aesthetic
/// - Top Bar: PoseNova Atelier brand title, language switch pill, and stylish role switcher
/// - Bottom Navigation Bar: Standard non-overlapping Scaffold bottom bar (extendBody: false)
///   with frosted white background, 24px top radius, and glossy Coral-Orange active tab pill.
class ClientMainShell extends StatefulWidget {
  final int initialTabIndex;

  const ClientMainShell({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<ClientMainShell> createState() => _ClientMainShellState();
}

class _ClientMainShellState extends State<ClientMainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLanguageController.instance,
      builder: (context, _) {
        final t = AppLanguageController.instance.t;

        return Scaffold(
          backgroundColor: AppColors.canvas,
          extendBody: false, // Prevents bottom bar from overlapping body content
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white.withValues(alpha: 0.95),
            elevation: 0,
            titleSpacing: 18,
            title: Text(
              'PoseNova',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
                letterSpacing: -0.6,
              ),
            ),
            actions: [
              // Language Switcher (Compact VI / EN)
              const Padding(
                padding: EdgeInsets.only(right: 6.0),
                child: LanguageSwitchPill(compact: true),
              ),

              // Role Switcher ("Stylist")
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const StylistMainShell()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: AppColors.chipShadow,
                    ),
                    child: Text(
                      'Stylist',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ),
              ),

              // Client Avatar & Logout Action
              Padding(
                padding: const EdgeInsets.only(right: 14.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (r) => false,
                    );
                  },
                  child: Tooltip(
                    message: t.isVi ? 'Đăng xuất' : 'Logout',
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.rosePink, width: 1.5),
                        boxShadow: AppColors.chipShadow,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const CircleAvatar(
                            radius: 12.5,
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&auto=format&fit=crop&q=80',
                            ),
                            backgroundColor: AppColors.rosePinkSoft,
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: AppColors.coralOrange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.logout,
                                size: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              DiscoveryFeedScreen(
                embeddedInShell: true,
                onNavigateToTab: (idx) => setState(() => _currentIndex = idx),
              ),
              const PoseCameraScreen(),
              const MilestoneWorkspaceScreen(
                embeddedInShell: true,
              ),
            ],
          ),
          bottomNavigationBar: _buildCleanBottomBar(t),
        );
      },
    );
  }

  /// Sleek Floating Glass Capsule Bottom Navigation Bar (Wavespace Style)
  Widget _buildCleanBottomBar(AppTranslations t) {
    final navItems = [
      {'label': t.navAtelier, 'icon': Icons.auto_awesome_mosaic},
      {'label': t.navPoseCamera, 'icon': Icons.camera_alt},
      {'label': t.navMilestones, 'icon': Icons.verified_user},
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x248A4F60),
              blurRadius: 28,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (idx) {
            final isSelected = _currentIndex == idx;
            final item = navItems[idx];

            return GestureDetector(
              onTap: () => setState(() => _currentIndex = idx),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 18 : 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: isSelected ? AppColors.buttonShadow : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 20,
                      color: isSelected ? Colors.white : AppColors.textMuted,
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Text(
                        item['label'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
