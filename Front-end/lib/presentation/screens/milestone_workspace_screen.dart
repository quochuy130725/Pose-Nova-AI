import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/milestone_model.dart';
import '../../data/models/styling_request_model.dart';
import '../../data/repositories/mock_repository.dart';
import '../widgets/brutalist_button.dart';
import '../widgets/compact_product_tag.dart';
import '../widgets/fashion_dock_button.dart';
import '../widgets/technical_grid_background.dart';
import 'client_main_shell.dart';
import 'dispute_review_screen.dart';
import 'stylist_wallet_screen.dart';

/// Multi-state Upload & AI Processing states for Stylist Deliverable
enum UploadState { idle, analyzing, tagged }

/// Vector Skeleton Overlay Painter rendering 33 AI Pose landmarks over fashion model photo
class SkeletonOverlayPainter extends CustomPainter {
  final bool showPoints;
  final bool showLines;
  final Color skeletonColor;

  SkeletonOverlayPainter({
    this.showPoints = true,
    this.showLines = true,
    this.skeletonColor = AppColors.cyber,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Map<int, Offset> landmarks = {
      0: Offset(size.width * 0.50, size.height * 0.16),
      1: Offset(size.width * 0.48, size.height * 0.14),
      2: Offset(size.width * 0.47, size.height * 0.14),
      3: Offset(size.width * 0.45, size.height * 0.14),
      4: Offset(size.width * 0.52, size.height * 0.14),
      5: Offset(size.width * 0.53, size.height * 0.14),
      6: Offset(size.width * 0.55, size.height * 0.14),
      7: Offset(size.width * 0.43, size.height * 0.16),
      8: Offset(size.width * 0.57, size.height * 0.16),
      9: Offset(size.width * 0.48, size.height * 0.19),
      10: Offset(size.width * 0.52, size.height * 0.19),
      11: Offset(size.width * 0.38, size.height * 0.26),
      12: Offset(size.width * 0.62, size.height * 0.26),
      13: Offset(size.width * 0.31, size.height * 0.38),
      14: Offset(size.width * 0.69, size.height * 0.37),
      15: Offset(size.width * 0.27, size.height * 0.49),
      16: Offset(size.width * 0.72, size.height * 0.48),
      17: Offset(size.width * 0.25, size.height * 0.52),
      18: Offset(size.width * 0.74, size.height * 0.51),
      19: Offset(size.width * 0.26, size.height * 0.53),
      20: Offset(size.width * 0.73, size.height * 0.52),
      21: Offset(size.width * 0.28, size.height * 0.51),
      22: Offset(size.width * 0.71, size.height * 0.50),
      23: Offset(size.width * 0.42, size.height * 0.52),
      24: Offset(size.width * 0.58, size.height * 0.52),
      25: Offset(size.width * 0.40, size.height * 0.70),
      26: Offset(size.width * 0.60, size.height * 0.69),
      27: Offset(size.width * 0.38, size.height * 0.88),
      28: Offset(size.width * 0.62, size.height * 0.88),
      29: Offset(size.width * 0.36, size.height * 0.92),
      30: Offset(size.width * 0.64, size.height * 0.92),
      31: Offset(size.width * 0.39, size.height * 0.95),
      32: Offset(size.width * 0.61, size.height * 0.95),
    };

    final List<List<int>> connections = [
      [11, 12],
      [11, 13], [13, 15], [15, 17], [15, 19], [15, 21],
      [12, 14], [14, 16], [16, 18], [16, 20], [16, 22],
      [11, 23], [12, 24], [23, 24],
      [23, 25], [25, 27], [27, 29], [27, 31], [29, 31],
      [24, 26], [26, 28], [28, 30], [28, 32], [30, 32],
      [0, 1], [1, 2], [2, 3], [3, 7],
      [0, 4], [4, 5], [5, 6], [6, 8],
      [9, 10],
    ];

    if (showLines) {
      final glowPaint = Paint()
        ..color = skeletonColor.withValues(alpha: 0.45)
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final linePaint = Paint()
        ..color = skeletonColor
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (final pair in connections) {
        final p1 = landmarks[pair[0]];
        final p2 = landmarks[pair[1]];
        if (p1 != null && p2 != null) {
          canvas.drawLine(p1, p2, glowPaint);
          canvas.drawLine(p1, p2, linePaint);
        }
      }
    }

    if (showPoints) {
      final pointGlow = Paint()
        ..color = skeletonColor.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;

      final pointRing = Paint()
        ..color = AppColors.ink
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke;

      final pointFill = Paint()
        ..color = AppColors.electricYellow
        ..style = PaintingStyle.fill;

      final centerWhite = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      landmarks.forEach((idx, pos) {
        final double r = (idx == 11 || idx == 12 || idx == 23 || idx == 24 || idx == 25 || idx == 26) ? 5.0 : 3.8;
        canvas.drawCircle(pos, r + 2.5, pointGlow);
        canvas.drawCircle(pos, r, pointFill);
        canvas.drawCircle(pos, r, pointRing);
        canvas.drawCircle(pos, r * 0.45, centerWhite);
      });
    }
  }

  @override
  bool shouldRepaint(covariant SkeletonOverlayPainter oldDelegate) =>
      oldDelegate.showPoints != showPoints ||
      oldDelegate.showLines != showLines ||
      oldDelegate.skeletonColor != skeletonColor;
}

/// Neo-Brutalist Dashed Border Painter for Stylist Deliverable Dropzone
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dash;
  final double gap;
  final double radius;

