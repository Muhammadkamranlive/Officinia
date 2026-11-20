import 'package:flutter/material.dart';
import '../constants.dart';
import '../screens/products/products_screen.dart';

class NewApplication extends StatelessWidget {
  const NewApplication({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, ProductsScreen.routeName),
          child: const Text(
            "More Products",
            style: TextStyle(
              fontSize: 18,
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: kPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
