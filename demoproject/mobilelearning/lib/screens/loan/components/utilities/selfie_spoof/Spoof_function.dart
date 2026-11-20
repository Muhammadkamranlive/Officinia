import 'package:mobile_onboarding/screens/loan/components/utilities/selfie_spoof/selfie_spoof_model.dart';

void handleResponse(String responseBody) {
  try {
    // Parse the response and get the spoof_score
    final spoofScoreResponse = SpoofScoreResponse.parseSafeJson(responseBody);

    // Access spoof_score safely
    double spoofScore = spoofScoreResponse.spoofScore ?? 0.0;
    print("Spoof Score: $spoofScore");

  } catch (e) {
    print("Error parsing response: $e");
  }
}
