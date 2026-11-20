import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/globlal_error_handler.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';

// Global variable to store the product value
int? globalProductValue;
String? globalProductAttribute;
String? globalProductname;

Future<int?> getProductId(String productId, BuildContext context) async {
  final url = Uri.parse('${getApiBaseUrl()}/LOS/getLimitTypeData');

  try {
    final client = await createHttpClientWithPinnedCert();
    final header = await getGenericHeaders();
    // Make the GET request
    final response = await client.get(url, headers: header);
    print('Product avalibilty check reponse${response.body}');

    // Check for HTTP status code 200 (OK)
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Check if 'data' is a list
      if (responseData['data'] is List) {
        List<dynamic> dataList = responseData['data'];

        // Iterate over the data list
        for (var item in dataList) {
          if (item['attribute'] == productId) {
            // Match found, save to global variable
            globalProductValue = item['value'];
            product_attributes = item['attribute'].toString();
            globalProductname = item['label'].toString();

            print(product_attributes);
            print(globalProductValue);

            // Return the value
            return globalProductValue;
          }
        }
      }

      // If no match found, show dialog
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('No product available'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      return null;
    } else {
      // Handle non-200 status codes
      print('Server responded with status code ${response.statusCode}');
      return null;
    }
  } catch (e) {
    showError(e);
    // Handle exceptions such as network errors
    print('An error occurred: $e');
    return null;
  }
}
