String? validateInputTF(
    String? value, String? isRequired, String fieldPlaceholder) {
  if (isRequired == "true") {
    if (value == null || value.isEmpty) {
      return 'Please Enter $fieldPlaceholder';
    }
  }
  return null;
}

String? validateInputDropBu(
    String? value, String? isRequired, String fieldPlaceholder) {
  if (isRequired == "true") {
    if (value == null || value.isEmpty) {
      return 'Please select $fieldPlaceholder';
    }
  }
  return null;
}
