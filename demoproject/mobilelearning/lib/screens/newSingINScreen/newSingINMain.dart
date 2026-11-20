import 'package:flutter/material.dart';
import 'package:mobile_onboarding/screens/newSingINScreen/components/mainBody.dart';
import 'package:mobile_onboarding/widgets/newappbar.dart';

class NewSignInScreen extends StatelessWidget {
  const NewSignInScreen({super.key});

  static String routeName = "/new_sign_in";

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBarWithPopup(
        title: "Apply for Card",
        icon: Icons.info_outline,
      ),
      body: MainBodyofSignIn(),
    );
  }
}
