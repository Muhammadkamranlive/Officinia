import 'package:flutter/material.dart';
import 'package:mobile_onboarding/widgets/pfdButton.dart';

class AgreementContainer extends StatelessWidget {
  const AgreementContainer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Light-blue background color. You can adjust shade as you like:

      padding: const EdgeInsets.only(top: 10.0),
      // Round the corners
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Static text
          Text(
            "By submitting you to agree",
            style: TextStyle(fontSize: 16),
          ),
          // The underlined button we created
          UnderlinedPdfButton(
            attribute: "NC",
            buttonText: 'Noor Card Terms & Conditions',
          ),
          UnderlinedPdfButton(
            attribute: "MA",
            buttonText: 'Musawamah Agreement,',
          ),
          UnderlinedPdfButton(
            attribute: "ZD",
            buttonText: 'Zakat Declaration,',
          ),
          UnderlinedPdfButton(
            attribute: "KF",
            buttonText: 'Noor Card Key Fact Sheet,',
          ),
        ],
      ),
    );
  }
}
