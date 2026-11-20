import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/font_styles_roboto.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/font_styles_roboto.dart';

class DropDownBu extends StatefulWidget {
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hint;
  final String label;
  String? selectedValue;
  final FormFieldValidator<String>? validator;

  /// Determines whether the dropdown should include a search box.
  /// If [classID] is set to `'city'`, a search input is displayed at the top
  /// of the dropdown menu; otherwise, the dropdown behaves as before.
  final String classID;

  DropDownBu({
    Key? key,
    required this.items,
    required this.onChanged,
    required this.hint,
    required this.label,
    required this.selectedValue,
    this.validator,
    this.classID = '',
  }) : super(key: key);

  @override
  State<DropDownBu> createState() => _DropDownBuState();
}

class _DropDownBuState extends State<DropDownBu> {
  List<DropdownMenuItem<String>> addDividersAfterItems(List<String> items) {
    final List<DropdownMenuItem<String>> menuItems = [];
    for (final String item in items) {
      menuItems.addAll([
        DropdownMenuItem<String>(
          value: item,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              item,
              style: const TextStyle(
                color: descriptionText,
                fontSize: 14,
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

  final TextEditingController textEditingController = TextEditingController();
  bool _isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Column(
        children: [
          FormField<String>(
            initialValue: widget.selectedValue,
            validator: widget.validator,
            builder: (FormFieldState<String> state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            widget.label,
                            style: TextStyle(
                              color: newSecondaryColor,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Circular',
                            ),
                          ),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            onMenuStateChange: (isOpen) =>
                                setState(() => _isDropdownOpen = isOpen),
                            autofocus: true,
                            isExpanded: true,
                            hint: Text(
                              widget.hint,
                              style: AppTextStyles.robotoMedium16TFhint,
                            ),
                            items: addDividersAfterItems(widget.items),
                            value: widget.selectedValue,
                            onChanged: (value) {
                              setState(() {
                                widget.selectedValue = value;
                                state.didChange(value);
                              });
                              widget.onChanged(value);
                            },
                            buttonStyleData: const ButtonStyleData(
                              height: 50,
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 14),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 400,
                              width: 400,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: Colors.white,
                              ),
                            ),
                            menuItemStyleData: MenuItemStyleData(
                              height: MediaQuery.of(context).size.height * 0.04,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                            ),
                            iconStyleData: IconStyleData(
                              icon: _isDropdownOpen
                                  ? const Icon(
                                      FontAwesomeIcons.chevronUp,
                                      size: 18.0,
                                      color: newSecondaryColor,
                                    )
                                  : const Icon(
                                      FontAwesomeIcons.chevronDown,
                                      size: 18.0,
                                      color: newSecondaryColor,
                                    ),
                              iconDisabledColor: Colors.grey,
                            ),
                            // Show the search box only when classID is 'city'.
                            dropdownSearchData:
                                widget.classID == 'current_city' ||
                                        widget.classID == "office_city" ||
                                        widget.classID == 'place_of_birth'
                                    ? DropdownSearchData(
                                        searchController: textEditingController,
                                        searchInnerWidgetHeight: 50,
                                        searchInnerWidget: Container(
                                          height: 50,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                            horizontal: 8,
                                          ),
                                          child: TextField(
                                            controller: textEditingController,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 8,
                                              ),
                                              hintText: 'Search for an item...',
                                              hintStyle:
                                                  const TextStyle(fontSize: 12),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
                          ),
                        ),
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(left: 14, top: 5),
                            child: Text(
                              state.errorText ?? '',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}


// class DropDownBu extends StatefulWidget {
//   final List<String> items;
//   final ValueChanged<String?> onChanged;
//   final String hint;
//   final String label;
//   String? selectedValue;
//   final FormFieldValidator<String>? validator;

//   DropDownBu({
//     Key? key,
//     required this.items,
//     required this.onChanged,
//     required this.hint,
//     required this.label,
//     required this.selectedValue,
//     this.validator,
//   }) : super(key: key);

//   @override
//   State<DropDownBu> createState() => _DropDownBuState();
// }

// class _DropDownBuState extends State<DropDownBu> {
//   List<DropdownMenuItem<String>> addDividersAfterItems(List<String> items) {
//     final List<DropdownMenuItem<String>> menuItems = [];
//     for (final String item in items) {
//       menuItems.addAll([
//         DropdownMenuItem<String>(
//           value: item,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Text(item,
//                 style: const TextStyle(
//                   color: descriptionText,
//                   fontSize: 14,
//                   // fontWeight: FontWeight.bold
//                 )),
//           ),
//         ),
//         if (item != items.last)
//           const DropdownMenuItem<String>(enabled: false, child: Divider()),
//       ]);
//     }
//     return menuItems;
//   }

//   final TextEditingController textEditingController = TextEditingController();
//   bool _isDropdownOpen = false;
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 2.0, left: 0, right: 0),
//       child: Column(
//         children: [
//           FormField<String>(
//             initialValue: widget.selectedValue,
//             validator: widget.validator,
//             builder: (FormFieldState<String> state) {
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: Colors.white,
//                     ),
//                     width: double.infinity,
//                     // height: MediaQuery.of(context).size.height * 0.08,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.only(top: 8, left: 12),
//                           child: Text(
//                             widget.label,
//                             style: TextStyle(
//                                 color: newSecondaryColor,
//                                 fontSize: 13.sp,
//                                 fontWeight: FontWeight.w500,
//                                 fontFamily: 'Circular'),
//                           ),
//                         ),
//                         DropdownButtonHideUnderline(
//                           child: DropdownButton2<String>(
//                             onMenuStateChange: (isOpen) {
//                               setState(() {
//                                 _isDropdownOpen = isOpen;
//                               });
//                             },
//                             autofocus: true,
//                             isExpanded: true,
//                             hint: Text(
//                               widget.hint,
//                               style: AppTextStyles.robotoMedium16TFhint,
//                             ),
//                             items: addDividersAfterItems(widget.items),
//                             value: widget.selectedValue,
//                             onChanged: (value) {
//                               setState(() {
//                                 widget.selectedValue = value;
//                                 state.didChange(value);
//                               });
//                               widget.onChanged(value);
//                             },
//                             buttonStyleData: const ButtonStyleData(
//                               height: 50,
//                               width: double.infinity,
//                               padding: EdgeInsets.only(left: 14, right: 14),
//                             ),
//                             dropdownStyleData: DropdownStyleData(
//                               maxHeight: 400,
//                               width: 400,
//                               decoration: BoxDecoration(
//                                 // border: Border.all(
//                                 //   color: kPrimaryColor,
//                                 //   width: 1,
//                                 // ),
//                                 borderRadius: BorderRadius.circular(14),
//                                 color: Colors.white,
//                               ),
//                             ),
//                             menuItemStyleData: MenuItemStyleData(
//                               height: MediaQuery.of(context).size.height * 0.04,
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 8.0),
//                             ),
//                             iconStyleData: IconStyleData(
//                               icon: _isDropdownOpen
//                                   ? const Icon(FontAwesomeIcons.chevronUp,
//                                       size: 18.0, color: newSecondaryColor)
//                                   : const Icon(FontAwesomeIcons.chevronDown,
//                                       size: 18.0, color: newSecondaryColor),
//                               iconDisabledColor: Colors.grey,
//                             ),
//                             // dropdownSearchData: DropdownSearchData(
//                             //   searchController: textEditingController,
//                             //   searchInnerWidgetHeight: 50,
//                             //   searchInnerWidget: Container(
//                             //     height: 50,
//                             //     padding: const EdgeInsets.only(
//                             //       top: 8,
//                             //       bottom: 4,
//                             //       right: 8,
//                             //       left: 8,
//                             //     ),
//                             //     child: TextField(
//                             //       controller: textEditingController,
//                             //       decoration: InputDecoration(
//                             //         isDense: true,
//                             //         contentPadding: const EdgeInsets.symmetric(
//                             //           horizontal: 10,
//                             //           vertical: 8,
//                             //         ),
//                             //         hintText: 'Search for an item...',
//                             //         hintStyle: const TextStyle(fontSize: 12),
//                             //         border: OutlineInputBorder(
//                             //           borderRadius: BorderRadius.circular(8),
//                             //         ),
//                             //       ),
//                             //     ),
//                             //   ),
//                             // ),
//                           ),
//                         ),
//                         if (state.hasError)
//                           Padding(
//                             padding: const EdgeInsets.only(left: 14, top: 5),
//                             child: Text(
//                               state.errorText!,
//                               style: const TextStyle(
//                                 color: Colors.red,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
