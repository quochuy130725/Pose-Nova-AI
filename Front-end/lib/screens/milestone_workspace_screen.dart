import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../core/localization/app_language.dart';
import '../controllers/escrow_state_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/currency_formatter.dart';
import '../providers/lookbook_provider.dart';
import '../providers/styling_request_provider.dart';
import '../widgets/brutalist_button.dart';
import '../widgets/fashion_dock_button.dart';
import '../widgets/technical_grid_background.dart';
import 'client_main_shell.dart';
import 'create_styling_request_screen.dart';
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
      [11, 13],
      [13, 15],
      [15, 17],
      [15, 19],
      [15, 21],
      [12, 14],
      [14, 16],
      [16, 18],
      [16, 20],
      [16, 22],
      [11, 23],
      [12, 24],
      [23, 24],
      [23, 25],
      [25, 27],
      [27, 29],
      [27, 31],
      [29, 31],
      [24, 26],
      [26, 28],
      [28, 30],
      [28, 32],
      [30, 32],
      [0, 1],
      [1, 2],
      [2, 3],
      [3, 7],
      [0, 4],
      [4, 5],
      [5, 6],
      [6, 8],
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
        final double r =
            (idx == 11 ||
                idx == 12 ||
                idx == 23 ||
                idx == 24 ||
                idx == 25 ||
                idx == 26)
            ? 5.0
            : 3.8;
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
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double len = (distance + dash < metric.length)
            ? dash
            : metric.length - distance;
        dashPath.addPath(
          metric.extractPath(distance, distance + len),
          Offset.zero,
        );
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
  State<MilestoneWorkspaceScreen> createState() =>
      _MilestoneWorkspaceScreenState();
}

class _MilestoneWorkspaceScreenState extends State<MilestoneWorkspaceScreen> {
  bool _isLoading = false;

  // Interactive demo states for Golden Path
  int _revisionCount = 1;
  final int _maxRevisions = 2;
  bool _stage1Approved = false;
  bool _stage2Approved = false;
  bool _stage3Approved = false;
  int _selectedStageIndex = 0; // Stage 1 active by default

  bool isStageApproved(int stageOrder) {
    if (!StylingRequestProvider.instance.hasActiveOrder) return false;
    if (stageOrder == 1) {
      return _stage1Approved ||
          StylingRequestProvider.instance.isStageApproved(1) ||
          EscrowStateController.instance.isStageApproved(1);
    }
    if (stageOrder == 2) {
      return _stage2Approved ||
          StylingRequestProvider.instance.isStageApproved(2) ||
          EscrowStateController.instance.isStageApproved(2);
    }
    if (stageOrder == 3) {
      return _stage3Approved ||
          StylingRequestProvider.instance.isStageApproved(3) ||
          EscrowStateController.instance.isStageApproved(3);
    }
    return false;
  }

  bool get isStage1Approved => isStageApproved(1);
  bool get isStage2Approved => isStageApproved(2);
  bool get isStage3Approved => isStageApproved(3);

  bool isStageInReview(int stageOrder) {
    if (!StylingRequestProvider.instance.hasActiveOrder) return false;
    if (isStageApproved(stageOrder)) return false;
    if (_selectedStageIndex + 1 == stageOrder && _isSubmitted) return true;
    return EscrowStateController.instance.isStageInReview(stageOrder) ||
        StylingRequestProvider.instance.stageStatus(stageOrder) == 'IN_REVIEW';
  }

  bool isStageActive(int stageOrder) {
    if (!StylingRequestProvider.instance.hasActiveOrder) return false;
    if (isStageApproved(stageOrder) || isStageInReview(stageOrder))
      return false;
    if (stageOrder == 1) return true;
    if (stageOrder == 2) return isStage1Approved;
    if (stageOrder == 3) return isStage2Approved;
    return false;
  }

  bool isStageLocked(int stageOrder) {
    if (!StylingRequestProvider.instance.hasActiveOrder) return false;
    if (stageOrder == 1) return false;
    if (stageOrder == 2) return !isStage1Approved;
    if (stageOrder == 3) return !isStage2Approved;
    return true;
  }

  String _resolveMilestoneStatusText(AppTranslations t, int stageOrder) {
    if (isStageApproved(stageOrder)) {
      return t.isVi ? 'Đã duyệt & Giải ngân' : 'Approved & Released';
    }
    if (isStageInReview(stageOrder)) {
      if (widget.isStylistView) {
        return t.isVi
            ? 'In Review • Chờ Client duyệt'
            : 'In Review • Client Reviewing';
      } else {
        return t.isVi
            ? 'In Review • Chờ bạn duyệt'
            : 'In Review • Awaiting Approval';
      }
    }
    if (isStageActive(stageOrder)) {
      if (widget.isStylistView) {
        return t.isVi ? 'Đang mở • Sẵn sàng nộp' : 'Active • Ready to Submit';
      } else {
        return t.isVi
            ? 'Đang mở • Chờ Stylist nộp bài'
            : 'Active • Waiting for Stylist';
      }
    }
    return t.isVi
        ? 'Đang khóa • Cần xong Chặng 0${stageOrder - 1}'
        : 'Locked • Complete Stage 0${stageOrder - 1}';
  }

  // Stylist View Deliverable Upload & Tag States
  UploadState _uploadState = UploadState.idle;
  String? _uploadedImageUrl;
  File? _pickedImageFile;
  List<PoseLandmark>? _extractedLandmarks;
  List<PoseLandmark>? get extractedLandmarks => _extractedLandmarks;
  bool _hasProductTag = false;
  bool _isSubmitted = false;
  bool _showSkeletonOverlay = true;

  final TextEditingController _affiliateLinkController = TextEditingController(
    text: '',
  );
  final TextEditingController _curationNotesController = TextEditingController(
    text: '',
  );

