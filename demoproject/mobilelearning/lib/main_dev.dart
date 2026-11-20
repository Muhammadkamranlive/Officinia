import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_onboarding/utilities/Nadra_finger_varification/model_SKD.dart';
import 'package:permission_handler/permission_handler.dart';
// TODO: Import your FingerCaptureResponse model
// import 'path/to/finger_capture_response.dart';

const String identyChannel = 'identy';

void main() {
  runApp(const MyDevApp());
}

class MyDevApp extends StatelessWidget {
  const MyDevApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dev Face & Fingerprint Capture',
      home: Builder(
        builder: (ctx) => Scaffold(
          appBar: AppBar(title: const Text('Dev Capture App')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final result = await const MethodChannel(identyChannel)
                          .invokeMethod('face_capture');
                      if (result != null && result.toString().isNotEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Face capture successful'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Face capture failed'),
                          ),
                        );
                      }
                    } on PlatformException catch (e) {
                      _showErrorDialog(
                        ctx,
                        'Camera Access Needed',
                        'Please enable Camera permission in Settings.',
                      );
                    }
                  },
                  child: const Text('Capture Face'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final platform = const MethodChannel(identyChannel);
                    // Request camera permission if needed
                    if (!await Permission.camera.isGranted) {
                      await Permission.camera.request();
                    }
                    try {
                      final result =
                          await platform.invokeMethod('finger_capture');
                      final Map<String, dynamic> fingerMap =
                          jsonDecode(result as String);
                      if (fingerMap.isEmpty) {
                        _showErrorDialog(
                          ctx,
                          'Error',
                          'Biometric Services Currently not Available',
                        );
                        return;
                      }
                      // Parse response into your model
                      final fingerCaptureResponse =
                          FingerCaptureResponse.fromJson(fingerMap);
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Fingerprint capture successful'),
                        ),
                      );
                    } on PlatformException catch (e) {
                      _showErrorDialog(
                        ctx,
                        'Error',
                        e.message ?? 'Unknown error',
                      );
                    }
                  },
                  child: const Text('Capture Fingerprint'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
