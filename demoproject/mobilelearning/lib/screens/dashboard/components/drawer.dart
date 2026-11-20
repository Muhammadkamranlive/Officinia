import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_onboarding/utilities/securedData/secureDataHandler.dart';
import 'package:mobile_onboarding/widgets/circularAvatar/circularAvatar.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart';
import '../../../constants.dart';
import '../../../utilities/notification_handler/in_app_notification.dart';
import '../../profile/components/profile_menu.dart';
import '../../profile/components/profile_switch_menu.dart';
import '../../welcome/welcome_screen.dart';

class CustomDrawer extends StatefulWidget {
  CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? _phoneNumber;
  Future<String> getPhoneNumber() async {
    try {
      String? phoneNumber = await UserSecretStore.getSignNumber();
      if (phoneNumber != null) {
        setState(() {
          _phoneNumber = phoneNumber;
        });
        print(phoneNumber);
        return phoneNumber;
      } else {
        return 'name';
      }
    } catch (e) {
      print('Exception in getPhoneNumber(): $e');
      return 'name'; // Return a default value in case of an exception
    }
  }

  final NotificationService _notificationService = NotificationService();

  Future<void> _launchInBrowserView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  void initState() {
    getPhoneNumber();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Uri toLaunchContact = Uri(
        scheme: 'https', host: 'www.faysalbank.com', path: 'en/contact-us/');

    final Uri toLaunchPrivacy = Uri(
        scheme: 'https',
        host: 'www.faysalbank.com',
        path: 'en/privacy-statement/');

    final Uri toLaunchTerms = Uri(
        scheme: 'https',
        host: 'www.faysalbank.com',
        path: 'en/islamic/schedule-of-charges-islamic');

    Future<void>? _launched;

    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: kPrimaryGradientColor,
            ),
            child: Row(
              children: [
                ProfileAvatar(),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  '${_phoneNumber}',
                  // getPhoneNumber(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          ProfileSwitchMenu(
            text: "Biometric Login",
            icon: "assets/icons/ic_fingerprint.svg",
            press: () {},
          ),
          ProfileMenu(
            text: "Privacy & Policy",
            icon: "assets/icons/Bell.svg",
            press: () {
              _launched = _launchInBrowserView(toLaunchPrivacy);
            },
          ),
          ProfileMenu(
            text: "Terms & Conditions",
            icon: "assets/icons/check_mark_rounded.svg",
            press: () {
              _launched = _launchInBrowserView(toLaunchTerms);
            },
          ),
          ProfileMenu(
            text: "Help Center",
            icon: "assets/icons/question_mark.svg",
            press: () {
              _launched = _launchInBrowserView(toLaunchContact);
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.settings),
          //   title: const Text('Settings'),
          //   onTap: () {
          //     // Handle the tap here
          //     Navigator.pop(context);
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.help),
          //   title: const Text('Help'),
          //   onTap: () {
          //     // Handle the tap here
          //     Navigator.pop(context);
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.contact_phone),
          //   title: const Text('Contact'),
          //   onTap: () {
          //     // Handle the tap here
          //     Navigator.pop(context);
          //   },
          // ),
          const Spacer(), // This will push the following widgets to the bottom
          const Divider(),
          ListTile(
            leading: SvgPicture.asset(
              "assets/icons/Log out.svg",
              color: kPrimaryColor,
              width: 22,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(color: kPrimaryLightColor),
            ),
            onTap: () {
              // Handle the tap here
              Navigator.pushNamedAndRemoveUntil(context,
                  WelcomeScreen.routeName, (Route<dynamic> route) => false);

              _notificationService.showCustomNotification(
                  'Successfully Signed-out',
                  'you have successfully signed out');
            },
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
