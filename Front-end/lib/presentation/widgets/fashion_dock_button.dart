import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// Sunset Rose-Pink & Golden-Yellow Dock Button
/// Glossy Coral-Orange gradient (#FF8A3D -> #FF5E2B) dock with soft glow shadow,
/// wrapping a clean white/coral inner pill with an arrow icon.
class FashionDockButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;
  final IconData icon;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color textColor;
  final Color? arrowBadgeColor;
  final Color arrowIconColor;

  const FashionDockButton({
    super.key,
    required this.text,
    this.onPressed,
    this.height = 52.0,
    this.icon = Icons.arrow_forward,
    this.backgroundColor,
    this.gradient,
    this.textColor = Colors.white,
    this.arrowBadgeColor,
    this.arrowIconColor = AppColors.coralOrange,
    List<Color>? gradientColors,
  });

  @override
  State<FashionDockButton> createState() => _FashionDockButtonState();
}

class _FashionDockButtonState extends State<FashionDockButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
    final Gradient dockGradient = widget.gradient ?? AppColors.primaryGradient;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: widget.height,
        transform: Matrix4.translationValues(
          _isPressed ? 1.0 : 0.0,
          _isPressed ? 1.0 : 0.0,
          0.0,
        ),
        decoration: BoxDecoration(
          gradient: isEnabled ? dockGradient : null,
          color: isEnabled ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1.0,
          ),
          boxShadow: isEnabled && !_isPressed
              ? AppColors.buttonShadow
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: widget.textColor,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.arrowBadgeColor ?? Colors.white,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                size: 16,
                color: widget.arrowIconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
