// import 'dart:convert';
// import 'package:http/http.dart' as http;

// import '../../constants.dart';

// // Make sure to import your global 'journeyType' or define it above.

// Future<Map<String, dynamic>> getC360UserData({
//   required String? cnic,
//   required String productType,
// }) async {
//   String url = '${getApiBaseUrl()}/TPI/UserInformation';

//   // Build the POST body with the cnic & productType
//   final Map<String, dynamic> requestBody = {
//     "RequestHeader": {
//       "UserID": "TenxUser",
//       "Password": "Tenx@1234",
//       "Channel": "Tenx"
//     },
//     "RequestDetails": {
//       "Data": {
//         "cnic": cnic,
//         "product_type": productType,
//       }
//     }
//   };

//   try {
//     // Make the POST call
//     final http.Response response = await http.post(
//       Uri.parse(url),
//       headers: {
//         "Content-Type": "application/json",
//       },
//       body: json.encode(requestBody),
//     );
//     print(response.body);
//     // Check for a successful status code
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> jsonResponse = json.decode(response.body);

//       // Safely extract 'data' from the response
//       final dynamic data = jsonResponse["data"];

//       // If 'data' is missing or empty, set journeyType = "NTB"
//       if (data == null ||
//           (data is Map && data.isEmpty) ||
//           (data is List && data.isEmpty)) {
//         journeyType = "NTB";
//         // Return empty map since there's no data
//         print("Journet type:${journeyType}");
//         return <String, dynamic>{};
//       } else {
//         journeyType = "ETB";
//         print("Journet type:${journeyType}");
//         // Return the 'data' part of the response as a Map
//         return Map<String, dynamic>.from(data);
//       }
//     } else {
//       // Handle non-200 responses
//       throw Exception(
//         'Failed to fetch user data: ${response.statusCode} ${response.reasonPhrase}',
//       );
//     }
//   } catch (e) {
//     // Handle request/JSON exceptions
//     rethrow;
//   }
// }
