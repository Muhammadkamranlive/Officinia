class Base64Image {
  final String fieldClassID;
  final String base64String;
  final int requestId;

  Base64Image(this.fieldClassID, this.base64String, this.requestId);

  Map<String, dynamic> toMap() {
    return {
      "fieldClassID": fieldClassID,
      "base64String": base64String,
      "requestId": requestId
    };
  }
}