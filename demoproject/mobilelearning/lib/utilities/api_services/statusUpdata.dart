import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/utilities/securedData/secureDataHandler.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> updateStatus() async {
  try {
    // 1. Get CNIC from SharedPreferences
    final secureStorage = FlutterSecureStorage();
    String? cnic = await UserSecretStore.getCnic();

    // You may want to handle the case where CNIC is null
    if (cnic == null || cnic.isEmpty) {
      print('CNIC not found in SharedPreferences');
      return;
    }

    // 2. Prepare the JSON body
    final Map<String, dynamic> requestBody = {
      "RequestHeader": {"UserID": "", "Password": "", "Channel": ""},
      "RequestDetails": {
        "Data": {
          "cnic": cnic, // Insert the CNIC from SharedPreferences
          "status": "Accept"
        }
      }
    };

    // 3. Send the POST request
    final response = await http.post(
      Uri.parse('${getApiBaseUrl()}/TPI/CustomerProgress'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    // Print the response body
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  } catch (e) {
    print('Error while calling API: $e');
  }
}
