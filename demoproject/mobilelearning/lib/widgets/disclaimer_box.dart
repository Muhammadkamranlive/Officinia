import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_onboarding/constants.dart';

class DisclaimerContainer extends StatelessWidget {
  final String disclaimerText;

  const DisclaimerContainer({
    required this.disclaimerText,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: Container(
        width: 330.w,
        decoration: const BoxDecoration(
          color: kDisclaimerBG,
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            disclaimerText,
            style: TextStyle(fontSize: 11.sp, color: kDisclaimerText),
          ),
        ),
      ),
    );
  }
}
