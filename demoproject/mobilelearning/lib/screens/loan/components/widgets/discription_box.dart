import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';

class InfoRow extends StatelessWidget {
  final String text;

  final Color iconColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const InfoRow({
    Key? key,
    required this.text,
    this.iconColor = descriptionText,
    this.textColor = descriptionText,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: disclaimerBG,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info, color: iconColor),
          const SizedBox(width: 8.0),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
