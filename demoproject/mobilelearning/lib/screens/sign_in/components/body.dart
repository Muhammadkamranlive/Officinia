import 'package:flutter/material.dart';
import 'package:mobile_onboarding/Screens/sign_in/components/sign_in_form.dart';
import 'package:mobile_onboarding/utilities/internet_checker/connectivity_checker.dart';

import '../../../size_config.dart';
import 'package:mobile_onboarding/constants.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          ConnectivityBanner(),
          Flexible(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    'assets/images/backgroung_image/Login.png',
                  ),
                ),
                color: Color(0xFFf3f3f3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    const Text("Let\'s begin your journey!",
                        style: headingStyle),
                    SizedBox(height: SizeConfig.screenFieldSize5),
                    const Text("Enter your mobile number",
                        textAlign: TextAlign.center, style: labelStyle),
                    const Text("you will get a verification code via SMS",
                        textAlign: TextAlign.center, style: labelStyle),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.15,
                    ),
                    //SignInForm(),
                    // SizedBox(height: SizeConfig.screenFieldSize10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
