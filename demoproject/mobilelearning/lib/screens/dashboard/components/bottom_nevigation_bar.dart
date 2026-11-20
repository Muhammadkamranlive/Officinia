import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:mobile_onboarding/screens/newSingINScreen/newSingINMain.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants.dart';
import '../../../utilities/notification_handler/in_app_notification.dart';
import '../../products/products_screen.dart';

const List<TabItem> items = [
  TabItem(
    icon: Icons.question_answer_outlined,
    title: 'FAQ\'s',
  ),
  TabItem(
    icon: Icons.policy,
    title: 'Policy',
  ),
  TabItem(
    icon: Icons.home,
    title: 'Home',
  ),
  TabItem(
    icon: Icons.production_quantity_limits_rounded,
    title: 'Products',
  ),
  TabItem(
    icon: Icons.logout,
    title: 'Logout',
  ),
];

class CustomBottomBar extends StatefulWidget {
  CustomBottomBar({super.key});

  final NotificationService _notificationService = NotificationService();

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  int visit = 2;
  double height = 30;
  Color colorSelect = kPrimaryLightColor;
  Color color = kPrimaryLightColor;
  Color color2 = kPrimaryColor;
  Color bgColor = Colors.white;
  void _handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushNamedAndRemoveUntil(
      context,
      NewSignInScreen.routeName,
      (Route<dynamic> route) => false,
    );

    widget._notificationService.showCustomNotification(
      'Successfully Signed-out',
      'You have successfully signed out',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomBarDivider(
      items: items,
      backgroundColor: bgColor,
      color: color,
      colorSelected: colorSelect,
      indexSelected: visit,
      styleDivider: StyleDivider.top,
      bottom: MediaQuery.of(context).size.height * 0.02,
      onTap: (int index) {
        setState(() {
          visit = index;
          print("Card tapped! $visit");
        });

        // Handle navigation and asynchronous tasks outside setState
        if (index == 0) {
          // Handle index 0
        } else if (index == 1) {
          // Handle index 1
        } else if (index == 2) {
          // Handle index 2
        } else if (index == 3) {
          Navigator.pushNamed(context, ProductsScreen.routeName);
        } else if (index == 4) {
          _handleLogout();
        }
      },
    );
  }
}
