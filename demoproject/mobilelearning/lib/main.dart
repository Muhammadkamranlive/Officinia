import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobile_onboarding/globlal_error_handler.dart';
import 'package:mobile_onboarding/routes.dart';
import 'package:mobile_onboarding/screens/splash/splash_screen.dart';
import 'package:mobile_onboarding/security/env_bootstrap.dart';
import 'package:mobile_onboarding/theme.dart';
import 'package:mobile_onboarding/theme_provider.dart';
import 'package:mobile_onboarding/screens/new_product_list/components/api_service/products_json.dart';
import 'package:mobile_onboarding/utilities/core_banking_data/providerClass.dart';
import 'package:mobile_onboarding/utilities/notification_handler/notification_handler.dart';
import 'package:mobile_onboarding/utilities/parameters/provider.dart';
import 'package:mobile_onboarding/utilities/securedData/secureDataHandler.dart';
import 'package:mobile_onboarding/utilities/securityCheckHandler/DeviceBlockedScreen.dart';
import 'package:mobile_onboarding/utilities/securityCheckHandler/securityCheckHandler.dart';
import 'package:mobile_onboarding/utilities/updateChecker/version_service.dart';
import 'package:provider/provider.dart';
import 'helper/PreferenceUtils.dart';
import 'utilities/connect360/user_info_provider.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      if (kIsWeb) {
        print("Running in a Browser (Flutter Web)");
        //return;
      } else {
        await Hive.initFlutter();
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        await VersionService.ensureVersionIsValid();
        // await secureScreen();
        await Firebase.initializeApp();
        await PreferenceUtils.init();
        if (await shouldBlockDevice()) {
          runApp(const DeviceBlockedScreen());
          return;
        }
        await UserSecretStore.ensureDeviceKey();
        await EnvBootstrap.init();
        print("Running on Mobile/Desktop");
      }

      final policyProvider = PolicyProvider();
      await policyProvider.fetchPolicies();
      if (kReleaseMode) {
        debugPrint = (String? message, {int? wrapWidth}) {};
      }

      // await AppCheckBootstrap.initAndCache();
      runApp(MyApp(policyProvider: policyProvider));
    },

    (Object error, StackTrace stack) {},

    //globally swallow print() in release
    zoneSpecification: kReleaseMode
        ? ZoneSpecification(print: (self, parent, zone, line) {})
        : null,
  );
}

class MyApp extends StatelessWidget {
  Future<void> initApp(BuildContext context) async {
    await Provider.of<PolicyProvider>(context, listen: false).fetchPolicies();
  }

  final PolicyProvider policyProvider;

  MyApp({Key? key, required this.policyProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Set your design size to match your original design specs.
      designSize: const Size(375, 812),
      minTextAdapt: true, // This ensures text scales properly as well.
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => ThemeProvider()),
            // ChangeNotifierProvider(create: (context) => BValueProvider()),
            ChangeNotifierProvider(create: (_) => ApiService()),
            ChangeNotifierProvider(create: (context) => ClientProvider()),
            ChangeNotifierProvider(create: (context) => ApiResponseProvider()),
            // ChangeNotifierProvider(
            //   create: (_) => ProductProvider()..fetchProductData(),
            // ),
            // ChangeNotifierProvider(
            //     create: (context) => ImageProviderNotifier()),
            // ChangeNotifierProvider(
            //   create: (_) => ProductProvider()..fetchProductData(),
            // ),
            ChangeNotifierProvider.value(value: policyProvider),
          ],
          child: NotificationHandler(
            child: MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              title: '',
              theme: theme(),
              initialRoute: SplashScreen.routeName,
              routes: routes,
            ),
          ),
        );
      },
    );
  }
}
