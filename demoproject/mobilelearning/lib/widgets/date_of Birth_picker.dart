import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_onboarding/constants.dart';

// ignore: must_be_immutable
class DateOfBirthPicker extends StatefulWidget {
  final FormFieldValidator<String>? validator;
  final ValueChanged<String?> onChanged;
  final Widget? icon;
  final String label;
  final String hint;
  String? selectedValue;

  DateOfBirthPicker({
    Key? key,
    this.validator,
    this.icon,
    required this.onChanged,
    required this.label,
    required this.hint,
    required this.selectedValue,
  }) : super(key: key);

  @override
  State<DateOfBirthPicker> createState() => _DateOfBirthPickerState();
}

class _DateOfBirthPickerState extends State<DateOfBirthPicker> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.selectedValue != null) {
      _controller.text = widget.selectedValue!;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
      setState(() {
        widget.selectedValue = formattedDate;
        _controller.text = formattedDate;
      });
      widget.onChanged(formattedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            width: double.infinity,
            child: FormField<String>(
              validator: widget.validator,
              builder: (FormFieldState<String> state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _controller,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        prefixIcon: widget.icon,
                        labelText: widget.label,
                        labelStyle: PoppinRegular16,
                        hintText: widget.hint,
                        hintStyle: PoppinRegular14,
                        border: _inputBorder(), // Consistent border behavior
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
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(left: 14, top: 5),
                        child: Text(
                          state.errorText!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                );
              },
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
