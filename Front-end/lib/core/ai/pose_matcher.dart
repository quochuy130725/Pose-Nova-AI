import 'pose_matching_config.dart';

/// Kết quả đánh giá sự tương đồng tư thế từ một Strategy
class PoseMatchEvaluation {
  /// Điểm số tổng thể (0.0 - 100.0)
  final double score;

  /// Độ lệch thô trung bình (độ)
  final double rawDiff;

  /// Độ lệch hiệu dụng sau khi qua đường cong dung sai
  final double effectiveDiff;

  /// Có đang xét theo hướng lật gương (mirrored) hay trực tiếp (direct)
  final bool isMirrored;

  /// Chi tiết độ lệch từng góc khớp xương
  final Map<String, double> jointDiffs;

  const PoseMatchEvaluation({
    required this.score,
    required this.rawDiff,
    required this.effectiveDiff,
    required this.isMirrored,
    this.jointDiffs = const {},
  });

  static const empty = PoseMatchEvaluation(
    score: 0.0,
    rawDiff: 60.0,
    effectiveDiff: 60.0,
    isMirrored: false,
    jointDiffs: {},
  );
}

/// Interface Chiến lược Chấm điểm Khớp Dáng (Strategy Pattern)
/// Cho phép linh hoạt thay thế giải thuật toán học mà không làm thay đổi luồng Camera hay UI.
abstract class PoseMatcherStrategy {
  String get name;

  PoseMatchEvaluation evaluate({
    required Map<String, double> userAngles,
    required Map<String, double> targetAngles,
    required Map<String, String> mirrorJointMapping,
    required PoseMatchingConfig config,
  });
}

/// Chiến lược 1 (Mặc định): Chấm điểm góc Vector với Đường cong Dung sai Tự nhiên (Natural Tolerance Curve)
class VectorAngleToleranceMatcher implements PoseMatcherStrategy {
  const VectorAngleToleranceMatcher();

  @override
  String get name => 'VectorAngleTolerance';

  @override
  PoseMatchEvaluation evaluate({
    required Map<String, double> userAngles,
    required Map<String, double> targetAngles,
    required Map<String, String> mirrorJointMapping,
    required PoseMatchingConfig config,
  }) {
    if (userAngles.isEmpty || targetAngles.isEmpty) {
      return PoseMatchEvaluation.empty;
    }

    final direct = _compute(
      userAngles,
      targetAngles,
      mirrorJointMapping,
      swapSides: false,
      config: config,
    );
    final mirrored = _compute(
      userAngles,
      targetAngles,
      mirrorJointMapping,
      swapSides: true,
      config: config,
    );

    return direct.effectiveDiff <= mirrored.effectiveDiff ? direct : mirrored;
  }

  PoseMatchEvaluation _compute(
    Map<String, double> user,
    Map<String, double> target,
    Map<String, String> mirrorMap, {
    required bool swapSides,
    required PoseMatchingConfig config,
  }) {
    double totalEffectiveDiff = 0.0;
    double totalRawDiff = 0.0;
    int counted = 0;
    final jointDiffs = <String, double>{};

    for (final entry in user.entries) {
      final name = entry.key;
      final targetKey = swapSides ? (mirrorMap[name] ?? name) : name;
      final targetAngle = target[targetKey];
      if (targetAngle == null) continue;

      final rawDiff = (entry.value - targetAngle).abs();
      totalRawDiff += rawDiff;
      jointDiffs[name] = rawDiff;

      // Nới lỏng dung sai góc theo cấu hình
      final double effectiveDiff;
      if (rawDiff <= config.toleranceAngleDeg) {
        effectiveDiff = rawDiff * config.mildDiffFactor;
      } else {
        final base = config.toleranceAngleDeg * config.mildDiffFactor;
        effectiveDiff =
            base + (rawDiff - config.toleranceAngleDeg) * config.steepDiffFactor;
      }

      totalEffectiveDiff += effectiveDiff;
      counted++;
    }

    if (counted == 0) {
      return const PoseMatchEvaluation(
        score: 0.0,
        rawDiff: 50.0,
        effectiveDiff: 50.0,
        isMirrored: false,
      );
    }

    final avgEffective = totalEffectiveDiff / counted;
    final avgRaw = totalRawDiff / counted;
    final score = (100.0 - avgEffective).clamp(0.0, 100.0);

    return PoseMatchEvaluation(
      score: score,
      rawDiff: avgRaw,
      effectiveDiff: avgEffective,
      isMirrored: swapSides,
      jointDiffs: jointDiffs,
    );
  }
}

