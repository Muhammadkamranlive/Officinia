class PickerID {
  final String fieldClassID;
  final String pickerId;
  final int requestId;

  PickerID(this.fieldClassID, this.pickerId, this.requestId);

  Map<String, dynamic> toMap() {
    return {
      "fieldClassID": fieldClassID,
      "pickerId": pickerId,
      "requestId": requestId
    };
  }
}