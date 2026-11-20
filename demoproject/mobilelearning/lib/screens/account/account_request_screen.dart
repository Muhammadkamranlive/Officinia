import 'package:flutter/material.dart';

import '../../constants.dart';
import '../account/components/body.dart';

class AccountScreen extends StatelessWidget {
  static String routeName = "/account";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, "Account Request"),
      body: Body(),
    );
  }
}
