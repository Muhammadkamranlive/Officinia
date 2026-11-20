class SwitchState {
  final String fieldClassID;
  final String state;
  final int requestId;

  SwitchState(this.fieldClassID, this.state, this.requestId);

  Map<String, dynamic> toMap() {
    return {
      "fieldClassID": fieldClassID,
      "state": state,
      "requestId": requestId
    };
  }
}