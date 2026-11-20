import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_onboarding/constants.dart';

class CnicTypeCustomRadioWidget extends StatefulWidget {
  final List<String> listItems; // e.g. ['NADRA', 'Passport', 'Other']
  final Function(String) onSelectionChanged;
  final String?
      initialSelectedValue; // The currently saved selection (could be empty or "Other")

  const CnicTypeCustomRadioWidget({
    Key? key,
    required this.listItems,
    required this.onSelectionChanged,
    required this.initialSelectedValue,
  }) : super(key: key);

  @override
  _CnicTypeCustomRadioWidgetState createState() =>
      _CnicTypeCustomRadioWidgetState();
}

class _CnicTypeCustomRadioWidgetState extends State<CnicTypeCustomRadioWidget> {
  String? _selectedItem;

  @override
  void initState() {
    super.initState();

    // If the incoming value is not empty AND it exists in the list, select it.
    if (widget.initialSelectedValue != null &&
        widget.initialSelectedValue!.isNotEmpty &&
        widget.listItems.contains(widget.initialSelectedValue)) {
      _selectedItem = widget.initialSelectedValue;
    }
    // Otherwise, if the list isn't empty, select the first item by default.
    else if (widget.listItems.isNotEmpty) {
      _selectedItem = widget.listItems.first;
    }
    // If the list is empty, _selectedItem remains null (no selection).
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 5.h),
        Container(
          width: 300.w,
          height: 75.h,
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            // border: Border.all(color: newSecondaryColor, width: 3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: widget.listItems.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _selectedItem == item,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          // Mark this item as selected
                          _selectedItem = item;
                          // Notify the parent with the newly selected item
                          widget.onSelectionChanged(_selectedItem!);
                        } else {
                          // Unchecking the same item
                          _selectedItem = null;
                          // Notify the parent that no item is selected
                          widget.onSelectionChanged('');
                        }
                      });
                    },
                    activeColor: newSecondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  Text(
                    item,
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontFamily: 'Circular',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
