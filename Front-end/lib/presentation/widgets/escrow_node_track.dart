import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';

/// 3-Stage Escrow Node Track
/// Visual 3-stage node bar (30% —o— 30% —o— 40%) in Coral-Orange and Sunshine Yellow
/// with soft hairline border and ambient shadow.
class EscrowNodeTrack extends StatelessWidget {
  final int activeIndex;
  final int revisionCount;
  final int maxRevisions;
  final bool isDark;

  const EscrowNodeTrack({
    super.key,
    this.activeIndex = 1,
    this.revisionCount = 1,
    this.maxRevisions = 2,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF221E1B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white12 : AppColors.hairlineBorder,
          width: 1.0,
        ),
        boxShadow: AppColors.softDribbbleShadow,
      ),
      child: Column(
        children: [
          // 1. Top Row: 3 Status Pills
          ListenableBuilder(
            listenable: AppLanguageController.instance,
            builder: (context, _) {
              final t = AppLanguageController.instance.t;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pill 1: Approved (Rose-Pink Soft)
                  _buildPill(
                    label: t.nodeStage01,
                    bgColor: AppColors.rosePinkSoft,
                    textColor: AppColors.coralOrange,
                    icon: Icons.check,
                  ),

                  // Pill 2: In Review (Sunshine Yellow)
                  _buildPill(
                    label: t.nodeStage02,
                    bgColor: AppColors.sunshineYellow,
                    textColor: AppColors.ink,
                    icon: Icons.hourglass_top,
                  ),

                  // Pill 3: Locked Final (Soft Alabaster)
                  _buildPill(
                    label: t.nodeStage03,
                    bgColor: const Color(0xFFFFF0F3),
                    textColor: AppColors.textMuted,
                    icon: Icons.lock_outline,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          // 2. Continuous Visual Node Track: (30% —o— 30% —o— 40%)
          Row(
            children: [
              // Node 01
              _buildCircleNode(
                isPassed: true,
                color: AppColors.coralOrange,
                child: const Icon(Icons.check, size: 13, color: Colors.white),
              ),

              // Segment 1 Line (Coral Orange 30%)
              Expanded(
                child: Container(
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: AppColors.coralOrange,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),

              // Node 02
              _buildCircleNode(
                isPassed: activeIndex >= 1,
                color: AppColors.sunshineYellow,
                child: const Text(
                  '2',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
              ),

              // Segment 2 Line (Soft Rose-Gray 40%)
              Expanded(
                child: Container(
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE2E8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),

              // Node 03
              _buildCircleNode(
                isPassed: activeIndex >= 2,
                color: const Color(0xFFFDE2E8),
                child: const Icon(
                  Icons.lock,
                  size: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 3. Bottom Quota & Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.coralOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Escrow Milestone: Stage 02 / 03',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.rosePinkSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Revision: $revisionCount / $maxRevisions',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.coralOrange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleNode({
    required bool isPassed,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: AppColors.chipShadow,
      ),
      child: Center(child: child),
    );
  }

  Widget _buildPill({
    required String label,
    required Color bgColor,
    required Color textColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        boxShadow: AppColors.chipShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
