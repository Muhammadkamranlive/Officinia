import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/font_styles_roboto.dart';

class NewCustomDatePicker_DF extends StatefulWidget {
  final FormFieldValidator<String>? validator;
  final ValueChanged<String?> onChanged;
  final Widget? icon;
  final String label;
  final String hint;
  final String? errorMessage;
  final String classID; // Added classID
  String? selectedValue;

  NewCustomDatePicker_DF({
    Key? key,
    this.validator,
    this.icon,
    required this.onChanged,
    required this.label,
    required this.hint,
    this.errorMessage,
    required this.selectedValue,
    required this.classID, // Added classID in constructor
  }) : super(key: key);

  @override
  State<NewCustomDatePicker_DF> createState() => _NewCustomDatePicker_DFState();
}

class _NewCustomDatePicker_DFState extends State<NewCustomDatePicker_DF> {
  final TextEditingController _controller = TextEditingController();
  DateTime _lastDate = DateTime.now(); // Default to today's date

  @override
  void initState() {
    super.initState();
    if (widget.selectedValue != null) {
      _controller.text = widget.selectedValue!;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    DateTime firstDate = DateTime(1900, 1); // Default first date
    DateTime lastDate = _lastDate; // Default last date
    DateTime initialDate = now; // Default initial date
    if (widget.classID == "id_expiry_date") {
      // For expiry date, allow selection from today onwards
      firstDate = now;
      lastDate = DateTime(2040);
      initialDate = now; // Calendar starts from today
    } else if (widget.classID == "date_of_birth") {
      // For date of birth, user must be at least 18 years old
      lastDate = now.subtract(const Duration(days: 18 * 365)); // 18 years ago
      initialDate = lastDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate, // ✅ Corrected to use the dynamic value
      firstDate: firstDate,
      lastDate: lastDate,
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
      padding: const EdgeInsets.only(top: 8.0, left: 0, right: 0, bottom: 10),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 20.0, left: 0, right: 0, bottom: 10),
              child: TextFormField(
                readOnly: true,
                onTap: () => _selectDate(context),
                autofocus: true,
                controller: _controller,
                decoration: InputDecoration(
                  errorStyle: TextStyle(
                    color:
                        Colors.red, // 🔥 Change to your custom validator color
                    fontSize: 11.sp,
                  ),
                  suffixIcon: widget.icon,
                  labelText: widget.label,
                  labelStyle: PoppinRegular16,
                  hintText: widget.hint,
                  hintStyle: AppTextStyles.robotoMedium16TFhint,
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
                onChanged: widget.onChanged,
                style: const TextStyle(color: descriptionText, fontSize: 16),
                validator: widget.validator,
              ),
            ),
          ),
          // if (widget.errorMessage != null)
          //   Padding(
          //     padding: const EdgeInsets.only(top: 8.0),
          //     child: Text(
          //       widget.errorMessage!,
          //       style: TextStyle(color: Colors.black, fontSize: 12),
          //     ),
          //   ),
        ],
      ),
    );
  }

  OutlineInputBorder _inputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    );
  }
}
