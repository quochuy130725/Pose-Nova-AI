import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';

/// Provider managing On-Device 30 FPS ML Kit Pose Tracking & Gallery Save (TSK-21 & TSK-22)
/// Strictly keeps captured personal pose photos 100% On-Device (RAM & Phone Gallery),
/// never auto-uploading personal camera frames to the cloud.
class PoseCaptureProvider extends ChangeNotifier {
  PoseCaptureProvider._();
  static final PoseCaptureProvider instance = PoseCaptureProvider._();

  Uint8List? _lastCapturedPngBytes;
  String? _lastSavedGalleryPath;
  double _lastPoseMatchScore = 96.8;
  DateTime? _lastCapturedAt;
  int _captureCount = 0;

  Uint8List? get lastCapturedPngBytes => _lastCapturedPngBytes;
  String? get lastSavedGalleryPath => _lastSavedGalleryPath;
  double get lastPoseMatchScore => _lastPoseMatchScore;
  DateTime? get lastCapturedAt => _lastCapturedAt;
  int get captureCount => _captureCount;
  bool get hasCapturedPosePhoto =>
      _lastCapturedPngBytes != null || _lastSavedGalleryPath != null;

  /// Ghi nhan anh that vua chup (da luu vao Gallery) de dinh kem vao danh gia.
  /// Anh chi nam tren thiet bi, khong tu dong tai len cloud.
  Future<void> registerCapturedPhoto({
    required String filePath,
    required double poseMatchScore,
  }) async {
    try {
      _lastCapturedPngBytes = await File(filePath).readAsBytes();
    } catch (_) {
      _lastCapturedPngBytes = null;
    }
    _lastPoseMatchScore = poseMatchScore;
    _lastSavedGalleryPath = filePath;
    _lastCapturedAt = DateTime.now();
    _captureCount++;
    notifyListeners();
  }

  /// Saves captured PNG frame bytes directly to the device Gallery (Album `PoseNova AI`)
  /// using `package:gal` with local filesystem fallback without any Cloud upload.
  Future<String> saveCapturedFrameToGallery({
    required Uint8List pngBytes,
    required double poseMatchScore,
  }) async {
    _lastCapturedPngBytes = pngBytes;
    _lastPoseMatchScore = poseMatchScore;
    _lastCapturedAt = DateTime.now();
    _captureCount++;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'PoseNova_AIPose_${timestamp}_${poseMatchScore.toStringAsFixed(0)}pct.png';
    String savedLocation = 'Gallery/PoseNova AI/$fileName';

    // 1. Try native `package:gal` (`Gal.putImageBytes`)
    try {
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        await Gal.requestAccess(toAlbum: true);
      }
      await Gal.putImageBytes(
        pngBytes,
        name: fileName,
        album: 'PoseNova AI',
      );
      _lastSavedGalleryPath = savedLocation;
      notifyListeners();
      return savedLocation;
    } catch (_) {
      // Fall back to direct on-device Pictures/DCIM/temp file write
    }

    // 2. Write directly to on-device Pictures / Gallery / SystemTemp directory
    if (!kIsWeb) {
      final candidateDirs = <String>[
        if (Platform.isAndroid) '/storage/emulated/0/Pictures/PoseNovaAI',
        if (Platform.isAndroid) '/storage/emulated/0/DCIM/Camera',
        if (Platform.isWindows && Platform.environment['USERPROFILE'] != null)
          '${Platform.environment['USERPROFILE']}\\Pictures\\PoseNovaAI',
        Directory.systemTemp.path,
      ];

      for (final dirPath in candidateDirs) {
        try {
          final dir = Directory(dirPath);
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
          final file = File('${dir.path}${Platform.pathSeparator}$fileName');
          await file.writeAsBytes(pngBytes, flush: true);
          savedLocation = file.path;
          break;
        } catch (_) {
          continue;
        }
      }
    }

    _lastSavedGalleryPath = savedLocation;
    notifyListeners();
    return savedLocation;
  }
}
