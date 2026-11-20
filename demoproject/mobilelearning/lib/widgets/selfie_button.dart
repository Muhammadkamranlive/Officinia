import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        SizedBox(
          height: 150.h,
        ),
        SizedBox(
          // width: double.infinity,
          height: 60.h,
          width: 300.w,
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              backgroundColor: newSecondaryColor,
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
