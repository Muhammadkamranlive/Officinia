import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';

class DeliveryAddressCheckboxWidget extends StatefulWidget {
  /// The single-select checkbox options, e.g. ["Residential Address", "Office Address"]
  final List<String> listItems;

  /// Parallel array of details to build subfields. For "Office Address",
  /// this typically contains a JSON structure describing an extra text field.
  /// Example:
  ///
  /// [
  ///   [], // No extra fields for "Residential Address"
  ///   [
  ///     {
  ///       "isRequired": "true",
  ///       "fieldType": "Entry",
  ///       "fieldKeyboardType": "text",
  ///       "fieldPlaceholder": "Office Address",
  ///       "fieldValue": "Enter your Office Address",
  ///       "fieldClassID": "office_address",
  ///       "fieldIsRequired": true,
  ///       "listItems": [],
  ///       "listItemsDetails": []
  ///     }
  ///   ]
  /// ]
  final List<dynamic> listItemsDetails;

  /// A validator that checks the user’s selection (and optionally subfields).
  /// Return `null` if valid; otherwise an error string.
  final FormFieldValidator<List<String>>? validator;

  /// A label/title to display above the checkboxes.
  final String title;

  const DeliveryAddressCheckboxWidget({
    Key? key,
    required this.listItems,
    required this.listItemsDetails,
    this.validator,
    this.title = "Where would you like your card to be delivered?",
  }) : super(key: key);

  @override
  State<DeliveryAddressCheckboxWidget> createState() =>
      _DeliveryAddressCheckboxWidgetState();
}

class _DeliveryAddressCheckboxWidgetState
    extends State<DeliveryAddressCheckboxWidget> {
  /// We store a single selection in a list to keep compatibility
  /// with FormField<List<String>>. At any time, this list will have
  /// at most one element.
  final List<String> _selectedOptions = [];

  /// Example text controller for "Office Address"
  final TextEditingController _officeAddressController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // By default, select "Residential Address" if it exists
    if (widget.listItems.contains("Residential Address")) {
      _selectedOptions.add("Residential Address");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<List<String>>(
      initialValue: _selectedOptions,
      validator: widget.validator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 12.0),
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: newSecondaryColor),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Display "checkboxes" horizontally (one selection at a time)
                    Wrap(
                      direction: Axis.horizontal,
                      spacing: 12.0,
                      runSpacing: 8.0,
                      children: widget.listItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final option = entry.value;
                        final isChecked = field.value!.contains(option);

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              activeColor: newSecondaryColor,
                              shape:
                                  const CircleBorder(), // Make the checkbox circular
                              value: isChecked,
                              onChanged: (bool? checked) {
                                setState(() {
                                  if (checked == true) {
                                    // Clear previous selection and select this one
                                    field.value!.clear();
                                    field.value!.add(option);
                                  } else {
                                    // If user unchecks, we allow no selection
                                    field.value!.remove(option);
                                  }

                                  // Notify the FormField that the selection changed
                                  field.didChange(field.value);
                                });
                              },
                            ),
                            Text(option),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Show extra text field(s) if "Office Address" is selected
            if (field.value!.contains("Office Address"))
              ..._buildOfficeAddressFields(),

            // Show a validation error if present
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  field.errorText ?? '',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Conditionally build extra widget(s) for "Office Address"
  List<Widget> _buildOfficeAddressFields() {
    final index = widget.listItems.indexOf("Office Address");
    if (index == -1) return [];

    final subFields = widget.listItemsDetails[index];
    final List<Widget> fields = [];

    for (var item in subFields) {
      if (item["fieldType"] == "Entry") {
        final placeholder = item["fieldPlaceholder"] ?? "Office Address";
        final hintText = item["fieldValue"] ?? "Enter Office Address";
        final isRequired = (item["isRequired"] == "true");

        fields.add(
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: TextFormField(
                  controller: _officeAddressController,
                  decoration: InputDecoration(
                    labelText: placeholder,
                    labelStyle: const TextStyle(
                        color: newSecondaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    hintText: hintText,
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                    border: _inputBorder(), // Consistent border behavior
                    focusedBorder: _inputBorder(),
                    enabledBorder: _inputBorder(),
                    errorBorder: _inputBorder(),
                    disabledBorder: _inputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 15.0,
                    ),
                  ),
                  validator: (value) {
                    // If "Office Address" is checked AND the field is required,
                    // user must enter something
                    if (isRequired &&
                        _selectedOptions.contains("Office Address") &&
                        (value == null || value.trim().isEmpty)) {
                      return "Please enter your Office Address";
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
        );
      }
    }
    return fields;
  }

  OutlineInputBorder _inputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none, // Keep the visual appearance of no border
    );
  }
}
