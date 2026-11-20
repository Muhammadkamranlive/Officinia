import 'package:http/http.dart' as http;
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';

Future<String> getProductJson(String attribute, String journeyType) async {
  final headers = await getGenericHeaders();
  final String url =
      '${getApiBaseUrl()}/DynamicUIUX/GetFormData?attribute=$attribute&JType=$journeyType';

  try {
    final client = await createHttpClientWithPinnedCert();
    // Making the GET request
    final response = await client.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      print('Json Fetched successfully');
      return response.body;
    } else {
      // Return an error message if the response status is not 200
      return 'Error: ${response.statusCode} - ${response.body}';
    }
  } catch (e) {
    // Return an error message if the request fails
    return 'Failed to load data: $e';
  }
}
// import 'package:flutter/cupertino.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobile_onboarding/constants.dart';
// import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';

// Future<String> getProductJson(
//     String attribute, String journeyType, BuildContext context) async {
//   final String url =
//       'http://110.36.222.125:100/Services/DynamicUIUX/GetFormData?attribute=$attribute&JType=$journeyType';

//   try {
//     // Retrieve generic headers
//     final headers = await getGenericHeaders();
//     // Making the GET request
//     final response = await http.get(Uri.parse(url), headers: headers);

//     if (response.statusCode == 200) {
//       print('Json Fetched successfully');
//       return response.body;
//     } else if (response.statusCode == 400) {
//       // If invalid token, show dialog and exit the app.
//       await showInvalidTokenDialog(context);
//       return 'Error: 400 - Invalid token';
//     } else {
//       // Return an error message if the response status is not 200
//       return 'Error: ${response.statusCode} - ${response.statusCode}';
//     }
//   } catch (e) {
//     // Return an error message if the request fails
//     return 'Failed to load data: $e';
//   }
// }
