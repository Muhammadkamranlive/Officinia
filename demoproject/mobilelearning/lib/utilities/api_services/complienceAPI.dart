import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_onboarding/model/complience_response.dart';

// Global function to fetch AccountScreening data
Future<AccountScreening> fetchAccountScreening({
  required String unitId,
  required String referenceNo,
  required String postingDate,
  required String insertedBy,
  required String accountTitle,
  required String activity,
  required String cnic,
  required String custType,
  required String dob,
  required String requestType,
  required String reserve1,
  required String reserve2,
  required String reserve3,
  required String reserve4,
  required String reserve5,
}) async {
  final String baseUrl = 'http://10.11.11.4:8050/screen/AccountScreening';

  // Construct query parameters
  final Map<String, String> queryParams = {
    'unitId': unitId,
    'referenceNo': referenceNo,
    'postingDate': postingDate,
    'insertedBy': insertedBy,
    'accountTitle': accountTitle,
    'activity': activity,
    'CNIC': cnic,
    'custType': custType,
    'DOB': dob,
    'requestType': requestType,
    'reserve1': reserve1,
    'reserve2': reserve2,
    'reserve3': reserve3,
    'reserve4': reserve4,
    'reserve5': reserve5,
  };

  // Encode query parameters
  final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
  print(uri);
  try {
    accountTitle = accountTitle.isEmpty ? 'Unknown' : accountTitle;
    cnic = cnic.isEmpty ? 'Unknown' : cnic;
    dob = dob.isEmpty ? 'Unknown' : dob;
    
    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      // Parse the JSON response
      final dynamic jsonResponse = json.decode(response.body);
      print("Compliance API response: ${response.body}");

      if (jsonResponse is Map<String, dynamic>) {
        // Handle the Map response
        return AccountScreening.fromJson(jsonResponse);
      } else if (jsonResponse is List) {
        // Handle the List response (Assume you want the first item)
        if (jsonResponse.isNotEmpty) {
          return AccountScreening.fromJson(jsonResponse[0]);
        } else {
          throw Exception('Empty response list');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load AccountScreening data: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching data: $e');
  }
}

String getFormattedDate() {
  DateTime now = DateTime.now();
  String formattedDate =
      "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  return formattedDate;
}
