import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';

/// 3-Stage Capsule Stepper (Sunset Rose-Pink, Sunshine Yellow, Coral-Orange)
/// - Stage 1: Soft Rose-Pink (#FFF0F5) [✓ Approved • 30%]
/// - Stage 2: Vibrant Sunshine Yellow (#FFD400) [In Review • 30%]
/// - Stage 3: Soft Pearl Alabaster (#FFF0F3) [Locked • 40%]
class NestedPillStepper extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int>? onSelectIndex;

  const NestedPillStepper({
    super.key,
    this.activeIndex = 1,
    this.onSelectIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.hairlineBorder,
          width: 1.0,
        ),
        boxShadow: AppColors.softDribbbleShadow,
      ),
      child: ListenableBuilder(
        listenable: AppLanguageController.instance,
        builder: (context, _) {
          final t = AppLanguageController.instance.t;

          return Row(
            children: [
              // Segment 1: Rose-Pink (#FFF0F5)
              Expanded(
                child: _buildSegment(
                  index: 0,
                  label: t.isVi ? '✓ Duyệt • 30%' : '✓ Approved • 30%',
                  backgroundColor: AppColors.rosePinkSoft,
                  textColor: AppColors.coralOrange,
                  isActive: activeIndex == 0,
                ),
              ),
              const SizedBox(width: 4),

              // Segment 2: Sunshine Yellow (#FFD400)
              Expanded(
                child: _buildSegment(
                  index: 1,
                  label: t.isVi ? 'Đang duyệt • 30%' : 'In Review • 30%',
                  backgroundColor: AppColors.sunshineYellow,
                  textColor: AppColors.ink,
                  isActive: activeIndex == 1,
                ),
              ),
              const SizedBox(width: 4),

              // Segment 3: Soft Pearl (#FFF0F3)
              Expanded(
                child: _buildSegment(
                  index: 2,
                  label: t.isVi ? 'Khóa • 40%' : 'Locked • 40%',
                  backgroundColor: const Color(0xFFFFF0F3),
                  textColor: AppColors.textMuted,
                  isActive: activeIndex == 2,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSegment({
    required int index,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onSelectIndex != null ? () => onSelectIndex!(index) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 38,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? AppColors.coralOrange : Colors.transparent,
            width: isActive ? 1.8 : 1.0,
          ),
          boxShadow: isActive ? AppColors.chipShadow : null,
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            color: textColor,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
