// lib/screens/device_blocked_screen.dart

import 'package:flutter/material.dart';

class DeviceBlockedScreen extends StatelessWidget {
  const DeviceBlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand, // Makes the background image fill the screen
          children: [
            // Background Image
            Image(
              image: AssetImage(
                  'assets/images/appRestriction.png'), // path to your image
              fit: BoxFit.fill, // make sure it covers the whole screen
            ),

            // Main Content
            // Center(
            //   child: Padding(
            //     padding: EdgeInsets.all(24.0),
            //     child: Column(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         Icon(Icons.warning_rounded, size: 80, color: Colors.red),
            //         SizedBox(height: 24),
            //         Text(
            //           'For security reasons, this app cannot run on rooted, jailbroken, or emulated devices.',
            //           textAlign: TextAlign.center,
            //           style: TextStyle(
            //               fontSize: 16,
            //               color:
            //                   Colors.white), // white text for better visibility
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
