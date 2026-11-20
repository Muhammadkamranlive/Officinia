import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';
import '../../../helper/PreferenceUtils.dart';

class ProfileSwitchMenu extends StatefulWidget {
  const ProfileSwitchMenu({
    Key? key,
    required this.text,
    required this.icon,
    this.press,
  }) : super(key: key);

  final String text, icon;
  final VoidCallback? press;

  @override
  State<ProfileSwitchMenu> createState() {
    return _ProfileSwitchMenuState();
  }
}

class _ProfileSwitchMenuState extends State<ProfileSwitchMenu> {
  bool on = false;

  void checkBiometricSettings() {
    on = PreferenceUtils.getBool(biometricLogin);
    if (kDebugMode) {
      print("Biometric Enables : ${on}");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkBiometricSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: kPrimaryLightColor,
          padding: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: const Color(0xFFF5F6F9),
        ),
        onPressed: widget.press,
        child: Row(
          children: [
            SvgPicture.asset(
              widget.icon,
              color: kPrimaryColor,
              width: 22,
            ),
            const SizedBox(width: 20),
            Expanded(child: Text(widget.text)),
            CupertinoSwitch(
              activeColor: kPrimaryColor,
              thumbColor: on ? kPrimaryLightColor : kPrimaryColor,
              //trackColor: kPrimaryLightColor,
              value: on,
              onChanged: (value) => setState(() {
                on = !on;
                PreferenceUtils.setBool(biometricLogin, on);
              }),
            ),
            // AnimatedToggle(
            //   values: const ['Enable', 'Disable'],
            //   onToggleCallback: (value) {
            //     //_toggleValue = value;
            //   },
            //   buttonColor: const Color(0xFF0A3157),
            //   backgroundColor: const Color(0xFFB5C1CC),
            //   textColor: const Color(0xFFFFFFFF),
            // ),
          ],
        ),
      ),
    );
  }
}
