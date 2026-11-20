import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/font_styles_roboto.dart';

class HeadingSection extends StatelessWidget {
  const HeadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Get Your \n Noor Card Instantly",
          style: AppTextStyles.robotoBold24,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Enter your mobile number and email address, \nYou will get a verification code",
          style: AppTextStyles.robotoRegular13,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
