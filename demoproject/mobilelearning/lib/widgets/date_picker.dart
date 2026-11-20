import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_onboarding/constants.dart';

// Example short dropdown widget (unchanged except no FormField).
class DropDownBuShort extends StatefulWidget {
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hint;
  String? selectedValue;

  DropDownBuShort({
    Key? key,
    required this.items,
    required this.onChanged,
    required this.hint,
    required this.selectedValue,
  }) : super(key: key);

  @override
  State<DropDownBuShort> createState() => _DropDownBuShortState();
}

class _DropDownBuShortState extends State<DropDownBuShort> {
  List<DropdownMenuItem<String>> _buildMenuItems(List<String> items) {
    final menuItems = <DropdownMenuItem<String>>[];
    for (final String item in items) {
      menuItems.addAll([
        DropdownMenuItem<String>(
          value: item,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              item,
              style: const TextStyle(
                color: descriptionText,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (item != items.last)
          const DropdownMenuItem<String>(enabled: false, child: Divider()),
      ]);
    }
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: Text(
          widget.hint,
          style: const TextStyle(color: Colors.grey),
        ),
        items: _buildMenuItems(widget.items),
        value:
            widget.selectedValue?.isEmpty == true ? null : widget.selectedValue,
        onChanged: (value) {
          setState(() {
            widget.selectedValue = value;
          });
          widget.onChanged(value);
        },
        buttonStyleData: ButtonStyleData(
          height: 40.h,
        ),
        menuItemStyleData: MenuItemStyleData(height: 20.h),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 300,
          width: 80,
          decoration: BoxDecoration(
            // border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
        ),
        iconStyleData: const IconStyleData(
          icon: FaIcon(
            FontAwesomeIcons.chevronDown,
            color: newSecondaryColor,
          ),
          iconSize: 17,
        ),
      ),
    );
  }
}

/// The main widget that organizes everything in one container
class DateSelectorWidget extends StatefulWidget {
  final Function(String) onDateSelected;
  final String label;
  final String? Function(String?)? validator;
  final String? initialDate;
  const DateSelectorWidget({
    Key? key,
    required this.onDateSelected,
    required this.label,
    this.validator,
    this.initialDate,
  }) : super(key: key);

  @override
  _DateSelectorWidgetState createState() => _DateSelectorWidgetState();
}

class _DateSelectorWidgetState extends State<DateSelectorWidget> {
  final List<String> months = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
  ];

  final List<String> years = List.generate(51, (index) => index.toString());

  String? selectedMonth = '';
  String? selectedYear = '';
  // ➋ Initialise from the stored value
  @override
  void initState() {
    super.initState();
    _loadInitial(widget.initialDate);
  }

  // ➋ If the parent rebuilds with a different value:
  @override
  void didUpdateWidget(covariant DateSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      _loadInitial(widget.initialDate);
    }
  }

  void _loadInitial(String? yM) {
    if (yM == null || yM.isEmpty || !yM.contains('-')) return;
    final parts = yM.split('-');
    if (parts.length == 2) {
      selectedYear = parts[0];
      selectedMonth = parts[1];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (val) {
        // #1 Basic check: month & year must not be blank

        if (selectedYear == null || selectedYear!.isEmpty) {
          return "Please select a year";
        }
        if (selectedMonth == null || selectedMonth!.isEmpty) {
          return "Please select a month";
        }
        // #2 If there's an external validator:
        if (widget.validator != null) {
          return widget.validator!(selectedMonth! + "-" + selectedYear!);
        }
        return null; // all good
      },
      builder: (fieldState) {
        // fieldState.hasError => bool, fieldState.errorText => message
        return Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Container(
            // Removed fixed height so the container expands as needed
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white, // White container
            ),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The "label" at the top
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: newSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),

                // The row with the two dropdowns
                Row(
                  children: [
                    Expanded(
                      child: DropDownBuShort(
                        items: years,
                        onChanged: (value) {
                          setState(() {
                            selectedYear = value ?? '';
                            _notifyDateSelected();
                            // Let the form know something changed
                            fieldState.didChange("updated-year");
                          });
                        },
                        hint: 'Select Years',
                        selectedValue: selectedYear,
                      ),
                    ),
                    SizedBox(width: 50.w),
                    Expanded(
                      child: DropDownBuShort(
                        items: months,
                        onChanged: (value) {
                          setState(() {
                            selectedMonth = value ?? '';
                            _notifyDateSelected();
                            fieldState.didChange("updated-month");
                          });
                        },
                        hint: 'Select Months',
                        selectedValue: selectedMonth,
                      ),
                    ),
                  ],
                ),

                // #3 Single error line at bottom if there's an error
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
        );
      },
    );
  }

  void _notifyDateSelected() {
    if (selectedMonth != null &&
        selectedMonth!.isNotEmpty &&
        selectedYear != null &&
        selectedYear!.isNotEmpty) {
      widget.onDateSelected('$selectedYear-$selectedMonth');
    }
  }
}
