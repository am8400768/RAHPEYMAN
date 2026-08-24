import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rahpeyman/core/config/app_config.dart';
import 'package:rahpeyman/core/services/api_service.dart';
import 'package:rahpeyman/core/services/device_attestation_service.dart';

class AuthService {
  AuthService._();

  static const _storage = FlutterSecureStorage();
  static const _installationIdKey = 'rahpeyman_installation_id';

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(
      key: AppConfig.authTokenStorageKey,
    );
    return token != null && token.isNotEmpty;
  }

  static Future<void> requestOtp(String phone) async {
    final normalizedPhone = _normalizePhone(phone);
    await ApiService.post(
      'auth/request-otp',
      {'phone': normalizedPhone},
    );
  }

  static Future<void> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final installationId = await _getOrCreateInstallationId();
    final normalizedPhone = _normalizePhone(phone);
    final rawSystemDeviceId = await DeviceAttestationService.getSystemDeviceId();
    final systemDeviceId = rawSystemDeviceId.startsWith('unavailable-')
        ? null
        : rawSystemDeviceId;

    final payload = <String, dynamic>{
      'phone': normalizedPhone,
      'otp': otp,
      'device_id': installationId,
      'platform': 'mobile',
      if (systemDeviceId != null) 'system_device_id': systemDeviceId,
    };

    if (systemDeviceId != null) {
      final proof =
          await DeviceAttestationService.collectConfiguredAndroidProof(
        googleCloudProjectNumber: AppConfig.googleCloudProjectNumber,
        phone: normalizedPhone,
        installationId: installationId,
        systemDeviceId: systemDeviceId,
      );
      if (proof != null) {
        payload.addAll(proof.toJson());
      }
    }

    final response = await ApiService.post(
      'auth/verify-otp',
      payload,
    );

    final token = response['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw const ApiException(
        statusCode: 500,
        message: 'ورود انجام نشد',
      );
    }
    await _storage.write(
      key: AppConfig.authTokenStorageKey,
      value: token,
    );
  }

  static Future<void> logout() async {
    await _storage.delete(key: AppConfig.authTokenStorageKey);
  }

  static Future<String> _getOrCreateInstallationId() async {
    final existing = await _storage.read(key: _installationIdKey);
    if (existing != null && existing.length >= 32) {
      return existing;
    }

    const alphabet =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    final id = List.generate(
      48,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
    await _storage.write(key: _installationIdKey, value: id);
    return id;
  }

  static String _normalizePhone(String phone) {
    var value = phone.trim().replaceAll(RegExp(r'[\s\-()]'), '');
    if (value.startsWith('+98')) {
      value = '0${value.substring(3)}';
    } else if (value.startsWith('0098')) {
      value = '0${value.substring(4)}';
    }
    return value;
  }
}
