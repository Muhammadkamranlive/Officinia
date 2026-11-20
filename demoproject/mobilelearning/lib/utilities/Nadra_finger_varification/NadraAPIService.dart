import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/utilities/Nadra_finger_varification/NadraAPiModel.dart';

import 'package:mobile_onboarding/utilities/Nadra_finger_varification/model_SKD.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';
import 'package:mobile_onboarding/utilities/securedData/secureDataHandler.dart';

import 'package:shared_preferences/shared_preferences.dart';

// Send the POST request and return the raw response body
Future<String> sendVerificationRequest(
  FingerPrintVerificationRequest requestModel,
) async {
  final headers = await getGenericHeaders();
  final url = Uri.parse(
    '${getApiBaseUrl()}/TPI/FingerPrintVerification',
  );

  final bodyJson = jsonEncode(requestModel.toJson());
  print('sending finger data reguest:${bodyJson}');
  final response = await http.post(
    url,
    headers: headers,
    body: bodyJson,
  );

  if (response.statusCode == 200) {
    return response.body; // Return the raw response body
  } else {
    // Handle errors appropriately
    throw Exception(
      'Failed with status ${response.statusCode}: ${response.body}',
    );
  }
}

// Verify fingers one by one and return the final response body
Future<String?> verifyFingersOneByOne(
  FingerCaptureResponse fingerData,
  BuildContext context,
) async {
  final secureStorage = FlutterSecureStorage();
  // Retrieve necessary details from SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final mobile = await UserSecretStore.getSignNumber();

  String? cnicWithDashes = await UserSecretStore.getCnic();
  // removeDashes(cnicWithDashes);
  String? cnic = "";
  cnic = await UserSecretStore.getCnic();
  // Define the order of fingers to try
  final fingerKeys = [
    // 'rightindex',
    // 'rightmiddle',
    // 'leftindex',
    // 'leftmiddle',
    // 'leftthumb',
    'rightthumb'
  ];

  String? finalResponseBody;

  for (final key in fingerKeys) {
    final finger = fingerData.data?[key];
    if (finger == null) {
      // Skip if this finger is not present in the data
      continue;
    }
    String? encodeString(dynamic input) {
      if (input == null) return null;

      // If input is already a string, encode it:
      if (input is String) {
        return base64Encode(utf8.encode(input));
      }

      // If input is a map, attempt to find the actual string property you need
      if (input is Map<String, dynamic>) {
        // Extract the string part you actually want
        final rawString = input['rawTemplate'];
        if (rawString is String) {
          return base64Encode(utf8.encode(rawString));
        }
      }

      // If it’s something else or you can’t find a string, return null or throw
      return null;
    }

    // Build the POST request model
    final requestModel = FingerPrintVerificationRequest(
      strAppID: "",
      strADC_TranCode: finger.finger,
      strDelimiter: "",
      strDate: "",
      strTime: "",
      strNetID: "",
      intRefNum: "",
      intSTAN: "",
      strTranMsg: "",
      strMerName: "",
      strMCC: "",
      strToken: "",
      citizenNumber: cnic,
      contactNumber: mobile,
      fingerIndex: "1", // e.g., "index", "middle", etc.
      fingerTemplate: encodeString(finger.templates?.iso197942?.defaultValue),
      templateType: "ISO_19794_2",
      areaName: "Punjab",
      reasonCode: "",
      r1: "",
      r2: "",
      r3: "",
      r4: "",
    );
    print(finger.templates?.iso197942?.defaultValue);
    try {
      // Show the "Verifying from NADRA" dialog

      // Send the POST request and get the raw response
      showDialog(
        context: context,
        barrierDismissible: false, // user can't close it manually
        builder: (_) {
          return const AlertDialog(
            title: Text("Please Wait"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Verifying from NADRA..."),
              ],
            ),
          );
        },
      );

      final rawResponse = await sendVerificationRequest(requestModel);
      Navigator.pop(context);
      print("finger print API response: ${rawResponse.toString()}");

      // Store the raw response body
      finalResponseBody = rawResponse;

      // Parse the raw response
      // Map<String, dynamic> responseMap = jsonDecode(rawResponse);
      // final verificationResponse =
      //     FingerVerificationResponse.fromJson(responseMap);

      // if (verificationResponse.code == "100") {
      //   // Success: Return the response body immediately
      //   return finalResponseBody;
      // } else {
      //   // Log failure for this finger and try the next one
      //   print(
      //       'Finger $key failed. Code: ${verificationResponse.code}, trying next finger...');
      // }
    } catch (e) {
      // Handle exceptions and continue to the next finger
      print('Error while sending finger $key: $e');
      continue;
    }
  }

  // Return the last response body (if none succeeded)
  return finalResponseBody;
}
