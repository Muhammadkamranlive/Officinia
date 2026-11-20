import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/size_config.dart';
import 'package:mobile_onboarding/utilities/internet_checker/connectivity_checker.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'otp_form.dart';

/*
class Body extends StatelessWidget {
  Body(this.otpNumber, this.otpEmail, this.emailVisible, {super.key});

  String? otpNumber;
  String? otpEmail;
  bool emailVisible;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: SizeConfig.screenFieldSize20),
            const Text(
              "OTP Verification",
              style: headingStyle,
            ),
            Text(
              emailVisible
                  ? "Please enter the one time password sent to \nyour registered mobile number / Email"
                  : "Please enter the one time password sent to \nyour registered mobile number",
              textAlign: TextAlign.center,
              style: labelStyle,
            ),
            OtpForm(otpNumber, otpEmail, emailVisible),
            SizedBox(height: SizeConfig.screenFieldSize20),
            buildTimer(),
            GestureDetector(
              onTap: () {
                // OTP code resend
              },
              child: const Text(
                "Resend OTP Code",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: kPrimaryColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Row buildTimer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("You can resend OTP after "),
        TweenAnimationBuilder(
          tween: Tween(begin: 59.0, end: 00.0),
          duration: const Duration(seconds: 59),
          builder: (_, dynamic value, child) => Text(
            "00:${value.toInt()}",
            style: const TextStyle(color: kPrimaryColor),
          ),
        ),
      ],
    );
  }
}
 */

class Body extends StatefulWidget {
  Body(this.otpNumber, this.otpEmail, this.emailVisible, {super.key});

  String? otpNumber;
  String? otpEmail;
  bool emailVisible;

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
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
      Positioned.fill(
        child: Image.asset(
          'assets/images/backgroung_image/Login.png',
          fit: BoxFit.cover,
        ),
      ),
      const Align(
        alignment: Alignment.topCenter,
        child: ConnectivityBanner(),
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.12,
          ),
          const Text(
            "Verify",
            style: headingStyle,
          ),
          Text(
            widget.emailVisible
                ? "Please enter the one time password sent to \nyour registered mobile number &  Email"
                : "We have sent you a 6 digit OTP \n+92${widget.otpNumber}",
            textAlign: TextAlign.center,
            style: labelStyle,
          ),

          SizedBox(height: SizeConfig.screenFieldSize30),
          OtpForm(widget.otpNumber, widget.otpEmail, widget.emailVisible),
          // SizedBox(height: SizeConfig.screenFieldSize20),
        ],
      ),
    ]);
  }
}
