import 'dart:convert';

import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/globlal_error_handler.dart';
import 'package:mobile_onboarding/model/proposal_status.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';
import 'package:mobile_onboarding/utilities/securedData/secureDataHandler.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

List<ProposalStatus> proposalStatus = [];
Future<int> getProposalStatus() async {
  try {
    final client = await createHttpClientWithPinnedCert();
    final headers = await getGenericHeaders();

    final phoneNumber = await UserSecretStore.getSignNumber();
    String encodedPhoneNumber = Uri.encodeComponent(phoneNumber!);

    var uri = Uri.parse(
        "${getApiBaseUrl()}/LOS/getProposalStatus?mobileNo=$encodedPhoneNumber");
    print("Complete API URL: ${uri.toString()}");

    var response = await client.get(uri, headers: headers);

    print("Response received in getProposalStatus(): ${response.statusCode}");

    if (response.statusCode == 200) {
      Map<String, dynamic> nTypes =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      List<dynamic> dataList = nTypes['data'];

      print("Length of Data List: ${dataList.length}");

      proposalStatus.clear(); // Clear previous data before adding new

      for (var item in dataList) {
        proposalStatus.add(
          ProposalStatus(
            item['appRef'],
            item['status'],
            item['productName'] ?? 15,
            item['productName'],
          ),
        );
      }

      print("Total Proposals: ${proposalStatus.length}");

      // If length > 0, navigate to NewProductListScreen
    }
  } catch (e) {
    showError(e);
    print('Exception in getProposalStatus(): $e');
  }

  return proposalStatus.length;
}
