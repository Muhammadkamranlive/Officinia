import 'package:flutter/material.dart';
import 'package:mobile_onboarding/screens/productdetails/components/product_detail_form.dart';
import 'package:mobile_onboarding/utilities/internet_checker/connectivity_checker.dart';

class Body extends StatelessWidget {
  Body(this.itemDetails, {super.key});

  List<dynamic> itemDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConnectivityBanner(),
          Expanded(
            child: ProductDetailForm(itemDetails),
          ),
        ],
      ),
    );
  }
}
