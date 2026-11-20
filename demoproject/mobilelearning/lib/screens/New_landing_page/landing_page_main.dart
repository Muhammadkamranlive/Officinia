import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/screens/New_landing_page/components/landing_page_body.dart';

class LandingPageMain extends StatelessWidget {
  const LandingPageMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // You can leave backgroundColor as fallback if needed.
      backgroundColor: ScaffoldBackground,
      body: SafeArea(
        child: Stack(
          // fit: StackFit.expand,
          children: [
            // Background GIF covering the entire screen.
            Positioned.fill(
              child: Image.asset(
                'assets/gif/LandingPage.gif',  // Ensure this path is correct.
                fit: BoxFit.fill, 
              ),
            ),
            // Overlay your landing page body.
            const LandingPageBody(),
          ],
        ),
      ),
    );
  }
}
