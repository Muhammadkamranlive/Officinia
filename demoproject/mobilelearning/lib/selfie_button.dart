import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_onboarding/model/form_field_data_new.dart';

import '../constants.dart';

class SelfieButton extends StatefulWidget {
  final FormFieldDataNew fieldData;
  final VoidCallback onPressed;
  SelfieButton({required this.fieldData, required this.onPressed});

  @override
  State<SelfieButton> createState() => _SelfieButtonState();
}

class _SelfieButtonState extends State<SelfieButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 16,
        ),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              backgroundColor: kPrimaryColor,
            ),
            onPressed: widget.onPressed,
            child: Text(
              widget.fieldData.fieldPlaceholder,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
