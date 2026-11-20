// ignore: file_names
import 'dart:io';

import 'package:client/AdminPannel/AdminAccountScreen.dart';
import 'package:client/AdminPannel/BlockedScreen.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Authentication/EmailAuth/EmailAuth.dart';
import 'package:client/Authentication/phoneAuth/PhoneAuth.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Guard/AuthProvider/RoleSelectionProvider.dart';
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
import 'package:client/widgets/custom_toast.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../routes/app_routes.dart';
import '../../l10n/app_localizations.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<Register> {
  final AuthService _authService = AuthService();
  bool _googleloginLoading = false;
  bool _appleLoginLoading = false;
  bool _isLoading=false;
  
   
  final RecruiterRepository _RecruiterRepo = RecruiterRepository(); 
  void _loginGoogle() async {
    setState(() => _googleloginLoading = true);
    
    try {
      late UserRole selectedRole = context.read<RoleSelectionProvider>().role!;
      final user = await _authService.signUpWithGoogleAppledevice(selectedRole, context);

      if (user == null) {
        return;
      }

      context.read<AuthProvider>().setUser(user);
      await _navigateBasedOnRole(user);
    } catch (e) 
    {
      //showCustomToast(e.toString());
    } finally {
      setState(() => _googleloginLoading = false);
    }
  }

 void _loginApple() async {
    setState(() => _appleLoginLoading = true);
    
    try {
      late UserRole selectedRole = context.read<RoleSelectionProvider>().role!;
      final user = await _authService.signInWithApple(selectedRole, context);

      if (user == null) {
        return;
      }
      context.read<AuthProvider>().setUser(user);
      await _navigateBasedOnRole(user);
    } catch (e) 
    {
      showCustomToast(e.toString(),context);
    } finally {
      setState(() => _appleLoginLoading = false);
    }
  }

 

  Future<void> _navigateBasedOnRole(AppUser user) async {
  final l10n = AppLocalizations.of(context)!;
  final RecruiterRepository _RecruiterRepo = RecruiterRepository();
  final JobSeekerRepository _jobSeekerRepo = JobSeekerRepository();
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
        else if (user.isDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.deletion_queue_error),
                duration: const Duration(seconds: 3),
              ),
            );
            return;
        } 
        else {
          final profile = await _RecruiterRepo.getByUid(user.userId);
          if (profile == null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const RecruiterAccountScreen(mode: AccountFormMode.create),
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
         else if (user.isDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.deletion_queue_error),
                duration: const Duration(seconds: 3),
              ),
            );
            return;
        }  
        else {
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
          // Top circle background
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

          SizedBox(
            height: size.height,
            child: Center(
              child: SafeArea(
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
                          SizedBox(height: size.height * 0.1),
                              SizedBox(
                              width: double.infinity,
                              child: Text(
                                l10n.join_ophicina,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: size.width * 0.1,
                              fontWeight: FontWeight.bold,
                              color: AppColors.greenCeladon,
                                ),
                              ),
                            ),    
                         
                          SizedBox(height: size.height * 0.02),
                                  
                          // Subtitle
                          Text(
                            l10n.join_subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                                  
                          // Sign Up with Phone
                          // _customButton(
                          //   text: "Sign Up with Phone",
                          //   onPressed: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(builder: (context) => PhoneAuth()),
                          //     );
                          //   },
                          //   size: size,
                          // ),
                                  
                          // SizedBox(height: size.height * 0.02),
                                  
                          // Sign Up with Email
                          _customButton(
                            text: l10n.signup_with_email,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EmailAuth()),
                              );
                            },
                            size: size,
                          ),
                                  
                          
                          SizedBox(height: size.height * 0.02),
                          // Social Media Buttons
                          _socialLoginButton(
                            size,
                            text: l10n.signup_with_google,
                            onPressed: () async {
                               _loginGoogle();
                            },
                            backgroundColor: Colors.transparent,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4285F4), AppColors.greenCeladon],
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
                         if (Platform.isIOS || Platform.isMacOS)
                          _AppleLogin(
                            size,
                            text: l10n.signup_with_apple,
                            onPressed: () async {
                              _loginApple();
                            },
                            backgroundColor: Colors.black,
                            icon: const Icon(Icons.apple, color: Colors.white, size: 39),
                          ),
                         SizedBox(height: size.height * 0.02),
                          // Already have an account?
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.login);
                            },
                            child: Text(
                              l10n.already_have_account,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                              
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


  Widget _socialLoginButton(
    Size size, {
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Widget icon,
    Gradient? gradient,
  }) {
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.07,
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
            backgroundColor: Colors.transparent, // important
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
                        fontSize: size.width * 0.05,
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
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Widget icon,
    Gradient? gradient,
  }) {
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.07,
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
            backgroundColor: Colors.transparent, // important
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
                        fontSize: size.width * 0.05,
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


  // Custom Button Widget
  Widget _customButton({
    required String text,
    required void Function() onPressed,
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
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}
