import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/security/secure_env.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';
import 'package:mobile_onboarding/utilities/api_services/tokenEnc/tokenClass.dart';
import 'package:mobile_onboarding/utilities/dialog_boxes/dialog_class.dart';
import 'package:mobile_onboarding/utilities/securedData/secureDataHandler.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';

Future<bool> getTokenAndCache(String userId, BuildContext context) async {
  final url = '${getApiBaseUrl()}/Auth/GetAuthenticatedToken';
  try {
    final client = await createHttpClientWithPinnedCert();

    final apiUser = SecureDotEnv.get('API_USER') ?? '';
    final passPhrase = SecureDotEnv.get('API_PASSPHRASE') ?? '';

    final request = http.Request('POST', Uri.parse(url))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        "apiUser": apiUser,
        "passPhrase": passPhrase,
      });

    ReusableDialogs.showProgressDialog(context);

    final response = await client.send(request);
    Navigator.pop(context);

    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseString) as Map<String, dynamic>;

      final token = jsonResponse['access_token'];
      if (token is String && token.isNotEmpty) {
        await TokenStorage.cache(token, const Duration(seconds: 9000));
        debugPrint('Token cached securely');
        return true; // success
      }
    }

    await _showError(context, 'Services are not working, try again');
    return false; // failure
  } catch (e) {
    await _showError(context, 'Services are not working, Please try again');
    return false; // failure
  }
}

Future<void> _showError(BuildContext context, String msg) async {
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Error'),
      content: Text(msg),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Future<void> showInvalidTokenDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Invalid Token'),
      content: const Text(
          'Your token is invalid or expired. The app will now exit.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            SystemNavigator.pop();
          },
          child: const Text('Exit'),
        ),
      ],
    ),
  );
}

Future<void> getAuthTokenAndCache(BuildContext context) async {
  final url = '${getApiBaseUrl()}/Auth/GetToken';

  try {
    final header = getGenericHeaders();
    final client = await createHttpClientWithPinnedCert();

    // final apiUser = dotenv.env['API_USER'] ?? '';
    final apiUser = await UserSecretStore.getSignNumber();
    final passPhrase = await TokenStorage.getValid();

    final request = http.Request('POST', Uri.parse(url))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        "apiUser": apiUser,
        "passPhrase": passPhrase,
      });

    ReusableDialogs.showProgressDialog(context);
    final response = await client.send(request);
    Navigator.pop(context);

    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      final Map<String, dynamic> jsonResponse = jsonDecode(responseString);

      final token = jsonResponse['access_token'];
      final expiresIn = jsonResponse['expires_in'] ?? 0;

      if (token is String && token.isNotEmpty) {
        await TokenStorage.cache(token, Duration(seconds: 9000));
        debugPrint('🔐 Token cached securely');
      } else {
        await _showError(context, 'Services are not working, try again');
      }
    } else {
      await _showError(context, 'Services are not working, Please try again.');
    }
  } catch (e) {
    await _showError(context, 'Services are not working, Please try again');
  }
}






// old one
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobile_onboarding/constants.dart';
// import 'package:mobile_onboarding/utilities/api_services/tokenEnc/tokenClass.dart';
// import 'package:mobile_onboarding/utilities/dialog_boxes/dialog_class.dart';
// import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';

// Future<void> getTokenAndCache(String userId, BuildContext context) async {
//   final url = '${getApiBaseUrl()}/Auth/GetToken?UserId=$userId&authenticated=';
// // ${getApiBaseUrl()}/Auth/GetAuthenticatedToken';
//   try {
//     final client = await createHttpClientWithPinnedCert();
//     final request = http.Request('GET', Uri.parse(url));

//     ReusableDialogs.showProgressDialog(context);
//     final response = await client.send(request);
//     Navigator.pop(context);

//     if (response.statusCode == 200) {
//       final responseString = await response.stream.bytesToString();
//       final Map<String, dynamic> jsonResponse = jsonDecode(responseString);
//       final token = jsonResponse['access_token'];
//       final expiresIn = jsonResponse['expires_in'] ?? 0;

//       if (token is String && token.isNotEmpty) {
//         // 🔐  Store token securely
//         await TokenStorage.cache(token, Duration(seconds: 9000));
//         debugPrint('🔐 Token cached securely');
//       } else {
//         await _showError(context, 'Services are not working, try again');
//       }
//     } else {
//       await _showError(context, 'Services are not working, Please try again.');
//     }
//   } catch (e) {
//     await _showError(context, 'Services are not working, Please try again');
//   }
// }

// // Centralised error dialog helper ------------------------------------------------
// Future<void> _showError(BuildContext context, String msg) async {
//   await showDialog(
//     context: context,
//     builder: (ctx) => AlertDialog(
//       title: const Text('Error'),
//       content: Text(msg),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(ctx),
//           child: const Text('OK'),
//         ),
//       ],
//     ),
//   );
// }

// Future<void> showInvalidTokenDialog(BuildContext context) async {
//   await showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (ctx) => AlertDialog(
//       title: const Text('Invalid Token'),
//       content: const Text(
//           'Your token is invalid or expired. The app will now exit.'),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.pop(ctx);
//             SystemNavigator.pop();
//           },
//           child: const Text('Exit'),
//         ),
//       ],
//     ),
//   );
// }
