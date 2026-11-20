import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/font_styles_roboto.dart';

/// A Form‐aware dropdown that mimics the UI/UX of your previous DropDownBu
/// but automatically validates whenever the parent Form is validated.
class ValidatingDropDownBu extends FormField<String> {
  ValidatingDropDownBu({
    Key? key,
    required List<String> items,
    String? initialValue,
    required String label,
    required String hint,
    required ValueChanged<String?> onChanged,
    FormFieldValidator<String>? validator,
  }) : super(
          key: key,
          initialValue: initialValue,
          validator: validator,
          builder: (FormFieldState<String> state) {
            // Helper to build DropdownMenuItems with dividers:
            List<DropdownMenuItem<String>> buildMenuItems(List<String> list) {
              final result = <DropdownMenuItem<String>>[];
              for (var item in list) {
                result.add(
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
                );
                if (item != list.last) {
                  result.add(
                    const DropdownMenuItem<String>(
                      enabled: false,
                      child: Divider(),
                    ),
                  );
                }
              }
              return result;
            }

            bool _isDropdownOpen = false;

            return StatefulBuilder(builder: (context, setDropdownState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label Text
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: newSecondaryColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Circular',
                      ),
                    ),
                  ),

                  // The dropdown container
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: state.hasError ? Colors.red : kPrimaryColor,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: Text(
                          hint,
                          style: AppTextStyles.robotoMedium16TFhint,
                        ),
                        items: buildMenuItems(items),
                        value: state.value,
                        onMenuStateChange: (isOpen) {
                          setDropdownState(() {
                            _isDropdownOpen = isOpen;
                          });
                        },
                        onChanged: (value) {
                          state.didChange(value);
                          onChanged(value);
                        },
                        buttonStyleData: const ButtonStyleData(
                          height: 50,
                          width: double.infinity,
                          padding: EdgeInsets.only(left: 0, right: 0),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 400,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white,
                            border: Border.all(color: kPrimaryColor),
                          ),
                        ),
                        menuItemStyleData: MenuItemStyleData(
                          height: 40.h,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        iconStyleData: IconStyleData(
                          icon: _isDropdownOpen
                              ? const Icon(
                                  FontAwesomeIcons.chevronUp,
                                  size: 18,
                                  color: newSecondaryColor,
                                )
                              : const Icon(
                                  FontAwesomeIcons.chevronDown,
                                  size: 18,
                                  color: newSecondaryColor,
                                ),
                        ),
                      ),
                    ),
                  ),

                  // Error text
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
            });
          },
        );
}

// // ---------------------
// // Example usage inside a Form:
// // ---------------------

// class MyFormPage extends StatefulWidget {
//   const MyFormPage({Key? key}) : super(key: key);

//   @override
//   State<MyFormPage> createState() => _MyFormPageState();
// }

// class _MyFormPageState extends State<MyFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   String? _selectedCountry;

//   final List<String> _countryOptions = [
//     'Pakistan',
//     'India',
//     'USA',
//     'Canada',
//     'UK'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Validated Dropdown Example')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               ValidatingDropDownBu(
//                 items: _countryOptions,
//                 initialValue: _selectedCountry,
//                 label: 'Country',
//                 hint: 'Select your country',
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please select Country';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedCountry = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     // All visible fields pass validation.
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Form is valid!')),
//                     );
//                   }
//                 },
//                 child: const Text('Submit'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
