import 'dart:io';
import 'package:client/Server/Model/NotificationModel.dart';
import 'package:client/Server/Repo/Notifications/NotificationsRepository.dart';
import 'package:client/Server/Services/NavigationService.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static final NotificationRepository _repo = NotificationRepository();

  static const String _channelId = 'high_importance_channel';

  // ✅ Incrementing counter instead of hashCode (prevents duplicate IDs)
  static int _notificationIdCounter = 0;

  // ✅ Track if listener already started (prevents duplicate listeners)
  static bool _isListening = false;

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // ✅ v20: Added defaultPresentBanner and defaultPresentList
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          defaultPresentAlert: true,
          defaultPresentBadge: true,
          defaultPresentSound: true,
          defaultPresentBanner: true, // ✅ v20 required for foreground banners
          defaultPresentList: true, // ✅ v20 required for notification center
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _local.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final route = response.payload;
        if (route != null && route.isNotEmpty) {
          _navigateToRoute(route);
        }
      },
    );
    if (kIsWeb) return;
    // ✅ iOS permissions
    if (!kIsWeb && Platform.isIOS) {
      await _local
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    // ✅ Android channel
    if (!kIsWeb && Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        'High Importance Notifications',
        description: 'Used for important notifications',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  static void _navigateToRoute(String route) {
    if (NavigationService.navigatorKey.currentState == null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _navigateToRoute(route);
      });
      return;
    }
    NavigationService.navigatorKey.currentState!.pushNamed(route);
  }

  static Future<void> show({
    required String title,
    required String body,
    String? uniqueKey,
    String? route,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            _channelId,
            'High Importance Notifications',
            channelDescription: 'App notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
          );

      // ✅ v20: Added presentBanner and presentList
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true, // ✅ v20 - shows banner when app is foreground
        presentList: true, // ✅ v20 - shows in notification center
        sound: 'default',
        badgeNumber: 1,
        interruptionLevel: InterruptionLevel.active,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // ✅ Incrementing counter for unique IDs
      final int notificationId = _notificationIdCounter++;

      await _local.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: details,
        payload: route,
      );
    } catch (e, stackTrace) {}
  }

  static void listenToUserNotifications(String userId) {
    // ✅ Prevent duplicate listeners
    if (_isListening) {
      return;
    }
    _isListening = true;

    // ✅ Only listen to notifications created AFTER app launch
    final Timestamp startTime = Timestamp.now();

    FirebaseFirestore.instance
        .collection('Notifications')
        .where('userId', isEqualTo: userId)
        .where('createdAt', isGreaterThan: startTime) // ✅ Ignore old docs
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            for (var change in snapshot.docChanges) {
              if (change.type != DocumentChangeType.added) continue;

              final data = change.doc.data();
              if (data == null || data['createdAt'] == null) continue;

              final notification = NotificationModel.fromMap(
                data as Map<String, dynamic>,
                change.doc.id,
              );

              show(
                title: notification.title,
                body: notification.description,
                uniqueKey: change.doc.id,
                route: notification.route,
              );
            }
          },
          onError: (error) {
            _isListening = false; // ✅ Allow retry on error
          },
        );
  }

  static Future<void> sendToUser({
    required String targetUserId,
    required String type,
    required String title,
    required String description,
    String? targetId,
    String? targetType,
    String? route,
    Map<String, dynamic>? payload,
  }) async {
    final notification = NotificationModel(
      userId: targetUserId,
      type: type,
      title: title,
      description: description,
      createdAt: DateTime.now(),
      targetId: targetId,
      targetType: targetType,
      route: route,
      payload: payload,
    );

    await _repo.add(notification);
  }

  // In NotificationService.dart — add this method:
static void reset() {
  _isListening = false;
}
}
