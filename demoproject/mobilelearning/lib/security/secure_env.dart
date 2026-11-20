// lib/security/secure_env.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/services.dart' show rootBundle;

class SecureDotEnv {
  static final Map<String, String> _env = {};
  static bool _loaded = false;

  static Future<void> load({
    String assetPath = 'assets/env/.env.enc',
    required Uint8List keyBytes,
    required Uint8List nonce,
  }) async {
    if (_loaded) return;
    final algo = AesGcm.with256bits(); // AES-256 key, 128-bit tag (default)
    final secretKey = SecretKey(keyBytes);

    final encB64 = await rootBundle.loadString(assetPath);
    final encAll = base64Decode(encB64);

    if (encAll.length < 16) {
      throw StateError('Invalid encrypted env payload.');
    }
    final cipherText = encAll.sublist(0, encAll.length - 16);
    final macBytes = encAll.sublist(encAll.length - 16);

    final clearBytes = await algo.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes)),
      secretKey: secretKey,
    );

    final envText = utf8.decode(clearBytes);
    _parse(envText);
    _loaded = true;
  }

  static String? get(String key) => _env[key];

  static void _parse(String text) {
    final lines = const LineSplitter().convert(text);
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final idx = line.indexOf('=');
      if (idx <= 0) continue;
      final k = line.substring(0, idx).trim();
      var v = line.substring(idx + 1).trim();
      // Strip wrapping quotes
      if ((v.startsWith('"') && v.endsWith('"')) ||
          (v.startsWith("'") && v.endsWith("'"))) {
        v = v.substring(1, v.length - 1);
      }
      _env[k] = v;
    }
  }
}
