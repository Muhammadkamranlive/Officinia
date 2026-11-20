import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mobile_onboarding/font_styles_roboto.dart';
import 'package:mobile_onboarding/screens/otp/newSingIn_OTP_Screen/SingIn_OTP_Form.dart';

import 'package:mobile_onboarding/utilities/internet_checker/connectivity_checker.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class SingIN_otp_Body extends StatefulWidget {
  SingIN_otp_Body(this.otpNumber, this.otpEmail, this.emailVisible,
      {super.key});

  String? otpNumber;
  String? otpEmail;
  bool emailVisible;

  @override
  State<SingIN_otp_Body> createState() => _SingIN_otp_BodyState();
}

// ignore: camel_case_types
class _SingIN_otp_BodyState extends State<SingIN_otp_Body> {
  @override
  Widget build(BuildContext context) {
    Key timerKey = const Key('timer');

    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: false);
    pr.style(
        message: 'Please wait...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: const Center(
          child: SizedBox(
              width: 50, height: 50, child: CircularProgressIndicator()),
        ),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        //textDirection: TextDirection.rtl,
        padding: const EdgeInsets.all(16),
        maxProgress: 100.0,
        progressTextStyle: const TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: const TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));

    return Stack(children: [
      const Align(
        alignment: Alignment.topCenter,
        child: ConnectivityBanner(),
      ),
      SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Text("Verify",
                style: TextStyle(
                    fontSize: 24.sp,
                    // fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(
              height: 10.h,
            ),
            // Text(
            //   widget.emailVisible
            //       ? "Please enter the one time password sent to \nyour registered mobile number & Email"
            //       : "We have sent you a 6 digit OTP \n+92${widget.otpNumber}",
            //   textAlign: TextAlign.center,
            //   style: labelStyle,
            // ),
            Text(
              "We have sent you a 6 digit OTP\n on your Mobile Number",
              textAlign: TextAlign.center,
              style: AppTextStyles.robotoMedium13White,
            ),

            // SizedBox(height: SizeConfig.screenFieldSize30),
            // SizedBox(height: SizeConfig.screenFieldSize30),
            // Text(
            //   obfuscatePhoneNumber(widget.otpNumber ?? ''),
            //   textAlign: TextAlign.center,
            //   style: circularbookOtpPhEmail,
            // ),
            // Text(
            //   obfuscateEmail(widget.otpEmail ?? ''),
            //   textAlign: TextAlign.center,
            //   style: circularbookOtpPhEmail,
            // ),

            SignInOtpForm(
                widget.otpNumber, widget.otpEmail, widget.emailVisible),
            // SizedBox(height: SizeConfig.screenFieldSize20),
          ],
        ),
      ),
    ]);
  }
}
