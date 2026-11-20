import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_onboarding/screens/newSingUpScreen/newSingupMain.dart';

import '../../constants.dart';
import 'components/body.dart';

class AlertsStatusScreen extends StatelessWidget {
  static String routeName = "/alerts_status";

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {},
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.chevronLeft,
                color: descriptionText),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ),
        body: Body(),
      ),
    );
  }
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // force the user to choose
    builder: (BuildContext dialogCtx) {
      return AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () {
              // Dismiss the dialog only
              Navigator.of(dialogCtx).pop();
            },
            child: const Text(
              "No",
              style: TextStyle(color: newSecondaryColor),
            ),
          ),
          TextButton(
            onPressed: () {
              // First close the dialog
              Navigator.of(dialogCtx).pop();

              // Now pop until we reach the SignupScreen
              Navigator.of(context).pushNamedAndRemoveUntil(
                NewSignUpScreen.routeName,
                (route) => false,
              );

              // Explanation:
              //   popUntil() pops screens off the navigation stack
              //   until the condition (route.settings.name == SignupScreen.routeName) is satisfied.
              //   This means we stop popping once we get back to the SignupScreen.
            },
            child: const Text(
              "Yes",
              style: TextStyle(color: newSecondaryColor),
            ),
          ),
        ],
      );
    },
  );
}