  DashedBorderPainter({
    this.color = AppColors.ink,
    this.strokeWidth = 2.5,
    this.dash = 8.0,
    this.gap = 5.0,
    this.radius = 24.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double len = (distance + dash < metric.length) ? dash : metric.length - distance;
        dashPath.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        distance += dash + gap;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) => false;
}

/// Screen 06 (Màn hình Đinh): Milestone Tracking Workspace
/// Redesigned under the "Street-Zine Neo-Pop" aesthetic
class MilestoneWorkspaceScreen extends StatefulWidget {
  final bool embeddedInShell;
  final bool isStylistView;

  const MilestoneWorkspaceScreen({
    super.key,
    this.embeddedInShell = false,
    this.isStylistView = false,
  });

  @override
  State<MilestoneWorkspaceScreen> createState() => _MilestoneWorkspaceScreenState();
}

class _MilestoneWorkspaceScreenState extends State<MilestoneWorkspaceScreen> {
  final MockRepository _repository = MockRepository();
  List<MilestoneModel>? _milestones;
  StylingRequestModel? _request;
  bool _isLoading = true;

  // Interactive demo states for Golden Path
  int _revisionCount = 1;
  final int _maxRevisions = 2;
  bool _stage2Approved = false;
  int _selectedStageIndex = 1; // Stage 2 active

  // Stylist View Deliverable Upload & Tag States
  UploadState _uploadState = UploadState.idle;
  String? _uploadedImageUrl;
  bool _hasProductTag = false;
  bool _isSubmitted = false;
  bool _showSkeletonOverlay = true;

  final TextEditingController _affiliateLinkController = TextEditingController(
    text: 'https://shopee.vn/cyber-utility-jacket-aw26-ltd',
  );
  final TextEditingController _curationNotesController = TextEditingController(
    text: 'Gợi ý phối cùng quần túi hộp ống rộng và boots đế cao.',
  );

  @override
  void initState() {
    super.initState();
    _uploadedImageUrl = widget.isStylistView
        ? null
        : 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=800&q=80';
    _uploadState = widget.isStylistView ? UploadState.idle : UploadState.tagged;
    _hasProductTag = !widget.isStylistView;
    _loadData();
  }

