// ignore: file_names
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/RoleSelectionProvider.dart';
import 'package:client/Server/Enums/UserRole.dart';
import 'package:client/Server/Services/AuthService.dart';
import 'package:client/widgets/SocialLoginButton.dart';
import 'package:client/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import '../../routes/app_routes.dart';

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

class PhoneAuth extends StatefulWidget {
  const PhoneAuth({super.key});

  @override
  State<PhoneAuth> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<PhoneAuth> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  String get _enteredOtp => _otpControllers.map((e) => e.text).join();

  // Country data
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

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries[0]; // Default to Algeria
    selectedRole = context.read<RoleSelectionProvider>().role!;
  }

  bool _isValidPhone(String phone) {
    final regex = RegExp(_selectedCountry.regex);
    return regex.hasMatch(phone);
  }

  String get _fullPhoneNumber =>
      "${_selectedCountry.code}${_phoneController.text.trim()}";

  String? _verificationId;
  bool _otpSent = false;

  late UserRole selectedRole;

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      showCustomToast("Enter phone number",context);
      return;
    }

    if (!_isValidPhone(phone)) {
      String message = _selectedCountry.name == 'Algeria'
          ? "Enter a valid Algerian number (5, 6 or 7 followed by 8 digits)"
          : "Enter a valid Pakistani number (3 followed by 9 digits)";
      showCustomToast(message,context);
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
        showCustomToast("OTP sent to $_fullPhoneNumber",context);
      },
      onError: (error) {
        setState(() => _isLoading = false);
        showCustomToast(error, context);
      },
    );
  }

  Future<void> _verifyOtp() async {
    if (_verificationId == null) {
      showCustomToast("OTP not sent yet",context);
      return;
    }

    if (_enteredOtp.length != 6) {
      showCustomToast("Enter complete 6-digit OTP",context);
      return;
    }

    setState(() => _isLoading = true);

    final user = await _authService.verifyOtpForRegister(
      verificationId: _verificationId!,
      smsCode: _enteredOtp,
      role: selectedRole,
      context: context,
    );

    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _onCountryChanged(Country? country) {
    if (country != null && country != _selectedCountry) {
      setState(() {
        _selectedCountry = country;
        _phoneController.clear(); // Clear phone input when country changes
        _otpSent = false; // Reset OTP state
        _verificationId = null;
        for (var controller in _otpControllers) {
          controller.clear();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
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
                color: AppColors.green.withOpacity(0.09),
              ),
            ),
          ),
          SafeArea(
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
                      Text(
                        "Welcome to Officina",
                        style: TextStyle(
                          fontSize: size.width * 0.09,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),
                      Text(
                        _otpSent
                            ? "Enter the verification code sent to your phone"
                            : "Sign up using your phone number",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: size.height * 0.05),
                      if (!_otpSent) ...[
                        // Country Selector
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.greenCeladon,
                              width: 1.8,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Country>(
                              value: _selectedCountry,
                              isExpanded: true,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.green,
                              ),
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
                                              child: Text(
                                                country.code,
                                                style: TextStyle(fontSize: 10),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        "${country.name} ${country.code}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.greenCeladon,
                              width: 1.8,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              // Flag
                              Image.asset(
                                _selectedCountry.flag,
                                width: 28,
                                height: 20,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 28,
                                    height: 20,
                                    color: Colors.grey.shade300,
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              // Country Code
                              Text(
                                _selectedCountry.code,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Phone input
                              Expanded(
                                child: TextField(
                                  enabled: !_otpSent,
                                  controller: _phoneController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(
                                        _selectedCountry.maxLength),
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
                        SizedBox(height: size.height * 0.02),
                      ],
                      if (_otpSent) ...[
                        Text(
                          "Enter 6-digit code",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
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
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  counterText: "",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade400,
                                      width: 1.6,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.green,
                                      width: 2.2,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 5) {
                                    _otpFocusNodes[index + 1].requestFocus();
                                  }
                                  if (value.isEmpty && index > 0) {
                                    _otpFocusNodes[index - 1].requestFocus();
                                  }
                                },
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: size.height * 0.03),
                      ],
                      customButton(
                        text: _otpSent ? "Verify OTP" : "Send OTP",
                        onPressed: _isLoading
                            ? null
                            : _otpSent
                                ? _verifyOtp
                                : _sendOtp,
                        size: size,
                        isLoading: _isLoading,
                      ),
                      // Already have an account?
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                        child: const Text(
                          "Already have an account",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.04),
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

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}