import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/font_styles_roboto.dart';

class BottomActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const BottomActionButton(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: newSecondaryColor),
          width: MediaQuery.of(context).size.width * 0.9,
          height: 50.h,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: newSecondaryColor),
            child: Text(
              text,
              style: AppTextStyles.robotoMedium20White,
            ),
          ),
        ),
      ),
    );
  }
}
