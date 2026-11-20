import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_onboarding/utilities/api_services/tokenEnc/tokenClass.dart';
import 'package:mobile_onboarding/utilities/securedData/secureDataHandler.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _storage = FlutterSecureStorage(); // const, no await

Future<Map<String, String>> getGenericHeaders() async {
  final token = await TokenStorage.getValid();
  final username = await UserSecretStore.getCnic();

  debugPrint('username from secure storage: $username');

  final headers = <String, String>{
    'accept': 'text/plain',
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    if (username != null && username.isNotEmpty) 'Username': username,
  };

  return headers;
}

Future<void> showInvalidTokenDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false, // User must tap "Exit" to dismiss.
    builder: (ctx) => AlertDialog(
      title: const Text("Invalid Token"),
      content: const Text("Your token is invalid. The app will now exit."),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(ctx); // Close the dialog.
            SystemNavigator.pop(); // Exit the app.
          },
          child: const Text("Exit"),
        ),
      ],
    ),
  );
}
