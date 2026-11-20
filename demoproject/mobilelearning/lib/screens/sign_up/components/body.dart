import 'package:flutter/material.dart';
import 'package:mobile_onboarding/screens/sign_up/components/sign_up_form.dart';
import 'package:mobile_onboarding/utilities/internet_checker/connectivity_checker.dart';
import '../../../size_config.dart';
import 'package:mobile_onboarding/constants.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        child: Image.asset(
          'assets/images/backgroung_image/Login.png',
          fit: BoxFit.cover,
        ),
      ),
      Align(alignment: Alignment.topCenter, child: ConnectivityBanner()),
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            const Text("Let's begin your journey!", style: headingStyle),
            SizedBox(height: SizeConfig.screenFieldSize5),
            const Text(
              "Enter your mobile number",
              textAlign: TextAlign.center,
              style: labelStyle,
            ),
            const Text(
              "you will get a verification code via SMS",
              textAlign: TextAlign.center,
              style: labelStyle,
            ),
          ],
        ),
      ),
      // SizedBox(
      //   height: MediaQuery.of(context).size.height * 0.2,
      // ),
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SignUpForm(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          )
        ],
      ),
    ],);
  }
}
