

// ignore: file_names
import 'package:client/AdminPannel/AdminAccountScreen.dart';
import 'package:client/AdminPannel/BlockedScreen.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/JobSeekerDashboard/JobSeekerAccount/JobSeekerAccountScreen.dart';
import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
import 'package:client/Server/Enums/AdminEnum.dart';
import 'package:client/Server/Enums/JobSeekerEnum.dart';
import 'package:client/Server/Enums/Recruiterenum.dart';
import 'package:client/Server/Enums/UserRole.dart';
import 'package:client/Server/Model/AppUser.dart';
import 'package:client/Server/Repo/AdminRepo.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/Server/Services/AuthService.dart';
import 'package:client/Server/Services/FcmTokenService.dart';
import 'package:client/Server/Services/NotificationService.dart';
import 'package:client/routes/app_routes.dart';
import 'package:client/widgets/CustomTextField.dart';
import 'package:client/widgets/SocialLoginButton.dart';
import 'package:client/widgets/custom_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';

class EmailLogin extends StatefulWidget {
  const EmailLogin({super.key});

  @override
  State<EmailLogin> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLogin> {
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  final AuthService         _authService   = AuthService();
  final RecruiterRepository _RecruiterRepo = RecruiterRepository();
  final JobSeekerRepository _jobSeekerRepo = JobSeekerRepository();

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    return emailRegex.hasMatch(email);
  }

  void _login() async {
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final l10n     = AppLocalizations.of(context)!;

    if (email.isEmpty || !isValidEmail(email)) {
      showCustomToast(l10n.enter_valid_email, context);
      return;
    }
    if (password.isEmpty) {
      showCustomToast(l10n.enter_password, context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.signIn(
          email: email, password: password, context: context);

      if (user == null) return;

      context.read<AuthProvider>().setUser(user);
      if (!kIsWeb) await FcmTokenService.init(user.userId);
      NotificationService.listenToUserNotifications(user.userId);

      // ✅ Login Notification
      final time = "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";
      await NotificationService.sendToUser(
        targetUserId: user.userId,
        type: 'login',
        title: l10n.notif_login_title,
        description: l10n.notif_login_desc(time),
      );

      await _navigateBasedOnRole(user);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateBasedOnRole(AppUser user) async {
    final l10n = AppLocalizations.of(context)!;
    switch (user.role) {
      case UserRole.admin:
        AdminRepository _AdminRepo = AdminRepository();
        final profile = await _AdminRepo.getByUid(user.userId);
        if (profile == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AdminAccountScreen(mode: AdminFormMode.create),
            ),
          );
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.adminDash);
        }
        break;

      case UserRole.recruiter:
        if (user.isBlocked) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => BlockedScreen(user: user)),
          );
        }
        if (user.isDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.del_account_dialog_msg),
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        } else {
          final profile = await _RecruiterRepo.getByUid(user.userId);
          if (profile == null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const RecruiterAccountScreen(
                    mode: AccountFormMode.create),
              ),
            );
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
          }
        }
        break;

      case UserRole.jobSeeker:
        if (user.isBlocked) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => BlockedScreen(user: user)),
          );
        }
        if (user.isDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.del_account_dialog_msg),
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        } else {
          final profile = await _jobSeekerRepo.getByUid(user.userId);
          if (profile == null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const JobSeekerAccountScreen(
                  mode: JobSeekerFormMode.create,
                ),
              ),
            );
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.jobSeekerDash);
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;

    // ✅ Web only: cap at 480. Mobile: full size.width, no change.
    final double maxWidth =
        kIsWeb ? (size.width > 600 ? 480.0 : size.width) : size.width;

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
          // Top circle background — completely unchanged
          Positioned(
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
          ),

          // ✅ Center the card on web, full width on mobile
          SafeArea(
            top: false,
            child: Center(
              child: SizedBox(
                width: maxWidth, // mobile: == size.width, no visual change
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      // ✅ Mobile: original 6% padding. Web: fixed 24px feels better.
                      horizontal: kIsWeb ? 24.0 : size.width * 0.06,
                      vertical: 24.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: size.height * 0.06),
                        // Title
                        Text(
                          l10n.login_title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: kIsWeb
                                ? (maxWidth * 0.1).clamp(28.0, 42.0)
                                : size.width * 0.1,
                            fontWeight: FontWeight.bold,
                            color: AppColors.green,
                          ),
                        ),

                        SizedBox(height: size.height * 0.015),

                        // Subtitle
                        Text(
                          l10n.login_subtitle_email,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: kIsWeb
                                ? (maxWidth * 0.04).clamp(13.0, 16.0)
                                : size.width * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),

                        SizedBox(height: size.height * 0.03),

                        // Email Input — unchanged
                        customTextField(
                          l10n.email_label,
                          _emailController,
                          TextInputType.emailAddress,
                        ),

                        SizedBox(height: size.height * 0.02),

                        // Password Input — unchanged
                        customTextField(
                          l10n.password_label,
                          _passwordController,
                          TextInputType.text,
                          isPassword: true,
                        ),

                        // Forgot password — unchanged
                        const ForgetText(),

                        SizedBox(height: size.height * 0.01),

                        // Login Button
                        customButtonAsync(
                          text: l10n.sign_in_button,
                          onPressed: _login,
                          size: kIsWeb
                              ? Size(maxWidth, size.height) // ✅ web: use capped width
                              : size,                       // ✅ mobile: original size
                          isLoading: _isLoading,
                        ),

                        SizedBox(height: size.height * 0.02),

                        // Create new account — unchanged
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.selectRole);
                          },
                          child: Text(
                            l10n.create_account,
                            style: const TextStyle(
                              color: AppColors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.04),
                      ],
                    ),
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

// — unchanged widgets below —

class ForgetText extends StatelessWidget {
  const ForgetText({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.forgotPassword);
        },
        child:  Text(
          l10n.forgotPassword,
          style: TextStyle(color: AppColors.green),
        ),
      ),
    );
  }
}

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key, required this.size});
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Text(
      "Welcome Back!\nSecure & Simple Login",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: size.width * 0.05,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class LoginText extends StatelessWidget {
  const LoginText({super.key, required this.size});
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Text(
      "Login here",
      style: TextStyle(
        fontSize: size.width * 0.1,
        fontWeight: FontWeight.bold,
        color: AppColors.greenCeladon,
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