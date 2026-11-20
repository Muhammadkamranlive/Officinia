import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/screens/noorcard/components/appBar.dart';

import '../noorcard/components/body.dart';

class NoorCardScreen extends StatefulWidget {
  static String routeName = "/noor_card";

  @override
  State<NoorCardScreen> createState() => _NoorCardScreenState();
}

class _NoorCardScreenState extends State<NoorCardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScaffoldBackground,
      appBar: CustomAppBarwithHeadingIcon(
        appBarHeading: 'Apply for Noor Card',
        appBarIcon: Icons.info_outline,
      ),
      body: Body(),
    );
  }
}