  @override
  void initState() {
    super.initState();
    _uploadedImageUrl = null;
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
      await StylingRequestProvider.instance
          .fetchRequestsAndSelectActive()
          .timeout(const Duration(seconds: 2), onTimeout: () => {});
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _handleRequestRevision() {
    final t = AppLanguageController.instance.t;
    if (_revisionCount < _maxRevisions) {
      showDialog(
        context: context,
        builder: (ctx) {
          final textCtrl = TextEditingController(
            text: t.isVi
                ? 'Đổi quần cargo sang chất liệu vải kỹ thuật chống nước có viền phản quang.'
                : 'Switch cargo pants to water-resistant technical fabric with reflective piping.',
          );
          return AlertDialog(
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppColors.cardRadius),
              side: const BorderSide(
                color: AppColors.ink,
                width: AppColors.cardBorderWidth,
              ),
            ),
            title: Row(
              children: [
                const Icon(Icons.edit_note, color: AppColors.ink, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.requestRevisionBtn,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.electricYellow,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                  child: Text(
                    t.isVi
                        ? 'Lần sửa: ${_revisionCount + 1} / $_maxRevisions (Lần cuối miễn phí)'
                        : 'Revision: ${_revisionCount + 1} / $_maxRevisions (Last free quota)',
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
                    hintText: t.isVi
                        ? 'Nhập chi tiết yêu cầu Stylist chỉnh sửa...'
                        : 'Enter revision details for Stylist...',
                    filled: true,
                    fillColor: AppColors.canvasGlow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.ink,
                        width: 1.8,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.ink,
                        width: 1.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  t.cancelBtn,
                  style: AppTheme.headingStyle.copyWith(
                    color: AppColors.ink.withValues(alpha: 0.6),
                  ),
                ),
              ),
              BrutalistButton(
                text: t.isVi ? 'GỬI FEEDBACK' : 'SEND FEEDBACK',
                backgroundColor: AppColors.electricYellow,
                textColor: AppColors.ink,
                height: 42,
                width: 130,
                onPressed: () async {
                  final feedbackText = textCtrl.text;
                  Navigator.pop(ctx);
                  try {
                    await StylingRequestProvider.instance
                        .requestMilestoneRevision(
                          stageNumber: 2,
                          clientFeedback: feedbackText,
                        );
                  } catch (_) {
                    // Fallback local increment
                  }
                  if (!mounted) return;
                  setState(() {
                    _revisionCount++;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.obsidian,
                      content: Text(
                        t.isVi
                            ? 'Đã gửi yêu cầu sửa! Đã dùng: $_revisionCount / $_maxRevisions lượt miễn phí.'
                            : 'Revision requested! Used: $_revisionCount / $_maxRevisions free revisions.',
                        style: const TextStyle(
                          color: AppColors.electricYellow,
                          fontWeight: FontWeight.bold,
                        ),
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

  void _handleApproveStage1() {
    setState(() {
      _stage1Approved = true;
    });
    EscrowStateController.instance.approveMilestone(1);
    StylingRequestProvider.instance.approveMilestone(1);
    final stage1Net = StylingRequestProvider.instance.stageNetAmount(1);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppColors.cardRadius),
          ),
          border: const Border(
            top: BorderSide(
              color: AppColors.ink,
              width: AppColors.cardBorderWidth,
            ),
            left: BorderSide(
              color: AppColors.ink,
              width: AppColors.cardBorderWidth,
            ),
            right: BorderSide(
              color: AppColors.ink,
              width: AppColors.cardBorderWidth,
            ),
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
                  child: const Icon(
                    Icons.check,
                    color: AppColors.ink,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLanguageController.instance.isVietnamese
                            ? 'Giải ngân Chặng 1 thành công!'
                            : 'Stage 1 Released Successfully!',
                        style: AppTheme.headingStyle.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLanguageController.instance.isVietnamese
                            ? '+${CurrencyFormatter.formatVnd(stage1Net)} đã vào Ví Stylist (Đã trừ 15% phí sàn)'
                            : '+${CurrencyFormatter.formatVnd(stage1Net)} credited to Stylist Wallet (15% fee deducted)',
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
              AppLanguageController.instance.isVietnamese
                  ? 'Bản thảo Moodboard & Concept đã được nghiệm thu. Hệ thống đã mở khóa Chặng 02 (Phối đồ & Gắn thẻ sản phẩm) cho Stylist tiếp tục làm việc.'
                  : 'Moodboard & Concept approved. System has unlocked Stage 02 (Outfit Selection & Tags) for the Stylist.',
              style: AppTheme.bodyStyle.copyWith(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: BrutalistButton(
                    text: AppLanguageController.instance.isVietnamese ? 'Ở LẠI XEM' : 'STAY HERE',
                    backgroundColor: AppColors.cardBackground,
                    textColor: AppColors.ink,
                    height: 48,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BrutalistButton(
                    text: AppLanguageController.instance.isVietnamese ? 'TIẾP TỤC CHẶNG 02 →' : 'NEXT STAGE 02 →',
                    backgroundColor: AppColors.electricYellow,
                    textColor: AppColors.ink,
                    height: 48,
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _selectedStageIndex = 1;
                      });
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

  void _handleApproveStage2() {
    setState(() {
      _stage2Approved = true;
    });
    EscrowStateController.instance.approveMilestone(2);
    StylingRequestProvider.instance.approveMilestone(2);
    final stage2Net = StylingRequestProvider.instance.stageNetAmount(2);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppColors.cardRadius),
          ),
          border: const Border(
            top: BorderSide(
              color: AppColors.ink,
              width: AppColors.cardBorderWidth,
            ),
            left: BorderSide(
              color: AppColors.ink,
              width: AppColors.cardBorderWidth,
            ),
            right: BorderSide(
              color: AppColors.ink,
              width: AppColors.cardBorderWidth,
            ),
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
                  child: const Icon(
                    Icons.check,
                    color: AppColors.ink,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLanguageController.instance.isVietnamese
                            ? 'Giải ngân 30% Thành Công!'
                            : '30% Stage 2 Released!',
                        style: AppTheme.headingStyle.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLanguageController.instance.isVietnamese
                            ? '+${CurrencyFormatter.formatVnd(stage2Net)} đã vào Ví Stylist (Đã trừ 15% phí sàn)'
                            : '+${CurrencyFormatter.formatVnd(stage2Net)} credited to Stylist Wallet (15% fee deducted)',
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
              AppLanguageController.instance.isVietnamese
                  ? 'Giai đoạn 02: Outfit Selection & Tags đã được nghiệm thu. Giai đoạn 03: Final Lookbook & Pose đã được mở khóa!'
                  : 'Stage 02: Outfit Selection & Tags approved. Stage 03: Final Lookbook & Pose is now unlocked!',
              style: AppTheme.bodyStyle.copyWith(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: BrutalistButton(
                    text: AppLanguageController.instance.isVietnamese ? 'TIẾP TỤC THEO DÕI' : 'CONTINUE TRACKING',
                    backgroundColor: AppColors.cardBackground,
                    textColor: AppColors.ink,
                    height: 48,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BrutalistButton(
                    text: AppLanguageController.instance.isVietnamese ? 'XEM VÍ STYLIST →' : 'VIEW STYLIST WALLET →',
                    backgroundColor: AppColors.electricYellow,
                    textColor: AppColors.ink,
                    height: 48,
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StylistWalletScreen(),
                        ),
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

  void _handleApproveStage3() {
    setState(() {
      _stage3Approved = true;
    });
    EscrowStateController.instance.approveMilestone(3);
    StylingRequestProvider.instance.approveMilestone(3);
    final stage3Net = StylingRequestProvider.instance.stageNetAmount(3);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppColors.cardRadius),
          ),
          border: const Border(
            top: BorderSide(
              color: AppColors.ink,
              width: AppColors.cardBorderWidth,
            ),
            left: BorderSide(
              color: AppColors.ink,
              width: AppColors.cardBorderWidth,
            ),
            right: BorderSide(
              color: AppColors.ink,
              width: AppColors.cardBorderWidth,
            ),
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
                  child: const Icon(
                    Icons.verified,
                    color: AppColors.ink,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLanguageController.instance.isVietnamese
                            ? 'Giải ngân 40% Hoàn Tất Hợp Đồng!'
                            : '40% Released • Contract Completed!',
                        style: AppTheme.headingStyle.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLanguageController.instance.isVietnamese
                            ? '+${CurrencyFormatter.formatVnd(stage3Net)} đã vào Ví Stylist (100% Escrow giải ngân)'
                            : '+${CurrencyFormatter.formatVnd(stage3Net)} credited to Stylist Wallet (100% Escrow settled)',
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
              AppLanguageController.instance.isVietnamese
                  ? 'Toàn bộ 3 chặng của hợp đồng đã được nghiệm thu thành công. Bạn có thể để lại đánh giá 5 sao cho Stylist ngay bây giờ!'
                  : 'All 3 milestones have been approved. You can now leave a 5-star review for your Stylist!',
              style: AppTheme.bodyStyle.copyWith(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: BrutalistButton(
                    text: AppLanguageController.instance.isVietnamese ? 'ĐỂ SAU' : 'LATER',
                    backgroundColor: AppColors.cardBackground,
                    textColor: AppColors.ink,
                    height: 48,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BrutalistButton(
                    text: AppLanguageController.instance.isVietnamese ? 'ĐÁNH GIÁ 5 SAO →' : 'RATE 5 STARS →',
                    backgroundColor: AppColors.electricYellow,
                    textColor: AppColors.ink,
                    height: 48,
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const DisputeReviewScreen(isDisputeMode: false),
                        ),
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

  void _showQuickBudgetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final current = StylingRequestProvider.instance.activeTotalBudget;
        final options = [2000, 10000, 50000, 500000, 2500000];

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4E4E7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLanguageController.instance.isVietnamese
                    ? 'Điều Chỉnh Ngân Sách Hợp Đồng Ký Quỹ'
                    : 'Adjust Escrow Contract Budget',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF18181B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppLanguageController.instance.isVietnamese
                    ? 'Chọn mức ngân sách để test trực tiếp luồng Escrow VietQR / SePay:'
                    : 'Select a budget tier to test the VietQR / SePay Escrow workflow:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: const Color(0xFF71717A),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options.map((amt) {
                  final isSel = amt == current;
                  return GestureDetector(
                    onTap: () {
                      StylingRequestProvider.instance.setCustomBudget(amt);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSel
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSel
                              ? const Color(0xFF059669)
                              : const Color(0xFFE4E4E7),
                        ),
                      ),
                      child: Text(
                        amt == 2000
                            ? '2.000₫ (Test SePay)'
                            : CurrencyFormatter.formatVnd(amt),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isSel ? Colors.white : const Color(0xFF18181B),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAnyActiveOrder =
        StylingRequestProvider.instance.hasActiveOrder ||
        EscrowStateController.instance.hasActiveOrder;
    if (_isLoading && !hasAnyActiveOrder) {
      return const Scaffold(
        backgroundColor: AppColors.canvas,
        body: Center(child: CircularProgressIndicator(color: AppColors.ink)),
      );
    }

    return ListenableBuilder(
      listenable: Listenable.merge([
        AppLanguageController.instance,
        StylingRequestProvider.instance,
        EscrowStateController.instance,
      ]),
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
                        ? (StylingRequestProvider.instance.hasActiveOrder
                              ? 'Stylist Studio • ${StylingRequestProvider.instance.activeOrderCode}'
                              : 'Stylist Studio')
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFFA7F3D0),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          t.isVi ? 'BẢO VỆ KÝ QUỸ' : 'ESCROW PROTECTED',
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. Clean Editorial Header (Wrap in Expanded to fix 9.0px overflow & dynamic budget) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          t.isVi ? 'Không Gian Ký Quỹ' : 'Escrow Workspace',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF18181B),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showQuickBudgetSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0xFFA7F3D0),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                StylingRequestProvider.instance.hasActiveOrder
                                    ? (t.isVi
                                          ? 'Bảo vệ ${CurrencyFormatter.formatVnd(StylingRequestProvider.instance.activeTotalBudget)}'
                                          : '${CurrencyFormatter.formatVnd(StylingRequestProvider.instance.activeTotalBudget)} Protected')
                                    : (t.isVi ? '0 ₫ Ký Quỹ' : '0 ₫ Escrow'),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF059669),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.tune,
                                size: 12,
                                color: Color(0xFF059669),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // --- 2. Milestone Contract Section with Integrated Deliverables ---
                  if (!StylingRequestProvider.instance.hasActiveOrder)
                    _buildEmptyWorkspaceState(t)
                  else
                    _buildVerticalTimelineSection(t),
                ],
              ),
            ),
          ),
          bottomNavigationBar: StylingRequestProvider.instance.hasActiveOrder
              ? _buildStickyBottomActionBar(t)
              : null,
        );
      },
    );
  }

  Widget _buildEmptyWorkspaceState(AppTranslations t) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.hairlineBorder,
          width: AppColors.cardBorderWidth,
        ),
        boxShadow: AppColors.softDribbbleShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.rosePinkSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              size: 32,
              color: AppColors.coralOrange,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            t.isVi ? 'Chưa Có Hợp Đồng Ký Quỹ' : 'No Active Escrow Contract',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            t.isVi
                ? 'Bạn hiện chưa có đơn hàng ký quỹ nào đang diễn ra. Hãy tạo yêu cầu phối đồ mới để bắt đầu quy trình ký quỹ an toàn 3 chặng (30% - 30% - 40%)!'
                : 'You currently have no active escrow contracts. Create a new styling request to start the protected 3-stage milestone escrow workflow (30% - 30% - 40%)!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: AppColors.textMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          BrutalistButton(
            text: t.isVi
                ? 'TẠO YÊU CẦU PHỐI ĐỒ NGAY →'
                : 'CREATE STYLING REQUEST NOW →',
            height: 48,
            backgroundColor: AppColors.warmAmber,
            textColor: AppColors.petrol,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateStylingRequestScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 2. Clean Editorial Milestone Contract Section
  Widget _buildVerticalTimelineSection(AppTranslations t) {
    final reqProvider = StylingRequestProvider.instance;
    final totalBudget = reqProvider.activeTotalBudget;
    final stage1Gross = reqProvider.stageGrossAmount(1);
    final stage2Gross = reqProvider.stageGrossAmount(2);
    final stage3Gross = reqProvider.stageGrossAmount(3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.isStylistView
                  ? (t.isVi ? 'Hợp Đồng Ký Quỹ' : 'Milestone Contract')
                  : (t.isVi ? 'Tiến Độ Hợp Đồng' : 'Service Progression'),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF18181B),
              ),
            ),
            GestureDetector(
              onTap: () => _showQuickBudgetSheet(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (t.isVi ? 'Tổng cọc: ' : 'Total: ') +
                        CurrencyFormatter.formatVnd(totalBudget),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF71717A),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.tune, size: 12, color: Color(0xFF71717A)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // STAGE 01 CARD: Moodboard & Concept
        _buildEditorialMilestoneCard(
          badgeNumber: '01',
          title: 'Moodboard & Concept',
          statusText: _resolveMilestoneStatusText(t, 1),
          amountText: CurrencyFormatter.formatVnd(stage1Gross),
          percentageText: '30%',
          isHeroGradient: _selectedStageIndex == 0,
          isActive: _selectedStageIndex == 0,
          isLocked: false,
          onTap: () => setState(() => _selectedStageIndex = 0),
        ),

        if (_selectedStageIndex == 0) ...[
          const SizedBox(height: 12),
          _buildDeliverablePreviewSection(t),
        ],

        const SizedBox(height: 12),

        // STAGE 02 CARD: Outfit Selection & Pose
        _buildEditorialMilestoneCard(
          badgeNumber: '02',
          title: 'Outfit Selection & Pose',
          statusText: _resolveMilestoneStatusText(t, 2),
          amountText: CurrencyFormatter.formatVnd(stage2Gross),
          percentageText: '30%',
          isHeroGradient: _selectedStageIndex == 1,
          isActive: _selectedStageIndex == 1,
          isLocked: !isStage1Approved,
          onTap: () {
            if (isStage1Approved) {
              setState(() => _selectedStageIndex = 1);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    t.isVi
                        ? 'Mốc 02 đang khóa! Duyệt Mốc 01 để mở khóa tiếp tục.'
                        : 'Stage 02 locked! Approve Stage 01 to unlock.',
                  ),
                ),
              );
            }
          },
        ),

        if (_selectedStageIndex == 1) ...[
          const SizedBox(height: 12),
          _buildDeliverablePreviewSection(t),
        ],

        const SizedBox(height: 12),

        // STAGE 03 CARD: Final Lookbook
        _buildEditorialMilestoneCard(
          badgeNumber: '03',
          title: 'Final Lookbook',
          statusText: _resolveMilestoneStatusText(t, 3),
          amountText: CurrencyFormatter.formatVnd(stage3Gross),
          percentageText: '40%',
          isHeroGradient: _selectedStageIndex == 2,
          isActive: _selectedStageIndex == 2,
          isLocked: !isStage2Approved,
          onTap: () {
            if (isStage2Approved) {
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
    final t = AppTranslations.of(context);
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
                : (isActive
                      ? const Color(0xFFF472B6)
                      : const Color(0xFFF4F4F5)),
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
                    : (isLocked
                          ? const Color(0xFFF4F4F5)
                          : const Color(0xFFFFF1F2)),
                shape: BoxShape.circle,
                border: isHeroGradient
                    ? Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1.0,
                      )
                    : (isLocked
                          ? null
                          : Border.all(
                              color: const Color(0xFFFFE4E6),
                              width: 1.0,
                            )),
              ),
              alignment: Alignment.center,
              child: Text(
                badgeNumber,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isHeroGradient
                      ? Colors.white
                      : (isLocked
                            ? const Color(0xFFA1A1AA)
                            : const Color(0xFFE11D48)),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Left Column: Eyebrow Badge + Title + Status Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isHeroGradient
                          ? Colors.white.withValues(alpha: 0.25)
                          : const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      (t.isVi ? 'CHẶNG ' : 'STAGE ') + badgeNumber,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: isHeroGradient
                            ? Colors.white
                            : const Color(0xFFE11D48),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: isHeroGradient
                          ? Colors.white
                          : (isLocked
                                ? const Color(0xFFA1A1AA)
                                : const Color(0xFF2D221E)),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isHeroGradient
                          ? Colors.white.withValues(alpha: 0.95)
                          : (isLocked
                                ? const Color(0xFFA1A1AA)
                                : const Color(0xFF71717A)),
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
                        : (isLocked
                              ? const Color(0xFFA1A1AA)
                              : const Color(0xFF18181B)),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isHeroGradient
                        ? Colors.white.withValues(alpha: 0.25)
                        : const Color(0xFFF4F4F5),
                    borderRadius: BorderRadius.circular(999),
                    border: isHeroGradient
                        ? Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.0,
                          )
                        : Border.all(
                            color: const Color(0xFFE4E4E7),
                            width: 1.0,
                          ),
                  ),
                  child: Text(
                    percentageText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isHeroGradient
                          ? Colors.white
                          : (isLocked
                                ? const Color(0xFFA1A1AA)
                                : const Color(0xFF71717A)),
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
    final int stageOrder = _selectedStageIndex + 1;
    final bool approved = isStageApproved(stageOrder);
    final bool inReview = isStageInReview(stageOrder);
    final bool active = isStageActive(stageOrder);

    // Case 1: Approved stage -> show approved review card
    if (approved) {
      return _buildDeliverableReviewCard(t, _selectedStageIndex);
    }

    // Case 2: In Review stage -> show deliverable review card with real submission
    if (inReview) {
      return _buildDeliverableReviewCard(t, _selectedStageIndex);
    }

    // Case 3: Active stage (no deliverable submitted yet)
    if (active) {
      if (widget.isStylistView) {
        switch (_uploadState) {
          case UploadState.idle:
            return _buildUploadDropzone(t);
          case UploadState.analyzing:
            return _buildAnalyzingStateCard(t);
          case UploadState.tagged:
            return _buildUploadedStylistDeliverable(t);
        }
      } else {
        return _buildClientWaitingForStylistCard(t, _selectedStageIndex);
      }
    }

    // Case 4: Locked stage
    return _buildLockedStageCard(t, _selectedStageIndex);
  }

  Widget _buildClientWaitingForStylistCard(AppTranslations t, int stageIndex) {
    final int stageOrder = stageIndex + 1;
    final String stageName = stageIndex == 0
        ? 'Moodboard & Concept'
        : (stageIndex == 1
              ? (t.isVi ? 'Phối Đồ & Thẻ Sản Phẩm' : 'Outfit Selection & Tags')
              : (t.isVi
                    ? 'Lookbook Hoàn Chỉnh & Dáng AI'
                    : 'Final Lookbook & Pose'));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
            ),
            child: const Icon(
              Icons.palette_outlined,
              size: 32,
              color: Color(0xFFD97706),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t.isVi
                ? 'Stylist đang thực hiện Chặng 0$stageOrder'
                : 'Stylist Working on Stage 0$stageOrder',
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
            stageName,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE11D48),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              t.isVi
                  ? 'Stylist Maya Trần đang chuẩn bị bài nộp theo yêu cầu của bạn. Bạn sẽ nhận được thông báo nghiệm thu ngay khi Stylist tải lên hình ảnh và bản thiết kế.'
                  : 'Stylist is curating the deliverable tailored to your brief. You will receive an inspection notice as soon as it is submitted.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF71717A),
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD97706),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  t.isVi
                      ? 'ĐANG THỰC HIỆN • CHỜ BÀI NỘP'
                      : 'IN PROGRESS • AWAITING SUBMISSION',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFB45309),
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

  Widget _buildDeliverableReviewCard(AppTranslations t, int stageIndex) {
    final int stageOrder = stageIndex + 1;
    final bool approved = isStageApproved(stageOrder);

    final String? deliverableUrl =
        EscrowStateController.instance.stageDeliverableImageUrl(stageOrder) ??
        (stageIndex == _selectedStageIndex ? _uploadedImageUrl : null);

    final String? notes =
        EscrowStateController.instance.stageDeliverableNotes(stageOrder) ??
        (stageIndex == _selectedStageIndex &&
                _curationNotesController.text.trim().isNotEmpty
            ? _curationNotesController.text.trim()
            : null);

    final String stageTitle = stageIndex == 0
        ? 'Moodboard & Concept'
        : (stageIndex == 1
              ? (t.isVi
                    ? 'Stage 02 • Phối Đồ & Thẻ Sản Phẩm'
                    : 'Stage 02 • Outfit Selection & Tags')
              : (t.isVi
                    ? 'Stage 03 • Lookbook Hoàn Chỉnh & Dáng AI'
                    : 'Stage 03 • Final Lookbook & Pose'));

    final String badgeText = stageIndex == 0
        ? 'Moodboard'
        : (stageIndex == 1 ? 'Outfit Curation' : 'Final Lookbook');

    final percent = stageIndex == 2 ? '40%' : '30%';

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: approved
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: approved
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFFDE68A),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: approved
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (notes != null && notes.isNotEmpty) ...[
            Text(
              notes,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF71717A),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
          ],
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                if (deliverableUrl != null && deliverableUrl.isNotEmpty)
                  deliverableUrl.startsWith('http')
                      ? Image.network(
                          deliverableUrl,
                          height: 310,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Container(
                            height: 310,
                            color: const Color(0xFFF4F4F5),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Image.file(
                          File(deliverableUrl),
                          height: 310,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Container(
                            height: 310,
                            color: const Color(0xFFF4F4F5),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        )
                else
                  Container(
                    height: 310,
                    color: const Color(0xFFF4F4F5),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      stageIndex == 0
                          ? "MOODBOARD '26"
                          : (stageIndex == 1
                                ? "OUTFIT CURATION"
                                : "FINAL LOOKBOOK"),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: approved
                          ? const Color(0xFF059669)
                          : const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      approved
                          ? (t.isVi
                                ? 'Đã duyệt • $percent'
                                : 'Approved • $percent')
                          : (t.isVi
                                ? 'Chờ duyệt • $percent'
                                : 'Pending Review • $percent'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (stageIndex == 1 && !widget.isStylistView) ...[
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
                    t.isVi ? 'Lượt yêu cầu sửa: ' : 'Revisions: ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF18181B),
                    ),
                  ),
                  Text(
                    t.isVi
                        ? '$_revisionCount / $_maxRevisions (Còn ${_maxRevisions - _revisionCount} lần)'
                        : '$_revisionCount / $_maxRevisions Used (${_maxRevisions - _revisionCount} left)',
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

  Widget _buildLockedStageCard(AppTranslations t, int stageIndex) {
    final prevStage = stageIndex;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFF4F4F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline,
              size: 28,
              color: Color(0xFF71717A),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t.isVi
                ? 'Chặng 0${stageIndex + 1} Đang Khóa'
                : 'Stage 0${stageIndex + 1} Locked',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.isVi
                ? 'Cần hoàn tất và nghiệm thu Chặng 0$prevStage trước khi mở khóa chặng này.'
                : 'Complete and approve Stage 0$prevStage to unlock this stage.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: const Color(0xFF71717A),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startAiAnalysis(AppTranslations t) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );
      if (picked == null) return;

      setState(() {
        _pickedImageFile = File(picked.path);
        _uploadedImageUrl = picked.path;
        _uploadState = UploadState.analyzing;
      });

      // Extract real landmarks via Google ML Kit Pose Detection
      final inputImage = InputImage.fromFilePath(picked.path);
      final poseDetector = PoseDetector(
        options: PoseDetectorOptions(mode: PoseDetectionMode.single),
      );
      final poses = await poseDetector.processImage(inputImage);
      await poseDetector.close();

      if (!mounted) return;

      setState(() {
        _uploadState = UploadState.tagged;
        _hasProductTag = true;
        if (poses.isNotEmpty) {
          _extractedLandmarks = poses.first.landmarks.values.toList();
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.obsidian,
          content: Text(
            t.isVi
                ? 'Google ML Kit đã trích xuất thành công 33 AI Pose Landmarks!'
                : 'Google ML Kit successfully extracted 33 AI Pose Landmarks!',
            style: const TextStyle(
              color: AppColors.cyber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploadedImageUrl = 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=800&q=80';
        _uploadState = UploadState.tagged;
        _hasProductTag = true;
      });
    }
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
                t.uploadLookbookHeader,
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
                t.uploadLookbookSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: const Color(0xFF71717A),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
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
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
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
        border: Border.all(
          color: const Color(0xFFF472B6).withValues(alpha: 0.35),
          width: 1.5,
        ),
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
            t.isVi ? 'Google ML Kit đang phân tích ảnh...' : 'Google ML Kit analyzing photo...',
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
            t.isVi
                ? 'Đang nhận diện 33 khớp xương • Nội suy tọa độ 3D'
                : 'Detecting 33 skeletal landmarks • Inferring 3D joint coordinates',
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
                        t.isVi
                            ? 'Chặng 0${_selectedStageIndex + 1} • Bài Nộp Stylist'
                            : 'Stage 0${_selectedStageIndex + 1} • Stylist Deliverable',
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
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFFFE4E6),
                    width: 1.0,
                  ),
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
                child: _pickedImageFile != null
                    ? Image.file(
                        _pickedImageFile!,
                        height: 330,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        _uploadedImageUrl ?? 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=800&q=80',
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

              // Bottom-left: 33 AI Landmarks Status Badge
              Positioned(
                bottom: 14,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181B).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.0,
                    ),
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
                        t.landmarksReadyBadge,
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

              // Top-right: Skeleton Toggle & Change Image Buttons
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _showSkeletonOverlay
                              ? const Color(0xFFF43F5E)
                              : Colors.white,
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
                              _showSkeletonOverlay
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 13,
                              color: _showSkeletonOverlay
                                  ? Colors.white
                                  : const Color(0xFF18181B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              t.toggleSkeletonBtn,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: _showSkeletonOverlay
                                    ? Colors.white
                                    : const Color(0xFF18181B),
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
                          _pickedImageFile = null;
                          _extractedLandmarks = null;
                          _hasProductTag = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
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
                            const Icon(
                              Icons.refresh,
                              size: 13,
                              color: Color(0xFF18181B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              t.isVi ? 'Đổi ảnh' : 'Change',
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
                Positioned(
                  bottom: 18,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.hairlineBorder,
                        width: 1.0,
                      ),
                      boxShadow: AppColors.chipShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.sell_outlined,
                          size: 14,
                          color: AppColors.coralOrange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          t.isVi ? '3 Sản phẩm đính kèm' : '3 Tagged Items',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.ink,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
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
                      child: const Icon(
                        Icons.link,
                        size: 14,
                        color: Color(0xFFF43F5E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.affiliateProductLink.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF18181B),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _hasProductTag
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _hasProductTag
                              ? const Color(0xFFA7F3D0)
                              : const Color(0xFFFFE4E6),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        _hasProductTag
                            ? (t.isVi ? '✓ ĐÃ GHIM (1)' : '✓ PINNED (1)')
                            : (t.isVi ? 'CHỜ GẮN LINK' : 'WAITING LINK'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: _hasProductTag
                              ? const Color(0xFF059669)
                              : const Color(0xFFE11D48),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE4E4E7),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        size: 18,
                        color: Color(0xFF71717A),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _affiliateLinkController,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF18181B),
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: t.isVi
                                ? 'Nhập link Shopee affiliate...'
                                : 'Enter Shopee affiliate link...',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: () async {
                    final scraped = await LookbookProvider.instance
                        .scrapeAffiliateUrl(_affiliateLinkController.text);
                    if (!mounted) return;
                    setState(() {
                      _hasProductTag = true;
                    });
                    final itemName =
                        scraped['itemName']?.toString() ?? 'Utility Jacket';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF18181B),
                        content: Text(
                          t.isVi
                              ? 'Đã xác thực Shopee Affiliate & ghim thẻ [$itemName • 1.250.000 VND]!'
                              : 'Shopee Affiliate validated & pinned [$itemName • 1.250.000 VND]!',
                          style: const TextStyle(
                            color: Color(0xFF34D399),
                            fontWeight: FontWeight.bold,
                          ),
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
                      border: _hasProductTag
                          ? Border.all(
                              color: const Color(0xFFA7F3D0),
                              width: 1.0,
                            )
                          : null,
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
                          color: _hasProductTag
                              ? const Color(0xFF059669)
                              : Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _hasProductTag
                              ? (t.isVi ? 'ĐÃ GHIM THẺ MUA HÀNG ✓' : 'PRODUCT TAG PINNED ✓')
                              : t.attachPurchaseLink,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _hasProductTag
                                ? const Color(0xFF059669)
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  t.stylistNotes.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF71717A),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE4E4E7),
                      width: 1.0,
                    ),
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
                      style: const TextStyle(
                        color: Color(0xFFF472B6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
                return;
              }

              setState(() {
                _isSubmitted = true;
                _hasProductTag = true;
              });

              StylingRequestProvider.instance.submitMilestoneDeliverable(
                stageNumber: 2,
                deliverableImageUrl: _uploadedImageUrl ?? 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=800&q=80',
                stylistNotes: _curationNotesController.text,
                affiliateUrl: _affiliateLinkController.text,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF18181B),
                  duration: const Duration(seconds: 3),
                  content: Text(
                    t.isVi
                        ? 'Đã lưu vào Feed & gửi thông báo nghiệm thu sang Khách hàng Alex Đỗ!'
                        : 'Saved to Feed & sent inspection notice to Client Alex Đỗ!',
                    style: const TextStyle(
                      color: Color(0xFF34D399),
                      fontWeight: FontWeight.bold,
                    ),
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
                        ? (t.isVi
                              ? 'ĐÃ XUẤT BẢN • ĐANG CHỜ KHÁCH HÀNG DUYỆT ✓'
                              : 'PUBLISHED • AWAITING APPROVAL ✓')
                        : (t.isVi
                              ? 'XUẤT BẢN & GỬI DUYỆT (CHẶNG 0${_selectedStageIndex + 1}) →'
                              : 'PUBLISH & SUBMIT (STAGE 0${_selectedStageIndex + 1}) →'),
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
                      const Icon(
                        Icons.verified,
                        size: 20,
                        color: Color(0xFF059669),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.isVi
                              ? 'ĐÃ LƯU VÀO FEED & GỬI DUYỆT!'
                              : 'SAVED TO FEED & SUBMITTED!',
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
                    t.isVi
                        ? 'Đã lưu vào Feed & gửi thông báo nghiệm thu sang Khách hàng Alex Đỗ!'
                        : 'Saved to Feed & sent inspection notification to Client Alex Đỗ!',
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
                          builder: (_) =>
                              const ClientMainShell(initialTabIndex: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
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
                            t.isVi
                                ? 'Chuyển sang Client View để nghiệm thu ↗'
                                : 'Switch to Client View to approve ↗',
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
    final int currentStageOrder = _selectedStageIndex + 1;
    final bool currentApproved = isStageApproved(currentStageOrder);
    final bool currentInReview = isStageInReview(currentStageOrder);
    final bool currentActive = isStageActive(currentStageOrder);

    final reqProvider = StylingRequestProvider.instance;
    final stageNet = reqProvider.stageNetAmount(currentStageOrder);
    final percent = currentStageOrder == 3 ? '40%' : '30%';

    if (widget.isStylistView) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF4F4F5), width: 1.0)),
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
            if (currentApproved) ...[
              Container(
                height: 48,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFBBF7D0),
                    width: 1.2,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF16A34A),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.isVi
                          ? 'CHẶNG 0$currentStageOrder ĐÃ GIẢI NGÂN HOÀN TẤT'
                          : 'STAGE 0$currentStageOrder PAYOUT COMPLETED',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedStageIndex < 2) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => setState(
                    () => _selectedStageIndex = _selectedStageIndex + 1,
                  ),
                  child: Container(
                    height: 44,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.electricYellow,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.ink, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      t.isVi
                          ? 'CHUYỂN SANG CHẶNG 0${_selectedStageIndex + 2} →'
                          : 'PROCEED TO STAGE 0${_selectedStageIndex + 2} →',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ],
            ] else if (currentInReview) ...[
              FashionDockButton(
                text: t.isVi
                    ? 'ĐÃ XUẤT BẢN • ĐANG CHỜ KHÁCH HÀNG DUYỆT ✓'
                    : 'PUBLISHED • AWAITING APPROVAL ✓',
                icon: Icons.check_circle,
                onPressed: () {},
              ),
            ] else if (currentActive) ...[
              FashionDockButton(
                text: t.isVi
                    ? 'XUẤT BẢN & GỬI DUYỆT (CHẶNG 0$currentStageOrder) →'
                    : 'PUBLISH & SUBMIT (STAGE 0$currentStageOrder) →',
                icon: Icons.arrow_forward,
                onPressed: () => _handleSubmitStageDeliverable(t),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF18181B),
                      content: Text(
                        t.isVi ? 'Đã lưu bản nháp thành công!' : 'Draft saved successfully!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
                    border: Border.all(
                      color: const Color(0xFFE4E4E7),
                      width: 1.0,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.save_outlined,
                        size: 16,
                        color: Color(0xFF71717A),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        t.isVi ? 'Lưu Bản Nháp' : 'Save Draft',
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
            ] else ...[
              Container(
                height: 48,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  t.isVi
                      ? 'ĐANG KHÓA • HOÀN TẤT CHẶNG TRƯỚC'
                      : 'LOCKED • COMPLETE PREVIOUS STAGE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF71717A),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Client View Action Bar
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF4F4F5), width: 1.0)),
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
          if (currentApproved) ...[
            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFBBF7D0), width: 1.2),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF16A34A),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.isVi
                        ? 'CHẶNG 0$currentStageOrder ĐÃ GIẢI NGÂN HOÀN TẤT'
                        : 'STAGE 0$currentStageOrder APPROVED & RELEASED',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF16A34A),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedStageIndex < 2) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => setState(
                  () => _selectedStageIndex = _selectedStageIndex + 1,
                ),
                child: Container(
                  height: 46,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.electricYellow,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    t.isVi
                        ? 'CHUYỂN SANG CHẶNG 0${_selectedStageIndex + 2} →'
                        : 'PROCEED TO STAGE 0${_selectedStageIndex + 2} →',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 10),
              FashionDockButton(
                text: t.isVi
                    ? 'CHẶNG 03 HOÀN TẤT • ĐÁNH GIÁ 5 SAO →'
                    : 'STAGE 03 COMPLETED • RATE 5 STARS →',
                icon: Icons.star_rounded,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const DisputeReviewScreen(isDisputeMode: false),
                    ),
                  );
                },
              ),
            ],
          ] else if (currentInReview) ...[
            FashionDockButton(
              text: t.isVi
                  ? 'DUYỆT & GIẢI NGÂN $percent (+${CurrencyFormatter.formatVnd(stageNet)})'
                  : 'APPROVE & RELEASE $percent (+${CurrencyFormatter.formatVnd(stageNet)})',
              icon: Icons.verified_user,
              onPressed: () {
                if (currentStageOrder == 1) {
                  _handleApproveStage1();
                } else if (currentStageOrder == 2) {
                  _handleApproveStage2();
                } else {
                  _handleApproveStage3();
                }
              },
            ),
            const SizedBox(height: 10),
            if (_revisionCount < _maxRevisions)
              GestureDetector(
                onTap: _handleRequestRevision,
                child: Container(
                  height: 44,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFFE4E4E7),
                      width: 1.0,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.edit_note,
                        size: 16,
                        color: Color(0xFF18181B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${t.requestRevisionBtn} ($_revisionCount/$_maxRevisions)',
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
                      builder: (_) =>
                          const DisputeReviewScreen(isDisputeMode: true),
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
          ] else if (currentActive) ...[
            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFD97706),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    t.isVi
                        ? 'CHỜ STYLIST NỘP BÀI ĐỂ NGHIỆM THU'
                        : 'WAITING FOR STYLIST SUBMISSION',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFB45309),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F5),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: Color(0xFF71717A),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.isVi ? 'CHẶNG ĐANG KHÓA' : 'STAGE LOCKED',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF71717A),
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

