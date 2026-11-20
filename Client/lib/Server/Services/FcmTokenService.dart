// // lib/Server/Services/FcmTokenService.dart
// import 'dart:io';
// import 'package:client/Server/Repo/UserTokenRepository.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';

// class FcmTokenService {
//   static final _repo = UserTokenRepository();

//   static Future<void> init(String userId) async {
//     final messaging = FirebaseMessaging.instance;

//     // 🔐 Permission (iOS)
//     await messaging.requestPermission();

//     // 🔐 Proper permission handling
//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//       provisional: false,
//     );

//     if (settings.authorizationStatus != AuthorizationStatus.authorized) {
//       return;
//     }



//     final token = await messaging.getToken();
//     if (token == null) return;

//     await _repo.saveToken(
//       userId: userId,
//       token: token,
//       platform: kIsWeb ? 'web' : (Platform.isAndroid ? 'android' : 'ios'),
//     );

//     // 🔁 Token refresh listener
//     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
//       await _repo.saveToken(
//         userId: userId,
//         token: newToken,
//         platform:  kIsWeb ? 'web' : (Platform.isAndroid ? 'android' : 'ios'),
//       );
//     });
//   }
// }


import 'dart:io';
import 'package:client/Server/Repo/UserTokenRepository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmTokenService {
  static final _repo = UserTokenRepository();

  static Future<void> init(String userId) async {
    final messaging = FirebaseMessaging.instance;

    // ── Request permission once (removed the duplicate call) ─────
    final settings = await messaging.requestPermission(
      alert:       true,
      badge:       true,
      sound:       true,
      provisional: false,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      // User denied — cannot receive notifications
      return;
    }

    // ── iOS: wait for APNS token before getting FCM token ────────
    // This is the main reason iOS silently fails after restart.
    // APNS registration is async and FCM needs it to be ready first.
    if (!kIsWeb && Platform.isIOS) {
      String? apnsToken;
      int retries = 0;

      // Retry up to 5 times with 1s gap — APNS can be slow on cold start
      while (apnsToken == null && retries < 5) {
        apnsToken = await messaging.getAPNSToken();
        if (apnsToken == null) {
          await Future.delayed(const Duration(seconds: 1));
          retries++;
        }
      }

      if (apnsToken == null) {
        // APNS token never arrived — skip for now, onTokenRefresh will retry
        return;
      }
    }

    // ── Get FCM token ─────────────────────────────────────────────
    final token = await messaging.getToken();
    if (token == null) return;

    await _repo.saveToken(
      userId:   userId,
      token:    token,
      platform: kIsWeb ? 'web' : (Platform.isAndroid ? 'android' : 'ios'),
    );

    // ── Token refresh — device can rotate FCM tokens at any time ──
    // Re-register the listener each call is safe because we only
    // store the latest token in Firestore anyway.
    messaging.onTokenRefresh.listen((newToken) async {
      await _repo.saveToken(
        userId:   userId,
        token:    newToken,
        platform: kIsWeb ? 'web' : (Platform.isAndroid ? 'android' : 'ios'),
      );
    });
  }
}