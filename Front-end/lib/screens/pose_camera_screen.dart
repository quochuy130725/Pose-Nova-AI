import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../core/ai/pose_matching_config.dart';
import '../core/services/mlkit_pose_service.dart';
import '../core/theme/app_colors.dart';
import '../providers/lookbook_provider.dart';
import '../providers/pose_capture_provider.dart';
import '../widgets/technical_grid_background.dart';

/// Screen 02: AI Pose Coach Camera
/// - Nhận diện tư thế thời gian thực bằng Google ML Kit
/// - Khung Xương Mẫu Nét Đứt tự động neo theo vai người dùng (Shoulder-Anchored Ghost Skeleton)
/// - Tô màu từng đoạn xương (Per-Limb Color Feedback) & lời nhắc hành động tức thời
/// - Auto-Shutter 1.2s & hiệu ứng chớp sáng Shutter Flash
/// - Modal kết quả chuẩn Tạp chí Editorial Magazine & lưu đúng ảnh đã lật gương
class PoseCameraScreen extends StatefulWidget {
  final PoseLookbook? lookbook;
  final VoidCallback? onBack;

  const PoseCameraScreen({super.key, this.lookbook, this.onBack});

  @override
  State<PoseCameraScreen> createState() => _PoseCameraScreenState();
}

