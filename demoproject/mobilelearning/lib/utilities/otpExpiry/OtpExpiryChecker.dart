import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Returns true if the stored “lastModified” timestamp is within [thresholdMinutes]
/// of the current time; otherwise returns false.
/// Prints lastModified, now, and the difference.
Future<bool> isWithinThreshold(int thresholdMinutes) async {
  final prefs = await SharedPreferences.getInstance();
  final lastModifiedString = prefs.getString('lastModified');
  if (lastModifiedString == null) {
    print('No lastModified found in prefs.');
    return false;
  }

  DateTime lastModified;
  try {
    lastModified = DateTime.parse(lastModifiedString);
  } catch (e) {
    print('Failed to parse lastModified: $lastModifiedString');
    return false;
  }

  final now = DateTime.now();
  final diff = now.difference(lastModified);

  print('lastModified: $lastModified');
  print('now:          $now');
  print(
      'difference:   ${diff.inMinutes} minute(s), ${diff.inSeconds % 60} second(s)');

  return diff < Duration(minutes: thresholdMinutes);
}

/// Assumes the following helper functions exist:
///   Future<Map<String, String>> getGenericHeaders();
///   Future<http.Client> createHttpClientWithPinnedCert();
///   String getApiBaseUrl(); // e.g. "http://10.42.2.102:1000/Services/Services"
///
/// Example usage:
///   final result = await callGetCustomerRegistrationAPI("03004412273");
///   if (result == 200) { /* success */ }
///

/// Assumes these helpers exist elsewhere:
///   Future<Map<String, String>> getGenericHeaders();
///   Future<http.Client> createHttpClientWithPinnedCert();
///   String getApiBaseUrl(); // e.g. returns "http://10.42.2.102:1000/Services"
///
/// Example call:
///   final status = await callGetCustomerRegistrationAPI("03214956659");
///   if (status == 200) { /* success */ }

Future<int> callGetCustomerRegistrationAPI(String mobileNumber) async {
  http.Client? client;

  try {
    // 1) Prepare headers & HTTP client
    final header = await getGenericHeaders();
    client = await createHttpClientWithPinnedCert();

    // 2) Construct the URI using path parameter style:
    //    http://10.42.2.102:1000/Services/Registration/GetCustomerRegistration/03214956659
    final uri = Uri.parse(
      "${getApiBaseUrl()}/Registration/GetCustomerRegistration/$mobileNumber",
    );
    print("Complete API URL: $uri");

    // 3) Execute GET
    final response = await client.get(uri, headers: header);
    print(
        "Response received in callGetCustomerRegistrationAPI(): ${response.body}");

    // 4) On HTTP 200, parse JSON and store 'lastmodifieddate' if present
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? lastModified = data['lastmodifieddate']?.toString();
      prefs.setString('lastModified', lastModified!);
      if (lastModified != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('lastModified', lastModified);
        print("API lastModified saved: $lastModified");
      }

      return 200;
    } else {
      // Propagate non-200 status
      return response.statusCode;
    }
  } catch (e) {
    print("Exception in callGetCustomerRegistrationAPI(): $e");
    return 0;
  } finally {
    // 5) Clean up the HTTP client if needed
    client?.close();
  }
}
