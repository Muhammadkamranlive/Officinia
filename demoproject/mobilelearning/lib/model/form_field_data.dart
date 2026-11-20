class FormFieldData {
  final String Type;
  final String ImageURL;
  final String Title;
  final String Description;
  final bool isRequired;
  final List<dynamic> listItemsDetails;

  FormFieldData(
      {required this.Type,
      required this.ImageURL,
      required this.Title,
      required this.Description,
      required this.isRequired,
      required this.listItemsDetails});

  factory FormFieldData.fromJson(Map<String, dynamic> json) {
    return FormFieldData(
        Type: json['Type'],
        ImageURL: json['ImageURL'],
        Title: json['Title'],
        Description: json['Description'],
        isRequired: json['isRequired'],
        listItemsDetails: json['ItemsDetails']);
  }

  @override
  String toString() {
    return '{ ${this.Type}, ${this.isRequired}, ${this.Title}, ${this.Description}, ${this.ImageURL}, ${this.listItemsDetails} }';
  }
}
