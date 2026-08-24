import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rahpeyman/core/config/app_config.dart';
import 'package:rahpeyman/features/courses/models/course_models.dart';

class CourseApi {
  CourseApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _storage = FlutterSecureStorage();

  Future<Map<String, String>> _headers() async {
    final token = await _storage.read(
      key: AppConfig.authTokenStorageKey,
    );
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<CourseSummary>> getCourses() async {
    final response = await _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}/courses/'),
      headers: await _headers(),
    );
    _checkResponse(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => CourseSummary.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<CourseVideo>> getVideos(int courseId) async {
    final response = await _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}/courses/$courseId/videos'),
      headers: await _headers(),
    );
    _checkResponse(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => CourseVideo.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<String> getVideoStream(int videoId) async {
    final response = await _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}/courses/videos/$videoId/stream'),
      headers: await _headers(),
    );
    _checkResponse(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final streamUrl = data['stream_url'] as String?;
    if (streamUrl == null || streamUrl.isEmpty) {
      throw Exception('لینک پخش ویدئو در دسترس نیست.');
    }
    return streamUrl;
  }

  Future<String> createSubscriptionPayment() async {
    final response = await _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}/payments/subscription'),
      headers: {
        ...await _headers(),
        'Content-Type': 'application/json',
      },
    );
    _checkResponse(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final url = data['payment_url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception(
        data['message'] as String? ?? 'ایجاد پرداخت ناموفق بود',
      );
    }
    return url;
  }

  void dispose() => _client.close();

  void _checkResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        response.statusCode == 401
            ? 'برای مشاهده دوره‌ها ابتدا وارد حساب کاربری شوید'
            : 'دریافت اطلاعات دوره‌ها ناموفق بود',
      );
    }
  }
}
