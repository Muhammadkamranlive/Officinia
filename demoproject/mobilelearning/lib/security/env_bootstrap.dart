import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'secure_env.dart';

class EnvBootstrap {
  static const List<int> _devKey32 = <int>[
    21,
    134,
    9,
    77,
    190,
    13,
    44,
    199,
    18,
    251,
    60,
    9,
    99,
    140,
    200,
    11,
    91,
    42,
    210,
    79,
    201,
    33,
    87,
    166,
    18,
    44,
    199,
    89,
    10,
    210,
    33,
    77,
  ];

  static const List<int> _devNonce12 = <int>[
    11,
    22,
    33,
    44,
    55,
    66,
    77,
    88,
    99,
    10,
    20,
    30,
  ];

  static const _kKey = 'env_key_b64';
  static const _kNonce = 'env_nonce_b64';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(),
  );

  static Future<void> init() async {
    await _ensureKeyMaterialSeeded();
    final (key, nonce) = await _readKeyMaterial();
    if (key == null || nonce == null) {
      throw StateError('ENV key/nonce missing in secure storage.');
    }
    await SecureDotEnv.load(keyBytes: key, nonce: nonce);
  }

  static Future<void> _ensureKeyMaterialSeeded() async {
    final exists = await _exists();
    if (exists) return;

    if (_devKey32.length != 32) {
      throw ArgumentError('DEV key must be 32 bytes for AES-256.');
    }
    if (_devNonce12.length != 12) {
      throw ArgumentError('DEV nonce must be 12 bytes for AES-GCM.');
    }

    final keyBytes = Uint8List.fromList(_devKey32);
    final nonceBytes = Uint8List.fromList(_devNonce12);

    await _storage.write(key: _kKey, value: base64Encode(keyBytes));
    await _storage.write(key: _kNonce, value: base64Encode(nonceBytes));
  }

  static Future<(Uint8List?, Uint8List?)> _readKeyMaterial() async {
    final keyB64 = await _storage.read(key: _kKey);
    final nonceB64 = await _storage.read(key: _kNonce);
    final key =
        (keyB64 == null) ? null : Uint8List.fromList(base64Decode(keyB64));
    final nonce =
        (nonceB64 == null) ? null : Uint8List.fromList(base64Decode(nonceB64));
    return (key, nonce);
  }

  static Future<bool> _exists() async {
    final (k, n) = await _readKeyMaterial();
    return k != null && n != null;
  }

  static Future<void> clear() async {
    await _storage.delete(key: _kKey);
    await _storage.delete(key: _kNonce);
  }
}
