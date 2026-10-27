class UserModel {
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String role; // REGULAR_USER or STYLIST
  final double? rating;
  final int? reviewCount;

  UserModel({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    this.rating,
    this.reviewCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
    );
  }
}

class GeminiAiDraftModel {
  final String enhancedBrief;
  final List<Map<String, String>> colorPalette;
  final List<String> recommendedVibes;
  final List<String> suggestedPoses;

  GeminiAiDraftModel({
    required this.enhancedBrief,
    required this.colorPalette,
    required this.recommendedVibes,
    required this.suggestedPoses,
  });

  factory GeminiAiDraftModel.fromJson(Map<String, dynamic> json) {
    final rawColors = json['colorPalette'] as List<dynamic>? ?? [];
    final colors = rawColors.map((c) => Map<String, String>.from(c as Map)).toList();

    return GeminiAiDraftModel(
      enhancedBrief: json['enhancedBrief'] as String? ?? '',
      colorPalette: colors,
      recommendedVibes: (json['recommendedVibes'] as List<dynamic>? ?? []).cast<String>(),
      suggestedPoses: (json['suggestedPoses'] as List<dynamic>? ?? []).cast<String>(),
    );
  }
}

class StylingRequestModel {
  final String requestId;
  final UserModel client;
  final UserModel? stylist;
  final String conceptDescription;
  final String occasion;
  final String vibe;
  final String bodyType;
  final int budgetVnd;
  final double platformFeeRate;
  final int stylistNetEarningsVnd;
  final String status;
  final String escrowStatus;
  final int escrowPercentageFunded;
  final GeminiAiDraftModel? geminiAiDraft;

  StylingRequestModel({
    required this.requestId,
    required this.client,
    this.stylist,
    required this.conceptDescription,
    required this.occasion,
    required this.vibe,
    required this.bodyType,
    required this.budgetVnd,
    required this.platformFeeRate,
    required this.stylistNetEarningsVnd,
    required this.status,
    required this.escrowStatus,
    required this.escrowPercentageFunded,
    this.geminiAiDraft,
  });

  factory StylingRequestModel.fromJson(Map<String, dynamic> json) {
    return StylingRequestModel(
      requestId: json['requestId'] as String,
      client: UserModel.fromJson(json['client'] as Map<String, dynamic>),
      stylist: json['stylist'] != null
          ? UserModel.fromJson(json['stylist'] as Map<String, dynamic>)
          : null,
      conceptDescription: json['conceptDescription'] as String,
      occasion: json['occasion'] as String? ?? '',
      vibe: json['vibe'] as String? ?? '',
      bodyType: json['bodyType'] as String? ?? '',
      budgetVnd: (json['budgetVnd'] as num).toInt(),
      platformFeeRate: (json['platformFeeRate'] as num?)?.toDouble() ?? 0.15,
      stylistNetEarningsVnd: (json['stylistNetEarningsVnd'] as num?)?.toInt() ?? 0,
      status: json['status'] as String,
      escrowStatus: json['escrowStatus'] as String,
      escrowPercentageFunded: json['escrowPercentageFunded'] as int? ?? 100,
      geminiAiDraft: json['geminiAiDraft'] != null
          ? GeminiAiDraftModel.fromJson(json['geminiAiDraft'] as Map<String, dynamic>)
          : null,
    );
  }
}
