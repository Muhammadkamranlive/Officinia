// ignore: file_names
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/RoleSelectionProvider.dart';
import 'package:client/Server/Enums/UserRole.dart';
import 'package:client/Server/Services/AuthService.dart';
import 'package:client/widgets/CustomTextField.dart';
import 'package:client/widgets/SocialLoginButton.dart';
import 'package:client/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';
import '../../l10n/app_localizations.dart';

class EmailAuth extends StatefulWidget {
  const EmailAuth({super.key});

  @override
  State<EmailAuth> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<EmailAuth> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  late UserRole selectedRole;

  @override
  void initState() {
    super.initState();
    selectedRole = context.read<RoleSelectionProvider>().role!;
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$", // stricter email regex
    );
    return emailRegex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    // At least 6 characters, 1 uppercase, 1 lowercase, 1 number
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$');
    return passwordRegex.hasMatch(password);
  }

  Future<void> _signup() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    final l10n = AppLocalizations.of(context)!;
    // ✅ Email validation
    if (email.isEmpty) {
      showCustomToast(l10n.email_required, context);
      return;
    }
    if (!isValidEmail(email)) {
      showCustomToast(l10n.valid_email_error, context);
      return;
    }

    // ✅ Password validation
    if (password.isEmpty) {
      showCustomToast(l10n.password_required, context);
      return;
    }
    if (!isValidPassword(password)) {
      showCustomToast(l10n.password_format_error, context);
      return;
    }

    // ✅ Confirm password check
    if (confirmPassword.isEmpty) {
      showCustomToast(l10n.confirm_password_required, context);
      return;
    }
    if (password != confirmPassword) {
      showCustomToast(l10n.passwords_dont_match, context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        name: 'Email Based User',
        email: email.toLowerCase(),
        phone: '3434343332322',
        password: password,
        role: selectedRole,
        context: context,
      );

      showCustomToast(l10n.signup_successful, context);
      Navigator.pushNamed(context, AppRoutes.login);
    } catch (e) {
      showCustomToast(e.toString(), context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;

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
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: size.width / 1.1,
              height: size.height / 1.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.greenCeladon.withOpacity(0.09),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.02,
              ),
              child: SizedBox(
                height: size.height,
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * 0.2),

                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          l10n.welcome_to_ophicina,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: size.width * 0.1,
                              fontWeight: FontWeight.bold,
                              color: AppColors.greenCeladon,
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),
                      Text(
                        l10n.tagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: size.height * 0.05),

                      // Email
                      customTextField(
                        l10n.email_label,
                        _emailController,
                        TextInputType.emailAddress,
                      ),
                      SizedBox(height: size.height * 0.02),

                      // Password
                      customTextField(
                        l10n.password_label,
                        _passwordController,
                        TextInputType.text,
                        isPassword: true,
                      ),
                      SizedBox(height: size.height * 0.02),

                      // Confirm Password
                      customTextField(
                        l10n.confirm_password_label,
                        _confirmPasswordController,
                        TextInputType.visiblePassword,
                        isPassword: true,
                      ),
                      SizedBox(height: size.height * 0.04),

                      // Sign Up Button
                      customButton(
                        text: l10n.sign_up,
                        onPressed: _isLoading ? null : _signup,
                        size: size,
                        isLoading: _isLoading,
                      ),
                      SizedBox(height: size.height * 0.03),

                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                        child: Text(
                          l10n.already_have_account,
                          style: TextStyle(
                            fontSize: 16,
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
}
