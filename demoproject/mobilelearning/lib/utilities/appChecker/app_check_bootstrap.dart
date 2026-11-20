// lib/security/app_check_bootstrap.dart
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_onboarding/utilities/api_services/tokenEnc/tokenClass.dart';

class AppCheckBootstrap {
  static Future<String> initAndCache({
    final androidProvider =
        kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
    final appleProvider =
        kReleaseMode ? AppleProvider.deviceCheck : AppleProvider.debug,
    bool forceRefresh = true,
  }) async {
    await Firebase.initializeApp();
    await FirebaseAppCheck.instance.activate(
      androidProvider: androidProvider,
      appleProvider: appleProvider,
    );
    final token = await FirebaseAppCheck.instance.getToken(forceRefresh);
    if (token == null || token.isEmpty) {
      throw StateError('Failed to obtain Firebase App Check token at startup.');
    }
    await TokenStorage.setAppCheckToken(token);
    print("App checker token: $token");
    return token;
  }
}
