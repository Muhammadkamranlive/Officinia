import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';
import '../home/components/body.dart';

class HomeScreen extends StatelessWidget {
  static String routeName = "/home";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: buildAppBar(context),
      body: Body(),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Image.asset(
        "assets/images/faisal_bank_banner.png",
        height: 45,
        //color: const Color(0xFFf3ca20),
      ),
      toolbarHeight: 56,
      centerTitle: true,
      automaticallyImplyLeading: false,
      elevation: 6,
      backgroundColor: Colors.white,
      shape: const Border(
        bottom: BorderSide(color: kPrimaryLightColor),
      ),
    );
  }
}
