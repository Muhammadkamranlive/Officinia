import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/utilities/connect360/model.dart';

Future<ApiResponse> fetchUserInformation(
    String? cnic, String? productType) async {
  final url = '${getApiBaseUrl()}/TPI/UserInformation';

  final headers = {
    'Accept': 'text/plain',
    'Content-Type': 'application/json',
  };

  final body = json.encode({
    'RequestHeader': {
      'UserID': 'string',
      'Password': 'string',
      'Channel': 'string',
    },
    'RequestDetails': {
      'Data': {
        'cnic': cnic,
        'product_type': productType,
      }
    },
  });

  try {
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ApiResponse.fromJson(data);
    } else {
      throw Exception('Failed to load data');
    }
  } catch (error) {
    throw Exception('Failed to make API call: $error');
  }
}
