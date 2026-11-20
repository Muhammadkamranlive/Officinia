import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants.dart';

class DefaultImageButton extends StatefulWidget {
  const DefaultImageButton({
    Key? key,
    this.text,
    this.icon,
    this.press,
  }) : super(key: key);

  final String? text;
  final String? icon;
  final VoidCallback? press;

  @override
  State<DefaultImageButton> createState() => _DefaultImageButtonState();
}

class _DefaultImageButtonState extends State<DefaultImageButton> {
  @override
  Widget build(BuildContext context) {
    bool _isPressed = false;
    return GestureDetector(
      // onLongPressStart: (details) {
      //   setState(() {
      //     _isPressed = true;
      //   });
      // },
      // onLongPressEnd: (details) {
      //   setState(() {
      //     _isPressed = false;
      //   });
      // },
      onTap: widget.press,
      child: Container(
        decoration: const BoxDecoration(
          // color: _isPressed ? Colors.green : Colors.white,
          color: Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              // color: Colors.grey.withOpacity(0.5),
              color: Colors.transparent,
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.fingerprint,
          size: MediaQuery.of(context).size.height * 0.05,
          // color: _isPressed ? Colors.white : Colors.black,
          color: Colors.white,
        ),
      ),
    );
  }
}
//   @override
//   Widget build(BuildContext context) {
//     return TextButton.icon(
//       style: TextButton.styleFrom(
//         foregroundColor: Colors.white,
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         backgroundColor: Colors.white,
//       ),
//       icon: SvgPicture.asset(
//         icon!,
//         color: kPrimaryColor,
//         width: 22,
//       ),
//       onPressed: press as void Function()?,
//       label: Text(
//         text!,
//         style: const TextStyle(
//           fontSize: 18,
//           color: kPrimaryColor,
//         ),
//       ),
//     );
//   }
// }
