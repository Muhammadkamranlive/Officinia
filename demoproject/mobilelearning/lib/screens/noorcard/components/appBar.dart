import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/font_styles_roboto.dart';

class CustomAppBarwithHeadingIcon extends StatelessWidget
    implements PreferredSizeWidget {
  final String? appBarHeading;
  final IconData? appBarIcon;
  final VoidCallback? onBackButtonPressed; // Optional function for back button

  CustomAppBarwithHeadingIcon({
    this.appBarHeading,
    this.appBarIcon,
    this.onBackButtonPressed, // Accepting the function
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      backgroundColor: ScaffoldBackground,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(FontAwesomeIcons.chevronLeft,
                size: 18.0.sp, color: Colors.grey),
            onPressed: () {
              // Call the provided function if it exists, otherwise pop the navigation stack
              if (onBackButtonPressed != null) {
                onBackButtonPressed!();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          Text(
            appBarHeading ?? '', // Use an empty string if appBarHeading is null
            style: AppTextStyles.robotoMedium18AppbarHeading,
          ),
          Spacer(),
          // IconButton(
          //   icon: Icon(
          //     appBarIcon,
          //     color: newSecondaryColor,
          //     size: 20,
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
