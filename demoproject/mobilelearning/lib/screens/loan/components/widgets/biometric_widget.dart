import 'package:flutter/material.dart';

class BiometricVerificationWidget extends StatefulWidget {
  final Future<void> Function(BuildContext) fingerBiometric;

  const BiometricVerificationWidget({
    Key? key,
    required this.fingerBiometric,
  }) : super(key: key);

  @override
  _BiometricVerificationWidgetState createState() =>
      _BiometricVerificationWidgetState();
}

class _BiometricVerificationWidgetState
    extends State<BiometricVerificationWidget>
    with SingleTickerProviderStateMixin {
  bool isVerifying = true;
  bool verificationSuccess = false;

  @override
  void initState() {
    super.initState();
    _startBiometricVerification();
  }

  Future<void> _startBiometricVerification() async {
    try {
      await widget.fingerBiometric(context);
      setState(() {
        verificationSuccess = true;
        isVerifying = false;
      });
    } catch (e) {
      setState(() {
        verificationSuccess = false;
        isVerifying = false;
      });
      _showFailureDialog();
    }
  }

  void _showFailureDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            const Icon(Icons.close, color: Colors.red, size: 50),
            const SizedBox(height: 10),
            const Text(
              'Biometric Verification Failed',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Please try again.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startBiometricVerification();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              isVerifying
                  ? const CircularProgressIndicator()
                  : verificationSuccess
                      ? const Icon(Icons.check_circle,
                          color: Colors.green, size: 60)
                      : const Icon(Icons.fingerprint,
                          color: Colors.blue, size: 60),
              const SizedBox(height: 20),
              Text(
                isVerifying
                    ? 'Verifying Biometric...'
                    : verificationSuccess
                        ? 'Biometric Verified Successfully'
                        : 'Verification Failed',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
