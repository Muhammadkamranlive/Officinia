import 'dart:convert';

class FingerVerificationResponse {
  final String? code;
  final String? message;
  final String? transactionID;
  final String? sessionID;
  final String? citizenNumber;
  final String? fingerIndex;

  FingerVerificationResponse({
    this.code,
    this.message,
    this.transactionID,
    this.sessionID,
    this.citizenNumber,
    this.fingerIndex,
  });

  factory FingerVerificationResponse.fromJson(Map<String, dynamic> json) {
    return FingerVerificationResponse(
      code: json['code'] as String?,
      message: json['message'] as String?,
      transactionID: json['transactionID'] as String?,
      sessionID: json['sessionID'] as String?,
      citizenNumber: json['citizenNumber'] as String?,
      fingerIndex: json['finger_Index'] as String?,
    );
  }
}

FingerVerificationResponse parseStringResponseToModel(String response) {
  try {
    // Decode the JSON string into a Map
    final Map<String, dynamic> responseMap = jsonDecode(response);

    // Parse the Map into the FingerVerificationResponse model
    return FingerVerificationResponse.fromJson(responseMap);
  } catch (e) {
    // Handle JSON parsing errors
    print('Error parsing response: $e');
    throw Exception('Failed to parse response into FingerVerificationResponse');
  }
}
