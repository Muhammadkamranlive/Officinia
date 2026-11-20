// ignore: file_names
import 'dart:io';

import 'package:client/AdminPannel/AdminAccountScreen.dart';
import 'package:client/AdminPannel/BlockedScreen.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Authentication/EamilLogin/EmailLogin.dart';
import 'package:client/Authentication/Role/SelectRoleScreen.dart';
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
import 'package:client/l10n/app_localizations.dart';
import 'package:client/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Login> {
  bool _isLoading = false;
  bool _googleloginLoading = false;
  bool _appleLoginLoading = false;

  final AuthService _authService = AuthService();
  final RecruiterRepository _RecruiterRepo = RecruiterRepository();

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    return emailRegex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$');
    return passwordRegex.hasMatch(password);
  }

  void _loginGoogle() async {
    setState(() => _googleloginLoading = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final user = await _authService.signInWithGoogleAppledevice(context);
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
    } catch (e) {
      // handle error
    } finally {
      setState(() => _googleloginLoading = false);
    }
  }

  void _loginApple() async {
    setState(() => _appleLoginLoading = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final user = await _authService.signInWithApples(context);
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
    } catch (e) {
      // handle error
    } finally {
      setState(() => _appleLoginLoading = false);
    }
  }

  Future<void> _navigateBasedOnRole(AppUser user) async {
    final RecruiterRepository _RecruiterRepo = RecruiterRepository();
    final JobSeekerRepository _jobSeekerRepo = JobSeekerRepository();
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;

    // ✅ Web only: cap content width at 480. Mobile: full size.width, no change.
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
          // Background Shape — completely unchanged
          TopCircle(size: size),

          SizedBox(
            height: size.height,
            child: Center(
              child: SizedBox(
                width: maxWidth, // mobile: full width, no visual difference
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: size.height * 0.1),

                          LoginText(size: size, maxWidth: maxWidth),

                          SizedBox(height: size.height * 0.02),
                          
                          WelcomeText(size: size, maxWidth: maxWidth),

                          SizedBox(height: size.height * 0.02),

                          _customButton(
                            text: l10n.login_with_email,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const EmailLogin()),
                              );
                            },
                            size: size,
                            maxWidth: maxWidth,
                          ),

                          SizedBox(height: size.height * 0.02),

                          _socialLoginButton(
                            size,
                            maxWidth: maxWidth,
                            text: l10n.login_with_google,
                            onPressed: _loginGoogle,
                            backgroundColor: Colors.transparent,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF4285F4),
                                AppColors.greenCeladon
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            icon: const FaIcon(
                              FontAwesomeIcons.google,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),

                          SizedBox(height: size.height * 0.02),

                          if (!kIsWeb && (Platform.isIOS || Platform.isMacOS))
                            _AppleLogin(
                              size,
                              maxWidth: maxWidth,
                              text: l10n.login_with_apple,
                              onPressed: _loginApple,
                              backgroundColor: Colors.black,
                              icon: const Icon(
                                Icons.apple,
                                color: Colors.white,
                                size: 39,
                              ),
                            ),

                          SizedBox(height: size.height * 0.02),

                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SelectRoleScreen()),
                              );
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

                          SizedBox(height: size.height * 0.02),
                          SizedBox(width: size.width * 0.03),
                          const SizedBox(height: 26),
                        ],
                      ),
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

  Widget _customButton({
    required String text,
    required void Function() onPressed,
    required Size size,
    required double maxWidth,
  }) {
    return SizedBox(
      width: double.infinity,
      // ✅ Mobile: original value. Web: clamped so it doesn't overflow.
      height: kIsWeb
          ? (size.height * 0.07).clamp(48.0, 60.0)
          : size.height * 0.07,
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
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
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
                    // ✅ Mobile: original size.width * 0.05. Web: clamped.
                    fontSize: kIsWeb
                        ? (maxWidth * 0.05).clamp(14.0, 18.0)
                        : size.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _socialLoginButton(
    Size size, {
    required double maxWidth,
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Widget icon,
    Gradient? gradient,
  }) {
    return SizedBox(
      width: double.infinity,
      height: kIsWeb
          ? (size.height * 0.07).clamp(48.0, 60.0)
          : size.height * 0.07,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? backgroundColor : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: (gradient != null ? AppColors.green : backgroundColor)
                  .withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _googleloginLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    const SizedBox(width: 12),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: kIsWeb
                            ? (maxWidth * 0.05).clamp(14.0, 18.0)
                            : size.width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _AppleLogin(
    Size size, {
    required double maxWidth,
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Widget icon,
    Gradient? gradient,
  }) {
    return SizedBox(
      width: double.infinity,
      height: kIsWeb
          ? (size.height * 0.07).clamp(48.0, 60.0)
          : size.height * 0.07,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? backgroundColor : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: (gradient != null ? AppColors.green : backgroundColor)
                  .withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _appleLoginLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    const SizedBox(width: 12),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: kIsWeb
                            ? (maxWidth * 0.05).clamp(14.0, 18.0)
                            : size.width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ✅ Mobile: size.width * 0.04 (original, untouched)
// ✅ Web:    (maxWidth * 0.04).clamp(13.0, 17.0)
class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key, required this.size, this.maxWidth});
  final Size size;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final double mw = maxWidth ?? size.width;
    return Text(
      AppLocalizations.of(context)!.welcomeMessage,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: kIsWeb
            ? (mw * 0.04).clamp(13.0, 17.0)
            : size.width * 0.04,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// ✅ Mobile: size.width * 0.1 (original, untouched)
// ✅ Web:    (maxWidth * 0.1).clamp(28.0, 48.0)
class LoginText extends StatelessWidget {
  const LoginText({super.key, required this.size, this.maxWidth});
  final Size size;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final double mw = maxWidth ?? size.width;
    return Text(
      AppLocalizations.of(context)!.loginHere,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: kIsWeb
            ? (mw * 0.1).clamp(28.0, 48.0)
            : size.width * 0.1,
        fontWeight: FontWeight.bold,
        color: AppColors.greenCeladon,
        
      ),
    );
  }
}

// TopCircle — completely unchanged
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