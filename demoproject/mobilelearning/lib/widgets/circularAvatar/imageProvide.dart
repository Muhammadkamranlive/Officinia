import 'package:flutter/material.dart';
import 'package:mobile_onboarding/utilities/securedData/secureDataHandler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageProviderNotifier extends ChangeNotifier {
  String? _imagePath;

  String? get imagePath => _imagePath;

  ImageProviderNotifier() {
    _loadImagePath();
  }

  Future<void> _loadImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final mobileNumber = await UserSecretStore.getSignNumber();
    if (mobileNumber != null) {
      _imagePath = prefs.getString('image_path_$mobileNumber');
    }
    notifyListeners();
  }

  Future<void> setImagePath(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final mobileNumber = await UserSecretStore.getSignNumber();
    if (mobileNumber != null) {
      _imagePath = path;
      await prefs.setString('image_path_$mobileNumber', path);
    }
    notifyListeners();
  }

  Future<void> clearImagePath() async {
    _imagePath = null;
    notifyListeners();
  }

  Future<void> loadNewProfileImage() async {
    await _loadImagePath();
  }
}
