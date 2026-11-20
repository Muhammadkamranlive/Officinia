import 'dart:convert'; // For encoding/decoding JSON
import 'package:http/http.dart' as http;
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart'; // Import the http package

// Global variables to store API data
String? globalProductImageBase64;
String? globalProductInstructionImageBase64;
List<dynamic>? globalSections;

Future<void> getProductInstructions(String attribute) async {
  final String apiUrl =
      "${getApiBaseUrl()}/DynamicUIUX/GetProductInstructions?attribute=$attribute";

  try {
    final client = await createHttpClientWithPinnedCert();
    final headers = await getGenericHeaders();
    final response = await client.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      // Decode the JSON response
      final Map<String, dynamic> data = json.decode(response.body);

      // Store imageBase64 and sections into global variables
      globalProductImageBase64 = data['imageBase64'];
      globalProductInstructionImageBase64 = data['image2Base64'];
      globalSections = data['sections'];

      print("Data fetched and stored successfully.");
    } else {
      print("Failed to fetch data. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error occurred: $e");
  }
}
