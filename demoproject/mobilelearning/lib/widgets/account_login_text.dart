import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/screens/newSingINScreen/newSingINMain.dart';

class AccountLoginText extends StatelessWidget {
  const AccountLoginText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Existing Applicant? ",
          style: PoppinRegular14,
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, NewSignInScreen.routeName),
          child: const Text(
            "Login",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                color: newSecondaryColor),
          ),
        ),
      ],
    );
  }
}
