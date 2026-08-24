import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rahpeyman/core/config/app_config.dart';

class ApiService {
  ApiService._();

  static const _storage = FlutterSecureStorage();

  static Future<Map<String, String>> _headers() async {
    final token = await _storage.read(
      key: AppConfig.authTokenStorageKey,
    );
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/$endpoint'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return _decode(response);
  }

  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/$endpoint'),
      headers: await _headers(),
    );
    return _decode(response);
  }

  static dynamic _decode(http.Response response) {
    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = data is Map<String, dynamic>
          ? (data['detail'] ?? data['message'])
          : null;
      throw ApiException(
        statusCode: response.statusCode,
        message: message?.toString() ?? 'ارتباط با سرور ناموفق بود',
      );
    }

    if (data is Map<String, dynamic>) {
      return data;
    }
    return data;
  }
}

class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
  });

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}
