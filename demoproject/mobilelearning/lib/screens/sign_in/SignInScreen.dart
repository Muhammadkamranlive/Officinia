import 'package:flutter/material.dart';
import 'package:mobile_onboarding/widgets/custom_app_bar.dart';

import 'components/body.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  static String routeName = "/sign_in";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(true, false),
      body: const Body(),
    );
  }
}
