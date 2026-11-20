import 'package:flutter/material.dart';

import 'package:mobile_onboarding/screens/newSingUpScreen/components/mainBody.dart';

import 'package:mobile_onboarding/widgets/newappbar.dart';

class NewSignUpScreen extends StatelessWidget {
  const NewSignUpScreen({super.key});

  static String routeName = "/new_sign_up";

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBarWithPopup(
        title: "Apply for Card",
        icon: Icons.info_outline,
      ),
      body: MainBodyofSignUP(),
    );
  }
}
