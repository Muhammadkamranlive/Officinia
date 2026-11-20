// services/api_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/screens/new_product_list/components/model/product_model.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';

class ApiService extends ChangeNotifier {
  List<Product> products = [];
  List<dynamic> categories = [];
  List<dynamic> accounts = [];

  final String apiUrl = '${getApiBaseUrl()}/DynamicUIUX/GetProductJSON';

  // Function to fetch and update state with data
  Future<void> fetchData() async {
    try {
      final client = await createHttpClientWithPinnedCert();
      final headers = await getGenericHeaders();
      final response = await client.get(Uri.parse(apiUrl), headers: headers);
      print(response.statusCode.toString());
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        // Parse categories and accounts
        categories = data['fields_categories'] ?? [];
        accounts = data['fields_accounts'] ?? [];

        // Filter products where isRequired is true
        List<dynamic> productsJson = data['fields_products']
            .where((product) => product['isRequired'] == true)
            .toList();

        // Convert JSON to Product model instances
        products = productsJson.map((json) => Product.fromJson(json)).toList();

        notifyListeners(); // Notifies listeners when data is updated
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to return the raw API response without updating the state
  Future<Map<String, dynamic>?> fetchApiResponse() async {
    try {
      final client = await createHttpClientWithPinnedCert();
      final response = await client.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        // Return the decoded JSON response as a map
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      print('Error: $e');
      return null; // Return null in case of error
    }
  }
}
