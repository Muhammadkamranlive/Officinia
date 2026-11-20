import 'package:flutter/material.dart';
import 'package:mobile_onboarding/widgets/custom_app_bar.dart';

import '../products/components/body.dart';

class ProductsScreen extends StatelessWidget {
  static String routeName = "/products";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(true, false),
      body: Body(),
    );
  }
}
