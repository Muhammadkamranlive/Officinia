// lib/security/env_key_store.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EnvKeyStore {
  static const _kKey = 'env_key_b64';
  static const _kNonce = 'env_nonce_b64';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(),
  );

  static Future<void> save({
    required Uint8List keyBytes,
    required Uint8List nonceBytes,
  }) async {
    if (keyBytes.length != 32) {
      throw ArgumentError('AES-256 key must be 32 bytes.');
    }
    if (nonceBytes.length != 12) {
      throw ArgumentError('GCM nonce must be 12 bytes.');
    }
    await _storage.write(key: _kKey, value: base64Encode(keyBytes));
    await _storage.write(key: _kNonce, value: base64Encode(nonceBytes));
  }

  /// Read both, or nulls if not set.
  static Future<(Uint8List?, Uint8List?)> read() async {
    final keyB64 = await _storage.read(key: _kKey);
    final nonceB64 = await _storage.read(key: _kNonce);
    final key =
        (keyB64 == null) ? null : Uint8List.fromList(base64Decode(keyB64));
    final nonce =
        (nonceB64 == null) ? null : Uint8List.fromList(base64Decode(nonceB64));
    return (key, nonce);
  }

  static Future<bool> exists() async {
    final (k, n) = await read();
    return k != null && n != null;
  }

  /// For rotation / revoke
  static Future<void> clear() async {
    await _storage.delete(key: _kKey);
    await _storage.delete(key: _kNonce);
  }
}
