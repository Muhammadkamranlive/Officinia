import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';

// class TermsCheckbox extends StatefulWidget {
//   @override
//   _TermsCheckboxState createState() => _TermsCheckboxState();
// }

// class _TermsCheckboxState extends State<TermsCheckbox> {
//   bool _isChecked = false;

//   @override
//   Widget build(BuildContext context) {
//     double textScaleFactor = MediaQuery.of(context).textScaleFactor;

//     return Row(
//       children: [
//         Checkbox(
//           activeColor: Colors.white,
//           checkColor: kPrimaryColor,
//           value: _isChecked,
//           onChanged: (bool? value) {
//             setState(() {
//               _isChecked = value ?? false;
//             });
//           },
//         ),
//         Expanded(
//           child: GestureDetector(
//             onTap: () {
//               setState(() {
//                 _isChecked = !_isChecked;
//               });
//             },
//             child: Text.rich(
//               TextSpan(
//                 text: 'I agree to the terms of ',
//                 style: TextStyle(color: Colors.white),
//                 children: [
//                   TextSpan(
//                     text: 'Services & Privacy Policy',
//                     style: TextStyle(
//                       color: Colors.white,
//                       decoration: TextDecoration.underline,
//                       fontSize: 12 * textScaleFactor,
//                     ),
//                   ),
//                 ],
//               ),
//               softWrap: true,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
class TermsCheckbox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  const TermsCheckbox({
    Key? key,
    required this.isChecked,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Row(
      children: [
        Checkbox(
          activeColor: Colors.white,
          checkColor: kPrimaryColor,
          value: isChecked,
          onChanged: onChanged,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              onChanged(!isChecked);
            },
            child: Text.rich(
              TextSpan(
                text: 'I agree to the terms of ',
                style: TextStyle(color: Colors.white),
                children: [
                  TextSpan(
                    text: 'Services & Privacy Policy',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      fontSize: 12 * textScaleFactor,
                    ),
                  ),
                ],
              ),
              softWrap: true,
            ),
          ),
        ),
      ],
    );
  }
}
