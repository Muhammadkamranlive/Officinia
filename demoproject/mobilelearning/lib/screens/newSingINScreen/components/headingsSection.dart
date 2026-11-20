import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/font_styles_roboto.dart';

class HeadingSection extends StatelessWidget {
  const HeadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Existing User Log-in",
          style: AppTextStyles.robotoBold24,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15.h),
        Text(
          "Enter your mobile number\n you will get a verification code via SMS",
          style: AppTextStyles.robotoRegular13,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15.h),
      ],
    );
  }
}
