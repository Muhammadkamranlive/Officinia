import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mobile_onboarding/screens/sign_in/SignInScreen.dart';
import 'package:mobile_onboarding/utilities/session_manager.dart';
import 'package:mobile_onboarding/widgets/custom_app_bar.dart';

import '../requests/components/body.dart';

class RequestStatusScreen extends StatefulWidget {
  static String routeName = "/request_status";

  @override
  State<RequestStatusScreen> createState() => _RequestStatusScreenState();
}

class _RequestStatusScreenState extends State<RequestStatusScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Body(),
    );
  }
}
