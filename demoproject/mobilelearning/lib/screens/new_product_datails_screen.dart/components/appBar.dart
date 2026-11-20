import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_onboarding/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      backgroundColor: ScaffoldBackground,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.chevronLeft,
                color: newSecondaryColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            'Noor Card',
            style: circularAppBarheading18,
          ),
          // IconButton(
          //   icon: Icon(
          //     Icons.home,
          //     color: newSecondaryColor,
          //   ),
          //   onPressed: () {
          //     Navigator.of(context)
          //         .pushNamedAndRemoveUntil('/', (route) => false);
          //   },
          // ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
