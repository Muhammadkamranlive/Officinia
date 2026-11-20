import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductProvider with ChangeNotifier {
  Map<String, dynamic>? _productData;
  bool _isLoading = true;

  Map<String, dynamic>? get productData => _productData;
  bool get isLoading => _isLoading;

  // Function to fetch data from the API
  Future<void> fetchProductData() async {
    final url = 'http://10.11.11.205:5134/Services/DynamicUIUX/GetProductJSON';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        _productData = json.decode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      throw error;
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners to update the UI
    }
  }
}
