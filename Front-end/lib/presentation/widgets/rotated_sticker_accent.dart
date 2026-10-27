import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// Fashion Sticker Accent Pill
/// Upright pill with hairline border and soft ambient shadow.
class RotatedStickerAccent extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double angle;

  const RotatedStickerAccent({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.sunshineYellow,
    this.textColor = AppColors.ink,
    this.angle = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.hairlineBorder,
          width: 1.0,
        ),
        boxShadow: AppColors.chipShadow,
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: textColor,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