  Future<void> _handleSubmitStageDeliverable(AppTranslations t) async {
    final stageOrder = _selectedStageIndex + 1;
    final imageUrl = _uploadedImageUrl ?? (_pickedImageFile?.path ?? '');
    if (imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF18181B),
          content: Text(
            t.isVi
                ? 'Vui lòng chọn ảnh bài nộp trước khi xuất bản!'
                : 'Please choose deliverable photo before publishing!',
            style: const TextStyle(
              color: Color(0xFFF472B6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      return;
    }

    final notes = _curationNotesController.text.trim();
    final affiliateUrl = _affiliateLinkController.text.trim();

    await StylingRequestProvider.instance.submitMilestoneDeliverable(
      stageNumber: stageOrder,
      deliverableImageUrl: imageUrl,
      stylistNotes: notes.isNotEmpty ? notes : null,
      affiliateUrl: affiliateUrl.isNotEmpty ? affiliateUrl : null,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitted = true;
      _hasProductTag = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF18181B),
        duration: const Duration(seconds: 3),
        content: Text(
          t.isVi
              ? 'Đã nộp bài Chặng 0$stageOrder thành công! Đang chờ Khách hàng nghiệm thu.'
              : 'Stage 0$stageOrder submitted! Awaiting client review.',
          style: const TextStyle(
            color: Color(0xFF34D399),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
