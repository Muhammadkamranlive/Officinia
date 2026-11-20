
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
import 'package:client/widgets/SocialLoginButton.dart';
import 'package:client/widgets/custom_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';

class Country {
  final String name;
  final String code;
  final String flag;
  final String regex;
  final String hint;
  final int maxLength;

  Country({
    required this.name,
    required this.code,
    required this.flag,
    required this.regex,
    required this.hint,
    required this.maxLength,
  });
}

class LoginPhone extends StatefulWidget {
  const LoginPhone({super.key});

  @override
  State<LoginPhone> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPhone> {
  final TextEditingController _phoneController = TextEditingController();

  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  String get _enteredOtp => _otpControllers.map((e) => e.text).join();

  final List<Country> _countries = [
    Country(
      name: 'Algeria',
      code: '+213',
      flag: 'assets/dz.png',
      regex: r'^[567]\d{8}$',
      hint: '5XXXXXXXX',
      maxLength: 9,
    ),
    Country(
      name: 'Pakistan',
      code: '+92',
      flag: 'assets/pakistan.png',
      regex: r'^3\d{9}$',
      hint: '3XXXXXXXXX',
      maxLength: 10,
    ),
  ];

  late Country _selectedCountry;
  String? _verificationId;
  bool _otpSent = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService();
  final RecruiterRepository _RecruiterRepo = RecruiterRepository();

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries[0]; // Default to Algeria
  }

  bool _isValidPhone(String phone) {
    final regex = RegExp(_selectedCountry.regex);
    return regex.hasMatch(phone);
  }

  String get _fullPhoneNumber =>
      "${_selectedCountry.code}${_phoneController.text.trim()}";

  void _onCountryChanged(Country? country) {
    if (country != null && country != _selectedCountry) {
      setState(() {
        _selectedCountry = country;
        _phoneController.clear();
        _otpSent = false;
        _verificationId = null;
        for (var controller in _otpControllers) {
          controller.clear();
        }
      });
    }
  }

