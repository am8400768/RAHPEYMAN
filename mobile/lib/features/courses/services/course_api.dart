// mobile/lib/features/courses/services/course_api.dart
import '../../../core/services/api_service.dart';
import '../models/course_model.dart';

class CourseApi {
  static Future<List<Course>> getCourses() async {
    final response = await ApiService.get('courses');
    return (response as List).map((e) => Course.fromJson(e)).toList();
  }
}