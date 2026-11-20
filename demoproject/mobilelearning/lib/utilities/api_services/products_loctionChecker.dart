import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';
import 'package:mobile_onboarding/utilities/api_services/product_catagory_id_getter.dart';

import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';

Future<bool> checkProductByLocation(
    BuildContext context, double? longitude, double? latitude) async {
  // Build the URL with query parameters
  final url = Uri.parse(
      '${getApiBaseUrl()}/LOS/productByLocation?productCodeId=$globalProductValue&longitude=$longitude&latitude=$latitude');

  try {
    final client = await createHttpClientWithPinnedCert();
    final headers = await getGenericHeaders();
    // Make the GET request
    final response = await client.get(url, headers: headers);

    // Close the loading dialog
    Navigator.of(context, rootNavigator: true).pop();

    // Check for HTTP status code 200 (OK)
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print(responseData);

      // Check if 'data' is 'Y'
      if (responseData['data'] == 'Y') {
        return true;
      } else {
        return false;
      }
    } else {
      print('Server responded with status code ${response.statusCode}');
      return false;
    }
  } catch (e) {
    Navigator.of(context, rootNavigator: true).pop();

    print('An error occurred: $e');

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content:
              Text('An error occurred while checking product availability.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    return false;
  }
}
