import 'package:flutter/material.dart';

import '../constants.dart';

class LoginSingupButton extends StatelessWidget {
  LoginSingupButton({
    Key? key,
    this.text,
    required this.isDisable,
    this.press,
  }) : super(key: key);

  final String? text;
  final Function? press;
  bool isDisable = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.055,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
          backgroundColor: isDisable ? Colors.white : Colors.grey,
          // backgroundColor: Colors.white
        ),
        onPressed: press as void Function()?,
        child: Text(
          text!,
          style: const TextStyle(
            fontFamily: 'Circular',
            fontSize: 20,
            color: newSecondaryColor,
          ),
        ),
      ),
    );
  }
}
