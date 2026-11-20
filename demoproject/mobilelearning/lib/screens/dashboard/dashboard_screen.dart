import 'package:flutter/material.dart';
import '../dashboard/components/body.dart';
import 'components/bottom_nevigation_bar.dart';
import 'components/drawer.dart';

class DashboardScreen extends StatelessWidget {
  static String routeName = "/dashboard";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      drawer: CustomDrawer(),
      //appBar: CustomAppBar(true, false),
      body: const Body(),
      bottomNavigationBar: CustomBottomBar(),
    );
  }
}
