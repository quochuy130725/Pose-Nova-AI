import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../core/ai/pose_matching_config.dart';
import '../core/services/mlkit_pose_service.dart';
import '../core/theme/app_colors.dart';
import '../providers/lookbook_provider.dart';
import '../providers/pose_capture_provider.dart';
import '../widgets/brutalist_badge.dart';

/// Screen 02: AI Pose Camera
/// - Camera that + Google ML Kit Pose Detection (33 landmark) chay tren thiet bi
/// - Khung xuong ve theo co the that cua nguoi dung
/// - Target la anh cua Lookbook dang duoc chon tu Discovery Feed
/// - Chup anh that (takePicture) va luu vao Gallery bang package `gal`
class PoseCameraScreen extends StatefulWidget {
  /// Lookbook muc tieu. Neu null se dung Lookbook da chon trong
  /// [LookbookProvider] (hoac Lookbook dau tien trong danh sach).
  final PoseLookbook? lookbook;

  /// Callback khi bam nut quay ve (ho tro ca khi embedded trong Tab/Shell hoac duoc Push qua Navigator)
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

  // ---------------------------------------------------------------------------
  // ML Kit: CameraImage -> InputImage -> Pose -> PoseFrame
  // ---------------------------------------------------------------------------

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
        );
        _previousPoints = raw.points;
        if (raw.hasPose) {
          if (_smoothedScore == 0) {
            _smoothedScore = raw.score; // Instant startup on first frame
          } else {
            _smoothedScore =
                _smoothedScore * (1.0 - _config.scoreSmoothingFactor) +
                    raw.score * _config.scoreSmoothingFactor;
          }
          frame = raw.copyWith(score: _smoothedScore);
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
  // Auto shutter
  // ---------------------------------------------------------------------------

  void _handleMatching(PoseFrame frame) {
    // Chỉ kích hoạt khi phát hiện toàn thân/nửa thân trên hợp lệ và điểm đạt chuẩn
    final matched = frame.hasPose &&
        !frame.needsFullBody &&
        frame.score >= _config.matchThreshold;
    _matchFrames = matched ? _matchFrames + 1 : 0;

    // Nếu người dùng bước lại quá gần (needsFullBody) hoặc score tụt -> hủy đếm ngược ngay lập tức
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
    setState(() => _countdown = _config.countdownSeconds > 0 ? _config.countdownSeconds : 1);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        _countdownTimer = null;
        setState(() => _countdown = 0);
        _capture();
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    if (mounted && _countdown != 0) setState(() => _countdown = 0);
  }

  // ---------------------------------------------------------------------------
  // Capture + save to Gallery
  // ---------------------------------------------------------------------------

  Future<void> _capture() async {
    final controller = _controller;
    if (_isCapturing || controller == null || !controller.value.isInitialized) return;
    _isCapturing = true;
    _cancelCountdown();
    final score = _frame.value.score;

    try {
      // Android: phai dung stream truoc khi chup de tranh treo camera.
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      final XFile file = await controller.takePicture();
      if (!mounted) return;

      setState(() => _isShutterFlashed = true);
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _isShutterFlashed = false);
      });

      String? saveError;
      try {
        if (!await Gal.hasAccess(toAlbum: true)) {
          await Gal.requestAccess(toAlbum: true);
        }
        await Gal.putImage(file.path, album: 'PoseNova AI');
      } catch (e) {
        saveError = e is GalException ? e.type.message : e.toString();
      }

      await PoseCaptureProvider.instance.registerCapturedPhoto(
        filePath: file.path,
        poseMatchScore: score,
      );
      if (!mounted) return;
      await _showResultSheet(file.path, score, saveError);
    } catch (e) {
      if (mounted) {
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
      _autoCooldownUntil = DateTime.now().add(const Duration(seconds: 4));
      if (mounted) await _startStream();
    }
  }

  Future<void> _showResultSheet(String path, double score, String? saveError) {
    final saved = saveError == null;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: const Color(0xFF221E1B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(ctx).size.height * 0.5,
                    ),
                    child: Image.file(File(path), fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(
                      saved ? Icons.check_circle : Icons.error_outline,
                      color: saved ? AppColors.cyber : AppColors.rosePink,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        saved
                            ? 'Đã lưu ảnh vào thư viện máy!'
                            : 'Chưa lưu được vào thư viện: $saveError',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Match Score: ${score.round()}%  |  Ảnh chỉ lưu trên máy, không tải lên cloud',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white70,
                      fontSize: 11.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: AppColors.buttonShadow,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Chụp lại',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  Widget _buildCameraLayer() {
    final controller = _controller;
    if (_cameraReady && controller != null && controller.value.isInitialized) {
      final preview = controller.value.previewSize;
      return ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              // previewSize luon la landscape; man hinh dung portrait nen hoan doi.
              width: preview?.height ?? 1,
              height: preview?.width ?? 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(controller),
                  CustomPaint(painter: _PoseOverlayPainter(_frame)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final message = _cameraError ??
        (_poseSupported
            ? 'Đang khởi động camera...'
            : 'Camera AI chỉ hỗ trợ Android và iOS.');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _cameraError != null ? Icons.videocam_off : Icons.videocam,
              color: Colors.white54,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
            ),
            if (_cameraError != null) ...[
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _initCamera,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Thử lại',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      border: Border.all(color: Colors.transparent, width: 2.0),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildCameraLayer(),
                        CustomPaint(painter: _AuraBorderPainter()),
                        const Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: _CornerBracketsOverlay(),
                          ),
                        ),
                        _buildStatusPill(),
                        _buildScoreHud(),
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
                      onTap: _handleBack,
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
                    GestureDetector(
                      onTap: _switchCamera,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cameraswitch, color: Colors.white, size: 18),
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

              // 3. Picture-in-Picture Target = anh cua Lookbook dang chon
              Positioned(
                top: 80,
                right: 24,
                child: ListenableBuilder(
                  listenable: LookbookProvider.instance,
                  builder: (context, _) => _buildTargetPip(_lookbook),
                ),
              ),

              // 4. Countdown Timer Banner
              if (_countdown > 0)
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

              // 5. Bottom Controls
              Positioned(
                bottom: 16,
                left: 18,
                right: 18,
                child: GestureDetector(
                  onTap: _capture,
                  child: Opacity(
                    opacity: (_cameraReady && !_isCapturing) ? 1 : 0.5,
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
                            _countdown > 0
                                ? 'Chụp Ngay (Auto Shutter)'
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

              // White Camera Flash effect
              if (_isShutterFlashed) Positioned.fill(child: Container(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill() {
    return Positioned(
      top: 18,
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
                ? AppColors.sunshineYellow
                : (isWarning ? AppColors.coralOrange : AppColors.rosePink);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
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
      bottom: 18,
      left: 18,
      right: 18,
      child: ValueListenableBuilder<PoseFrame>(
        valueListenable: _frame,
        builder: (context, frame, _) {
          final matched = frame.hasPose &&
              !frame.needsFullBody &&
              frame.score >= _config.matchThreshold;
          final accent = matched
              ? AppColors.sunshineYellow
              : (frame.needsFullBody ? AppColors.coralOrange : AppColors.rosePink);

          final String text;
          if (!frame.hasPose) {
            text = 'Match Score: --  |  Diff: --';
          } else if (frame.needsFullBody) {
            text = 'Match Score: ${frame.score.round()}%  |  Lùi lại để thấy rõ thân trên';
          } else {
            text =
                'Match Score: ${frame.score.round()}%  |  Diff: ${frame.diffDegrees.round()}°';
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: accent, width: 1.0),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
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
    final double targetWidth = _isTargetExpanded ? 180 : 118;
    final double targetHeight = _isTargetExpanded ? 240 : 156;

    return GestureDetector(
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

/// Ve khung xuong tu cac landmark ML Kit that, trong he toa do cua CameraPreview.
class _PoseOverlayPainter extends CustomPainter {
  final ValueNotifier<PoseFrame> frame;

  _PoseOverlayPainter(this.frame) : super(repaint: frame);

  @override
  void paint(Canvas canvas, Size size) {
    final f = frame.value;
    if (!f.hasPose || size.isEmpty) return;

    final matched =
        !f.needsFullBody && f.score >= PoseMatchingConfig.current.matchThreshold;
    final color = matched
        ? AppColors.sunshineYellow
        : (f.needsFullBody ? AppColors.coralOrange : AppColors.rosePink);

    final line = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.008
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final dotFill = Paint()..color = Colors.white;
    final dotRing = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.004;

    Offset? at(PoseLandmarkType t) {
      final o = f.points[t];
      return o == null ? null : Offset(o.dx * size.width, o.dy * size.height);
    }

    for (final bone in MlKitPoseService.bones) {
      final a = at(bone[0]);
      final b = at(bone[1]);
      if (a != null && b != null) canvas.drawLine(a, b, line);
    }

    final nose = at(PoseLandmarkType.nose);
    final ls = at(PoseLandmarkType.leftShoulder);
    final rs = at(PoseLandmarkType.rightShoulder);
    if (nose != null && ls != null && rs != null) {
      canvas.drawLine(nose, Offset((ls.dx + rs.dx) / 2, (ls.dy + rs.dy) / 2), line);
    }

    final radius = size.width * 0.012;
    for (final entry in f.points.entries) {
      final p = Offset(entry.value.dx * size.width, entry.value.dy * size.height);
      canvas.drawCircle(p, radius, dotFill);
      canvas.drawCircle(p, radius, dotRing);
    }
  }

  @override
  bool shouldRepaint(covariant _PoseOverlayPainter oldDelegate) =>
      oldDelegate.frame != frame;
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
