import 'package:flutter/material.dart';

import '../../constants.dart';
import '../contact_us/components/body.dart';

class ContactScreen extends StatelessWidget {
  static String routeName = "/contact_us";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, "Contact US"),
      body: Body(),
    );
  }
}
