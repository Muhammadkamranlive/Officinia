import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';

class UnderlinedButton extends StatelessWidget {
  final VoidCallback onPressed;

  const UnderlinedButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero, // Removes default padding
          minimumSize: const Size(50, 30), // Optional size adjustment
          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduces tap area
        ),
        child: const Text(
          "Read More",
          style: TextStyle(
            fontSize: 16,
            color: newSecondaryColor,
            decoration: TextDecoration.underline,
            decorationColor: newSecondaryColor, // Underline color
            decorationThickness: 1.5, // Thickness of the underline
          ),
        ),
      ),
    );
  }
}
