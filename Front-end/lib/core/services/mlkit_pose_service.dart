import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show Offset, Size;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../ai/pose_matcher.dart';
import '../ai/pose_matching_config.dart';

/// Kết quả của một khung hình sau khi ML Kit nhận diện tư thế
class PoseFrame {
  final Map<PoseLandmarkType, Offset> points;
  final double score;
  final double diffDegrees;
  final bool hasPose;
  final bool needsFullBody;
  final String statusText;
  final int validCoreJoints;

  const PoseFrame({
    required this.points,
    required this.score,
    required this.diffDegrees,
    required this.hasPose,
    required this.needsFullBody,
    required this.statusText,
    required this.validCoreJoints,
  });

  static const PoseFrame empty = PoseFrame(
    points: <PoseLandmarkType, Offset>{},
    score: 0,
    diffDegrees: 0,
    hasPose: false,
    needsFullBody: false,
    statusText: 'Đang tìm dáng người...',
    validCoreJoints: 0,
  );

  PoseFrame copyWith({
    Map<PoseLandmarkType, Offset>? points,
    double? score,
    double? diffDegrees,
    bool? hasPose,
    bool? needsFullBody,
    String? statusText,
    int? validCoreJoints,
  }) =>
      PoseFrame(
        points: points ?? this.points,
        score: score ?? this.score,
        diffDegrees: diffDegrees ?? this.diffDegrees,
        hasPose: hasPose ?? this.hasPose,
        needsFullBody: needsFullBody ?? this.needsFullBody,
        statusText: statusText ?? this.statusText,
        validCoreJoints: validCoreJoints ?? this.validCoreJoints,
      );
}

class PoseAngleDefinition {
  final String name;
  final PoseLandmarkType first;
  final PoseLandmarkType mid;
  final PoseLandmarkType last;
  final int iFirst;
  final int iMid;
  final int iLast;

  const PoseAngleDefinition(
    this.name,
    this.first,
    this.mid,
    this.last,
    this.iFirst,
    this.iMid,
    this.iLast,
  );
}

/// Dịch vụ tính toán tư thế & chấm điểm khớp góc vector thời gian thực
class MlKitPoseService {
  MlKitPoseService._();

  static const double minLikelihood = 0.50;

  /// 2 khớp vai bắt buộc để xác nhận thấy rõ thân người (chặn trường hợp chỉ dí khuôn mặt vào camera)
  static const List<PoseLandmarkType> upperBodyCoreJoints = [
    PoseLandmarkType.leftShoulder,
    PoseLandmarkType.rightShoulder,
  ];

  /// Các khớp theo dõi để vẽ khung xương
  static const List<PoseLandmarkType> trackedTypes = [
    PoseLandmarkType.nose,
    PoseLandmarkType.leftShoulder,
    PoseLandmarkType.rightShoulder,
    PoseLandmarkType.leftElbow,
    PoseLandmarkType.rightElbow,
    PoseLandmarkType.leftWrist,
    PoseLandmarkType.rightWrist,
    PoseLandmarkType.leftHip,
    PoseLandmarkType.rightHip,
    PoseLandmarkType.leftKnee,
    PoseLandmarkType.rightKnee,
    PoseLandmarkType.leftAnkle,
    PoseLandmarkType.rightAnkle,
  ];

