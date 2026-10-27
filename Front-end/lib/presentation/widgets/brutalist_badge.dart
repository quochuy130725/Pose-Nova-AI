import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// Fashion Sticker Badge
/// Stadium pill with hairline border, soft shadow, and Sunset Rose-Pink & Golden-Yellow accents.
class BrutalistBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isMonospace;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;

  const BrutalistBadge({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.sunshineYellow,
    this.textColor,
    this.icon,
    this.isMonospace = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
    this.borderRadius = 999.0, // Stadium Pill by default
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    Color resolvedBg = backgroundColor;
    Color resolvedText = textColor ?? AppColors.ink;

    if (backgroundColor == AppColors.cyber || backgroundColor == AppColors.emerald) {
      resolvedBg = AppColors.rosePinkSoft;
      resolvedText = textColor ?? AppColors.coralOrange;
    } else if (backgroundColor == AppColors.acid || backgroundColor == AppColors.electricYellow) {
      resolvedBg = AppColors.sunshineYellow;
      resolvedText = textColor ?? AppColors.ink;
    } else if (backgroundColor == AppColors.petrol || backgroundColor == AppColors.obsidian || backgroundColor == const Color(0xFF0D0F0E)) {
      resolvedBg = AppColors.ink;
      resolvedText = textColor ?? Colors.white;
    } else if (backgroundColor == AppColors.vermilion || backgroundColor == AppColors.disputeCrimson) {
      resolvedBg = AppColors.vermilion;
      resolvedText = textColor ?? Colors.white;
    }

    final Color effectiveBorder = borderColor ??
        (resolvedBg == AppColors.ink ? Colors.transparent : AppColors.hairlineBorder);

    return Container(
      decoration: BoxDecoration(
        color: resolvedBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveBorder,
          width: 1.0,
        ),
        boxShadow: AppColors.chipShadow,
      ),
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: resolvedText),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: resolvedText,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
