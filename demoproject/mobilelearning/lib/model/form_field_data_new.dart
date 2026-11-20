class FormFieldDataNew {
  final String? isRequired;
  final String fieldType;
  final String fieldKeyboardType;
  final String fieldPlaceholder;
  final String fieldValue;
  final String fieldClassID;
  final bool fieldIsRequired;
  final List<String> listItems;
  final List<dynamic> listItemsDetails;

  FormFieldDataNew(
      {this.isRequired,
      required this.fieldType,
      required this.fieldKeyboardType,
      required this.fieldPlaceholder,
      required this.fieldValue,
      required this.fieldClassID,
      required this.fieldIsRequired,
      required this.listItems,
      required this.listItemsDetails});

  factory FormFieldDataNew.fromJson(Map<String, dynamic> json) {
    return FormFieldDataNew(
        isRequired: json["isRequired"],
        fieldType: json['fieldType'],
        fieldKeyboardType: json['fieldKeyboardType'],
        fieldPlaceholder: json['fieldPlaceholder'],
        fieldValue: json['fieldValue'],
        fieldClassID: json['fieldClassID'],
        fieldIsRequired: json['fieldIsRequired'],
        listItems: json['listItems'],
        listItemsDetails: json['listItemsDetails']);
  }
}