  /// Các đoạn xương kết nối các điểm mốc
  static const List<List<PoseLandmarkType>> bones = [
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
    [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
    [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
    [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
    [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
    [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
  ];

  /// 8 góc cơ bản vector khớp xương
  static const List<PoseAngleDefinition> angleDefinitions = [
    PoseAngleDefinition(
      'leftElbow',
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.leftWrist,
      11,
      13,
      15,
    ),
    PoseAngleDefinition(
      'rightElbow',
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.rightWrist,
      12,
      14,
      16,
    ),
    PoseAngleDefinition(
      'leftShoulder',
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftElbow,
      23,
      11,
      13,
    ),
    PoseAngleDefinition(
      'rightShoulder',
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightElbow,
      24,
      12,
      14,
    ),
    PoseAngleDefinition(
      'leftHip',
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
      11,
      23,
      25,
    ),
    PoseAngleDefinition(
      'rightHip',
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
      12,
      24,
      26,
    ),
    PoseAngleDefinition(
      'leftKnee',
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.leftAnkle,
      23,
      25,
      27,
    ),
    PoseAngleDefinition(
      'rightKnee',
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.rightAnkle,
      24,
      26,
      28,
    ),
    // 3 góc thân trên & chân dung độc lập (không cần cổ tay hay hông)
    PoseAngleDefinition(
      'leftArmFlare',
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftElbow,
      12,
      11,
      13,
    ),
    PoseAngleDefinition(
      'rightArmFlare',
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightElbow,
      11,
      12,
      14,
    ),
    PoseAngleDefinition(
      'headShoulderSpan',
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.nose,
      PoseLandmarkType.rightShoulder,
      11,
      0,
      12,
    ),
  ];

  static const Map<String, String> mirrorJointNames = {
    'leftElbow': 'rightElbow',
    'rightElbow': 'leftElbow',
    'leftShoulder': 'rightShoulder',
    'rightShoulder': 'leftShoulder',
    'leftArmFlare': 'rightArmFlare',
    'rightArmFlare': 'leftArmFlare',
    'headShoulderSpan': 'headShoulderSpan',
    'leftHip': 'rightHip',
    'rightHip': 'leftHip',
    'leftKnee': 'rightKnee',
    'rightKnee': 'leftKnee',
  };

  /// Tính góc giữa 3 điểm mốc bằng hàm atan2 quy đổi ra độ (0° - 180°)
  static double calculateAngle(
    PoseLandmark first,
    PoseLandmark mid,
    PoseLandmark last,
  ) {
    final radians = math.atan2(last.y - mid.y, last.x - mid.x) -
        math.atan2(first.y - mid.y, first.x - mid.x);
    var deg = (radians * 180.0 / math.pi).abs();
    if (deg > 180.0) deg = 360.0 - deg;
    return deg;
  }

  /// Tính góc từ 3 tọa độ (x, y) bất kỳ
  static double calculateRawAngle(
    double ax,
    double ay,
    double bx,
    double by,
    double cx,
    double cy,
  ) {
    final radians = math.atan2(cy - by, cx - bx) - math.atan2(ay - by, ax - bx);
    var deg = (radians * 180.0 / math.pi).abs();
    if (deg > 180.0) deg = 360.0 - deg;
    return deg;
  }

  /// Trích xuất bộ góc chuẩn đặc trưng cho Lookbook
  static Map<String, double> getTargetAnglesForLookbook({
    dynamic poseLandmarksJson,
    String? title,
    String? category,
  }) {
    // 1. Thử trích xuất từ poseLandmarksJson nếu hợp lệ
    final fromJson = _extractTargetAnglesFromJson(poseLandmarksJson);
    if (fromJson != null && fromJson.length == 8) {
      return fromJson;
    }

    // 2. Fallback sang bộ góc chuẩn đặc trưng (Fashion Pose Presets)
    final combined = '${title ?? ''} ${category ?? ''}'.toLowerCase();

    // Dáng chân dung / Bán thân / Ngồi chống cằm / Cận cảnh (Portrait / Sitting Chin / Selfie)
    if (combined.contains('sakura') ||
        combined.contains('chin') ||
        combined.contains('portrait') ||
        combined.contains('face') ||
        combined.contains('selfie') ||
        combined.contains('blazer') ||
        combined.contains('headshot') ||
        combined.contains('relax')) {
      return {
        'leftArmFlare': 98.0,
        'rightArmFlare': 100.0,
        'headShoulderSpan': 82.0,
        'leftElbow': 110.0,
        'rightElbow': 115.0,
        'leftShoulder': 48.0,
        'rightShoulder': 46.0,
      };
    }

    // Dáng ngồi / Vest / Suit / Editorial Office
    if (combined.contains('vest') ||
        combined.contains('suit') ||
        combined.contains('office') ||
        combined.contains('sit') ||
        combined.contains('kimono')) {
      return {
        'leftArmFlare': 100.0,
        'rightArmFlare': 102.0,
        'headShoulderSpan': 82.0,
        'leftElbow': 110.0,
        'rightElbow': 115.0,
        'leftShoulder': 48.0,
        'rightShoulder': 46.0,
        'leftHip': 98.0, // Dáng ngồi góc hông ~90°-110°
        'rightHip': 102.0,
        'leftKnee': 92.0,
        'rightKnee': 95.0,
      };
    }

    // Dáng ngồi chồm / Dynamic Crouch / Acid Rave
    if (combined.contains('crouch') ||
        combined.contains('rave') ||
        combined.contains('acid') ||
        combined.contains('squat')) {
      return {
        'leftArmFlare': 108.0,
        'rightArmFlare': 105.0,
        'headShoulderSpan': 80.0,
        'leftElbow': 118.0,
        'rightElbow': 122.0,
        'leftShoulder': 56.0,
        'rightShoulder': 54.0,
        'leftHip': 105.0,
        'rightHip': 100.0,
        'leftKnee': 96.0,
        'rightKnee': 92.0,
      };
    }

    // Dáng đứng Streetwear / Trench Coat / Minimal Stance (Mặc định)
    return {
      'leftArmFlare': 102.0,
      'rightArmFlare': 102.0,
      'headShoulderSpan': 82.0,
      'leftElbow': 142.0, // Tay buông tự nhiên hơi gập nhẹ
      'rightElbow': 136.0,
      'leftShoulder': 38.0, // Cánh tay sát thân
      'rightShoulder': 42.0,
      'leftHip': 172.0, // Dáng đứng góc hông ~165°-180°
      'rightHip': 174.0,
      'leftKnee': 176.0,
      'rightKnee': 175.0,
    };
  }

  static Map<String, double>? _extractTargetAnglesFromJson(dynamic raw) {
    try {
      dynamic data = raw;
      if (data is String && data.trim().isNotEmpty) data = jsonDecode(data);
      if (data is Map && data['landmarks'] is List) data = data['landmarks'];
      if (data is! List || data.length < 33) return null;

      final xs = <int, double>{};
      final ys = <int, double>{};
      final vs = <int, double>{};
      for (final e in data) {
        if (e is! Map) continue;
        final idxRaw = e['landmarkIndex'] ?? e['index'];
        final x = e['x'];
        final y = e['y'];
        if (idxRaw is! num || x is! num || y is! num) continue;
        final idx = idxRaw.toInt();
        xs[idx] = x.toDouble();
        ys[idx] = y.toDouble();
        final vis = e['visibility'] ?? e['likelihood'] ?? e['inFrameLikelihood'] ?? 1.0;
        vs[idx] = vis is num ? vis.toDouble() : 1.0;
      }

      for (final i in const [0, 11, 12, 23, 24, 27, 28]) {
        if (!xs.containsKey(i)) return null;
      }
      final shoulderWidth = (xs[11]! - xs[12]!).abs();
      final bodySpan = ((ys[27]! + ys[28]!) / 2) - ys[0]!;
      if (shoulderWidth < 0.05 || bodySpan < 0.30) return null;

      final result = <String, double>{};
      for (final def in angleDefinitions) {
        if (!xs.containsKey(def.iFirst) ||
            !xs.containsKey(def.iMid) ||
            !xs.containsKey(def.iLast)) {
          continue;
        }
        if ((vs[def.iFirst] ?? 0) < minLikelihood ||
            (vs[def.iMid] ?? 0) < minLikelihood ||
            (vs[def.iLast] ?? 0) < minLikelihood) {
          continue;
        }
        result[def.name] = calculateRawAngle(
          xs[def.iFirst]!,
          ys[def.iFirst]!,
          xs[def.iMid]!,
          ys[def.iMid]!,
          xs[def.iLast]!,
          ys[def.iLast]!,
        );
      }
      return result.length == 8 ? result : null;
    } catch (_) {
      return null;
    }
  }

  /// Xây dựng PoseFrame từ đối tượng Pose của ML Kit
  /// Sử dụng PoseMatchingConfig và Strategy Pattern cho việc chấm điểm
  static PoseFrame buildFrame({
    required Pose pose,
    required Size uprightSize,
    required bool mirror,
    required Map<String, double> targetAngles,
    Map<PoseLandmarkType, Offset>? previousPoints,
    PoseMatchingConfig? config,
    PoseMatcherStrategy? strategy,
  }) {
    final effectiveConfig = config ?? PoseMatchingConfig.current;
    final effectiveStrategy = strategy ?? const VectorAngleToleranceMatcher();

    // 1. Kiểm tra Gate thân trên (yêu cầu tối thiểu minUpperBodyJoints hiển thị rõ)
    int upperBodyCount = 0;
    for (final type in upperBodyCoreJoints) {
      final lm = pose.landmarks[type];
      if (lm != null && lm.likelihood > effectiveConfig.minLikelihood) {
        upperBodyCount++;
      }
    }

    // 2. Chuyển đổi tọa độ 2D chuẩn hóa (0..1) kèm làm mượt (EMA Smoothing)
    // Instant Skeleton Startup: Nếu previousPoints rỗng (frame đầu tiên), gán ngay lập tức
    final points = <PoseLandmarkType, Offset>{};
    final double alpha = effectiveConfig.coordinateSmoothingAlpha;

    for (final type in trackedTypes) {
      final lm = pose.landmarks[type];
      if (lm == null || lm.likelihood < effectiveConfig.minLikelihood) continue;

      var nx = (lm.x / uprightSize.width).clamp(0.0, 1.0);
      final ny = (lm.y / uprightSize.height).clamp(0.0, 1.0);
      if (mirror) nx = 1.0 - nx;

      final current = Offset(nx, ny);
      if (previousPoints != null &&
          previousPoints.isNotEmpty &&
          previousPoints.containsKey(type)) {
        final prev = previousPoints[type]!;
        points[type] = Offset(
          prev.dx * (1.0 - alpha) + current.dx * alpha,
          prev.dy * (1.0 - alpha) + current.dy * alpha,
        );
      } else {
        // Frame đầu tiên hoặc khớp mới xuất hiện: gán ngay không có độ trễ
        points[type] = current;
      }
    }

    final bool hasPose = points.length >= 3;
    if (!hasPose) {
      return const PoseFrame(
        points: {},
        score: 0,
        diffDegrees: 0,
        hasPose: false,
        needsFullBody: false,
        statusText: 'Đang tìm dáng người...',
        validCoreJoints: 0,
      );
    }

    // 3. Tính góc vector CHỈ TRÊN NHỮNG GÓC HIỂN THỊ RÕ (cả 3 khớp đều có likelihood > minLikelihood)
    final userAngles = <String, double>{};
    for (final def in angleDefinitions) {
      final first = pose.landmarks[def.first];
      final mid = pose.landmarks[def.mid];
      final last = pose.landmarks[def.last];

      if (first == null ||
          mid == null ||
          last == null ||
          first.likelihood < effectiveConfig.minLikelihood ||
          mid.likelihood < effectiveConfig.minLikelihood ||
          last.likelihood < effectiveConfig.minLikelihood) {
        // Bỏ qua góc bị khuất khỏi màn hình (KHÔNG phạt)
        continue;
      }
      userAngles[def.name] = calculateAngle(first, mid, last);
    }

    // 4. Đánh giá độ tương đồng qua PoseMatcherStrategy
    final evaluation = effectiveStrategy.evaluate(
      userAngles: userAngles,
      targetAngles: targetAngles,
      mirrorJointMapping: mirrorJointNames,
      config: effectiveConfig,
    );

    // 5. Kiểm tra Gate thân trên:
    // Bắt buộc phải có đủ 2 vai VÀ ít nhất 1 góc chi thể (bắp tay/vai/cùi chỏ)
    // Chặn tuyệt đối lỗi chỉ đưa khuôn mặt lại gần mà vẫn đạt điểm cao
    final int limbAngleCount =
        userAngles.keys.where((k) => k != 'headShoulderSpan').length;
    final bool hasBodyAngles = limbAngleCount >= 1;
    final bool hasBothShoulders =
        upperBodyCount >= effectiveConfig.minUpperBodyJoints;
    final bool needsUpperBody = !hasBothShoulders || !hasBodyAngles;

    double finalScore = evaluation.score;
    String statusText;

    if (needsUpperBody) {
      finalScore =
          evaluation.score.clamp(15.0, effectiveConfig.faceOnlyMaxScore);
      statusText = 'Step Back • Show Upper Body';
    } else if (finalScore >= effectiveConfig.matchThreshold) {
      statusText = 'Pose Matched (${finalScore.round()}%)';
    } else {
      statusText = 'Scanning Pose... (${finalScore.round()}%)';
    }

    return PoseFrame(
      points: points,
      score: finalScore,
      diffDegrees: evaluation.rawDiff,
      hasPose: true,
      needsFullBody: needsUpperBody,
      statusText: statusText,
      validCoreJoints: upperBodyCount,
    );
  }
}
