import 'package:flutter/material.dart';
import '../constants.dart';

class NoAccountText extends StatelessWidget {
  const NoAccountText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don’t have an account? ",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Text(
            "Sign Up",
            style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white),
          ),
        ),
      ],
    );
  }
}
