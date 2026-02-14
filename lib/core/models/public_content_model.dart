class PublicContent {
  final int id;
  final String category;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  final String? imageUrl;
  final String? fileUrl;
  final bool isPublished;
  final DateTime createdAt;

  PublicContent({
    required this.id,
    required this.category,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
    this.imageUrl,
    this.fileUrl,
    required this.isPublished,
    required this.createdAt,
  });

  factory PublicContent.fromJson(Map<String, dynamic> json) {
    return PublicContent(
      id: json['id'],
      category: json['category'],
      titleAr: json['titleAr'],
      titleEn: json['titleEn'],
      bodyAr: json['bodyAr'],
      bodyEn: json['bodyEn'],
      imageUrl: json['imageUrl'],
      fileUrl: json['fileUrl'],
      isPublished: json['published'] ?? true, // match backend boolean field name if needed
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
