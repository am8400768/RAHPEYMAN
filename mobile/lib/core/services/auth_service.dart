// mobile/lib/core/services/auth_service.dart
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import '../config/app_config.dart';

class AuthService {
  static final _storage = const FlutterSecureStorage();
  static const _deviceIdKey = 'rahpeyman_installation_id';
  
  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: AppConfig.storageKey);
    return token != null;
  }
  
  static Future<Map<String, dynamic>> requestOtp(String phone) async {
    return await ApiService.post('auth/request-otp', {'phone': phone});
  }
  
  static Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final deviceId = await _getOrCreateDeviceId();
    final response = await ApiService.post(
      'auth/verify-otp',
      {'phone': phone, 'otp': otp, 'device_id': deviceId},
    );
    if (response['access_token'] != null) {
      await _storage.write(key: AppConfig.storageKey, value: response['access_token']);
    }
    return response;
  }
  
  static Future<void> logout() async {
    await _storage.delete(key: AppConfig.storageKey);
  }

  static Future<String> _getOrCreateDeviceId() async {
    final existing = await _storage.read(key: _deviceIdKey);
    if (existing != null && existing.length >= 32) {
      return existing;
    }

    const alphabet =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    final value = List.generate(
      48,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
    await _storage.write(key: _deviceIdKey, value: value);
    return value;
  }
}
