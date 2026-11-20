import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecretStore {
  static const String _kCnicKey = 'cnic';
  static const String _kSignNumberKey = 'sign_in_number';
  static const String _kDeviceKey = 'device_secret_key_b64url';
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(),
  );

  static Future<void> saveCnic(String cnic) =>
      _storage.write(key: _kCnicKey, value: cnic.trim());

  static Future<void> saveSignNumber(String signNumber) =>
      _storage.write(key: _kSignNumberKey, value: signNumber.trim());

  static Future<void> saveBoth(
      {required String cnic, required String signNumber}) async {
    await _storage.write(key: _kCnicKey, value: cnic.trim());
    await _storage.write(key: _kSignNumberKey, value: signNumber.trim());
  }

  static Future<String?> getCnic() => _storage.read(key: _kCnicKey);

  static Future<String?> getSignNumber() => _storage.read(key: _kSignNumberKey);

  static Future<Map<String, String>> dumpAll() => _storage.readAll();

  static Future<void> clearCnic() => _storage.delete(key: _kCnicKey);

  static Future<void> clearSignNumber() =>
      _storage.delete(key: _kSignNumberKey);

  static Future<void> clearAll() async {
    await _storage.delete(key: _kCnicKey);
    await _storage.delete(key: _kSignNumberKey);
  }

  static Future<bool> isProfileComplete() async {
    final cnic = await getCnic();
    final sign = await getSignNumber();
    return (cnic != null && cnic.isNotEmpty) &&
        (sign != null && sign.isNotEmpty);
  }

  static Future<String> ensureDeviceKey() async {
    final existing = await _storage.read(key: _kDeviceKey);
    if (existing != null && existing.isNotEmpty) {
      print('db key existing');
      return existing;
    }

    final algo = AesGcm.with256bits();
    final secretKey = await algo.newSecretKey(); // 256-bit key
    final keyBytes = await secretKey.extractBytes(); // Uint8List(32)

    final b64 = base64UrlEncode(keyBytes).replaceAll('=', '');

    await _storage.write(key: _kDeviceKey, value: b64);
    print('db key: $b64');
    return b64;
  }

  static Future<String?> getDeviceKeyBase64() async {
    return _storage.read(key: _kDeviceKey);
  }

  static Future<Uint8List?> getDeviceKeyBytes() async {
    final b64 = await _storage.read(key: _kDeviceKey);
    if (b64 == null || b64.isEmpty) return null;

    final padLen = (4 - (b64.length % 4)) % 4;
    final padded = b64 + ('=' * padLen);
    return Uint8List.fromList(base64Url.decode(padded));
  }

  static Future<bool> hasDeviceKey() async {
    final v = await _storage.read(key: _kDeviceKey);
    return v != null && v.isNotEmpty;
  }

  static Future<String> rotateDeviceKey() async {
    final algo = AesGcm.with256bits();
    final secretKey = await algo.newSecretKey();
    final keyBytes = await secretKey.extractBytes();
    final b64 = base64UrlEncode(keyBytes).replaceAll('=', '');
    await _storage.write(key: _kDeviceKey, value: b64);
    return b64;
  }
}
