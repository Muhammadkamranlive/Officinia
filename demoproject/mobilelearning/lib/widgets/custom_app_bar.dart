import 'package:flutter/material.dart';

import '../constants.dart';
import '../screens/profile/profile_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar(this.isBackVisible, this.isProfileVisible, {Key? key})
      : super(key: key);
  bool isBackVisible = true;
  bool isProfileVisible = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: AppBar(
        automaticallyImplyLeading: isBackVisible,
        title: Image.asset(
          'assets/images/faisal_bank_banner.png',
          width: 160,
        ),
        centerTitle: true,
        // Any other AppBar configurations you need
        actions: isProfileVisible
            ? <Widget>[
                IconButton(
                    icon: const Icon(Icons.settings, color: kPrimaryColor),
                    onPressed: () {
                      Navigator.pushNamed(context, ProfileScreen.routeName);
                    }),
              ]
            : [],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
