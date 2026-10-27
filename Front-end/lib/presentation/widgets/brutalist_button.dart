import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// Sunset Rose-Pink & Golden-Yellow Design System Button
/// Glossy Coral-Orange gradient (#FF8A3D -> #FF5E2B) or Frosted White / Warm Amber pill
/// with soft warm glow shadow and tactile press translation.
class BrutalistButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color textColor;
  final IconData? icon;
  final Widget? trailing;
  final double height;
  final double? width;
  final bool isFullWidth;
  final double borderWidth;
  final double borderRadius;
  final Color? borderColor;

  const BrutalistButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.gradient,
    this.textColor = Colors.white,
    this.icon,
    this.trailing,
    this.height = 50.0,
    this.width,
    this.isFullWidth = true,
    this.borderWidth = 1.0,
    this.borderRadius = 999.0, // Stadium Pill
    this.borderColor,
  });

  @override
  State<BrutalistButton> createState() => _BrutalistButtonState();
}

class _BrutalistButtonState extends State<BrutalistButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;

    // Default to Sunset Coral-Orange Gradient if no solid color or gradient specified
    final bool useDefaultGradient = widget.backgroundColor == null && widget.gradient == null;
    final Gradient? effectiveGradient = widget.gradient ?? (useDefaultGradient ? AppColors.primaryGradient : null);
    final Color? effectiveBgColor = effectiveGradient != null ? null : (widget.backgroundColor ?? AppColors.coralOrange);

    final Color effectiveBorderColor = widget.borderColor ??
        (effectiveBgColor == Colors.white
            ? AppColors.hairlineBorder
            : Colors.white.withValues(alpha: 0.18));

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: widget.isFullWidth ? double.infinity : widget.width,
        height: widget.height,
        transform: Matrix4.translationValues(
          _isPressed ? 1.0 : 0.0,
          _isPressed ? 1.0 : 0.0,
          0.0,
        ),
        decoration: BoxDecoration(
          color: isEnabled ? effectiveBgColor : Colors.grey.shade300,
          gradient: isEnabled ? effectiveGradient : null,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: effectiveBorderColor,
            width: widget.borderWidth,
          ),
          boxShadow: isEnabled && !_isPressed
              ? AppColors.buttonShadow
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: widget.textColor, size: 18),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: widget.textColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            if (widget.trailing != null) ...[
              const SizedBox(width: 8),
              widget.trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
