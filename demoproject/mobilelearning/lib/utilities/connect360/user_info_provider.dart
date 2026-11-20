import 'package:flutter/material.dart';
import 'package:mobile_onboarding/utilities/connect360/model.dart';

class ApiResponseProvider with ChangeNotifier {
  ApiResponse? _apiResponse;

  ApiResponse? get apiResponse => _apiResponse;

  void setApiResponse(ApiResponse response) {
    _apiResponse = response;
    notifyListeners();
  }
}
