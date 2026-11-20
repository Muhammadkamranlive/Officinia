import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double screenFieldSize5;
  static late double screenFieldSize10;
  static late double screenFieldSize15;
  static late double screenFieldSize20;
  static late double screenFieldSize25;
  static late double screenFieldSize30;
  static late double screenFieldSize35;
  static late double screenFieldSize40;

  static double? defaultSize;
  static Orientation? orientation;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    screenFieldSize5 = 5.0;
    screenFieldSize10 = 10.0;
    screenFieldSize15 = 15.0;
    screenFieldSize20 = 20.0;
    screenFieldSize25 = 25.0;
    screenFieldSize30 = 30.0;
    screenFieldSize35 = 35.0;
    screenFieldSize40 = 40.0;
    orientation = _mediaQueryData.orientation;
  }
}

// Get the proportionate height as per screen size
double getProportionateScreenHeight(double inputHeight) {
  double screenHeight = SizeConfig.screenHeight;
  // 812 is the layout height that designer use
  return (inputHeight / 812.0) * screenHeight;
}

// Get the proportionate height as per screen size
double getProportionateScreenWidth(double inputWidth) {
  double screenWidth = SizeConfig.screenWidth;
  // 375 is the layout width that designer use
  return (inputWidth / 375.0) * screenWidth;
}
