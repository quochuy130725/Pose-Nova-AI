/// Business logic constants for PoseNova AI
abstract class AppConstants {
  static const String appName = 'PoseNova AI';
  static const String appTagline = 'Managed C2C Fashion Styling & AI Pose Platform';

  // Escrow & Milestone Rules
  static const int stage1PayoutPercent = 30; // Moodboard & Concept
  static const int stage2PayoutPercent = 30; // Outfit Selection & Tags
  static const int stage3PayoutPercent = 40; // Final Lookbook & Pose
  static const int maxFreeRevisions = 2;
  static const double platformCommissionFeeRate = 0.15; // 15% platform fee

  // AI Pose Detection Constants
  static const int poseKeypointsCount = 33; // Google ML Kit 33 landmarks
  static const double poseMatchThresholdPercent = 85.0; // >= 85% initiates auto-shutter
  static const int autoShutterCountdownSeconds = 3;

  // Grid Configuration
  static const double gridSpacing = 20.0;
}
