import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

class DeviceAttestationProof {
  const DeviceAttestationProof({
    required this.provider,
    required this.systemDeviceId,
    this.token,
    this.keyId,
  });

  final String provider;
  final String systemDeviceId;
  final String? token;
  final String? keyId;

  Map<String, dynamic> toJson() => {
        'attestation_provider': provider,
        'system_device_id': systemDeviceId,
        if (token != null) 'attestation_token': token,
        if (keyId != null) 'attestation_key_id': keyId,
      };
}

class DeviceAttestationService {
  DeviceAttestationService._();

  static const _channel = MethodChannel('rahpeyman/device_attestation');

  static Future<String> getSystemDeviceId() async {
    try {
      return await _channel.invokeMethod<String>('getDeviceId') ??
          'unavailable-${Platform.operatingSystem}';
    } on PlatformException {
      return 'unavailable-${Platform.operatingSystem}';
    } on MissingPluginException {
      return 'unavailable-${Platform.operatingSystem}';
    }
  }

  static Future<DeviceAttestationProof?> collectConfiguredAndroidProof({
    required String googleCloudProjectNumber,
    required String phone,
    required String installationId,
    required String systemDeviceId,
  }) async {
    if (!Platform.isAndroid || googleCloudProjectNumber.trim().isEmpty) {
      return null;
    }

    final requestData = '$phone|$installationId|$systemDeviceId';
    try {
      return await collectAndroidProof(
        googleCloudProjectNumber: googleCloudProjectNumber,
        requestData: requestData,
      );
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  static Future<DeviceAttestationProof> collectAndroidProof({
    required String googleCloudProjectNumber,
    required String requestData,
  }) async {
    final deviceId = await getSystemDeviceId();
    await _channel.invokeMethod<bool>(
      'prepareIntegrity',
      {'projectNumber': googleCloudProjectNumber},
    );

    final requestHash =
        sha256.convert(utf8.encode(requestData)).toString();
    final token = await _channel.invokeMethod<String>(
      'getIntegrityToken',
      {'requestHash': requestHash},
    );

    return DeviceAttestationProof(
      provider: 'play_integrity',
      systemDeviceId: deviceId,
      token: token,
    );
  }

  static Future<bool> isAppAttestSupported() async {
    if (!Platform.isIOS) return false;
    return await _channel.invokeMethod<bool>('isAppAttestSupported') ?? false;
  }

  static Future<String> generateAppAttestKey() async {
    return await _channel.invokeMethod<String>('generateAppAttestKey') ?? '';
  }

  static Future<Map<String, String>> attestAppKey(String challengeBase64) async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'attestAppKey',
      {'challenge': challengeBase64},
    );
    return (result ?? {}).map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
  }

  static Future<DeviceAttestationProof> collectIosProof({
    required String attestationToken,
    required String keyId,
  }) async {
    return DeviceAttestationProof(
      provider: 'app_attest',
      systemDeviceId: await getSystemDeviceId(),
      token: attestationToken,
      keyId: keyId,
    );
  }
}
