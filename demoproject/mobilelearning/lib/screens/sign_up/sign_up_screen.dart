import 'package:flutter/material.dart';
import 'package:mobile_onboarding/screens/sign_up/components/body.dart';
import 'package:mobile_onboarding/widgets/custom_app_bar.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  static String routeName = "/sign_up";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(true, false),
      body: Body(),
    );
  }
}
