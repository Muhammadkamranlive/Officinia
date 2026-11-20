import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:otp_autofill/otp_autofill.dart';
import 'package:pinput/pinput.dart';

import 'package:http/http.dart' as http;

class OTPAutofillWidget extends StatefulWidget {
  final Function(String) onOtpComplete;

  const OTPAutofillWidget({
    Key? key,
    required this.onOtpComplete,
  }) : super(key: key);

  @override
  State<OTPAutofillWidget> createState() => _OTPAutofillWidgetState();
}

class _OTPAutofillWidgetState extends State<OTPAutofillWidget> {
  late OTPInteractor _otpInteractor;
  late OTPTextEditController _otpController;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initInteractor();
    _otpController = OTPTextEditController(
      codeLength: 6,
      otpInteractor: _otpInteractor,
      onCodeReceive: (code) {
        // This is triggered if SMS user-consent provides a code
        _otpController.text = code;
      },
    )..startListenUserConsent((code) {
        final exp = RegExp(r'(\d{6})');
        return exp.stringMatch(code ?? '') ?? '';
      });
  }

  Future<void> _initInteractor() async {
    _otpInteractor = OTPInteractor();
    final signature = await _otpInteractor.getAppSignature();
    debugPrint('App signature: $signature');
  }

  @override
  void dispose() {
    _otpController.stopListen();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define your box + text styling once
    final defaultPinTheme = PinTheme(
      width: 50.w, // each box width
      height: 60.h, // each box height
      textStyle: TextStyle(
        fontSize: 24.sp, // digit size
        color: Colors.white, // digit color
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.white, width: 2),
      ),
      textStyle: defaultPinTheme.textStyle!.copyWith(color: Colors.white),
    );
    return Pinput(
      length: 6,
      obscureText: true,
      controller: _otpController,
      focusNode: _focusNode,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,

      // Prevents the keyboard from hiding automatically:
      closeKeyboardWhenCompleted: false,
      showCursor: true,

      onCompleted: (otp) async {
        FocusScope.of(context).unfocus();
        // If you want them to be able to re-edit, re-focus:
        // Future.delayed(const Duration(milliseconds: 50), () {
        //   if (mounted) _focusNode.requestFocus();
        // });

        // Let's say you verify immediately:
        widget.onOtpComplete(otp);
        _otpController.clear();
        // If verification fails, clear and keep the user in:
        setState(() {
          _otpController.clear();
        });
        // _focusNode.unfocus();
      },
    );
  }

  Future<int> verifyOTP(String otp, String mobileNo) async {
    try {
      var client = http.Client();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/Registration/VerifyOTP?mobileNumber=${otp}&smsOTP=$mobileNo&emailOTP=$mobileNo");
      var response = await client.get(uri);
      final body = json.decode(response.body);
      // isActive = body['isactive'];
      return response.statusCode;
    } catch (e) {
      print("Exception in verifyOTP(): $e");
      return 0;
    }
  }

  Future<bool> verifyCode(String otp) async {
    // Your verification logic here
    // Return true if verified, false otherwise
    return false; // Suppose it fails
  }
}
