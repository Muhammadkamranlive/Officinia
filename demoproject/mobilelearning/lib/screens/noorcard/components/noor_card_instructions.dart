import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_onboarding/screens/dynamic_jour_steps/steps_main.dart';
import 'package:mobile_onboarding/screens/noorcard/components/dotted_container.dart';
import 'package:mobile_onboarding/screens/noorcard/noor_card_screen.dart';

import '../../../constants.dart';
import '../../../widgets/button_white_bg.dart';

class NoorCardInstructions extends StatefulWidget {
  const NoorCardInstructions({super.key});

  @override
  State<NoorCardInstructions> createState() => _NoorCardInstructionsState();
}

class _NoorCardInstructionsState extends State<NoorCardInstructions> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        alignment: Alignment.topCenter,
        height: 420,
        decoration: const BoxDecoration(
            gradient: kPrimaryGradientColor,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15.0),
                topLeft: Radius.circular(15.0))),
        child: Padding(
          padding: const EdgeInsets.all(20),
          //padding: const EdgeInsets.only(top: 20, left: 40, right: 40, bottom: 20),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      'Before you start, we request you to',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  //const ResponsiveDottedBorder(),
                  const SizedBox(height: 40),
                  DefaultWhiteButton(
                    text: "Proceed",
                    press: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) =>
                      //         DynamicForm(0, 0, false, productType),
                      //   ),
                      // );

                      Navigator.pushNamed(
                          context, ProductsScreenMain.routeName);
                    },
                  ),

                  //const ExistingApplicant(),
                  //const SizedBox(height: 10)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
