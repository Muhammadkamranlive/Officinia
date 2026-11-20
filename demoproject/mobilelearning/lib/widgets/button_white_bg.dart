import 'package:flutter/material.dart';

import '../constants.dart';

class DefaultWhiteButton extends StatelessWidget {
  const DefaultWhiteButton({
    Key? key,
    this.text,
    this.press,
  }) : super(key: key);
  final String? text;
  final Function? press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.065,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: kPrimaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.white,
        ),
        onPressed: press as void Function()?,
        child: Text(
          text!,
          style: const TextStyle(
            fontSize: 20,
            color: kPrimaryColor,
          ),
        ),
      ),
    );
  }
}
