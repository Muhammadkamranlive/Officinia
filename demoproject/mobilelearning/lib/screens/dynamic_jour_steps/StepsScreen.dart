import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/screens/dynamic_jour_steps/dynamicSteps/dynamicSteps.dart';
import 'package:mobile_onboarding/screens/products/components/stack_containers.dart';

class StepsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String imgPath = "assets/images/noor_card_banner.png";
    if (productType == 0) {
      imgPath = "assets/images/noor_card_banner.png";
    } else if (productType == 2) {
      imgPath = "assets/images/auto_car.jpg";
    } else if (productType == 3) {
      imgPath = "assets/images/home_loan.png";
    } else if (productType == 4) {
      imgPath = "assets/images/acount_opening.jpg";
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                image: DecorationImage(
                  image: AssetImage(imgPath),
                )),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(flex: 2, child: dynamicStepsList())
      ],
    );
  }
}
