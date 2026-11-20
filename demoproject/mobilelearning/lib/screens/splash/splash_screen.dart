import 'package:flutter/material.dart';
import 'package:mobile_onboarding/screens/splash/components/body.dart';

class SplashScreen extends StatelessWidget {
  static String routeName = "/splash";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SplashBody(),
    );
  }
}
