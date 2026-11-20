import 'dart:convert';

String extractMessage(String responseBody) {
  // Decode the JSON string into a Map
  final Map<String, dynamic> decoded = jsonDecode(responseBody);

  // Safely retrieve the "message" field if it exists
  // Return an empty string if the field doesn't exist or is null
  return decoded['message']?.toString() ?? '';
}