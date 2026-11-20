import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/font_styles_roboto.dart';

class NewCustomTextField_DF extends StatelessWidget {
  final TextEditingController controller;
  final String? errorMessage;
  final Widget? icon;
  final String labelText;
  final String hintText;
  final TextInputType inputType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? inputTextLength;

  NewCustomTextField_DF({
    Key? key,
    required this.controller,
    this.icon,
    this.inputTextLength,
    required this.labelText,
    required this.hintText,
    required this.inputType,
    this.errorMessage,
    this.inputFormatters,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, left: 0, right: 0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 22.0, left: 0, right: 0),
              child: TextFormField(
                enableInteractiveSelection: false,
                // ignore: deprecated_member_use
                toolbarOptions: const ToolbarOptions(
                  copy: false,
                  paste: false,
                  cut: false,
                  selectAll: false,
                ),
                // enableInteractiveSelection: false, // disables long-press menu
                // enableSuggestions:
                //     false, // optional: disables keyboard suggestions
                // autocorrect: false, // optional: disables auto-correct
                inputFormatters: inputFormatters,
                controller: controller,
                decoration: InputDecoration(
                  errorStyle: TextStyle(color: Colors.red),

                  prefixIcon: icon,
                  labelText: labelText,
                  labelStyle: AppTextStyles.robotoMedium16TFleble,
                  hintText: hintText,
                  hintStyle: AppTextStyles.robotoMedium16TFhint,
                  border: _inputBorder(), // Consistent border behavior
                  focusedBorder: _inputBorder(),
                  enabledBorder: _inputBorder(),
                  errorBorder: _inputBorder(),
                  disabledBorder: _inputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 15.0,
                  ),
                ),

                onChanged: onChanged,
                keyboardType: inputType,
                style: TextStyle(
                  color: descriptionText,
                  fontSize: 15.sp,
                ),
                // inputFormatters: inputFormatters,
                validator: validator,
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _inputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none, // Keep the visual appearance of no border
    );
  }
}
