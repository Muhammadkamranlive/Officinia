import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/screens/noorcard/noor_card_screen.dart';



class StackContainers extends StatelessWidget {
  const StackContainers({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StackContainer(
            containerColor: kTileColorOne,
            text: '01  Noor Cards',
            iconWidget: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, NoorCardScreen.routeName);
                },
                child: const Text(
                  'Start',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.white),
                )),
            heightofContainer: 420),
        StackContainer(
            containerColor: kTileColorTwo,
            text: '02  Personal Finance',
            iconWidget: const Icon(
              Icons.account_balance_outlined,
              color: Colors.white,
            ),
            heightofContainer: 350),
        StackContainer(
            containerColor: kTileColorThree,
            text: '03  Car Finance ',
            iconWidget: const Icon(
              Icons.drive_eta_outlined,
              color: Colors.white,
            ),
            heightofContainer: 280),
        StackContainer(
            containerColor: kTileColorFour,
            text: '04  Housing Finance',
            iconWidget: const Icon(
              Icons.house_outlined,
              color: Colors.white,
            ),
            heightofContainer: 210),
        StackContainer(
            containerColor: kTileColorFive,
            text: '05  Faysal Takmeel',
            iconWidget: const Icon(
              Icons.checklist_rtl_outlined,
              color: Colors.white,
            ),
            heightofContainer: 140),
        StackContainer(
            containerColor: kTileColorSix,
            text: '06  Solar Solution',
            iconWidget: const Icon(
              Icons.solar_power,
              color: Colors.white,
            ),
            heightofContainer: 70),
      ],
    );
  }

  // ignore: non_constant_identifier_names
  Widget StackContainer(
      {required Color containerColor,
      required String text,
      required Widget iconWidget,
      required double heightofContainer}) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        alignment: Alignment.topCenter,
        height: heightofContainer,
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              iconWidget
            ],
          ),
        ),
      ),
    );
  }
}
