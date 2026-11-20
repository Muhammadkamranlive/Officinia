import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/font_styles_roboto.dart';

class NewCustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorMessage;
  final Widget? icon;
  final String labelText;
  final String hintText;
  final TextInputType inputType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  NewCustomTextField({
    Key? key,
    required this.controller,
    this.icon,
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
      padding: const EdgeInsets.only(top: 2.0, left: 0, right: 0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 18.0, left: 0, right: 0),
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
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
                    vertical: 0,
                    horizontal: 25.0,
                  ),
                ),
                onChanged: onChanged,
                keyboardType: inputType,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                inputFormatters: inputFormatters,
                validator: validator,
              ),
            ),
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
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
