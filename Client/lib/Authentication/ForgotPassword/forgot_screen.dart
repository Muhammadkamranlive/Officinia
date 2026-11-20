import 'package:client/AppColors/AppColors.dart';
import 'package:client/Server/Services/AuthService.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:client/routes/app_routes.dart';
import 'package:client/widgets/custom_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  final bool _isLoading = false;

  Future<void> _sendPasswordResetEmail() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      showCustomToast(AppLocalizations.of(context)!.emailRequired, context);
      return;
    }

    try {
      await _authService.resetPassword(email);
      showCustomToast(AppLocalizations.of(context)!.resetLinkSent, context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showCustomToast(AppLocalizations.of(context)!.noAccountFound, context);
      } else {
        showCustomToast(AppLocalizations.of(context)!.errorPrefix + " ${e.message}", context);
      }
    }

  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
       backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Shape
          TopCircle(size: size),
          // Main Content
          // Main Content
          SizedBox(
            height: size.height,
            child: Center(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.06,
                    vertical: size.height * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * 0.1),
                
                      // Title
                      Text(
                        AppLocalizations.of(context)!.forgotPasswordTitle,
                        style: TextStyle(
                          fontSize: size.width * 0.1,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                
                      // Subtitle
                      Text(
                        AppLocalizations.of(context)!.forgotPasswordSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.height * 0.02,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: size.height * 0.04),
                
                      // Email Input Field
                      _customTextField(
                        AppLocalizations.of(context)!.emailLabel,
                        _emailController,
                        TextInputType.emailAddress,
                      ),
                      SizedBox(height: size.height * 0.04),
                
                      // Reset Password Button
                      _customButton(
                        text: AppLocalizations.of(context)!.resetPasswordButton,
                        onPressed: _isLoading ? null : _sendPasswordResetEmail,
                        size: size,
                      ),
                      SizedBox(height: size.height * 0.02),
                
                      // Back to Login
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                        child: Text(
                          AppLocalizations.of(context)!.backToLogin,
                          style: TextStyle(
                            fontSize: size.height * 0.02,
                            fontWeight: FontWeight.w500,
                          
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom TextField Widget
  Widget _customTextField(
    String label,
    TextEditingController controller,
    TextInputType inputType, {
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [AppColors.greenCeladon,AppColors.greenCeladon],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(2), // border thickness
      child: Container(
        decoration: BoxDecoration(
          color:
              Colors.white, // keep inner field white for clear input visibility
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          keyboardType: inputType,
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
          ),
          cursorColor: AppColors.green,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  // Custom Button Widget
  Widget _customButton({
    required String text,
    required Future<void> Function()? onPressed,
    required Size size,
  }) {
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.07,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradientgreen,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // important
            shadowColor: Colors.transparent, // remove default shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.w600, // SemiBold = premium
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }

}



class TopCircle extends StatelessWidget {
  const TopCircle({super.key, required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -100,
      left: -50,
      child: Container(
        width: size.width / 1.1,
        height: size.height / 1.8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.green.withOpacity(0.03),
        ),
      ),
    );
  }
}
