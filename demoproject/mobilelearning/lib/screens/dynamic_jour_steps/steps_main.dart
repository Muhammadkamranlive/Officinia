import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/screens/dynamic_jour_steps/StepsScreen.dart';
import 'package:mobile_onboarding/screens/product_list/components/body.dart';
import 'package:mobile_onboarding/screens/products/products_screen.dart';
import 'package:mobile_onboarding/widgets/custom_app_bar.dart';

void main() {
  runApp(MyApp2());
}

class MyApp2 extends StatelessWidget {
  const MyApp2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProductsScreenMain(),
    );
  }
}

class ProductsScreenMain extends StatelessWidget {
  const ProductsScreenMain({super.key});
  static String routeName = "/dynamicSteps";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(true, false),
      body: StepsScreen(),
    );
  }
}
