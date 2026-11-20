
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Guard/AuthProvider/RoleSelectionProvider.dart';
import 'package:client/Recruiter/Notifications/NotificationScreen.dart';
import 'package:client/Server/Services/NavigationService.dart';
import 'package:client/Server/Services/NotificationService.dart';
import 'package:client/Server/Services/PendingNotificationService.dart';
import 'package:client/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'package:client/Guard/AuthProvider/LocaleProvider.dart';
import 'package:client/Guard/AuthProvider/ThemeProvider.dart';
import 'package:client/AppColors/AppTheme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ── iOS foreground banners ────────────────────────────────────
  await FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await NotificationService.init();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

  // ── App launched from TERMINATED state by tapping notification ─
  final RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    final route = initialMessage.data['route'];
    if (route != null) PendingNotificationService.setPending(route);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RoleSelectionProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ── Track last handled message ID to prevent any duplicate ────
  String? _lastHandledMessageId;

  @override
  void initState() {
    super.initState();

    // ── FOREGROUND ────────────────────────────────────────────────
    //
    // NotificationService.listenToUserNotifications() already shows
    // a local notification when a new Firestore doc is added — that
    // covers the "new notification created" path for ALL platforms.
    //
    // onMessage fires when FCM delivers directly to the app while
    // it is in the foreground. We ONLY use it for:
    //   • DATA-ONLY messages (no notification payload) — system
    //     never shows these automatically on either platform.
    //   • Navigation routing from those data-only messages.
    //
    // For messages that have a notification payload:
    //   • Android foreground: system does NOT auto-show → handled
    //     by listenToUserNotifications local notification.
    //   • iOS foreground: system DOES auto-show (alert:true above)
    //     → we must NOT call show() again or it duplicates.
    //
    // Result: zero duplicates on both platforms.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Guard: skip if already handled
      if (message.messageId != null &&
          message.messageId == _lastHandledMessageId) return;
      _lastHandledMessageId = message.messageId;

      final hasNotificationPayload = message.notification != null;

      if (!hasNotificationPayload && message.data.isNotEmpty) {
        // Data-only message — system shows nothing automatically.
        // Show a local notification manually on both platforms.
        final title = message.data['title'] ?? 'New Notification';
        final body  = message.data['body']  ?? 'You have a new notification';
        final route = message.data['route'] as String?;

        if (title.isNotEmpty) {
          NotificationService.show(
            title: title,
            body:  body,
            route: route,
          );
        }

        // Handle navigation if route present
        if (route != null) {
          PendingNotificationService.setPending(route);
          _tryConsumePending();
        }
      }
    });

    // ── BACKGROUND: user taps notification banner ─────────────────
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final route = message.data['route'];
      if (route != null) PendingNotificationService.setPending(route);
      _tryConsumePending();
    });
  }


void _tryConsumePending() {
  if (!PendingNotificationService.hasPending) return;

  PendingNotificationService.consumePending(); // clear immediately

  // Give navigator time to be ready after cold/warm start
  Future.delayed(const Duration(milliseconds: 800), () {
    NavigationService.navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const NotificationScreen()),
    );
  });
}
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider  = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'Ophicina',
      locale: localeProvider.locale,
      themeMode: themeProvider.themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
      ],
      theme: AppTheme.lightTheme(localeProvider.locale),
      darkTheme: AppTheme.darkTheme(localeProvider.locale),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,

      onGenerateRoute: (settings) {
        final name = settings.name ?? '';
        // Swallow payment deep links — handled by RecruiterPaymentScreen
        if (name.startsWith('pharmajobs://')) return null;
        return null;
      },

      onUnknownRoute: (settings) {
        // Transparent no-op page for payment deep link segments
        // so Flutter doesn't crash trying to navigate
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SizedBox.shrink(),
        );
      },
    );
  }
}