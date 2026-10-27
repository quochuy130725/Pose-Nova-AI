import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Luminous Sunset Rose-Pink & Golden-Yellow Mesh Gradient Canvas Background
/// Matches the exact "AI Virtual Try-On Fashion" Dribbble aesthetic:
/// - Top-Right Glow: Soft Rose Pink / Blush Coral (#FFC2D1 -> #FF9EBB)
/// - Top-Left / Center Glow: Warm Golden Sunlight (#FFF0A5 -> #FFE066)
/// - Lower Canvas: Clean Warm Pearl White (#FFFDFB)
class TechnicalGridBackground extends StatelessWidget {
  final Widget child;
  final double gridSpacing;
  final Color? gridColor;

  const TechnicalGridBackground({
    super.key,
    required this.child,
    this.gridSpacing = 24.0,
    this.gridColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.canvas,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Dreamy Multi-Stop Mesh Aura
          Positioned.fill(
            child: CustomPaint(
              painter: _SunsetMeshGradientPainter(),
            ),
          ),
          // 2. Forefront Content
          child,
        ],
      ),
    );
  }
}

/// Alias for semantic clarity
typedef MeshGradientBackground = TechnicalGridBackground;

class _SunsetMeshGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final rect = Offset.zero & size;

    // Base fill: Soft Sakura Pink (#FDF2F7)
    final basePaint = Paint()..color = const Color(0xFFFDF2F7);
    canvas.drawRect(rect, basePaint);

    // 1. Top-Left / Center Peach Glow (#FED7AA)
    final peachCenter = Offset(size.width * 0.12, size.height * 0.16);
    final peachRadius = size.width * 0.88;
    final peachPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.65, -0.70),
        radius: 0.90,
        colors: [
          const Color(0xFFFED7AA).withValues(alpha: 0.55),
          const Color(0xFFFED7AA).withValues(alpha: 0.25),
          const Color(0xFFFDF2F7).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(Rect.fromCircle(center: peachCenter, radius: peachRadius));
    canvas.drawCircle(peachCenter, peachRadius, peachPaint);

    // 2. Top-Right Pastel Flamingo Pink Glow (#FBCFE8)
    final flamingoCenter = Offset(size.width * 0.88, size.height * 0.14);
    final flamingoRadius = size.width * 0.92;
    final flamingoPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.75, -0.75),
        radius: 0.92,
        colors: [
          const Color(0xFFFBCFE8).withValues(alpha: 0.60),
          const Color(0xFFFCE7F3).withValues(alpha: 0.30),
          const Color(0xFFFDF2F7).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.52, 1.0],
      ).createShader(Rect.fromCircle(center: flamingoCenter, radius: flamingoRadius));
    canvas.drawCircle(flamingoCenter, flamingoRadius, flamingoPaint);

    // 3. Lower Canvas Soft Sakura Pink Fade Overlay
    final fadePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.45, 1.0],
        colors: [
          Colors.transparent,
          const Color(0xFFFDF2F7).withValues(alpha: 0.4),
          const Color(0xFFFDF2F7),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, fadePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