  @override
  void dispose() {
    _affiliateLinkController.dispose();
    _curationNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final milestones = await _repository.loadMilestones();
      final requests = await _repository.loadStylingRequests();
      setState(() {
        _milestones = milestones;
        if (requests.isNotEmpty) {
          _request = requests.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _handleRequestRevision() {
    if (_revisionCount < _maxRevisions) {
      showDialog(
        context: context,
        builder: (ctx) {
          final textCtrl = TextEditingController(
            text: 'Đổi quần cargo sang chất liệu vải kỹ thuật chống nước có viền phản quang.',
          );
          return AlertDialog(
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppColors.cardRadius),
              side: const BorderSide(color: AppColors.ink, width: AppColors.cardBorderWidth),
            ),
            title: Row(
              children: [
                const Icon(Icons.edit_note, color: AppColors.ink, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Yêu cầu chỉnh sửa',
                    style: AppTheme.headingStyle.copyWith(fontSize: 16),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.electricYellow,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                  child: Text(
                    'Lần sửa: ${_revisionCount + 1} / $_maxRevisions (Lần cuối miễn phí)',
                    style: AppTheme.monoStyle.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: textCtrl,
                  maxLines: 3,
                  style: AppTheme.bodyStyle.copyWith(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Nhập chi tiết yêu cầu Stylist chỉnh sửa...',
                    filled: true,
                    fillColor: AppColors.canvasGlow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.ink, width: 1.8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.ink, width: 1.8),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('HỦY', style: AppTheme.headingStyle.copyWith(color: AppColors.ink.withValues(alpha: 0.6))),
              ),
              BrutalistButton(
                text: 'GỬI FEEDBACK',
                backgroundColor: AppColors.electricYellow,
                textColor: AppColors.ink,
                height: 42,
                width: 130,
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _revisionCount++;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.obsidian,
                      content: Text(
                        'Đã gửi yêu cầu! Đã dùng: $_revisionCount / $_maxRevisions Free Revisions.',
                        style: const TextStyle(color: AppColors.electricYellow, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _handleApproveStage2() {
    setState(() {
      _stage2Approved = true;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppColors.cardRadius)),
          border: const Border(
            top: BorderSide(color: AppColors.ink, width: AppColors.cardBorderWidth),
            left: BorderSide(color: AppColors.ink, width: AppColors.cardBorderWidth),
            right: BorderSide(color: AppColors.ink, width: AppColors.cardBorderWidth),
          ),
          boxShadow: AppColors.hardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cyber,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ink, width: 2.0),
                    boxShadow: AppColors.chipShadow,
                  ),
                  child: const Icon(Icons.check, color: AppColors.ink, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giải ngân 30% Thành Công!',
                        style: AppTheme.headingStyle.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+382.500₫ đã vào Ví Stylist (Đã trừ 15% phí sàn)',
                        style: AppTheme.monoStyle.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.cyber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Giai đoạn 02: Outfit Selection & Tags đã được nghiệm thu. Giai đoạn 03: Final Lookbook & Pose đã được mở khóa!',
              style: AppTheme.bodyStyle.copyWith(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: BrutalistButton(
                    text: 'TIẾP TỤC THEO DÕI',
                    backgroundColor: AppColors.cardBackground,
                    textColor: AppColors.ink,
                    height: 48,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BrutalistButton(
                    text: 'XEM VÍ STYLIST →',
                    backgroundColor: AppColors.electricYellow,
                    textColor: AppColors.ink,
                    height: 48,
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StylistWalletScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.canvas,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.ink),
        ),
      );
    }

    return ListenableBuilder(
      listenable: AppLanguageController.instance,
      builder: (context, _) {
        final t = AppLanguageController.instance.t;

        return Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: widget.embeddedInShell
              ? null
              : AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Color(0xFF18181B)),
                  titleSpacing: 0,
                  title: Text(
                    widget.isStylistView
                        ? 'Stylist Studio • #REQ-8452'
                        : (t.isVi ? 'Theo Dõi Ký Quỹ' : 'Milestone Tracking'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF18181B),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 14.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFA7F3D0), width: 1.0),
                        ),
                        child: Text(
                          'ESCROW PROTECTED',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF059669),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          body: TechnicalGridBackground(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. Clean Editorial Header (Replaces 3 redundant trackers & 141px overflow) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Escrow Workspace',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF18181B),
                          letterSpacing: -0.6,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFA7F3D0), width: 1.0),
                        ),
                        child: Text(
                          '🔒 2.500.000đ Protected',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF059669),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // --- 2. Milestone Contract Section with Integrated Deliverables ---
                  _buildVerticalTimelineSection(t),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildStickyBottomActionBar(t),
        );
      },
    );
  }

  /// 2. Clean Editorial Milestone Contract Section
  Widget _buildVerticalTimelineSection(AppTranslations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.isStylistView ? 'Milestone Contract' : 'Service Progression',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF18181B),
              ),
            ),
            Text(
              'Total: ${CurrencyFormatter.formatVnd(_request?.budgetVnd ?? 2500000)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF71717A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // STAGE 01 CARD: Moodboard & Concept
        _buildEditorialMilestoneCard(
          badgeNumber: '01',
          title: 'Moodboard & Concept',
          statusText: 'Approved & Released',
          amountText: '750.000đ',
          percentageText: '30%',
          isHeroGradient: false,
          isActive: _selectedStageIndex == 0,
          isLocked: false,
          onTap: () => setState(() => _selectedStageIndex = 0),
        ),

        if (_selectedStageIndex == 0) ...[
          const SizedBox(height: 12),
          _buildDeliverablePreviewSection(t),
        ],

        const SizedBox(height: 12),

        // STAGE 02 CARD: Outfit Selection & Pose (Signature Soft Rose-Pink to Sunset-Peach Gradient)
        _buildEditorialMilestoneCard(
          badgeNumber: '02',
          title: 'Outfit Selection & Pose',
          statusText: widget.isStylistView
              ? (_isSubmitted
                  ? 'In Review • Ready for Client'
                  : (_uploadState == UploadState.tagged
                      ? 'Ready to Submit • Tagged'
                      : 'Active • Ready to Upload'))
              : (_stage2Approved ? 'Approved & Released' : 'Active • Ready to Review'),
          amountText: '750.000đ',
          percentageText: '30%',
          isHeroGradient: true,
          isActive: _selectedStageIndex == 1,
          isLocked: false,
          onTap: () => setState(() => _selectedStageIndex = 1),
        ),

        // DIRECTLY BELOW ACTIVE STAGE 02 CARD: UPLOAD DROPZONE / DELIVERABLE
        if (_selectedStageIndex == 1) ...[
          const SizedBox(height: 12),
          _buildDeliverablePreviewSection(t),
        ],

        const SizedBox(height: 12),

        // STAGE 03 CARD: Final Lookbook
        _buildEditorialMilestoneCard(
          badgeNumber: '03',
          title: 'Final Lookbook',
          statusText: _stage2Approved ? 'Ready to Unlock' : 'Locked',
          amountText: '1.000.000đ',
          percentageText: '40%',
          isHeroGradient: false,
          isActive: _selectedStageIndex == 2,
          isLocked: !_stage2Approved,
          onTap: () {
            if (_stage2Approved) {
              setState(() => _selectedStageIndex = 2);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    t.isVi
                        ? 'Mốc 03 đang khóa! Duyệt Mốc 02 để mở khóa hoàn toàn.'
                        : 'Stage 03 locked! Approve Stage 02 to unlock.',
                  ),
                ),
              );
            }
          },
        ),

        if (_selectedStageIndex == 2) ...[
          const SizedBox(height: 12),
          _buildDeliverablePreviewSection(t),
        ],
      ],
    );
  }

  /// Clean 2-Column Milestone Card:
  /// - Left: Circular Badge (01, 02, 03) + Title + Status Text
  /// - Right: Amount in bold typography + Percentage Pill
  Widget _buildEditorialMilestoneCard({
    required String badgeNumber,
    required String title,
    required String statusText,
    required String amountText,
    required String percentageText,
    required bool isHeroGradient,
    required bool isActive,
    required bool isLocked,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: isHeroGradient
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF472B6), Color(0xFFFB923C)],
                )
              : null,
          color: isHeroGradient ? null : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isHeroGradient
                ? Colors.white.withValues(alpha: 0.5)
                : (isActive ? const Color(0xFFF472B6) : const Color(0xFFF4F4F5)),
            width: (isActive && !isHeroGradient) ? 1.8 : 1.0,
          ),
          boxShadow: isHeroGradient
              ? const [
                  BoxShadow(
                    color: Color(0x3DF43F5E),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Column: Circular Badge
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isHeroGradient
                    ? Colors.white.withValues(alpha: 0.25)
                    : (isLocked ? const Color(0xFFF4F4F5) : const Color(0xFFFFF1F2)),
                shape: BoxShape.circle,
                border: isHeroGradient
                    ? Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.0)
                    : (isLocked ? null : Border.all(color: const Color(0xFFFFE4E6), width: 1.0)),
              ),
              alignment: Alignment.center,
              child: Text(
                badgeNumber,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isHeroGradient
                      ? Colors.white
                      : (isLocked ? const Color(0xFFA1A1AA) : const Color(0xFFE11D48)),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Left Column: Title & Status Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isHeroGradient
                          ? Colors.white
                          : (isLocked ? const Color(0xFFA1A1AA) : const Color(0xFF18181B)),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    statusText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isHeroGradient
                          ? Colors.white.withValues(alpha: 0.95)
                          : (isLocked ? const Color(0xFFA1A1AA) : const Color(0xFF71717A)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right Column: Amount in Bold Typography + Percentage Pill
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: isHeroGradient
                        ? Colors.white
                        : (isLocked ? const Color(0xFFA1A1AA) : const Color(0xFF18181B)),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: isHeroGradient
                        ? Colors.white.withValues(alpha: 0.25)
                        : const Color(0xFFF4F4F5),
                    borderRadius: BorderRadius.circular(999),
                    border: isHeroGradient
                        ? Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.0)
                        : Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
                  ),
                  child: Text(
                    percentageText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isHeroGradient
                          ? Colors.white
                          : (isLocked ? const Color(0xFFA1A1AA) : const Color(0xFF71717A)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 4. Khu vực DELIVERABLE PREVIEW (Upload Dropzone cho Stylist / Preview cho Client)
  Widget _buildDeliverablePreviewSection(AppTranslations t) {
    if (widget.isStylistView && _selectedStageIndex == 1) {
      switch (_uploadState) {
        case UploadState.idle:
          return _buildUploadDropzone(t);
        case UploadState.analyzing:
          return _buildAnalyzingStateCard(t);
        case UploadState.tagged:
          return _buildUploadedStylistDeliverable(t);
      }
    }

    final activeStage = _milestones != null && _milestones!.length > _selectedStageIndex
        ? _milestones![_selectedStageIndex]
        : null;

    final String stageTitle = _selectedStageIndex == 0
        ? (t.isVi ? 'Stage 01 • Moodboard & Concept' : 'Stage 01 • Moodboard Deliverable')
        : (_selectedStageIndex == 1
            ? (t.isVi ? 'Stage 02 • Phối Đồ & Thẻ Sản Phẩm' : 'Stage 02 • Outfit Selection & Tags')
            : (t.isVi ? 'Stage 03 • Lookbook Hoàn Chỉnh & Dáng AI' : 'Stage 03 • Final Lookbook & Pose'));

    final String badgeText = _selectedStageIndex == 0
        ? 'Moodboard'
        : (_selectedStageIndex == 1 ? 'Outfit Curation' : 'Final Lookbook');

    final String descText = _selectedStageIndex == 0
        ? (t.isVi
            ? 'Bản định hướng phong cách nghệ thuật, bảng màu và cảm hứng Cyber-Streetwear.'
            : 'Artistic style guide, color palette, and Cyber-Streetwear inspiration.')
        : (_selectedStageIndex == 1
            ? (t.isVi
                ? 'Bộ phối trang phục hoàn chỉnh kèm thẻ sản phẩm thương mại điện tử giá tốt.'
                : 'Curated complete outfit paired with verified e-commerce product tags.')
            : (t.isVi
                ? 'Bộ ảnh Lookbook chất lượng cao và tệp mẫu dáng 33 điểm mốc cho Camera AI.'
                : 'High-res Lookbook editorial and 33-landmark pose model for AI Camera.'));

    final String imageUrl = _selectedStageIndex == 0
        ? 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=800&q=80'
        : (_selectedStageIndex == 1
            ? (_uploadedImageUrl ?? 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=800&q=80')
            : 'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?auto=format&fit=crop&w=800&q=80');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF4F4F5), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  stageTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF18181B),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _selectedStageIndex == 0
                      ? const Color(0xFFECFDF5)
                      : (_selectedStageIndex == 1 ? const Color(0xFFFFF1F2) : const Color(0xFFF4F4F5)),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _selectedStageIndex == 0
                        ? const Color(0xFFA7F3D0)
                        : (_selectedStageIndex == 1 ? const Color(0xFFFFE4E6) : const Color(0xFFE4E4E7)),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: _selectedStageIndex == 0
                        ? const Color(0xFF059669)
                        : (_selectedStageIndex == 1 ? const Color(0xFFE11D48) : const Color(0xFF71717A)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            descText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: const Color(0xFF71717A),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Image.network(
                  imageUrl,
                  height: 310,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 310,
                    color: const Color(0xFFF4F4F5),
                    alignment: Alignment.center,
                    child: Text(
                      activeStage?.deliverableTitle ?? 'Deliverable Preview',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF71717A),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _selectedStageIndex == 0
                          ? "MOODBOARD '26"
                          : (_selectedStageIndex == 1 ? "OUTFIT CURATION" : "FINAL LOOKBOOK"),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _selectedStageIndex == 0 || (_selectedStageIndex == 2 && _stage2Approved)
                          ? const Color(0xFF059669)
                          : const Color(0xFFE11D48),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _selectedStageIndex == 0
                          ? (t.isVi ? 'Đã duyệt • 30%' : 'Approved • 30%')
                          : (_selectedStageIndex == 1
                              ? 'AI Pose Ready'
                              : (_stage2Approved ? 'Unlocked' : 'Locked')),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (_selectedStageIndex == 1 && _hasProductTag)
                  const Positioned(
                    bottom: 16,
                    left: 14,
                    child: CompactProductTag(
                      productName: 'Utility Jacket',
                      priceText: '1.250.000₫',
                    ),
                  ),
                if (_selectedStageIndex == 2 && !_stage2Approved)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.6),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF18181B),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_outline, size: 16, color: Color(0xFFF472B6)),
                            const SizedBox(width: 8),
                            Text(
                              'LOCKED • APPROVE STAGE 02 TO UNLOCK',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 10.5,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (_selectedStageIndex == 1 && !widget.isStylistView) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _revisionCount >= _maxRevisions
                    ? const Color(0xFFFFF1F2)
                    : const Color(0xFFF4F4F5),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _revisionCount >= _maxRevisions
                      ? const Color(0xFFFFE4E6)
                      : const Color(0xFFE4E4E7),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _revisionCount >= _maxRevisions
                        ? Icons.warning_amber_rounded
                        : Icons.replay_circle_filled_outlined,
                    size: 16,
                    color: _revisionCount >= _maxRevisions
                        ? const Color(0xFFE11D48)
                        : const Color(0xFF18181B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Revisions: ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF18181B),
                    ),
                  ),
                  Text(
                    '$_revisionCount / $_maxRevisions Used',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: _revisionCount >= _maxRevisions
                          ? const Color(0xFFE11D48)
                          : const Color(0xFF18181B),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _revisionCount >= _maxRevisions
                        ? (t.isVi ? 'Hết lượt miễn phí' : 'Quota exhausted')
                        : '(${_maxRevisions - _revisionCount} ${t.isVi ? 'còn lại' : 'left'})',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: _revisionCount >= _maxRevisions
                          ? const Color(0xFFE11D48)
                          : const Color(0xFF71717A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _startAiAnalysis(AppTranslations t) {
    setState(() {
      _uploadState = UploadState.analyzing;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _uploadedImageUrl =
              'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=800&q=80';
          _uploadState = UploadState.tagged;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.obsidian,
            content: Text(
              t.isVi
                  ? 'Google ML Kit đã trích xuất thành công 33 AI Pose Landmarks!'
                  : 'Google ML Kit successfully extracted 33 AI Pose Landmarks!',
              style: const TextStyle(color: AppColors.cyber, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    });
  }

  /// 4A. Upload Dropzone for Stylist (UploadState.idle)
  Widget _buildUploadDropzone(AppTranslations t) {
    return GestureDetector(
      onTap: () => _startAiAnalysis(t),
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: const Color(0xFFF472B6),
          strokeWidth: 2.0,
          radius: 24.0,
          dash: 8,
          gap: 5,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14F43F5E),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  size: 30,
                  color: Color(0xFFF43F5E),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Upload Lookbook Photo & Pose',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF18181B),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Support JPG, PNG • Auto-extracts 33 AI Pose Landmarks',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: const Color(0xFF71717A),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF472B6), Color(0xFFFB923C)],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33F43F5E),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_photo_alternate_outlined, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      t.isVi ? 'CHỌN ẢNH TỪ THƯ VIỆN' : 'CHOOSE LOOKBOOK PHOTO',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 4B. AI Scanning Animation Card (UploadState.analyzing)
  Widget _buildAnalyzingStateCard(AppTranslations t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF472B6).withValues(alpha: 0.35), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1AF43F5E),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF472B6), Color(0xFFFB923C)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.center_focus_strong,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Google ML Kit analyzing photo...',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF18181B),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Detecting 33 skeletal landmarks • Inferring 3D joint coordinates',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF71717A),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 6,
              child: const LinearProgressIndicator(
                backgroundColor: Color(0xFFFFF1F2),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF43F5E)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF43F5E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '30 FPS BLAZEPOSE PIPELINE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE11D48),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 4C. Giao diện Deliverable khi Stylist đã trích xuất Pose & sẵn sàng gắn Affiliate (UploadState.tagged)
  Widget _buildUploadedStylistDeliverable(AppTranslations t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF4F4F5), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14F43F5E),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'Stage 02 • Stylist Deliverable',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF18181B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFECFDF5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 12, color: Color(0xFF059669)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFFFE4E6), width: 1.0),
                ),
                child: Text(
                  '#AW26',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE11D48),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            t.isVi
                ? 'Ảnh Lookbook đã trích xuất khung xương 33 điểm mốc AI và sẵn sàng gắn link Affiliate.'
                : 'Lookbook outfit with 33 AI Pose landmarks extracted and ready for affiliate tagging.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: const Color(0xFF71717A),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  _uploadedImageUrl!,
                  height: 330,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 330,
                    color: const Color(0xFFF4F4F5),
                    alignment: Alignment.center,
                    child: const Text('Stylist Deliverable'),
                  ),
                ),
              ),

              if (_showSkeletonOverlay)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: SkeletonOverlayPainter(
                        skeletonColor: const Color(0xFFF472B6),
                      ),
                    ),
                  ),
                ),

              Positioned(
                top: 14,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181B).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF34D399),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '✓ 33 AI POSE LANDMARKS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 14,
                right: 12,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showSkeletonOverlay = !_showSkeletonOverlay;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _showSkeletonOverlay ? const Color(0xFFF43F5E) : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1F000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showSkeletonOverlay ? Icons.visibility : Icons.visibility_off,
                              size: 13,
                              color: _showSkeletonOverlay ? Colors.white : const Color(0xFF18181B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Skeleton',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: _showSkeletonOverlay ? Colors.white : const Color(0xFF18181B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _uploadState = UploadState.idle;
                          _uploadedImageUrl = null;
                          _hasProductTag = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1F000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.refresh, size: 13, color: Color(0xFF18181B)),
                            const SizedBox(width: 4),
                            Text(
                              'Change',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF18181B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_hasProductTag)
                const Positioned(
                  bottom: 18,
                  left: 14,
                  child: CompactProductTag(
                    productName: 'Utility Jacket',
                    priceText: '1.250.000₫',
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // STEP 3: AFFILIATE PRODUCT TAGGING SECTION
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF4F4F5), width: 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF1F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.link, size: 14, color: Color(0xFFF43F5E)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AFFILIATE PRODUCT TAGGING',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF18181B),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _hasProductTag ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _hasProductTag ? const Color(0xFFA7F3D0) : const Color(0xFFFFE4E6),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        _hasProductTag ? '✓ PINNED (1)' : 'WAITING LINK',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: _hasProductTag ? const Color(0xFF059669) : const Color(0xFFE11D48),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 18, color: Color(0xFF71717A)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _affiliateLinkController,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF18181B),
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Nhập link Shopee affiliate...',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      _hasProductTag = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF18181B),
                        content: Text(
                          t.isVi
                              ? 'Đã xác thực Shopee Affiliate & ghim thẻ [Utility Jacket • 1.250.000 VND]!'
                              : 'Shopee Affiliate validated & pinned [Utility Jacket • 1.250.000 VND]!',
                          style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: _hasProductTag
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFFF472B6), Color(0xFFFB923C)],
                            ),
                      color: _hasProductTag ? const Color(0xFFECFDF5) : null,
                      borderRadius: BorderRadius.circular(999),
                      border: _hasProductTag ? Border.all(color: const Color(0xFFA7F3D0), width: 1.0) : null,
                      boxShadow: _hasProductTag
                          ? null
                          : const [
                              BoxShadow(
                                color: Color(0x33F43F5E),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _hasProductTag ? Icons.check_circle : Icons.add_link,
                          size: 16,
                          color: _hasProductTag ? const Color(0xFF059669) : Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _hasProductTag ? 'ĐÃ GHIM THẺ MUA HÀNG ✓' : '+ Gắn Link Mua Hàng',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _hasProductTag ? const Color(0xFF059669) : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'GỢI Ý PHỐI ĐỒ (CURATOR NOTES)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF71717A),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
                  ),
                  child: TextField(
                    controller: _curationNotesController,
                    maxLines: 2,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF18181B),
                      height: 1.3,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Direct "Publish & Submit (Stage 02) →" button inside Stage 02
          GestureDetector(
            onTap: () {
              if (_uploadState != UploadState.tagged) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF18181B),
                    content: Text(
                      t.isVi
                          ? 'Vui lòng tải ảnh Lookbook trước khi xuất bản!'
                          : 'Please upload Lookbook photo before publishing!',
                      style: const TextStyle(color: Color(0xFFF472B6), fontWeight: FontWeight.bold),
                    ),
                  ),
                );
                return;
              }

              setState(() {
                _isSubmitted = true;
                _hasProductTag = true;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color(0xFF18181B),
                  duration: Duration(seconds: 3),
                  content: Text(
                    'Đã lưu vào Feed & gửi thông báo nghiệm thu sang Khách hàng Alex Đỗ!',
                    style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF472B6), Color(0xFFFB923C)],
                ),
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x3DF43F5E),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isSubmitted ? Icons.check_circle : Icons.arrow_forward,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isSubmitted
                        ? (t.isVi ? 'ĐÃ XUẤT BẢN • ĐANG CHỜ ALEX ĐỖ DUYỆT ✓' : 'PUBLISHED • AWAITING APPROVAL ✓')
                        : (t.isVi ? 'XUẤT BẢN & GỬI DUYỆT (STAGE 02) →' : 'PUBLISH & SUBMIT (STAGE 02) →'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isSubmitted) ...[
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA7F3D0), width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified, size: 20, color: Color(0xFF059669)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'ĐÃ LƯU VÀO FEED & GỬI DUYỆT!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF065F46),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Đã lưu vào Feed & gửi thông báo nghiệm thu sang Khách hàng Alex Đỗ!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF047857),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ClientMainShell(initialTabIndex: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF18181B),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF34D399),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Chuyển sang Client View để nghiệm thu ↗',
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
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 5. Sticky Bottom Action Bar
  Widget _buildStickyBottomActionBar(AppTranslations t) {
    if (widget.isStylistView) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFF4F4F5), width: 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FashionDockButton(
              text: _isSubmitted
                  ? (t.isVi ? 'ĐÃ XUẤT BẢN • ĐANG CHỜ ALEX ĐỖ DUYỆT ✓' : 'PUBLISHED • AWAITING APPROVAL ✓')
                  : (t.isVi ? 'XUẤT BẢN & GỬI DUYỆT (STAGE 02) →' : 'PUBLISH & SUBMIT (STAGE 02) →'),
              icon: _isSubmitted ? Icons.check_circle : Icons.arrow_forward,
              onPressed: () {
                if (_uploadState != UploadState.tagged) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF18181B),
                      content: Text(
                        t.isVi
                            ? 'Vui lòng tải ảnh Lookbook trước khi xuất bản!'
                            : 'Please upload Lookbook photo before publishing!',
                        style: const TextStyle(color: Color(0xFFF472B6), fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  _isSubmitted = true;
                  _hasProductTag = true;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFF18181B),
                    duration: Duration(seconds: 3),
                    content: Text(
                      'Đã lưu vào Feed & gửi thông báo nghiệm thu sang Khách hàng Alex Đỗ!',
                      style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFF18181B),
                    content: Text(
                      'Đã lưu bản nháp thành công!',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
              child: Container(
                height: 44,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save_outlined, size: 16, color: Color(0xFF71717A)),
                    const SizedBox(width: 6),
                    Text(
                      'Lưu Bản Nháp',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF71717A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Client View Action Bar
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF4F4F5), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FashionDockButton(
            text: _stage2Approved
                ? t.stage2ApprovedContinueBtn
                : t.approveStage2Btn,
            icon: _stage2Approved ? Icons.verified : Icons.lock_open,
            onPressed: _stage2Approved
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đang ở Mốc 03: Final Lookbook & AI Pose.'),
                      ),
                    );
                  }
                : _handleApproveStage2,
          ),

          const SizedBox(height: 10),

          if (!_stage2Approved) ...[
            if (_revisionCount < _maxRevisions)
              GestureDetector(
                onTap: _handleRequestRevision,
                child: Container(
                  height: 44,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.edit_note, size: 16, color: Color(0xFF18181B)),
                      const SizedBox(width: 6),
                      Text(
                        t.requestRevisionBtn(_revisionCount, _maxRevisions),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF18181B),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DisputeReviewScreen(isDisputeMode: true),
                    ),
                  );
                },
                child: Container(
                  height: 44,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.gavel, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        t.openDisputeBtn,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
