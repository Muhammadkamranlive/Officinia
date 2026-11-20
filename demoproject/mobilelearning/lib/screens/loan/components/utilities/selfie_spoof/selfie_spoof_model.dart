import 'dart:convert';

class SpoofScoreResponse {
  double? spoofScore;

  SpoofScoreResponse({this.spoofScore});

  // Static method to parse the JSON response and return the spoof_score
  static SpoofScoreResponse parseSafeJson(String responseBody) {
    try {
      // Trim whitespace to avoid errors with unexpected spaces or characters
      String cleanedResponse = responseBody.trim();

      // Handle unexpected characters: remove extra quotes or escape sequences
      if (cleanedResponse.startsWith('"') && cleanedResponse.endsWith('"')) {
        cleanedResponse = cleanedResponse.substring(1, cleanedResponse.length - 1);
      }

      // Decode the cleaned JSON string
      final Map<String, dynamic> responseMap = jsonDecode(cleanedResponse);

      // Extract the spoof_score from the nested 'data' object safely
      double spoofScore = responseMap['data']?['data']['spoof_score']?.toDouble() ?? 0.0;

      // Return the model with spoof_score
      return SpoofScoreResponse(spoofScore: spoofScore);
    } catch (e) {
      print("Error parsing response: $e");
      // If parsing fails, return a default model with spoof_score as 0
      return SpoofScoreResponse(spoofScore: 0.0);
    }
  }
}