/// Chiến lược 2 (Mở rộng): Chấm điểm ưu tiên Thân trên (Upper-Body Weighted Matcher)
/// Tăng trọng số cho cánh tay và vai khi chụp góc bán thân
class UpperBodyPriorityMatcher implements PoseMatcherStrategy {
  final Map<String, double> weights;

  const UpperBodyPriorityMatcher({
    this.weights = const {
      'leftElbow': 1.4,
      'rightElbow': 1.4,
      'leftShoulder': 1.2,
      'rightShoulder': 1.2,
      'leftHip': 0.6,
      'rightHip': 0.6,
      'leftKnee': 0.4,
      'rightKnee': 0.4,
    },
  });

  @override
  String get name => 'UpperBodyPriority';

  @override
  PoseMatchEvaluation evaluate({
    required Map<String, double> userAngles,
    required Map<String, double> targetAngles,
    required Map<String, String> mirrorJointMapping,
    required PoseMatchingConfig config,
  }) {
    if (userAngles.isEmpty || targetAngles.isEmpty) {
      return PoseMatchEvaluation.empty;
    }

    final direct = _compute(
      userAngles,
      targetAngles,
      mirrorJointMapping,
      swapSides: false,
      config: config,
    );
    final mirrored = _compute(
      userAngles,
      targetAngles,
      mirrorJointMapping,
      swapSides: true,
      config: config,
    );

    return direct.effectiveDiff <= mirrored.effectiveDiff ? direct : mirrored;
  }

  PoseMatchEvaluation _compute(
    Map<String, double> user,
    Map<String, double> target,
    Map<String, String> mirrorMap, {
    required bool swapSides,
    required PoseMatchingConfig config,
  }) {
    double weightedEffectiveDiff = 0.0;
    double weightedRawDiff = 0.0;
    double totalWeight = 0.0;
    final jointDiffs = <String, double>{};

    for (final entry in user.entries) {
      final name = entry.key;
      final targetKey = swapSides ? (mirrorMap[name] ?? name) : name;
      final targetAngle = target[targetKey];
      if (targetAngle == null) continue;

      final w = weights[name] ?? 1.0;
      final rawDiff = (entry.value - targetAngle).abs();
      jointDiffs[name] = rawDiff;

      final double effectiveDiff;
      if (rawDiff <= config.toleranceAngleDeg) {
        effectiveDiff = rawDiff * config.mildDiffFactor;
      } else {
        final base = config.toleranceAngleDeg * config.mildDiffFactor;
        effectiveDiff =
            base + (rawDiff - config.toleranceAngleDeg) * config.steepDiffFactor;
      }

      weightedEffectiveDiff += effectiveDiff * w;
      weightedRawDiff += rawDiff * w;
      totalWeight += w;
    }

    if (totalWeight == 0) {
      return const PoseMatchEvaluation(
        score: 0.0,
        rawDiff: 50.0,
        effectiveDiff: 50.0,
        isMirrored: false,
      );
    }

    final avgEffective = weightedEffectiveDiff / totalWeight;
    final avgRaw = weightedRawDiff / totalWeight;
    final score = (100.0 - avgEffective).clamp(0.0, 100.0);

    return PoseMatchEvaluation(
      score: score,
      rawDiff: avgRaw,
      effectiveDiff: avgEffective,
      isMirrored: swapSides,
      jointDiffs: jointDiffs,
    );
  }
}

/// Bộ điều phối Chấm điểm Tư thế (Pose Evaluator)
class PoseEvaluator {
  PoseMatchingConfig config;
  PoseMatcherStrategy strategy;

  PoseEvaluator({
    PoseMatchingConfig? config,
    PoseMatcherStrategy? strategy,
  })  : config = config ?? PoseMatchingConfig.current,
        strategy = strategy ?? const VectorAngleToleranceMatcher();

  static final PoseEvaluator instance = PoseEvaluator();

  PoseMatchEvaluation evaluate({
    required Map<String, double> userAngles,
    required Map<String, double> targetAngles,
    required Map<String, String> mirrorJointMapping,
  }) {
    return strategy.evaluate(
      userAngles: userAngles,
      targetAngles: targetAngles,
      mirrorJointMapping: mirrorJointMapping,
      config: config,
    );
  }
}

