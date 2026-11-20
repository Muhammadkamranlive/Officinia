import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_onboarding/screens/profile/components/profile_menu.dart';
import 'package:mobile_onboarding/screens/profile/components/profile_switch_menu.dart';
import 'package:mobile_onboarding/screens/welcome/welcome_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class Body extends StatelessWidget {
  Future<void> _launchInBrowserView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $url');
    }
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

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
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
          ProfileMenu(
            text: "Log Out",
            icon: "assets/icons/Log out.svg",
            press: () {
              Navigator.pushNamedAndRemoveUntil(context,
                  WelcomeScreen.routeName, (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
    );
  }
}
