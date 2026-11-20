import 'package:flutter/material.dart';
import 'package:mobile_onboarding/utilities/core_banking_data/apiService.dart';
import 'client_info_model.dart';

class ClientProvider extends ChangeNotifier {
  ClientInfoModel? _clientInfo;

  ClientInfoModel? get clientInfo => _clientInfo;

  Future<void> fetchClientData(String globalID) async {
    _clientInfo = await fetchClientInfo(globalID);
    notifyListeners();
  }
}
