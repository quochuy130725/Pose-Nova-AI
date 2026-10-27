import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Stylofy × Street-Zine Card
/// Crisp White (#FFFFFF) or Pastel surface with 2.0px solid Deep Petrol (#0B3B49) border,
/// 24px border-radius, and 4px crisp Petrol offset shadow (4px 4px 0px #0B3B49).
class BrutalistCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderWidth;
  final double borderRadius;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const BrutalistCard({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.all(18.0),
    this.margin = EdgeInsets.zero,
    this.borderWidth = AppColors.cardBorderWidth,
    this.borderRadius = AppColors.cardRadius,
    this.borderColor,
    this.shadows = AppColors.softDribbbleShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.hairlineBorder,
          width: borderWidth,
        ),
        boxShadow: shadows ?? AppColors.softDribbbleShadow,
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
