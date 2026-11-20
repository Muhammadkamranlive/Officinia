class FormValue {
  final String fieldClassID;
  final String? fieldValue;
  final int requestId;

  FormValue(this.fieldClassID, this.fieldValue, this.requestId);

  Map<String, dynamic> toMap() {
    return {
      "fieldClassID": fieldClassID,
      "fieldValue": fieldValue ?? '',
      "requestId": requestId
    };
  }
}
