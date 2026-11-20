import 'package:flutter/material.dart';
import 'package:mobile_onboarding/screens/loan/components/dynamic_form.dart';

import '../constants.dart';

class ETBApplication extends StatelessWidget {
  const ETBApplication({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DynamicForm(0, 0, false, 1))),
          child: const Text(
            "ETB Application",
            style: TextStyle(
              fontSize: 18,
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: kPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
