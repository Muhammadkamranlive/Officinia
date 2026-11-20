import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/screens/otp/newSingUP_OTP_Screen/SignUp_body.dart';
import 'package:mobile_onboarding/size_config.dart';
import 'package:mobile_onboarding/widgets/custom_app_bar.dart';
import 'package:mobile_onboarding/widgets/screen_arguments.dart';

class SingUpOtpScreen extends StatelessWidget {
  const SingUpOtpScreen({super.key});

  static String routeName = "/otp_SingUp";

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;

    return Container(
        decoration: const BoxDecoration(
            // gradient: LinearGradient(
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            //   colors: [
            //     Color.fromRGBO(22, 188, 190, 100),
            //     Color.fromRGBO(20, 131, 140, 100)
            //   ],
            // ),
            gradient: radialGradient),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent, // Transparent background
            elevation: 0, // No shadow
            leading: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Colors.white), // Back button
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: SingUp_otp_Body(args.textOne, args.textTwo, args.emailDisplay),
        ));
  }
}
