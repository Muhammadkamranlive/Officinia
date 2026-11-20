import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';
import 'package:mobile_onboarding/utilities/core_banking_data/client_info_model.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';

Future<ClientInfoModel?> fetchClientInfo(String globalID) async {
  final url = Uri.parse("${getApiBaseUrl()}/TPI/GetClientCNIC");

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
    "globalID": globalID,
    "globalIDType": "NIC"
  };

  try {
    final client = await createHttpClientWithPinnedCert();
    final headers = await getGenericHeaders();
    final response = await client.post(
      url,
      headers: headers,
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print(responseData);
      return ClientInfoModel.fromJson(responseData);
    } else {
      print("Error: API returned ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Error: $e");
    return null;
  }
}
