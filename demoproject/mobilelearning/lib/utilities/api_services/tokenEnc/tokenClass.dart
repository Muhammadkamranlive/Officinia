import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _kAccessToken = 'access_token';
  static const _kExpiryMs = 'access_token_expiry';
  static const String _kAppCheckTokenKey = 'app_check_token';
  static final FlutterSecureStorage _sec = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// Cache [token] for the given [ttl].
  static Future<void> cache(String token, Duration ttl) async {
    final expiry = DateTime.now().add(ttl).millisecondsSinceEpoch.toString();
    await _sec.write(key: _kAccessToken, value: token);
    await _sec.write(key: _kExpiryMs, value: expiry);
  }

  /// returns null.
  static Future<String?> getValid() async {
    final token = await _sec.read(key: _kAccessToken);
    if (token == null) return null;

    final expiryStr = await _sec.read(key: _kExpiryMs);
    final expiryMs = int.tryParse(expiryStr ?? '') ?? 0;
    if (DateTime.now().millisecondsSinceEpoch >= expiryMs) {
      await clear();
      return null;
    }
    return token;
  }

  static Future<void> clear() async {
    await _sec.delete(key: _kAccessToken);
    await _sec.delete(key: _kExpiryMs);
  }

  static Future<void> setAppCheckToken(String token) async {
    await _sec.write(key: _kAppCheckTokenKey, value: token);
  }

  /// GET: return the cached token (or null if not present)
  static Future<String?> getAppCheckToken() async {
    return _sec.read(key: _kAppCheckTokenKey);
  }
}
