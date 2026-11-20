import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/screens/otp/newSingIn_OTP_Screen/SignIn_body.dart';
import 'package:mobile_onboarding/screens/otp/newSingUP_OTP_Screen/SignUp_body.dart';
import 'package:mobile_onboarding/size_config.dart';
import 'package:mobile_onboarding/widgets/custom_app_bar.dart';
import 'package:mobile_onboarding/widgets/newappbar.dart';
import 'package:mobile_onboarding/widgets/screen_arguments.dart';

class SingInOtpScreen extends StatelessWidget {
  const SingInOtpScreen({super.key});

  static String routeName = "/otp_SingIN";

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;

    return Container(
        decoration: const BoxDecoration(gradient: radialGradient),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CustomAppBarWithPopup(),
          body: SingIN_otp_Body(args.textOne, args.textTwo, args.emailDisplay),
        ));
  }
}
