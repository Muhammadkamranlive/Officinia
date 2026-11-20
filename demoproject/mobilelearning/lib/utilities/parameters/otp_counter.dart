import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';

/// Fetches JSON data from the given URL and returns the `n_VALUE` field.
/// Returns 60 if any error occurs or the field is missing.
Future<int> getOtpCounter() async {
  final url =
      '${getApiBaseUrl()}/ParametersPoliciesHeirarchy/GetPoliciesHeirarchy/13';

  try {
    final client = await createHttpClientWithPinnedCert();
    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey('n_VALUE') && data['n_VALUE'] is int) {
        return data['n_VALUE'] as int;
      } else {
        // `n_VALUE` not found or not an int
        return 60;
      }
    } else {
      // Non-200 status => treat as error
      return 60;
    }
  } catch (e) {
    // Any exception => return 60
    print('Error fetching data: $e');
    return 60;
  }
}
