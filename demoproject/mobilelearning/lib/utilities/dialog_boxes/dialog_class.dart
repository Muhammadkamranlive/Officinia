import 'package:flutter/material.dart';
import 'package:mobile_onboarding/screens/newDashboard/alerts_status_screen.dart';
import 'package:mobile_onboarding/screens/newSingUpScreen/newSingupMain.dart';

class ReusableDialogs {
  /// A simple progress dialog with a title and a message.
  static Future<void> showProgressDialog(
    BuildContext context, {
    String title = "Please Wait",
    String message = "Processing...",
    bool barrierDismissible = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible, // Default = false
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(title),
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showProgressDialogproposal(
    BuildContext context, {
    String title = "Please Wait",
    String message = "Processing...",
    bool barrierDismissible = false,
  }) {
    return showDialog(
      barrierColor: Colors.white,
      context: context,
      barrierDismissible: barrierDismissible, // Default = false
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(title),
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        );
      },
    );
  }

  /// A success dialog with a green check icon.
  static Future<void> showSuccessDialog(
    BuildContext context, {
    String title = "Uploaded",
    String message = "Document(s) have been uploaded!",
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 50),
              const SizedBox(height: 10),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showErrorDialogDocuments(
    BuildContext context, {
    String title = "Error",
    String message = "Something went wrong!",
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {},
          child: AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 10),
                Text(message, textAlign: TextAlign.left),
              ],
            ),
            actions: [
              TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigator.of(context).pushAndRemoveUntil(
                    //   MaterialPageRoute(
                    //       builder: (context) => AlertsStatusScreen()),
                    //   ModalRoute.withName(NewSignUpScreen
                    //       .routeName), // or LoginScreen.routeName
                    // );
                    // Navigator.of(context).pushAndRemoveUntil(
                    //   MaterialPageRoute(
                    //       builder: (context) => AlertsStatusScreen()),
                    //   ModalRoute.withName(
                    //       NewSignUpScreen.routeName), // or LoginScreen.routeName
                    // );
                  }),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showErrorDialogSendProposal(
    BuildContext context, {
    String title = "Error",
    String message = "Something went wrong!",
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {},
          child: AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 10),
                Text(message, textAlign: TextAlign.left),
              ],
            ),
            actions: [
              TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    // Navigator.pop(context);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => AlertsStatusScreen()),
                      ModalRoute.withName(NewSignUpScreen
                          .routeName), // or LoginScreen.routeName
                    );
                    // Navigator.of(context).pushAndRemoveUntil(
                    //   MaterialPageRoute(
                    //       builder: (context) => AlertsStatusScreen()),
                    //   ModalRoute.withName(
                    //       NewSignUpScreen.routeName), // or LoginScreen.routeName
                    // );
                  }),
            ],
          ),
        );
      },
    );
  }

  /// An error/failure dialog with a red cross or exclamation.
  static Future<void> showErrorDialog(
    BuildContext context, {
    String title = "Error",
    String message = "Something went wrong!",
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {},
          child: AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 10),
                Text(message, textAlign: TextAlign.left),
              ],
            ),
            actions: [
              TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // // // otp bypass
                    // Navigator.of(context).pushAndRemoveUntil(
                    //   MaterialPageRoute(
                    //       builder: (context) => AlertsStatusScreen()),
                    //   ModalRoute.withName(NewSignUpScreen
                    //       .routeName), // or LoginScreen.routeName
                    // );
                    // Navigator.of(context).pushAndRemoveUntil(
                    //   MaterialPageRoute(
                    //       builder: (context) => AlertsStatusScreen()),
                    //   ModalRoute.withName(
                    //       NewSignUpScreen.routeName), // or LoginScreen.routeName
                    // );
                  }),
            ],
          ),
        );
      },
    );
  }

  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    String title = "Confirmation",
    String message = "Are you sure?",
    String confirmText = "Yes",
    String cancelText = "No",
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Must choose one of the actions
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false; // Null-safety check
  }

  static Future<void> showOtpExceededDialog(
    BuildContext context, {
    String title = "OTP Attempts Exceeded",
    String message =
        "Your OTP attempts have been exceeded. Please retry after a minute.",
    String retryText = "Retry",
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogCtx) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();

                Navigator.of(context).pop();
              },
              child: Text(retryText),
            ),
          ],
        );
      },
    );
  }
}
