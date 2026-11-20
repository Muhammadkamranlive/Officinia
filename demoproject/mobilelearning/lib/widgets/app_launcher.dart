import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:installed_apps/installed_apps.dart';
class AppLauncher extends StatelessWidget {
    final String bankingAppPackageName = 'com.SindhBank.MobileBanking'; // Replace with your banking app package name
  final String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.SindhBank.MobileBanking&hl=en'; // Play Store link
    Future<void> _checkAndLaunchApp() async {
    bool? isAppInstalled = await InstalledApps.isAppInstalled(bankingAppPackageName);

    if (isAppInstalled ?? false) {
      // If the app is installed, launch it
      InstalledApps.startApp(bankingAppPackageName);
    } else {
      // If the app is not installed, launch the Play Store or prompt installation
      _launchPlayStore();
    }
  }

  Future<void> _launchPlayStore() async {
    final Uri playStoreUri = Uri.parse(playStoreUrl);
    if (await canLaunchUrl(playStoreUri)) {
      await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $playStoreUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: TextButton(
       onPressed: _checkAndLaunchApp,
      child: const Center(
        child: Text(
          "Open Mobile Banking",
          textAlign: TextAlign.center,
          style: TextStyle(decoration: TextDecoration.underline,color: Colors.white),
        ),
      ),
    ));
  }
  

}