  Future<void> _sendOtpLogin() async {
    final phone = _phoneController.text.trim();
    final l10n  = AppLocalizations.of(context)!;

    if (phone.isEmpty) {
      showCustomToast(l10n.enter_phone, context);
      return;
    }

    if (!_isValidPhone(phone)) {
      String message = _selectedCountry.name == 'Algeria'
          ? l10n.enter_valid_algerian
          : l10n.enter_valid_pakistani;
      showCustomToast(message, context);
      return;
    }

    setState(() => _isLoading = true);

    await _authService.sendOtp(
      phone: _fullPhoneNumber,
      onCodeSent: (verificationId) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _otpFocusNodes.first.requestFocus();
        });
        setState(() {
          _verificationId = verificationId;
          _otpSent = true;
          _isLoading = false;
        });
        showCustomToast(l10n.otp_sent_to(_fullPhoneNumber), context);
      },
      onError: (error) {
        setState(() => _isLoading = false);
        showCustomToast(error, context);
      },
    );
  }

  Future<void> _verifyOtpLogin() async {
    final l10n = AppLocalizations.of(context)!;
    if (_verificationId == null) {
      showCustomToast(l10n.otp_not_sent, context);
      return;
    }

    if (_enteredOtp.length != 6) {
      showCustomToast(l10n.otp_complete, context);
      return;
    }

    setState(() => _isLoading = true);

    final user = await _authService.verifyOtp(
      verificationId: _verificationId!,
      smsCode: _enteredOtp,
      context: context,
    );

    setState(() => _isLoading = false);

    if (user == null) {
      showCustomToast(l10n.account_not_found, context);
      for (final c in _otpControllers) c.clear();
      _otpFocusNodes.first.requestFocus();
      return;
    }

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
              builder: (_) => const AdminAccountScreen(mode: AdminFormMode.create),
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
        } else if (user.isDeleted) {
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
                builder: (_) => const RecruiterAccountScreen(mode: AccountFormMode.create),
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
        } else if (user.isDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.del_account_dialog_msg),
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        } else {
          JobSeekerRepository _jobSeekerRepo = JobSeekerRepository();
          final profile = await _jobSeekerRepo.getByUid(user.userId);
          if (profile == null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const JobSeekerAccountScreen(mode: JobSeekerFormMode.create),
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
        automaticallyImplyLeading: true,
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
                color: AppColors.green.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                height: size.height,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          l10n.login_title,
                          style: TextStyle(
                            fontSize: size.width * 0.1,
                            fontWeight: FontWeight.bold,
                            color: AppColors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: size.height * 0.015),
                        Text(
                          _otpSent
                              ? l10n.otp_complete
                              : l10n.login_subtitle_phone,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: size.height * 0.04),

                        if (!_otpSent) ...[
                          // Country Selector
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.greenCeladon, width: 1.8),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Country>(
                                value: _selectedCountry,
                                isExpanded: true,
                                icon: Icon(Icons.arrow_drop_down, color: AppColors.green),
                                items: _countries.map((Country country) {
                                  return DropdownMenuItem<Country>(
                                    value: country,
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          country.flag,
                                          width: 28,
                                          height: 20,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 28,
                                              height: 20,
                                              color: Colors.grey.shade300,
                                              child: Center(
                                                child: Text(country.code, style: const TextStyle(fontSize: 10)),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          "${country.name} ${country.code}",
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: _onCountryChanged,
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),

                          // Phone Input
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.greenCeladon, width: 1.8),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  _selectedCountry.flag,
                                  width: 28,
                                  height: 20,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(width: 28, height: 20, color: Colors.grey.shade300);
                                  },
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedCountry.code,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(_selectedCountry.maxLength),
                                    ],
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: _selectedCountry.hint,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 0.03),
                        ],

                        // OTP Boxes
                        if (_otpSent) ...[
                          Text(
                            l10n.otp_complete,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                          ),
                          SizedBox(height: size.height * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              return SizedBox(
                                width: size.width * 0.12,
                                child: TextField(
                                  controller: _otpControllers[index],
                                  focusNode: _otpFocusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    counterText: "",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.6),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.green, width: 2.2),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 5) _otpFocusNodes[index + 1].requestFocus();
                                    if (value.isEmpty && index > 0) _otpFocusNodes[index - 1].requestFocus();
                                  },
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: size.height * 0.03),
                        ],
                        // Button
                        customButton(
                          text: _otpSent ? l10n.otp_complete : l10n.login_subtitle_phone,
                          onPressed: _otpSent ? _verifyOtpLogin : _sendOtpLogin,
                          size: size,
                          isLoading: _isLoading,
                        ),

                       
                        SizedBox(height: size.height * 0.01),

                        // Create new account
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.selectRole);
                          },
                          child: Text(
                            l10n.create_account,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color: AppColors.green)
                          ),
                        ),
                        SizedBox(height: size.height * 0.04),

                        if (!_otpSent) ...[
                          // Country Selector
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.greenCeladon, width: 1.8),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Country>(
                                value: _selectedCountry,
                                isExpanded: true,
                                icon: Icon(Icons.arrow_drop_down, color: AppColors.green),
                                items: _countries.map((Country country) {
                                  return DropdownMenuItem<Country>(
                                    value: country,
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          country.flag,
                                          width: 28,
                                          height: 20,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 28,
                                              height: 20,
                                              color: Colors.grey.shade300,
                                              child: Center(
                                                child: Text(country.code, style: const TextStyle(fontSize: 10)),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          "${country.name} ${country.code}",
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: _onCountryChanged,
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),

                          // Phone Input
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.greenCeladon, width: 1.8),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  _selectedCountry.flag,
                                  width: 28,
                                  height: 20,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(width: 28, height: 20, color: Colors.grey.shade300);
                                  },
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedCountry.code,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(_selectedCountry.maxLength),
                                    ],
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: _selectedCountry.hint,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 0.03),
                        ],

                        // OTP Boxes
                        if (_otpSent) ...[
                          Text(
                            "Enter 6-digit code",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                          ),
                          SizedBox(height: size.height * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              return SizedBox(
                                width: size.width * 0.12,
                                child: TextField(
                                  controller: _otpControllers[index],
                                  focusNode: _otpFocusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    counterText: "",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.6),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.green, width: 2.2),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 5) _otpFocusNodes[index + 1].requestFocus();
                                    if (value.isEmpty && index > 0) _otpFocusNodes[index - 1].requestFocus();
                                  },
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: size.height * 0.03),
                        ],

                        customButton(
                          text: _otpSent ? "Verify OTP" : "Login with Phone",
                          onPressed: _isLoading ? null : _otpSent ? _verifyOtpLogin : _sendOtpLogin,
                          size: size,
                          isLoading: _isLoading,
                        ),

                        SizedBox(height: size.height * 0.01),

                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.selectRole);
                          },
                          child: Text(
                            "Create new account",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.green),
                          ),
                        ),
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

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _otpControllers) controller.dispose();
    for (var node in _otpFocusNodes) node.dispose();
    super.dispose();
  }
}