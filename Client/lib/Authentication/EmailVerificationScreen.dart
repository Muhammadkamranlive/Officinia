import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:client/AppColors/AppColors.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isLoading = false;

  Future<void> _checkVerification() async {
    setState(() => _isLoading = true);

    await FirebaseAuth.instance.currentUser!.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      Navigator.pop(context); // go back to login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email not verified yet.")),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _resendEmail() async {
    await FirebaseAuth.instance.currentUser!.sendEmailVerification();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Verification email sent again.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mark_email_unread,
                  size: 80, color: AppColors.green),

              const SizedBox(height: 20),

              Text(
                "Verify Your Email",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                "We have sent a verification link to:\n${widget.email}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _isLoading ? null : _checkVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("I Have Verified"),
              ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: _resendEmail,
                child: const Text("Resend Email"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}