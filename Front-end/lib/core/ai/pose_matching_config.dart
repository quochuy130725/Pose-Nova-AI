/// Cấu hình động cho thuật toán chấm điểm và nhận diện tư thế PoseNova AI
/// Cho phép điều chỉnh linh hoạt mọi ngưỡng số mà không cần sửa UI hay luồng Camera.
class PoseMatchingConfig {
  /// Độ tin cậy tối thiểu của một khớp xương ML Kit (0.0 - 1.0)
  final double minLikelihood;

  /// Hệ số làm mượt EMA tọa độ khung xương (0.0 - 1.0)
  final double coordinateSmoothingAlpha;

  /// Hệ số làm mượt điểm số giữa các khung hình (0.0 - 1.0)
  final double scoreSmoothingFactor;

  /// Ngưỡng điểm đạt tư thế tương đồng (bắt đầu đếm ngược auto-shutter)
  final double matchThreshold;

  /// Ngưỡng điểm hủy đếm ngược nếu tư thế bị lệch
  final double cancelThreshold;

  /// Số frame giữ dáng liên tục trước khi chụp tự động
  final int requiredMatchFrames;

  /// Góc dung sai tự nhiên (độ) - dưới ngưỡng này coi như đã tạo dáng chuẩn
  final double toleranceAngleDeg;

  /// Hệ số phạt nhẹ trong vùng dung sai (<= toleranceAngleDeg)
  final double mildDiffFactor;

  /// Hệ số phạt dốc ngoài vùng dung sai (> toleranceAngleDeg)
  final double steepDiffFactor;

  /// Số khớp thân trên tối thiểu bắt buộc phải thấy rõ
  final int minUpperBodyJoints;

  /// Điểm trần tối đa khi vi phạm Upper Body Gate (chỉ thấy khuôn mặt)
  final double faceOnlyMaxScore;

  /// Thời gian đếm ngược auto-shutter (giây)
  final int countdownSeconds;

  const PoseMatchingConfig({
    this.minLikelihood = 0.50,
    this.coordinateSmoothingAlpha = 0.70,
    this.scoreSmoothingFactor = 0.60,
    this.matchThreshold = 85.0,
    this.cancelThreshold = 70.0,
    this.requiredMatchFrames = 8,
    this.toleranceAngleDeg = 15.0,
    this.mildDiffFactor = 0.30,
    this.steepDiffFactor = 0.85,
    this.minUpperBodyJoints = 2,
    this.faceOnlyMaxScore = 35.0,
    this.countdownSeconds = 1,
  });

  /// Cấu hình mặc định hiện tại của toàn bộ ứng dụng
  static PoseMatchingConfig current = const PoseMatchingConfig();

  /// Cho phép cập nhật cấu hình toàn cục (từ Backend API, Remote Config hoặc Settings)
  static void updateGlobal(PoseMatchingConfig newConfig) {
    current = newConfig;
  }

  PoseMatchingConfig copyWith({
    double? minLikelihood,
    double? coordinateSmoothingAlpha,
    double? scoreSmoothingFactor,
    double? matchThreshold,
    double? cancelThreshold,
    int? requiredMatchFrames,
    double? toleranceAngleDeg,
    double? mildDiffFactor,
    double? steepDiffFactor,
    int? minUpperBodyJoints,
    double? faceOnlyMaxScore,
    int? countdownSeconds,
  }) {
    return PoseMatchingConfig(
      minLikelihood: minLikelihood ?? this.minLikelihood,
      coordinateSmoothingAlpha: coordinateSmoothingAlpha ?? this.coordinateSmoothingAlpha,
      scoreSmoothingFactor: scoreSmoothingFactor ?? this.scoreSmoothingFactor,
      matchThreshold: matchThreshold ?? this.matchThreshold,
      cancelThreshold: cancelThreshold ?? this.cancelThreshold,
      requiredMatchFrames: requiredMatchFrames ?? this.requiredMatchFrames,
      toleranceAngleDeg: toleranceAngleDeg ?? this.toleranceAngleDeg,
      mildDiffFactor: mildDiffFactor ?? this.mildDiffFactor,
      steepDiffFactor: steepDiffFactor ?? this.steepDiffFactor,
      minUpperBodyJoints: minUpperBodyJoints ?? this.minUpperBodyJoints,
      faceOnlyMaxScore: faceOnlyMaxScore ?? this.faceOnlyMaxScore,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
        'minLikelihood': minLikelihood,
        'coordinateSmoothingAlpha': coordinateSmoothingAlpha,
        'scoreSmoothingFactor': scoreSmoothingFactor,
        'matchThreshold': matchThreshold,
        'cancelThreshold': cancelThreshold,
        'requiredMatchFrames': requiredMatchFrames,
        'toleranceAngleDeg': toleranceAngleDeg,
        'mildDiffFactor': mildDiffFactor,
        'steepDiffFactor': steepDiffFactor,
        'minUpperBodyJoints': minUpperBodyJoints,
        'faceOnlyMaxScore': faceOnlyMaxScore,
        'countdownSeconds': countdownSeconds,
      };

  factory PoseMatchingConfig.fromJson(Map<String, dynamic> json) {
    return PoseMatchingConfig(
      minLikelihood: (json['minLikelihood'] as num?)?.toDouble() ?? 0.50,
      coordinateSmoothingAlpha:
          (json['coordinateSmoothingAlpha'] as num?)?.toDouble() ?? 0.70,
      scoreSmoothingFactor:
          (json['scoreSmoothingFactor'] as num?)?.toDouble() ?? 0.60,
      matchThreshold: (json['matchThreshold'] as num?)?.toDouble() ?? 85.0,
      cancelThreshold: (json['cancelThreshold'] as num?)?.toDouble() ?? 70.0,
      requiredMatchFrames: (json['requiredMatchFrames'] as num?)?.toInt() ?? 8,
      toleranceAngleDeg:
          (json['toleranceAngleDeg'] as num?)?.toDouble() ?? 15.0,
      mildDiffFactor: (json['mildDiffFactor'] as num?)?.toDouble() ?? 0.30,
      steepDiffFactor: (json['steepDiffFactor'] as num?)?.toDouble() ?? 0.85,
      minUpperBodyJoints: (json['minUpperBodyJoints'] as num?)?.toInt() ?? 2,
      faceOnlyMaxScore: (json['faceOnlyMaxScore'] as num?)?.toDouble() ?? 35.0,
      countdownSeconds: (json['countdownSeconds'] as num?)?.toInt() ?? 1,
    );
  }
}

