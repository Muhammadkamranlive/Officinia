import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';

class ApiService extends ChangeNotifier {
  List<Map<String, dynamic>> faqs = [];

  final String baseUrl = '${getApiBaseUrl()}/DynamicUIUX/GetCCFAQs';

  // Fetch FAQs from API with the specified attribute
  Future<void> fetchFaqs({required String attribute}) async {
    final String url = '$baseUrl?attribute=$attribute';
    try {
      final client = await createHttpClientWithPinnedCert();
      final response = await client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        faqs = List<Map<String, dynamic>>.from(data['faqs'] ?? []);
        notifyListeners();
      } else {
        throw Exception('Failed to load FAQs');
      }
    } catch (e) {
      print('Error fetching FAQs: $e');
    }
  }
}
