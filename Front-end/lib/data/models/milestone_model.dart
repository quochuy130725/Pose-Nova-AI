class ProductTagModel {
  final String tagId;
  final String productName;
  final int priceVnd;
  final String affiliateUrl;
  final double coordinateX;
  final double coordinateY;

  ProductTagModel({
    required this.tagId,
    required this.productName,
    required this.priceVnd,
    required this.affiliateUrl,
    required this.coordinateX,
    required this.coordinateY,
  });

  factory ProductTagModel.fromJson(Map<String, dynamic> json) {
    return ProductTagModel(
      tagId: json['tagId'] as String,
      productName: json['productName'] as String,
      priceVnd: (json['priceVnd'] as num).toInt(),
      affiliateUrl: json['affiliateUrl'] as String,
      coordinateX: (json['coordinateX'] as num).toDouble(),
      coordinateY: (json['coordinateY'] as num).toDouble(),
    );
  }
}

class MilestoneModel {
  final String milestoneId;
  final String requestId;
  final int stageOrder;
  final String stageName;
  final int payoutPercent;
  final int payoutAmountVnd;
  final String status; // LOCKED, IN_PROGRESS, SUBMITTED, APPROVED
  final String description;
  final String? deliverableTitle;
  final String? deliverableImageUrl;
  final bool isWatermarked;
  final int revisionCount;
  final int maxRevisions;
  final String? lastFeedback;
  final List<ProductTagModel> productTags;
  final String? poseTemplateId;
  final int? landmarksCount;

  MilestoneModel({
    required this.milestoneId,
    required this.requestId,
    required this.stageOrder,
    required this.stageName,
    required this.payoutPercent,
    required this.payoutAmountVnd,
    required this.status,
    required this.description,
    this.deliverableTitle,
    this.deliverableImageUrl,
    this.isWatermarked = false,
    this.revisionCount = 0,
    this.maxRevisions = 2,
    this.lastFeedback,
    this.productTags = const [],
    this.poseTemplateId,
    this.landmarksCount,
  });

  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    final rawTags = json['productTags'] as List<dynamic>?;
    return MilestoneModel(
      milestoneId: json['milestoneId'] as String,
      requestId: json['requestId'] as String,
      stageOrder: json['stageOrder'] as int,
      stageName: json['stageName'] as String,
      payoutPercent: json['payoutPercent'] as int,
      payoutAmountVnd: (json['payoutAmountVnd'] as num).toInt(),
      status: json['status'] as String,
      description: json['description'] as String,
      deliverableTitle: json['deliverableTitle'] as String?,
      deliverableImageUrl: json['deliverableImageUrl'] as String?,
      isWatermarked: json['isWatermarked'] as bool? ?? false,
      revisionCount: json['revisionCount'] as int? ?? 0,
      maxRevisions: json['maxRevisions'] as int? ?? 2,
      lastFeedback: json['lastFeedback'] as String?,
      productTags: rawTags != null
          ? rawTags.map((e) => ProductTagModel.fromJson(e as Map<String, dynamic>)).toList()
          : [],
      poseTemplateId: json['poseTemplateId'] as String?,
      landmarksCount: json['landmarksCount'] as int?,
    );
  }
}
