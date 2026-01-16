class BusinessLogo {
  final String id;
  final String fileUrl;
  final String fileName;
  final String businessPromotionId;
  final DateTime? uploadedAt;

  BusinessLogo({
    required this.id,
    required this.fileUrl,
    required this.fileName,
    required this.businessPromotionId,
    this.uploadedAt,
  });

  factory BusinessLogo.fromJson(Map<String, dynamic> json) {
    return BusinessLogo(
      id: json['id'] ?? json['_id'] ?? '',
      fileUrl: json['fileUrl'] ?? json['logo_url'] ?? '',
      fileName: json['fileName'] ?? json['file_name'] ?? '',
      businessPromotionId: json['businessPromotionId'] ?? json['business_promotion_id'] ?? '',
      uploadedAt: json['uploadedAt'] != null ? DateTime.tryParse(json['uploadedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'businessPromotionId': businessPromotionId,
      'uploadedAt': uploadedAt?.toIso8601String(),
    };
  }
}

