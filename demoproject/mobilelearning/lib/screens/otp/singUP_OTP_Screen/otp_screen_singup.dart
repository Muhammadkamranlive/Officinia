import 'package:flutter/material.dart';
import 'package:mobile_onboarding/size_config.dart';
import 'package:mobile_onboarding/widgets/custom_app_bar.dart';
import 'package:mobile_onboarding/widgets/screen_arguments.dart';

import 'components/body.dart';

class OtpSingUpScreen extends StatelessWidget {
  const OtpSingUpScreen({super.key});

  static String routeName = "/otpSignUp";

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(true, false),
      body: Body(args.textOne, args.textTwo, args.emailDisplay),
    );
  }
}
