import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/utilities/parameters/model.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';

class PolicyProvider with ChangeNotifier {
  Map<String, bool> policies = {};
  Map<String, int> policiesINT = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> fetchPolicies() async {
    final client = await createHttpClientWithPinnedCert();
    _isLoading = true;
    notifyListeners();

    List<String> urls = [
      '${getApiBaseUrl()}/ParametersPoliciesHeirarchy/GetPoliciesHeirarchy/1',
      '${getApiBaseUrl()}/ParametersPoliciesHeirarchy/GetPoliciesHeirarchy/2',
      '${getApiBaseUrl()}/ParametersPoliciesHeirarchy/GetPoliciesHeirarchy/3',
      '${getApiBaseUrl()}/ParametersPoliciesHeirarchy/GetPoliciesHeirarchy/4',
      '${getApiBaseUrl()}/ParametersPoliciesHeirarchy/GetPoliciesHeirarchy/5',
      '${getApiBaseUrl()}/ParametersPoliciesHeirarchy/GetPoliciesHeirarchy/6',
      '${getApiBaseUrl()}/ParametersPoliciesHeirarchy/GetPoliciesHeirarchy/7',
      '${getApiBaseUrl()}/ParametersPoliciesHeirarchy/GetPoliciesHeirarchy/8',
      '${getApiBaseUrl()}/ParametersPoliciesHeirarchy/GetPoliciesHeirarchy/9',
      '${getApiBaseUrl()}/ParametersPoliciesHeirarchy/GetPoliciesHeirarchy/10',
      '${getApiBaseUrl()}/ParametersPoliciesHeirarchy/GetPoliciesHeirarchy/11',
      '${getApiBaseUrl()}/ParametersPoliciesHeirarchy/GetPoliciesHeirarchy/14',
      '${getApiBaseUrl()}/ParametersPoliciesHeirarchy/GetPoliciesHeirarchy/16'
    ];

    try {
      for (String url in urls) {
        print(url.toString());

        final response = await client.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
        );

        print(response.statusCode.toString());
        if (response.statusCode == 200) {
          print('response :${response.toString()}');
          final data = json.decode(response.body);
          final policy = Policy.fromJson(data);
          policies[data['pname']] = policy.pnameValue;
          policiesINT[data['pname']] = policy.n_VALUE;
        } else {
          print(
              'Policy not found Status code ${response.statusCode.toString()}');
          throw Exception('Failed to load policy');
        }
      }
    } catch (e) {
      print('Policy not found: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int getIntPolicies(String pname) {
    return policiesINT[pname] ?? 0;
  }

  bool getPolicyValue(String pname) {
    return policies[pname] ?? false;
  }
}
