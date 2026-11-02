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
  final String coachingHint;
  final int validCoreJoints;
  final Map<String, double> jointDiffs;

  const PoseFrame({
    required this.points,
    required this.score,
    required this.diffDegrees,
    required this.hasPose,
    required this.needsFullBody,
    required this.statusText,
    required this.coachingHint,
    required this.validCoreJoints,
    this.jointDiffs = const {},
  });

  static const PoseFrame empty = PoseFrame(
    points: <PoseLandmarkType, Offset>{},
    score: 0,
    diffDegrees: 0,
    hasPose: false,
    needsFullBody: false,
    statusText: 'Đang tìm dáng người...',
    coachingHint: 'Đứng vào khung hình đối diện ống kính',
    validCoreJoints: 0,
    jointDiffs: {},
  );

  PoseFrame copyWith({
    Map<PoseLandmarkType, Offset>? points,
    double? score,
    double? diffDegrees,
    bool? hasPose,
    bool? needsFullBody,
    String? statusText,
    String? coachingHint,
    int? validCoreJoints,
    Map<String, double>? jointDiffs,
  }) =>
      PoseFrame(
        points: points ?? this.points,
        score: score ?? this.score,
        diffDegrees: diffDegrees ?? this.diffDegrees,
        hasPose: hasPose ?? this.hasPose,
        needsFullBody: needsFullBody ?? this.needsFullBody,
        statusText: statusText ?? this.statusText,
        coachingHint: coachingHint ?? this.coachingHint,
        validCoreJoints: validCoreJoints ?? this.validCoreJoints,
        jointDiffs: jointDiffs ?? this.jointDiffs,
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

/// Mô hình tọa độ các điểm mốc cho Khung Xương Mẫu Nét Đứt (Ghost Guide Skeleton)
class TargetGhostSkeleton {
  final Offset nose;
  final Offset leftShoulder;
  final Offset rightShoulder;
  final Offset leftElbow;
  final Offset rightElbow;
  final Offset leftWrist;
  final Offset rightWrist;
  final Offset? leftHip;
  final Offset? rightHip;

  const TargetGhostSkeleton({
    required this.nose,
    required this.leftShoulder,
    required this.rightShoulder,
    required this.leftElbow,
    required this.rightElbow,
    required this.leftWrist,
    required this.rightWrist,
    this.leftHip,
    this.rightHip,
  });

  /// Tính toán vị trí các khớp của Khung Xương Mẫu:
  /// - Nếu đã thấy 2 vai người dùng: neo gốc tại trung điểm 2 vai và co giãn theo khoảng cách 2 vai
  /// - Nếu chưa thấy: vẽ cân đối ở trung tâm màn hình
  factory TargetGhostSkeleton.compute({
    required Size size,
    required Map<String, double> targetAngles,
    Offset? userLeftShoulder,
    Offset? userRightShoulder,
    String? lookbookTitle,
  }) {
    final title = (lookbookTitle ?? '').toLowerCase();
    final bool isRaisedArmPose = title.contains('kimono') ||
        title.contains('outlaw') ||
        title.contains('tokyo') ||
        title.contains('cyber') ||
        title.contains('rave') ||
        title.contains('power') ||
        title.contains('flare');
    final bool isChinPose = title.contains('chin') ||
        title.contains('sakura') ||
        title.contains('portrait') ||
        title.contains('selfie');
    final bool isCrossArms = title.contains('cross');

    Offset ls;
    Offset rs;
    double span;
    double shoulderAngleRad = 0.0;

    if (userLeftShoulder != null && userRightShoulder != null) {
      ls = userLeftShoulder;
      rs = userRightShoulder;
      final dx = rs.dx - ls.dx;
      final dy = rs.dy - ls.dy;
      span = math.sqrt(dx * dx + dy * dy);
      if (span < 20.0) span = size.width * 0.32;
      shoulderAngleRad = math.atan2(dy, dx);
    } else {
      final cx = size.width * 0.5;
      final cy = size.height * 0.38;
      span = size.width * 0.34;
      ls = Offset(cx - span * 0.5, cy);
      rs = Offset(cx + span * 0.5, cy);
    }

    final midShoulder = Offset((ls.dx + rs.dx) * 0.5, (ls.dy + rs.dy) * 0.5);
    final upUnit = Offset(math.sin(shoulderAngleRad), -math.cos(shoulderAngleRad));
    final nose = Offset(
      midShoulder.dx + upUnit.dx * (span * 0.65),
      midShoulder.dy + upUnit.dy * (span * 0.65),
    );

    Offset le;
    Offset re;
    Offset lw;
    Offset rw;

    if (isRaisedArmPose) {
      // Dang 2 tay cao (Cyber Neo Kimono / Tokyo Outlaw)
      le = Offset(ls.dx - span * 0.85, ls.dy - span * 0.45);
      re = Offset(rs.dx + span * 0.85, rs.dy - span * 0.45);
      lw = Offset(le.dx - span * 0.75, le.dy - span * 0.30);
      rw = Offset(re.dx + span * 0.75, re.dy - span * 0.30);
    } else if (isChinPose) {
      // 1 tay chống cằm / giơ lên mặt, 1 tay buông
      le = Offset(ls.dx - span * 0.40, ls.dy + span * 0.50);
      lw = Offset(midShoulder.dx - span * 0.10, midShoulder.dy - span * 0.20);
      re = Offset(rs.dx + span * 0.30, rs.dy + span * 0.90);
      rw = Offset(re.dx + span * 0.15, re.dy + span * 0.80);
    } else if (isCrossArms) {
      // Khoanh tay trước ngực
      le = Offset(ls.dx - span * 0.35, ls.dy + span * 0.60);
      re = Offset(rs.dx + span * 0.35, rs.dy + span * 0.60);
      lw = Offset(midShoulder.dx + span * 0.25, midShoulder.dy + span * 0.55);
      rw = Offset(midShoulder.dx - span * 0.25, midShoulder.dy + span * 0.55);
    } else {
      // Dáng đứng tự nhiên / Vest / Streetwear
      le = Offset(ls.dx - span * 0.30, ls.dy + span * 0.90);
      re = Offset(rs.dx + span * 0.30, rs.dy + span * 0.90);
      lw = Offset(le.dx - span * 0.15, le.dy + span * 0.85);
      rw = Offset(re.dx + span * 0.15, re.dy + span * 0.85);
    }

    final lh = Offset(ls.dx + span * 0.10, ls.dy + span * 1.6);
    final rh = Offset(rs.dx - span * 0.10, rs.dy + span * 1.6);

    return TargetGhostSkeleton(
      nose: nose,
      leftShoulder: ls,
      rightShoulder: rs,
      leftElbow: le,
      rightElbow: re,
      leftWrist: lw,
      rightWrist: rw,
      leftHip: lh,
      rightHip: rh,
    );
  }
}

/// Dịch vụ tính toán tư thế & chấm điểm khớp góc vector thời gian thực
class MlKitPoseService {
  MlKitPoseService._();

  static const double minLikelihood = 0.45;

  /// 2 khớp vai bắt buộc để xác nhận thấy rõ thân người
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

  /// Trích xuất bộ góc chuẩn đặc trưng cho Lookbook
  static Map<String, double> getTargetAnglesForLookbook({
    dynamic poseLandmarksJson,
    String? title,
    String? category,
  }) {
    final combined = '${title ?? ''} ${category ?? ''}'.toLowerCase();

    // 1. Dáng dang 2 tay / Cyber Neo Kimono / Tokyo Outlaw / Dynamic Rave
    if (combined.contains('kimono') ||
        combined.contains('outlaw') ||
        combined.contains('tokyo') ||
        combined.contains('cyber') ||
        combined.contains('power') ||
        combined.contains('rave')) {
      return {
        'leftArmFlare': 138.0,
        'rightArmFlare': 138.0,
        'headShoulderSpan': 82.0,
        'leftElbow': 105.0,
        'rightElbow': 105.0,
        'leftShoulder': 88.0,
        'rightShoulder': 88.0,
        'leftHip': 172.0,
        'rightHip': 174.0,
      };
    }

    // 2. Dáng chân dung / Chống cằm / Sakura / Selfie / Blazer
    if (combined.contains('sakura') ||
        combined.contains('chin') ||
        combined.contains('portrait') ||
        combined.contains('selfie')) {
      return {
        'leftArmFlare': 115.0,
        'rightArmFlare': 100.0,
        'headShoulderSpan': 82.0,
        'leftElbow': 88.0,
        'rightElbow': 130.0,
        'leftShoulder': 78.0,
        'rightShoulder': 42.0,
        'leftHip': 170.0,
        'rightHip': 170.0,
      };
    }

    // 3. Dáng khoanh tay trước ngực
    if (combined.contains('cross')) {
      return {
        'leftArmFlare': 120.0,
        'rightArmFlare': 120.0,
        'headShoulderSpan': 82.0,
        'leftElbow': 72.0,
        'rightElbow': 72.0,
        'leftShoulder': 55.0,
        'rightShoulder': 55.0,
        'leftHip': 170.0,
        'rightHip': 170.0,
      };
    }

    // 4. Dáng ngồi / Suit / Office
    if (combined.contains('vest') ||
        combined.contains('suit') ||
        combined.contains('office') ||
        combined.contains('sit')) {
      return {
        'leftArmFlare': 100.0,
        'rightArmFlare': 102.0,
        'headShoulderSpan': 82.0,
        'leftElbow': 110.0,
        'rightElbow': 115.0,
        'leftShoulder': 48.0,
        'rightShoulder': 46.0,
        'leftHip': 98.0,
        'rightHip': 102.0,
        'leftKnee': 92.0,
        'rightKnee': 95.0,
      };
    }

    // 5. Dáng đứng Streetwear / Trench Coat mặc định
    return {
      'leftArmFlare': 102.0,
      'rightArmFlare': 102.0,
      'headShoulderSpan': 82.0,
      'leftElbow': 142.0,
      'rightElbow': 136.0,
      'leftShoulder': 38.0,
      'rightShoulder': 42.0,
      'leftHip': 172.0,
      'rightHip': 174.0,
      'leftKnee': 176.0,
      'rightKnee': 175.0,
    };
  }

  /// Xây dựng PoseFrame từ đối tượng Pose của ML Kit
  static PoseFrame buildFrame({
    required Pose pose,
    required Size uprightSize,
    required bool mirror,
    required Map<String, double> targetAngles,
    Map<PoseLandmarkType, Offset>? previousPoints,
    PoseMatchingConfig? config,
    PoseMatcherStrategy? strategy,
    String? lookbookTitle,
  }) {
    final effectiveConfig = config ?? PoseMatchingConfig.current;
    final effectiveStrategy = strategy ?? const VectorAngleToleranceMatcher();

    // 1. Kiểm tra 2 vai
    int upperBodyCount = 0;
    for (final type in upperBodyCoreJoints) {
      final lm = pose.landmarks[type];
      if (lm != null && lm.likelihood >= minLikelihood) {
        upperBodyCount++;
      }
    }

    // 2. Kiểm tra cùi chỏ (Elbow likelihood gate)
    final leftElbowLm = pose.landmarks[PoseLandmarkType.leftElbow];
    final rightElbowLm = pose.landmarks[PoseLandmarkType.rightElbow];
    final bool hasLeftElbow =
        leftElbowLm != null && leftElbowLm.likelihood >= minLikelihood;
    final bool hasRightElbow =
        rightElbowLm != null && rightElbowLm.likelihood >= minLikelihood;
    final int visibleElbowCount = (hasLeftElbow ? 1 : 0) + (hasRightElbow ? 1 : 0);

    // 3. Tọa độ chuẩn hóa (0..1) kèm làm mượt EMA
    final points = <PoseLandmarkType, Offset>{};
    final double alpha = effectiveConfig.coordinateSmoothingAlpha;

    for (final type in trackedTypes) {
      final lm = pose.landmarks[type];
      if (lm == null || lm.likelihood < minLikelihood) continue;

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
        coachingHint: 'Đứng vào khung hình đối diện ống kính',
        validCoreJoints: 0,
        jointDiffs: {},
      );
    }

    // 4. Tính các góc vector của người dùng
    final userAngles = <String, double>{};
    for (final def in angleDefinitions) {
      final first = pose.landmarks[def.first];
      final mid = pose.landmarks[def.mid];
      final last = pose.landmarks[def.last];

      if (first == null ||
          mid == null ||
          last == null ||
          first.likelihood < minLikelihood ||
          mid.likelihood < minLikelihood ||
          last.likelihood < minLikelihood) {
        continue;
      }
      userAngles[def.name] = calculateAngle(first, mid, last);
    }

    // 5. Đánh giá độ tương đồng qua PoseMatcherStrategy
    final evaluation = effectiveStrategy.evaluate(
      userAngles: userAngles,
      targetAngles: targetAngles,
      mirrorJointMapping: mirrorJointNames,
      config: effectiveConfig,
    );

    final jointDiffs = Map<String, double>.from(evaluation.jointDiffs);

    // 6. Kiểm tra độ nghiêng vai
    double shoulderTiltDeg = 0.0;
    if (points.containsKey(PoseLandmarkType.leftShoulder) &&
        points.containsKey(PoseLandmarkType.rightShoulder)) {
      final ls = points[PoseLandmarkType.leftShoulder]!;
      final rs = points[PoseLandmarkType.rightShoulder]!;
      shoulderTiltDeg = (math.atan2((rs.dy - ls.dy).abs(), (rs.dx - ls.dx).abs()) * 180.0 / math.pi);
    }

    // 7. Gate thân trên & Chặn nghịch lý buông tay không có khuỷu tay
    final bool hasBothShoulders = upperBodyCount >= 2;
    final bool needsShoulders = !hasBothShoulders;

    // Đối với các dáng có động tác tay: bắt buộc phải thấy ít nhất 1 khuỷu tay
    final title = (lookbookTitle ?? '').toLowerCase();
    final bool requiresArmPose = title.contains('kimono') ||
        title.contains('outlaw') ||
        title.contains('tokyo') ||
        title.contains('cyber') ||
        title.contains('chin') ||
        title.contains('cross') ||
        title.contains('rave');

    double finalScore = evaluation.score;
    bool needsFullBody = false;
    String statusText;
    String coachingHint;

    if (needsShoulders) {
      needsFullBody = true;
      finalScore = finalScore.clamp(10.0, 55.0);
      statusText = 'Step Back • Show Both Shoulders';
      coachingHint = 'Lùi lại nhẹ để thấy rõ hai vai';
    } else if (requiresArmPose && visibleElbowCount == 0) {
      // Người dùng buông tay khuất khung hình trong khi mẫu giơ tay
      needsFullBody = true;
      finalScore = finalScore.clamp(20.0, 68.0);
      statusText = 'Show Arms in Frame';
      coachingHint = 'Đưa tay vào khung hình theo mẫu';
    } else if (shoulderTiltDeg > 18.0) {
      finalScore = (finalScore - 12.0).clamp(20.0, 100.0);
      statusText = 'Balance Shoulders';
      coachingHint = 'Giữ cân bằng hai vai đối diện ống kính';
    } else {
      // Tìm khớp đang lệch nhiều nhất để nhắc hành động
      double maxArmDiff = 0.0;
      bool isArmLower = false;

      for (final key in ['leftArmFlare', 'rightArmFlare', 'leftShoulder', 'rightShoulder']) {
        final d = jointDiffs[key] ?? 0.0;
        if (d > maxArmDiff) {
          maxArmDiff = d;
          if (targetAngles.containsKey(key) && userAngles.containsKey(key)) {
            isArmLower = userAngles[key]! < targetAngles[key]!;
          }
        }
      }

      if (finalScore >= effectiveConfig.matchThreshold) {
        statusText = 'Pose Matched (${finalScore.round()}%)';
        coachingHint = 'Tư thế hoàn hảo! Giữ yên để chụp...';
      } else if (maxArmDiff > 18.0) {
        statusText = 'Scanning Pose... (${finalScore.round()}%)';
        coachingHint = isArmLower
            ? 'Nâng khuỷu tay cao lên theo khung mẫu'
            : 'Đưa cánh tay khớp vào đường nét đứt';
      } else {
        statusText = 'Scanning Pose... (${finalScore.round()}%)';
        coachingHint = 'Chỉnh khớp vào đường nét đứt';
      }
    }

    return PoseFrame(
      points: points,
      score: finalScore,
      diffDegrees: evaluation.rawDiff,
      hasPose: true,
      needsFullBody: needsFullBody,
      statusText: statusText,
      coachingHint: coachingHint,
      validCoreJoints: upperBodyCount,
      jointDiffs: jointDiffs,
    );
  }
}
