import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';

/// Language Switcher Pill (VI / EN)
/// Segmented pill with hairline border and Coral-Orange active state.
class LanguageSwitchPill extends StatelessWidget {
  final bool compact;

  const LanguageSwitchPill({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLanguageController.instance,
      builder: (context, _) {
        final isVi = AppLanguageController.instance.isVietnamese;

        return Container(
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
            boxShadow: AppColors.chipShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // VI Segment
              _buildSegment(
                label: compact ? 'VI' : '🇻🇳 VI',
                isActive: isVi,
                activeBg: AppColors.coralOrange,
                onTap: () => AppLanguageController.instance.setLanguage(AppLanguage.vi),
              ),
              const SizedBox(width: 2),
              // EN Segment
              _buildSegment(
                label: compact ? 'EN' : '🇬🇧 EN',
                isActive: !isVi,
                activeBg: AppColors.coralOrange,
                onTap: () => AppLanguageController.instance.setLanguage(AppLanguage.en),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSegment({
    required String label,
    required bool isActive,
    required Color activeBg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8.0 : 10.0,
          vertical: 3.5,
        ),
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: compact ? 10.0 : 10.5,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textMuted,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
