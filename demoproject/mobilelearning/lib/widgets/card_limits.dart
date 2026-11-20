import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';

import 'custom_app_bar.dart';
import 'custom_slider.dart';
import 'disclaimer_box.dart';

void main() {
  runApp(CardLimits());
}

class CardLimits extends StatefulWidget {
  const CardLimits({super.key});

  @override
  State<CardLimits> createState() => _CardLimitsState();
}

class _CardLimitsState extends State<CardLimits> {
  double _currentSliderValue = 80000;
  TextEditingController cardName = TextEditingController();
  var text = RichText(
      text: const TextSpan(
          style: TextStyle(
    fontSize: 14.0,
    color: Colors.black,
  )));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: CustomAppBar(true, false),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                //'assets/images/noor_cards.png',
                'assets/images/card_1.png',
                fit: BoxFit.cover,
                width: 360,
                height: 200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFe2eaec),
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: labelStyle,
                        children: <TextSpan>[
                          TextSpan(
                              text: 'Card Limit: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' PKR 700,000 to PKR 1000,000'),
                        ],
                      ),
                    ),
                    RichText(
                      text: const TextSpan(
                        style: labelStyle,
                        children: <TextSpan>[
                          TextSpan(
                              text: 'Annual Fee: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' PKR 500+Taxes'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFe2eaec),
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Set Limit',
                    style: labelStyle,
                  ),
                  Text(
                    'PKR | ${_currentSliderValue.round()}',
                    style: const TextStyle(
                        fontSize: 16,
                        //color: AppColors.secoundryColor2,
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            CustomSlider(
              value: _currentSliderValue,
              max: 300000,
              min: 80000,
              divisions: 2,
              onChanged: (double value) {
                setState(
                  () {
                    _currentSliderValue = value;
                  },
                );
              },
            ),
            const DisclaimerContainer(
              disclaimerText:
                  'Disclaimer: The Offered Noor Card and variant is subject to eligibility criteria',
            ),

            // const Center(
            //   child: Text(
            //     'Select your card',
            //     style: TextStyle(
            //         //color: AppColors.secoundryColor2,
            //         color: kPrimaryColor,
            //         fontSize: 25,
            //         fontWeight: FontWeight.bold),
            //   ),
            // ),
            // const Center(
            //     child: Text(
            //   'Step 2/5',
            //   style: TextStyle(
            //       //color: AppColors.secoundryColor2,
            //       color: kPrimaryColor,
            //       fontSize: 12,
            //       fontWeight: FontWeight.bold),
            // )),
            // Flexible(
            //   child: Container(
            //     decoration: const BoxDecoration(
            //       color: Color(0xFFeeeeee),
            //       borderRadius: BorderRadius.only(
            //         topLeft: Radius.circular(15),
            //         topRight: Radius.circular(15),
            //       ),
            //     ),
            //     height: double.infinity,
            //     width: double.infinity,
            //     child: Padding(
            //       padding: const EdgeInsets.all(20.0),
            //       child: SingleChildScrollView(
            //         child: Column(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