class _PoseCameraScreenState extends State<PoseCameraScreen>
    with WidgetsBindingObserver {
  static const Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  CameraController? _controller;
  CameraDescription? _camera;
  List<CameraDescription> _cameras = [];
  PoseDetector? _detector;

  bool _cameraReady = false;
  String? _cameraError;
  bool _isBusy = false;
  bool _isCapturing = false;
  bool _isShutterFlashed = false;

  final ValueNotifier<PoseFrame> _frame = ValueNotifier(PoseFrame.empty);
  Map<PoseLandmarkType, Offset> _previousPoints = {};
  double _smoothedScore = 0;
  int _matchFrames = 0;
  int _countdown = 0;
  Timer? _countdownTimer;
  DateTime _autoCooldownUntil = DateTime.now();
  bool _isTargetExpanded = false;

  final GlobalKey _previewRepaintKey = GlobalKey();

  String? _targetKey;
  Map<String, double>? _targetAngles;

  PoseMatchingConfig get _config => PoseMatchingConfig.current;

  bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  bool get _poseSupported => _isAndroid || _isIOS;

  PoseLookbook get _lookbook =>
      widget.lookbook ?? LookbookProvider.instance.activePoseLookbook;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_poseSupported) {
      _detector = PoseDetector(
        options: PoseDetectorOptions(
          mode: PoseDetectionMode.stream,
          model: PoseDetectionModel.base,
        ),
      );
    }
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isCapturing) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _cancelCountdown();
      _releaseCamera();
      if (mounted) setState(() => _cameraReady = false);
    } else if (state == AppLifecycleState.resumed && _controller == null) {
      _initCamera();
    }
  }

  Future<void> _initCamera({CameraLensDirection? lens}) async {
    if (mounted) {
      setState(() {
        _cameraReady = false;
        _cameraError = null;
      });
    }
    try {
      if (_cameras.isEmpty) _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) setState(() => _cameraError = 'Không tìm thấy camera trên thiết bị này.');
        return;
      }
      final want = lens ?? _camera?.lensDirection ?? CameraLensDirection.front;
      final description = _cameras.firstWhere(
        (c) => c.lensDirection == want,
        orElse: () => _cameras.first,
      );
      final controller = CameraController(
        description,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: _isAndroid
            ? ImageFormatGroup.nv21
            : (_isIOS ? ImageFormatGroup.bgra8888 : null),
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      _camera = description;
      _controller = controller;
      setState(() => _cameraReady = true);
      await _startStream();
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraError = e.code.toLowerCase().contains('denied')
            ? 'Bạn chưa cấp quyền camera. Hãy bật quyền trong Cài đặt rồi thử lại.'
            : (e.description ?? e.code);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cameraError = 'Không mở được camera: $e');
    }
  }

  Future<void> _startStream() async {
    final controller = _controller;
    if (!_poseSupported ||
        controller == null ||
        !controller.value.isInitialized ||
        controller.value.isStreamingImages) {
      return;
    }
    try {
      await controller.startImageStream(_onCameraImage);
    } catch (e) {
      debugPrint('[PoseCamera] startImageStream failed: $e');
    }
  }

  Future<void> _releaseCamera() async {
    final controller = _controller;
    _controller = null;
    if (controller == null) return;
    try {
      if (controller.value.isStreamingImages) await controller.stopImageStream();
    } catch (_) {}
    try {
      await controller.dispose();
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    if (_isCapturing || _camera == null) return;
    _cancelCountdown();
    final next = _camera!.lensDirection == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;
    await _releaseCamera();
    _previousPoints.clear();
    _frame.value = PoseFrame.empty;
    await _initCamera(lens: next);
  }

  InputImage? _toInputImage(CameraImage image) {
    final camera = _camera;
    final controller = _controller;
    if (camera == null || controller == null) return null;

    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (_isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (_isAndroid) {
      var compensation = _orientations[controller.value.deviceOrientation];
      if (compensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        compensation = (sensorOrientation + compensation) % 360;
      } else {
        compensation = (sensorOrientation - compensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(compensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (_isAndroid && format != InputImageFormat.nv21) ||
        (_isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  Map<String, double> _currentTargetAngles() {
    final lookbook = _lookbook;
    if (_targetKey != lookbook.id || _targetAngles == null) {
      _targetKey = lookbook.id;
      _targetAngles = MlKitPoseService.getTargetAnglesForLookbook(
        poseLandmarksJson: lookbook.poseLandmarksJson,
        title: lookbook.title,
      );
    }
    return _targetAngles!;
  }

  Future<void> _onCameraImage(CameraImage image) async {
    if (_isBusy || _isCapturing || !mounted) return;
    final detector = _detector;
    if (detector == null) return;
    _isBusy = true;
    try {
      final input = _toInputImage(image);
      if (input == null) return;
      final poses = await detector.processImage(input);
      if (!mounted || _isCapturing) return;

      final rotation = input.metadata!.rotation;
      final rotated = rotation == InputImageRotation.rotation90deg ||
          rotation == InputImageRotation.rotation270deg;
      final upright = rotated
          ? Size(image.height.toDouble(), image.width.toDouble())
          : Size(image.width.toDouble(), image.height.toDouble());

      PoseFrame frame = PoseFrame.empty;
      if (poses.isNotEmpty) {
        final raw = MlKitPoseService.buildFrame(
          pose: poses.first,
          uprightSize: upright,
          mirror: _camera?.lensDirection == CameraLensDirection.front,
          targetAngles: _currentTargetAngles(),
          previousPoints: _previousPoints.isEmpty ? null : _previousPoints,
          lookbookTitle: _lookbook.title,
        );
        _previousPoints = raw.points;
        if (raw.hasPose) {
          if (_smoothedScore == 0) {
            _smoothedScore = raw.score;
          } else {
            _smoothedScore =
                _smoothedScore * (1.0 - _config.scoreSmoothingFactor) +
                    raw.score * _config.scoreSmoothingFactor;
          }
          final int displayScore = _smoothedScore.round();
          final updatedStatus = raw.needsFullBody
              ? raw.statusText
              : (displayScore >= _config.matchThreshold
                  ? 'Pose Matched ($displayScore%)'
                  : 'Scanning Pose... ($displayScore%)');
          frame = raw.copyWith(
            score: _smoothedScore,
            statusText: updatedStatus,
          );
        } else {
          _smoothedScore = 0;
          frame = raw;
        }
      } else {
        _previousPoints.clear();
        _smoothedScore = 0;
      }
      _frame.value = frame;
      _handleMatching(frame);
    } catch (e) {
      debugPrint('[PoseCamera] processImage error: $e');
    } finally {
      _isBusy = false;
    }
  }

  void _handleBack() {
    _cancelCountdown();
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  // ---------------------------------------------------------------------------
  // Auto Shutter (1.2s Fast Trigger)
  // ---------------------------------------------------------------------------

  void _handleMatching(PoseFrame frame) {
    final matched = frame.hasPose &&
        !frame.needsFullBody &&
        frame.score >= _config.matchThreshold;
    _matchFrames = matched ? _matchFrames + 1 : 0;

    if (_countdownTimer != null &&
        (!frame.hasPose ||
            frame.needsFullBody ||
            frame.score < _config.cancelThreshold)) {
      _cancelCountdown();
    }

    if (_countdownTimer == null &&
        _matchFrames >= _config.requiredMatchFrames &&
        !_isCapturing &&
        DateTime.now().isAfter(_autoCooldownUntil)) {
      _startCountdown();
    }
  }

  void _startCountdown() {
    setState(() => _countdown = 1);
    // Auto-Shutter: 1.2s (1200ms) lock-in
    _countdownTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      _countdownTimer = null;
      setState(() => _countdown = 0);
      _capture();
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    if (mounted && _countdown != 0) setState(() => _countdown = 0);
  }

  // ---------------------------------------------------------------------------
  // Capture + Shutter Flash + Gallery Save
  // ---------------------------------------------------------------------------

  Future<void> _capture() async {
    final controller = _controller;
    if (_isCapturing || controller == null || !controller.value.isInitialized) return;
    _isCapturing = true;
    _cancelCountdown();
    final score = _frame.value.score;

    try {
      // 1. Dừng image stream an toàn trước khi chụp ảnh
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
        await Future<void>.delayed(const Duration(milliseconds: 60));
      }

      // 2. Chớp sáng màn trập (Shutter Flash 150ms)
      if (mounted) setState(() => _isShutterFlashed = true);
      final XFile file = await controller.takePicture();

      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _isShutterFlashed = false);
      });

      if (!mounted) return;

      await PoseCaptureProvider.instance.registerCapturedPhoto(
        filePath: file.path,
        poseMatchScore: score,
      );

      // Hiển thị Modal Tạp chí Editorial
      await _showResultSheet(file.path, score);
    } catch (e) {
      if (mounted) {
        setState(() => _isShutterFlashed = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.ink,
            content: Text(
              'Không thể chụp ảnh: $e',
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12),
            ),
          ),
        );
      }
    } finally {
      _isCapturing = false;
      _matchFrames = 0;
      _autoCooldownUntil = DateTime.now().add(const Duration(seconds: 3));
      if (mounted) await _startStream();
    }
  }

  // ---------------------------------------------------------------------------
  // Modal Ảnh Kết Quả chuẩn Tạp Chí Editorial & Lưu ảnh đã lật gương
  // ---------------------------------------------------------------------------

  Future<void> _showResultSheet(String path, double score) {
    final bool isFrontCamera = _camera?.lensDirection == CameraLensDirection.front;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: const Color(0xFF141211),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle Bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Preview Card: RepaintBoundary bọc trong ClipRRect để hiển thị bo góc trên màn hình
                    // nhưng xuất ảnh chụp thành phẩm vuông vức, sạch góc, không bị viền xám
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: RepaintBoundary(
                        key: _previewRepaintKey,
                        child: Container(
                          color: Colors.black,
                          child: Stack(
                            children: [
                              // Ảnh gốc (lật gương nếu chụp bằng Camera trước)
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(ctx).size.height * 0.52,
                                  minWidth: double.infinity,
                                ),
                                child: isFrontCamera
                                    ? Transform.flip(
                                        flipX: true,
                                        child: Image.file(
                                          File(path),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      )
                                    : Image.file(
                                        File(path),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                              ),

                              // Dải nhãn Editorial Magazine Watermark đè nhẹ ở góc dưới
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Color(0xE60A0A0A),
                                        Color(0xF5000000),
                                      ],
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'POSENOVA ATELIER',
                                              style: GoogleFonts.plusJakartaSans(
                                                color: AppColors.sunshineYellow,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Builder(
                                              builder: (_) {
                                                final rawTitle = _lookbook.title;
                                                final titleParts = rawTitle.split('•');
                                                final mainTitle = titleParts[0].trim().toUpperCase();
                                                final seasonBadge = titleParts.length > 1
                                                    ? titleParts[1].trim().toUpperCase()
                                                    : 'AW26';

                                                return Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        mainTitle,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: GoogleFonts.plusJakartaSans(
                                                          color: Colors.white,
                                                          fontSize: 14.5,
                                                          fontWeight: FontWeight.w900,
                                                          letterSpacing: -0.3,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFE11D48),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        seasonBadge,
                                                        style: GoogleFonts.plusJakartaSans(
                                                          color: Colors.white,
                                                          fontSize: 9.5,
                                                          fontWeight: FontWeight.w800,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'COLLECTION 2026 • VIETNAM',
                                              style: GoogleFonts.jetBrainsMono(
                                                color: Colors.white60,
                                                fontSize: 8.5,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withValues(alpha: 0.22),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(
                                            color: const Color(0xFF10B981),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Text(
                                          'AI POSE MATCH: ${score.round()}%',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFF34D399),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.4,
                                        ),
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

                    const SizedBox(height: 18),

                    // 2 Nút hành động: "Chụp lại" & "Hoàn tất & Lưu ảnh"
                    Row(
                      children: [
                        // Nút 1: Chụp lại
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: isSaving ? null : () => Navigator.of(ctx).pop(),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Colors.white24, width: 1.0),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Chụp lại',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Nút 2: Hoàn tất & Lưu ảnh
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: isSaving
                                ? null
                                : () async {
                                    setModalState(() => isSaving = true);
                                    try {
                                      final boundary = _previewRepaintKey.currentContext
                                          ?.findRenderObject() as RenderRepaintBoundary?;
                                      if (boundary != null) {
                                        final ui.Image image =
                                            await boundary.toImage(pixelRatio: 2.5);
                                        final ByteData? byteData = await image.toByteData(
                                          format: ui.ImageByteFormat.png,
                                        );
                                        if (byteData != null) {
                                          final Uint8List pngBytes =
                                              byteData.buffer.asUint8List();
                                          if (!await Gal.hasAccess(toAlbum: true)) {
                                            await Gal.requestAccess(toAlbum: true);
                                          }
                                          await Gal.putImageBytes(
                                            pngBytes,
                                            album: 'PoseNova AI',
                                            name: 'PoseNova_${DateTime.now().millisecondsSinceEpoch}',
                                          );
                                        }
                                      } else {
                                        if (!await Gal.hasAccess(toAlbum: true)) {
                                          await Gal.requestAccess(toAlbum: true);
                                        }
                                        await Gal.putImage(path, album: 'PoseNova AI');
                                      }

                                      if (mounted) {
                                        Navigator.of(ctx).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: const Color(0xFF0F172A),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            content: Row(
                                              children: [
                                                const Icon(
                                                  Icons.check_circle,
                                                  color: Color(0xFF10B981),
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    'Đã lưu bức ảnh phong cách Tạp chí vào Thư viện!',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 12.5,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: AppColors.ink,
                                            content: Text(
                                              'Lỗi khi lưu ảnh: $e',
                                              style: GoogleFonts.plusJakartaSans(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (mounted) setModalState(() => isSaving = false);
                                    }
                                  },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: AppColors.buttonShadow,
                              ),
                              alignment: Alignment.center,
                              child: isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.save_alt,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Hoàn tất & Lưu ảnh',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.white,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _releaseCamera();
    _detector?.close();
    _frame.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_poseSupported) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('AI Pose Camera'),
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Tính năng Camera AI hiện chỉ hỗ trợ trên thiết bị thật (Android / iOS).',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14),
            ),
          ),
        ),
      );
    }

    if (_cameraError != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AppColors.rosePink, size: 48),
                const SizedBox(height: 16),
                Text(
                  _cameraError!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _initCamera(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_cameraReady || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.sunshineYellow),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: TechnicalGridBackground(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Camera Viewfinder
              Center(
                child: AspectRatio(
                  aspectRatio: 1 / _controller!.value.aspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(_controller!),

                      // Khung Xương Mẫu Nét Đứt + Khung Xương Người Dùng
                      CustomPaint(
                        painter: _PoseOverlayPainter(
                          frame: _frame,
                          targetAngles: _currentTargetAngles(),
                          lookbookTitle: _lookbook.title,
                        ),
                      ),

                      // 4 Góc ngắm đối xứng
                      const _CornerBracketsOverlay(),

                      // Viền sáng mềm chuyển sắc
                      CustomPaint(painter: _AuraBorderPainter()),
                    ],
                  ),
                ),
              ),

              // 2. Header: Nút Thoát + Switch Camera
              Positioned(
                top: 14,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _handleBack,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 0.8),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _switchCamera,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 0.8),
                            ),
                            child: const Icon(
                              Icons.cameraswitch,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. Status Pill góc trên bên trái
              _buildStatusPill(),

              // 4. PIP Card Target Pose góc trên bên phải (Hỗ trợ chạm Phóng to / Thu nhỏ)
              Positioned(
                top: 14,
                right: 16,
                child: _buildTargetPip(_lookbook),
              ),

              // 5. Score & Actionable Coaching Hint Bar góc dưới
              _buildScoreHud(),

              // 6. Nút Shutter tròn ở đáy màn hình
              Positioned(
                bottom: 84,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _isCapturing ? null : _capture,
                    child: Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: _countdown > 0
                            ? const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                              )
                            : AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: AppColors.buttonShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            _countdown > 0
                                ? 'Đang Chụp 1.2s (Giữ yên dáng)...'
                                : 'Chụp ảnh (Take a Picture)',
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
                ),
              ),

              // 7. Hiệu ứng Shutter Flash trắng mịn khi bắt dính khoảnh khắc
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _isShutterFlashed ? 0.90 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill() {
    return Positioned(
      top: 68,
      left: 18,
      right: _isTargetExpanded ? 205 : 145,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ValueListenableBuilder<PoseFrame>(
          valueListenable: _frame,
          builder: (context, frame, _) {
            final matched = frame.hasPose &&
                !frame.needsFullBody &&
                frame.score >= _config.matchThreshold;
            final isWarning = frame.needsFullBody;
            final Color dotColor = matched
                ? const Color(0xFF10B981)
                : (isWarning ? AppColors.coralOrange : AppColors.sunshineYellow);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isWarning
                      ? AppColors.coralOrange.withValues(alpha: 0.6)
                      : Colors.white24,
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      frame.statusText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScoreHud() {
    return Positioned(
      bottom: 22,
      left: 18,
      right: 18,
      child: ValueListenableBuilder<PoseFrame>(
        valueListenable: _frame,
        builder: (context, frame, _) {
          final matched = frame.hasPose &&
              !frame.needsFullBody &&
              frame.score >= _config.matchThreshold;
          final accent = matched
              ? const Color(0xFF10B981)
              : (frame.needsFullBody ? AppColors.coralOrange : AppColors.sunshineYellow);

          final String text;
          if (!frame.hasPose) {
            text = 'Match Score: --  |  Đang tìm dáng người...';
          } else {
            text = 'Match Score: ${frame.score.round()}%  |  ${frame.coachingHint}';
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: accent, width: 1.2),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTargetPip(PoseLookbook lookbook) {
    final double targetWidth = _isTargetExpanded ? 185 : 115;
    final double targetHeight = _isTargetExpanded ? 245 : 150;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _isTargetExpanded = !_isTargetExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        width: targetWidth,
        height: targetHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.85),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                lookbook.imageUrl,
                key: ValueKey(lookbook.imageUrl),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: const Color(0xFF332D29),
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported, color: Colors.white38, size: 24),
                ),
              ),
            ),

            // Top-right Zoom Toggle Button
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 0.8),
                ),
                child: Icon(
                  _isTargetExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),

            // Top-left subtle hint
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _isTargetExpanded ? 'Thu nhỏ' : 'Phóng to',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),

            // Bottom Title & Target Label
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withValues(alpha: 0.75),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lookbook.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'TARGET POSE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: AppColors.sunshineYellow,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// CustomPainter vẽ Khung Xương Mẫu Nét Đứt + Khung Xương Người Dùng (Per-Limb Color Feedback)
class _PoseOverlayPainter extends CustomPainter {
  final ValueNotifier<PoseFrame> frame;
  final Map<String, double> targetAngles;
  final String lookbookTitle;

  _PoseOverlayPainter({
    required this.frame,
    required this.targetAngles,
    required this.lookbookTitle,
  }) : super(repaint: frame);

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Paint paint, {
    double dashWidth = 7.0,
    double dashSpace = 5.0,
  }) {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance <= 0) return;
    final unitX = dx / distance;
    final unitY = dy / distance;

    double currentDist = 0.0;
    while (currentDist < distance) {
      final nextDist = math.min(currentDist + dashWidth, distance);
      canvas.drawLine(
        Offset(p1.dx + unitX * currentDist, p1.dy + unitY * currentDist),
        Offset(p1.dx + unitX * nextDist, p1.dy + unitY * nextDist),
        paint,
      );
      currentDist += dashWidth + dashSpace;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final f = frame.value;

    Offset? at(PoseLandmarkType t) {
      final o = f.points[t];
      return o == null ? null : Offset(o.dx * size.width, o.dy * size.height);
    }

    final userLs = at(PoseLandmarkType.leftShoulder);
    final userRs = at(PoseLandmarkType.rightShoulder);

    // -------------------------------------------------------------------------
    // 1. Vẽ Khung Xương Mẫu Nét Đứt (Ghost Guide Skeleton)
    // -------------------------------------------------------------------------
    final ghost = TargetGhostSkeleton.compute(
      size: size,
      targetAngles: targetAngles,
      userLeftShoulder: userLs,
      userRightShoulder: userRs,
      lookbookTitle: lookbookTitle,
    );

    final ghostLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final ghostJointPaint = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final ghostJointRing = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Các đoạn xương nét đứt của khung mẫu
    final ghostSegments = [
      [ghost.leftShoulder, ghost.rightShoulder],
      [ghost.leftShoulder, ghost.leftElbow],
      [ghost.leftElbow, ghost.leftWrist],
      [ghost.rightShoulder, ghost.rightElbow],
      [ghost.rightElbow, ghost.rightWrist],
      if (ghost.leftHip != null) [ghost.leftShoulder, ghost.leftHip!],
      if (ghost.rightHip != null) [ghost.rightShoulder, ghost.rightHip!],
    ];

    for (final seg in ghostSegments) {
      _drawDashedLine(canvas, seg[0], seg[1], ghostLinePaint);
    }

    // Vẽ đầu/cổ nối khung mẫu
    final midGhostShoulder = Offset(
      (ghost.leftShoulder.dx + ghost.rightShoulder.dx) * 0.5,
      (ghost.leftShoulder.dy + ghost.rightShoulder.dy) * 0.5,
    );
    _drawDashedLine(canvas, ghost.nose, midGhostShoulder, ghostLinePaint);

    // Các điểm khớp của khung mẫu
    final ghostJoints = [
      ghost.nose,
      ghost.leftShoulder,
      ghost.rightShoulder,
      ghost.leftElbow,
      ghost.rightElbow,
      ghost.leftWrist,
      ghost.rightWrist,
      if (ghost.leftHip != null) ghost.leftHip!,
      if (ghost.rightHip != null) ghost.rightHip!,
    ];

    final double ghostRadius = size.width * 0.012;
    for (final j in ghostJoints) {
      canvas.drawCircle(j, ghostRadius, ghostJointPaint);
      canvas.drawCircle(j, ghostRadius, ghostJointRing);
    }

    // -------------------------------------------------------------------------
    // 2. Vẽ Khung Xương Người Dùng Thực Tế (Per-Limb Color Feedback)
    // -------------------------------------------------------------------------
    if (!f.hasPose) return;

    final jointDiffs = f.jointDiffs;

    Color colorForBone(PoseLandmarkType a, PoseLandmarkType b) {
      if ((a == PoseLandmarkType.leftShoulder && b == PoseLandmarkType.leftElbow) ||
          (a == PoseLandmarkType.leftElbow && b == PoseLandmarkType.leftShoulder)) {
        final d = jointDiffs['leftShoulder'] ?? jointDiffs['leftArmFlare'] ?? 0.0;
        return d <= 18.0 ? const Color(0xFF10B981) : const Color(0xFFF43F5E);
      }
      if ((a == PoseLandmarkType.leftElbow && b == PoseLandmarkType.leftWrist) ||
          (a == PoseLandmarkType.leftWrist && b == PoseLandmarkType.leftElbow)) {
        final d = jointDiffs['leftElbow'] ?? 0.0;
        return d <= 18.0 ? const Color(0xFF10B981) : const Color(0xFFF43F5E);
      }
      if ((a == PoseLandmarkType.rightShoulder && b == PoseLandmarkType.rightElbow) ||
          (a == PoseLandmarkType.rightElbow && b == PoseLandmarkType.rightShoulder)) {
        final d = jointDiffs['rightShoulder'] ?? jointDiffs['rightArmFlare'] ?? 0.0;
        return d <= 18.0 ? const Color(0xFF10B981) : const Color(0xFFF43F5E);
      }
      if ((a == PoseLandmarkType.rightElbow && b == PoseLandmarkType.rightWrist) ||
          (a == PoseLandmarkType.rightWrist && b == PoseLandmarkType.rightElbow)) {
        final d = jointDiffs['rightElbow'] ?? 0.0;
        return d <= 18.0 ? const Color(0xFF10B981) : const Color(0xFFF43F5E);
      }
      if ((a == PoseLandmarkType.leftShoulder && b == PoseLandmarkType.rightShoulder) ||
          (a == PoseLandmarkType.rightShoulder && b == PoseLandmarkType.leftShoulder)) {
        final d = jointDiffs['headShoulderSpan'] ?? 0.0;
        return d <= 18.0 ? const Color(0xFF10B981) : const Color(0xFFFBBF24);
      }

      // Các đoạn xương thân dưới
      final hipDiff = jointDiffs['leftHip'] ?? jointDiffs['rightHip'] ?? 0.0;
      return hipDiff <= 20.0 ? const Color(0xFF10B981) : const Color(0xFFF43F5E);
    }

    final dotFill = Paint()..color = Colors.white;

    for (final bone in MlKitPoseService.bones) {
      final a = at(bone[0]);
      final b = at(bone[1]);
      if (a != null && b != null) {
        final boneColor = colorForBone(bone[0], bone[1]);
        final bonePaint = Paint()
          ..color = boneColor
          ..strokeWidth = size.width * 0.010
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        canvas.drawLine(a, b, bonePaint);
      }
    }

    final nose = at(PoseLandmarkType.nose);
    final ls = at(PoseLandmarkType.leftShoulder);
    final rs = at(PoseLandmarkType.rightShoulder);
    if (nose != null && ls != null && rs != null) {
      final neckLine = Paint()
        ..color = const Color(0xFF10B981)
        ..strokeWidth = size.width * 0.008
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(nose, Offset((ls.dx + rs.dx) / 2, (ls.dy + rs.dy) / 2), neckLine);
    }

    final radius = size.width * 0.013;
    for (final entry in f.points.entries) {
      final p = Offset(entry.value.dx * size.width, entry.value.dy * size.height);
      final ringPaint = Paint()
        ..color = f.score >= 85.0 ? const Color(0xFF10B981) : AppColors.sunshineYellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.005;

      canvas.drawCircle(p, radius, dotFill);
      canvas.drawCircle(p, radius, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PoseOverlayPainter oldDelegate) => true;
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

    canvas.drawLine(const Offset(0, 0), const Offset(arm, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, arm), paint);

    canvas.drawLine(Offset(size.width, 0), Offset(size.width - arm, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, arm), paint);

    canvas.drawLine(Offset(0, size.height), Offset(arm, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - arm), paint);

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
