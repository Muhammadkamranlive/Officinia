import 'package:flutter/material.dart';

import '../../constants.dart';
import '../loan/components/body.dart';

class LoanRequestScreen extends StatelessWidget {
  static String routeName = "/loan_request";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, "Loan Request"),
      body: Body(),
    );
  }
}
