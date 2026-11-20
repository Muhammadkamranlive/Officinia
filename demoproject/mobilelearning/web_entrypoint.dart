import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:mobile_onboarding/main.dart';
import 'package:mobile_onboarding/utilities/parameters/provider.dart';

void main() {
  // Enable clean URLs on Web
  setUrlStrategy(PathUrlStrategy());

  // Web-only log
  debugPrint('[WebEntrypoint] Web startup — certificate pinning disabled.');
  final policyProvider = PolicyProvider();
  policyProvider.fetchPolicies();

  runApp(MyApp(policyProvider: policyProvider));
}
