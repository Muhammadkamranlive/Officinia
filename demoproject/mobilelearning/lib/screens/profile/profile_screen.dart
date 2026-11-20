import 'package:flutter/material.dart';
import 'package:mobile_onboarding/widgets/custom_app_bar.dart';

import '../profile/components/body.dart';

class ProfileScreen extends StatelessWidget {
  static String routeName = "/profile";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(true, false),
      body: Body(),
    );
  }
}
