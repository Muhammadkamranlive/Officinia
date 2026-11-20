import 'package:flutter/material.dart';

class BlankScreen extends StatelessWidget {
  static const String routeName = '/blank';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/images/faisal_bank_banner.png'),
      ),
    );
  }
}
