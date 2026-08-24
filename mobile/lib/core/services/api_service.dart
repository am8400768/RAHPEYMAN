// mobile/lib/core/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class ApiService {
  static final _storage = const FlutterSecureStorage();
  
  static Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: AppConfig.storageKey);
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }
  
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }
  
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/$endpoint'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }
}