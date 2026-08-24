class CourseSummary {
  const CourseSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.hasAccess,
    this.coverImageUrl,
  });

  final int id;
  final String title;
  final String? description;
  final int price;
  final bool hasAccess;
  final String? coverImageUrl;

  factory CourseSummary.fromJson(Map<String, dynamic> json) {
    return CourseSummary(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toInt() ?? 0,
      hasAccess: json['has_access'] as bool? ?? false,
      coverImageUrl: json['cover_image_url'] as String?,
    );
  }
}

class CourseVideo {
  const CourseVideo({
    required this.id,
    required this.title,
    required this.isPreview,
    required this.locked,
    this.description,
    this.durationSeconds,
  });

  final int id;
  final String title;
  final String? description;
  final int? durationSeconds;
  final bool isPreview;
  final bool locked;

  factory CourseVideo.fromJson(Map<String, dynamic> json) {
    return CourseVideo(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      isPreview: json['is_preview'] as bool? ?? false,
      locked: json['locked'] as bool? ?? false,
    );
  }
}
