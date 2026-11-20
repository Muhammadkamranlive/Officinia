import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';

class CustomCheckboxValidator extends FormField<String?> {
  CustomCheckboxValidator({
    Key? key,
    required String placeholder,
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String?> onValueChanged,
    required FormFieldValidator<String?> validator,
  }) : super(
          key: key,
          validator: validator,
          initialValue: selectedValue,
          builder: (FormFieldState<String?> field) {
            return Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        placeholder,
                        style: const TextStyle(
                          color: newSecondaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: options.map((option) {
                          final trimmedOption = option.trim();
                          return Row(
                            children: [
                              Checkbox(
                                shape: const CircleBorder(),
                                activeColor: const Color(0xFF079889),
                                value: field.value == trimmedOption,
                                onChanged: (bool? selected) {
                                  field.didChange(
                                      selected == true ? trimmedOption : null);
                                  onValueChanged(
                                      selected == true ? trimmedOption : null);
                                },
                              ),
                              // const SizedBox(width: 8),
                              Text(trimmedOption),
                              // SizedBox(width: 40.w),
                            ],
                          );
                        }).toList(),
                      ),
                      if (field.errorText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            field.errorText!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
}
