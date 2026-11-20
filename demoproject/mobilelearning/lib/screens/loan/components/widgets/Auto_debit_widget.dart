import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/widgets/newUI_TF_DF.dart';

class CustomSelectionWidget extends StatefulWidget {
  final String heading;
  final List<dynamic> dropdownItems;
  final List<String> radioButtonTexts;
  final Function(String?) onDropdownChanged;
  final Function(String?) onRadioChanged;

  const CustomSelectionWidget({
    Key? key,
    required this.heading,
    required this.dropdownItems,
    required this.radioButtonTexts,
    required this.onDropdownChanged,
    required this.onRadioChanged,
  }) : super(key: key);

  @override
  _CustomSelectionWidgetState createState() => _CustomSelectionWidgetState();
}

class _CustomSelectionWidgetState extends State<CustomSelectionWidget> {
  String? selectedDropdownValue;
  String? selectedRadioValue;
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 15),
      child: Container(
        padding: const EdgeInsets.only(top: 13.0),
        decoration: BoxDecoration(
          color: Colors.white30,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading
            Text(
              widget.heading,
              style: const TextStyle(
                fontSize: 20,
                color: newSecondaryColor,
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            // Dropdown
            Visibility(
              visible: journeyType == 'ETB',
              child: DropdownButton<String>(
                value: selectedDropdownValue,
                items: widget.dropdownItems
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDropdownValue = value;
                  });
                  widget.onDropdownChanged(value);
                },
                underline: const SizedBox(), // No underline
                hint: const Text(
                  "Select an option",
                  style: TextStyle(
                    fontSize: 16,
                    color: newSecondaryColor,
                    fontFamily: 'Circular',
                  ),
                ),
                isExpanded: true,
              ),
            ),

            // Radio Buttons (Horizontal + Responsive)
            // const SizedBox(height: 12),
            Visibility(
                visible: journeyType == 'NTB',
                child: NewCustomTextField_DF(
                  controller: _controller,
                  labelText: 'Account Number',
                  hintText: 'Enter FBL Account Number (If Any)',
                  inputType: TextInputType.text,
                )),
            Visibility(
              visible: journeyType == 'ETB',
              child: Wrap(
                spacing: 16.0, // Horizontal gap between items
                runSpacing: 8.0, // Vertical gap when wrapping to a new line
                children: widget.radioButtonTexts.map((text) {
                  return InkWell(
                    onTap: () => _onRadioTapped(text),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<String>(
                          value: text,
                          groupValue: selectedRadioValue,
                          onChanged: (value) => _onRadioTapped(text),
                        ),
                        Text(text),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            // Skip Now Button
            // Align(
            //   alignment: Alignment.bottomRight,
            //   child: OutlinedButton(
            //     style: OutlinedButton.styleFrom(
            //       side: const BorderSide(color: Colors.grey),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(15.0),
            //       ),
            //     ),
            //     onPressed: () {
            //       // Skip logic if required
            //     },
            //     child: const Text(
            //       'Skip for Now',
            //       style: TextStyle(
            //         color: Colors.black54,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _onRadioTapped(String text) {
    setState(() {
      selectedRadioValue = text;
    });
    widget.onRadioChanged(text);
  }
}
