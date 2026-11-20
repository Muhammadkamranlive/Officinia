import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_onboarding/constants.dart';

Future<String> PMDPostRequest(String? mobileNumber, String? cnic) async {
  final url = Uri.parse("${getApiBaseUrl()}/TPI/PMDVerification");

  final Map<String, dynamic> requestBody = {
    "strAppID": "string",
    "strADC_TranCode": "string",
    "strDelimiter": "string",
    "strDate": "string",
    "strTime": "string",
    "strNetID": "string",
    "intRefNum": 0,
    "intSTAN": 0,
    "strTranMsg": "string",
    "strMerName": "string",
    "strMCC": "string",
    "strToken": "string",
    "userId": "string",
    "password": "string",
    "cnic": cnic,
    "msisdn": mobileNumber,
    "transactionID": 0
  };

  try {
    final response = await http.post(
      url,
      headers: {
        "accept": "text/plain",
        "Content-Type": "application/json",
      },
      body: jsonEncode(requestBody),
    );
    print(response.body);
    if (response.statusCode == 200) {
      return "Y";
    } else {
      return "N";
    }
  } catch (e) {
    print("Error: $e");
    return "N";
  }
}
