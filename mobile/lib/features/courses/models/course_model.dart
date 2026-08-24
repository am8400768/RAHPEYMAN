// mobile/lib/features/courses/models/course_model.dart
class Course {
  final int id;
  final String title;
  final String description;
  final int price;
  final String? coverImageUrl;
  
  Course({required this.id, required this.title, required this.description, required this.price, this.coverImageUrl});
  
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      coverImageUrl: json['cover_image_url'],
    );
  }
}
