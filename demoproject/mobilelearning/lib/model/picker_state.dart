class PickerState {
  final String fieldClassID;
  final String pickerIndex;
  final int requestId;

  PickerState(this.fieldClassID, this.pickerIndex, this.requestId);

  Map<String, dynamic> toMap() {
    return {
      "fieldClassID": fieldClassID,
      "pickerIndex": pickerIndex,
      "requestId": requestId
    };
  }
}