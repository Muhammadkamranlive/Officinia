import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ConsentCheckboxSection extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool?>? onChanged;

  const ConsentCheckboxSection({
    Key? key,
    required this.isChecked,
    required this.onChanged,
  }) : super(key: key);

  // Method to open a link
  void _openLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
      ),
      // Example background color, replace with your constant
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            checkColor: newSecondaryColor,
            activeColor: Colors.white,
            value: isChecked,
            onChanged: onChanged,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0, right: 10),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    children: [
                      TextSpan(
                          text: "I agree to the terms of ",
                          style: PoppinRegular14),
                      TextSpan(
                        text: "Services & Privacy Policy.",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            color: newSecondaryColor),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _openLink(
                                "https://www.faysalbank.com/wp-content/uploads/2022/06/Noor-Card-Terms-Conditions-1.pdf"); // Replace with your URL
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
