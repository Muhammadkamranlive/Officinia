import 'package:flutter/material.dart';
import '../screens/requests/request_status_screen.dart';

class ExistingApplicant extends StatelessWidget {
  const ExistingApplicant({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () =>
              Navigator.pushNamed(context, RequestStatusScreen.routeName),
          child: const Text(
            "Existing Applicant",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
