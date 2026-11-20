import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/model/form_field_data_new.dart';

class RadioWithConditionalTextField extends StatefulWidget {
  final FormFieldDataNew fieldData;
  final String? initialText;
  final String? initialRadioValue;
  final void Function(String)? onRadioChanged;
  final void Function(String)? onTextChanged;

  /// Same signature you already use elsewhere
  final String? Function(String?)? validator; // NEW

  const RadioWithConditionalTextField({
    Key? key,
    required this.fieldData,
    this.initialText,
    this.initialRadioValue,
    this.onRadioChanged,
    this.onTextChanged,
    this.validator, // NEW
  }) : super(key: key);

  @override
  _RadioWithConditionalTextFieldState createState() =>
      _RadioWithConditionalTextFieldState();
}

class _RadioWithConditionalTextFieldState
    extends State<RadioWithConditionalTextField>
    with AutomaticKeepAliveClientMixin {
  String? selectedValue;
  late final TextEditingController textController;

  @override
  void initState() {
    super.initState();
    final items = widget.fieldData.listItems;

    // 1) Restore radio
    if (widget.initialRadioValue != null &&
        items.contains(widget.initialRadioValue)) {
      selectedValue = widget.initialRadioValue;
    }

    // 2) Restore / init text
    textController = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final listItems = widget.fieldData.listItems;
    final placeholder = widget.fieldData.fieldPlaceholder;

    return FormField<String>(
      validator: (val) {
        // -------- built-in validation ----------
        if (selectedValue == null || selectedValue!.isEmpty) {
          return 'Please select an option.';
        }
        if (selectedValue == 'Yes' && textController.text.trim().isEmpty) {
          return 'Please enter your current address.';
        }
        // -------- caller-supplied validation ----
        if (widget.validator != null) {
          // You can decide what you want to pass here.
          // Common choices:
          //   widget.validator!(selectedValue);            // only radio
          //   widget.validator!(textController.text);      // only text
          //   widget.validator!('$selectedValue|${textController.text}'); // both
          return widget.validator!(selectedValue);
        }
        return null;
      },
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----- Radio group -----
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    placeholder,
                    style: TextStyle(
                      color: newSecondaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: listItems.map((item) {
                      final isSelected = item == selectedValue;
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              shape: const CircleBorder(),
                              activeColor: newSecondaryColor,
                              value: isSelected,
                              onChanged: (checked) {
                                final newValue = checked == true ? item : null;
                                setState(() {
                                  selectedValue = newValue;
                                  // Clear address if user switches away from Yes
                                  if (newValue != 'Yes') textController.clear();
                                });
                                widget.onRadioChanged?.call(newValue ?? '');
                                widget.onTextChanged?.call(textController.text);
                                fieldState
                                    .didChange(newValue); // <- notify form
                              },
                            ),
                            Text(item),
                            SizedBox(width: 20.w),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  if (selectedValue == 'Yes')
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: TextField(
                            controller: textController,
                            onChanged: (v) {
                              widget.onTextChanged?.call(v);
                              fieldState.didChange(
                                  selectedValue); // keep form in sync
                            },
                            decoration: InputDecoration(
                              labelText: 'Current Address',
                              hintText: 'Enter your current address',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w500,
                                fontSize: 14.sp,
                              ),
                              labelStyle: TextStyle(
                                color: newSecondaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 18.sp,
                              ),
                              border: _inputBorder(),
                              focusedBorder: _inputBorder(),
                              enabledBorder: _inputBorder(),
                              errorBorder: _inputBorder(),
                              disabledBorder: _inputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 15.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // ----- Single error line -----
                  if (fieldState.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        fieldState.errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),

            // ----- Conditional TextField -----
          ],
        );
      },
    );
  }

  OutlineInputBorder _inputBorder() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      );
}
