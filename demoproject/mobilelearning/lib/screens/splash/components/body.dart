import 'package:animated_splash_screen/animated_splash_screen.dart';

import 'package:flutter/material.dart';

import 'package:mobile_onboarding/screens/New_landing_page/landing_page_main.dart';


class SplashBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      nextScreen: LandingPageMain(),
      splash: 'assets/images/faisal_bank_banner.png',
      splashTransition: SplashTransition.scaleTransition,
    );
  }
}
