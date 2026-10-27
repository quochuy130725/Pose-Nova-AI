import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/brutalist_badge.dart';

/// Screen 02: AI Pose Camera – 30 FPS Skeleton Overlay
/// Matches the exact "AI Virtual Try-On Fashion" Dribbble reference (Middle Screen):
/// - Soft Pink-to-Yellow aura border and white corner brackets ([ ])
/// - Top glass pill: "Scanning Pose..." + match score
/// - Bottom glossy Coral-Orange pill button: "Take a Picture (30 FPS)"
class PoseCameraScreen extends StatefulWidget {
  const PoseCameraScreen({super.key});

  @override
  State<PoseCameraScreen> createState() => _PoseCameraScreenState();
}

class _PoseCameraScreenState extends State<PoseCameraScreen> {
  bool _isMatched = false;
  int _countdown = 3;
  Timer? _countdownTimer;
  bool _isShutterFlashed = false;

  void _triggerMatch() {
    setState(() {
      _isMatched = true;
      _countdown = 3;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        // Trigger auto shutter flash
        setState(() => _isShutterFlashed = true);
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _isShutterFlashed = false);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.ink,
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.cyber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Auto-Shutter: Ảnh tạo dáng đã được chụp và lưu!',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int score = _isMatched ? 94 : 65;
    final int angleDiff = _isMatched ? 4 : 18;
    final Color skeletonColor = _isMatched ? AppColors.sunshineYellow : AppColors.rosePink;

    return Scaffold(
      backgroundColor: const Color(0xFF181513),
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Central Camera Viewport with Pink-to-Yellow Aura Frame
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 70, 16, 120),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF221E1B),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Soft Rose-Pink to Golden-Yellow Aura Border Outline
                        CustomPaint(
                          painter: _AuraBorderPainter(),
                        ),

                        // Skeleton CustomPaint
                        CustomPaint(
                          painter: _SkeletonPainter(
                            color: skeletonColor,
                            isDashed: !_isMatched,
                          ),
                        ),

                        // 4 White/Gold Corner Brackets: [  ]
                        const Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: _CornerBracketsOverlay(),
                          ),
                        ),

                        // Top "Scanning Pose..." Glass Pill
                        Positioned(
                          top: 18,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Colors.white24, width: 0.8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: _isMatched ? AppColors.sunshineYellow : AppColors.rosePink,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isMatched ? 'Pose Matched (94%)' : 'Scanning Pose... (30 FPS)',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Match Score HUD Pill
                        Positioned(
                          bottom: 18,
                          left: 18,
                          right: 18,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: _isMatched ? AppColors.sunshineYellow : AppColors.rosePink,
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bolt, size: 16, color: _isMatched ? AppColors.sunshineYellow : AppColors.rosePink),
                                const SizedBox(width: 6),
                                Text(
                                  'Match Score: $score%  |  Diff: $angleDiff°',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Top Header HUD Bar
              Positioned(
                top: 14,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'AI Virtual Try-On',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const BrutalistBadge(
                      label: '30 FPS AI',
                      backgroundColor: AppColors.sunshineYellow,
                      isMonospace: false,
                    ),
                  ],
                ),
              ),

              // 3. Picture-in-Picture Reference Photo
              Positioned(
                top: 85,
                right: 28,
                child: Container(
                  width: 80,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white38, width: 1.0),
                    boxShadow: AppColors.softDribbbleShadow,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=400&q=80',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.7),
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            'Target',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              color: AppColors.sunshineYellow,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Countdown Timer Banner
              if (_isMatched && _countdown > 0)
                Positioned(
                  top: 220,
                  left: 36,
                  right: 36,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppColors.bannerGradient,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: AppColors.chipShadow,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer, size: 16, color: AppColors.ink),
                        const SizedBox(width: 8),
                        Text(
                          'Giữ dáng trong $_countdown giây...',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 5. Bottom Controls: Glossy Coral-Orange Button "Take a Picture (30 FPS)"
              Positioned(
                bottom: 16,
                left: 18,
                right: 18,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glossy Coral-Orange Pill Button
                    GestureDetector(
                      onTap: () {
                        if (_isMatched) {
                          setState(() {
                            _isMatched = false;
                            _countdownTimer?.cancel();
                          });
                        } else {
                          _triggerMatch();
                        }
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: AppColors.buttonShadow,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              _isMatched ? 'Chụp Ngay (Auto Shutter)' : 'Take a Picture (30 FPS)',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // White Camera Flash effect
              if (_isShutterFlashed)
                Positioned.fill(
                  child: Container(color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 4 Corner Brackets Overlay: [  ]
class _CornerBracketsOverlay extends StatelessWidget {
  const _CornerBracketsOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CornerBracketsPainter(),
    );
  }
}

class _CornerBracketsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double arm = 22.0;

    // Top-Left
    canvas.drawLine(const Offset(0, 0), const Offset(arm, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, arm), paint);

    // Top-Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - arm, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, arm), paint);

    // Bottom-Left
    canvas.drawLine(Offset(0, size.height), Offset(arm, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - arm), paint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - arm, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - arm), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Soft Rose-Pink to Golden-Yellow Aura Border Painter
class _AuraBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(28),
    );

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFF9EBB),
          Color(0xFFFFE066),
        ],
      ).createShader(Offset.zero & size)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SkeletonPainter extends CustomPainter {
  final Color color;
  final bool isDashed;

  _SkeletonPainter({required this.color, required this.isDashed});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double cx = size.width / 2;
    final double cy = size.height * 0.45;

    // Head circle
    canvas.drawCircle(Offset(cx, cy - 80), 22, paint);

    // Shoulders
    final leftShoulder = Offset(cx - 50, cy - 40);
    final rightShoulder = Offset(cx + 50, cy - 40);
    canvas.drawLine(leftShoulder, rightShoulder, paint);

    // Spine
    final midHip = Offset(cx, cy + 60);
    canvas.drawLine(Offset(cx, cy - 40), midHip, paint);

    // Arms
    final leftElbow = Offset(cx - 75, cy + 10);
    final leftHand = Offset(cx - 90, cy + 60);
    canvas.drawLine(leftShoulder, leftElbow, paint);
    canvas.drawLine(leftElbow, leftHand, paint);

    final rightElbow = Offset(cx + 75, cy + 10);
    final rightHand = Offset(cx + 90, cy + 60);
    canvas.drawLine(rightShoulder, rightElbow, paint);
    canvas.drawLine(rightElbow, rightHand, paint);

    // Legs
    final leftHip = Offset(cx - 30, cy + 60);
    final rightHip = Offset(cx + 30, cy + 60);
    canvas.drawLine(leftHip, rightHip, paint);

    final leftKnee = Offset(cx - 40, cy + 130);
    final leftAnkle = Offset(cx - 45, cy + 190);
    canvas.drawLine(leftHip, leftKnee, paint);
    canvas.drawLine(leftKnee, leftAnkle, paint);

    final rightKnee = Offset(cx + 40, cy + 130);
    final rightAnkle = Offset(cx + 45, cy + 190);
    canvas.drawLine(rightHip, rightKnee, paint);
    canvas.drawLine(rightKnee, rightAnkle, paint);

    // Landmark dots
    for (final pt in [
      leftShoulder,
      rightShoulder,
      leftElbow,
      rightElbow,
      leftHand,
      rightHand,
      leftHip,
      rightHip,
      leftKnee,
      rightKnee,
      leftAnkle,
      rightAnkle,
    ]) {
      canvas.drawCircle(pt, 4.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SkeletonPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isDashed != isDashed;
  }
}
