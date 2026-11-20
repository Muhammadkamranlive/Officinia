import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/screens/dashboard/dashboard_screen.dart';
import 'package:mobile_onboarding/screens/otp/singUP_OTP_Screen/components/autofiller_handler.dart';
import 'package:mobile_onboarding/size_config.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';
import 'package:mobile_onboarding/utilities/notification_handler/in_app_notification.dart';

import 'package:mobile_onboarding/utilities/parameters/provider.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';

import 'package:mobile_onboarding/widgets/form_error.dart';
import 'package:mobile_onboarding/widgets/login_singup_button.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import 'package:pinput/pinput.dart';

import 'package:http/http.dart' as http;

class OtpForm extends StatefulWidget {
  OtpForm(
    this.otpNumber,
    this.otpEmail,
    this.isEmailVisible, {
    Key? key,
  }) : super(key: key);

  final String? otpNumber;
  final String? otpEmail;
  final bool isEmailVisible;
  final NotificationService _notificationService = NotificationService();

  @override
  _OtpFormState createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String mobileOTPPin = "";
  String emailOTPPin = "";
  List<String?> errors = [];
  bool enableResend = false;
  bool isActive = false;
  late ProgressDialog pr;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: false);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            enableResend = true;
          });
        }
      });
    startTimer();
  }

  void startTimer() {
    setState(() {
      enableResend = false;
    });
    _controller.reset();
    _controller.forward();
  }

  Future<void> generateOTP() async {
    // Your generate OTP logic here
    await Future.delayed(Duration(seconds: 1)); // Simulating network call
  }

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  void moveToNext() {
    Navigator.pushNamedAndRemoveUntil(
        context, DashboardScreen.routeName, (Route<dynamic> route) => false);

    widget._notificationService.showCustomNotification(
        'Successfully Signed-in', 'you have successfully signed in');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final policyProvider = Provider.of<PolicyProvider>(context);
    bool isEmailOtpEnabled = policyProvider.getPolicyValue('email_otp');
    bool isSmsOtpEnabled = policyProvider.getPolicyValue('sms_otp');
    if (!widget.isEmailVisible) {
      isEmailOtpEnabled = false;
    }

    print('is email OTP: ${isEmailOtpEnabled}');
    print('is sms OTP: ${isSmsOtpEnabled}');

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(
          fontSize: 20, color: Colors.white, fontWeight: FontWeight.w400),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.white),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith();

    pr.style(
        message: 'Please wait...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: const Center(
          child: SizedBox(
              width: 50, height: 50, child: CircularProgressIndicator()),
        ),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        padding: const EdgeInsets.all(16),
        maxProgress: 100.0,
        progressTextStyle: const TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: const TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));

    return Consumer<PolicyProvider>(builder: (context, provider, child) {
      return Form(
        key: _formKey,
        child: Center(
            child: Container(
          margin: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: SizeConfig.screenFieldSize20),
              Visibility(
                visible: isSmsOtpEnabled,
                child: Column(
                  children: [
                    const Text(
                      "Enter Your OTP Here",
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: SizeConfig.screenFieldSize10),
                    OTPAutofillWidget(
                      // onOtpReceived: (otp) {
                      //   setState(() {
                      //     mobileOTPPin = otp;
                      //   });
                      // },
                      onOtpComplete: (otp) {
                        print("OTP completed: $otp");
                        // Handle OTP completion logic here
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: SizeConfig.screenFieldSize10),
              Visibility(
                visible: isEmailOtpEnabled,
                child: Column(
                  children: [
                    Text(
                      "We sent your code to ${widget.otpEmail}",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: SizeConfig.screenFieldSize10),
                    Pinput(
                      length: 6,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: focusedPinTheme,
                      submittedPinTheme: submittedPinTheme,
                      showCursor: true,
                      onCompleted: (pin) {
                        debugPrint('onComplete: $pin');
                      },
                      onChanged: (value) {
                        debugPrint('onChanged: $value');
                        emailOTPPin = value;
                      },
                    ),
                    SizedBox(height: SizeConfig.screenFieldSize20),
                  ],
                ),
              ),
              FormError(errors: errors),
              SizedBox(height: SizeConfig.screenFieldSize20),
              buildTimer(),
              GestureDetector(
                onTap: () async {
                  if (enableResend) {
                    await pr.show();
                    await generateOTP();
                    await pr.hide();
                    startTimer();
                  }
                },
                child: Text(
                  "Resend",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: enableResend ? Colors.white : Colors.grey,
                    color: enableResend ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.screenFieldSize40),
              LoginSingupButton(
                text: "Continue",
                isDisable: true,
                press: () async {
                  moveToNext();
                  // if (_formKey.currentState!.validate()) {
                  //   _formKey.currentState!.save();
                  //   moveToNext();
                  //   await pr.show();
                  //   int statusCode = await verifyOTP();
                  //   await pr.hide();
                  //   KeyboardUtil.hideKeyboard(context);
                  //   if (statusCode == 200) {
                  //     if (isActive) {
                  //       setState(() {
                  //         removeError(error: kPhoneOTPNullError);
                  //         if (!widget.isEmailVisible) {
                  //           moveToNext();
                  //         }
                  //       });
                  //
                  //       if (widget.isEmailVisible) {
                  //         setState(() {
                  //           removeError(error: kEmailOTPNullError);
                  //           moveToNext();
                  //         });
                  //       }
                  //     } else {
                  //       setState(() {
                  //         addError(error: kPhoneOTPNullError);
                  //       });
                  //       if (widget.isEmailVisible) {
                  //         setState(() {
                  //           addError(error: kEmailOTPNullError);
                  //         });
                  //       }
                  //     }
                  //   }
                  //}
                },
              ),
            ],
          ),
        )),
      );
    });
  }

  Row buildTimer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "You can resend OTP after ",
          style: TextStyle(color: Colors.white),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            return Row(
              children: [
                Text(
                  "${(60 - _controller.value * 60).toInt()}",
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 5),
                const Icon(CupertinoIcons.timer, color: Colors.white, size: 20),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<int> verifyOTP() async {
    try {
      final headers = await getGenericHeaders();
      if (!widget.isEmailVisible) {
        emailOTPPin = mobileOTPPin;
      }

      var client = http.Client();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/Registration/VerifyOTP?mobileNumber=${widget.otpNumber}&smsOTP=$mobileOTPPin&emailOTP=$emailOTPPin");
      var response = await client.get(uri, headers: headers);
      final body = json.decode(response.body);
      isActive = body['isactive'];
      return response.statusCode;
    } catch (e) {
      print("Exception in verifyOTP(): $e");
      return 0;
    }
  }

  Future<int> generateOT() async {
    try {
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/Registration/GenerateOTP?mobileNumber=${widget.otpNumber}");
      var response = await client.get(uri);
      return response.statusCode;
    } catch (e) {
      print("Exception in generateOTP(): $e");
      return -1;
    }
  }
}



// older versions of otp form without timer functionality

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:mobile_onboarding/screens/dashboard/dashboard_screen.dart';
// import 'package:mobile_onboarding/testing_widgets/autofiller_sms/autoFillerHandler.dart';
// import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
// import '../../../constants.dart';
// import '../../../helper/keyboard.dart';
// import '../../../size_config.dart';
// import '../../../widgets/default_button.dart';
// import 'package:pinput/pinput.dart';
// import '../../../widgets/form_error.dart';
// import '../../home/home_screen.dart';
// import 'package:http/http.dart' as http;
// import '../../noorcard/noor_card_screen.dart';
// import '../../requests/request_status_screen.dart';

// class OtpForm extends StatefulWidget {
//   OtpForm(
//     this.otpNumber,
//     this.otpEmail,
//     this.isEmailVisible, {
//     Key? key,
//   }) : super(key: key);

//   final String? otpNumber;
//   final String? otpEmail;
//   final bool isEmailVisible;

//   @override
//   _OtpFormState createState() => _OtpFormState();
// }

// class _OtpFormState extends State<OtpForm> {
//   final _formKey = GlobalKey<FormState>();

//   String mobileOTPPin = "";
//   String emailOTPPin = "";
//   List<String?> errors = [];
//   bool enableResend = false;
//   bool isActive = false;

//   void addError({String? error}) {
//     if (!errors.contains(error)) {
//       setState(() {
//         errors.add(error);
//       });
//     }
//   }

//   void removeError({String? error}) {
//     if (errors.contains(error)) {
//       setState(() {
//         errors.remove(error);
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//   }

//   void moveToNext() {
//     Navigator.pushNamedAndRemoveUntil(context, RequestStatusScreen.routeName,
//         (Route<dynamic> route) => false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final defaultPinTheme = PinTheme(
//       width: 50,
//       height: 50,
//       textStyle: const TextStyle(
//           fontSize: 20, color: kPrimaryColor, fontWeight: FontWeight.w400),
//       decoration: BoxDecoration(
//         border: Border.all(color: kPrimaryColor),
//         borderRadius: BorderRadius.circular(8),
//       ),
//     );

//     final focusedPinTheme = defaultPinTheme.copyDecorationWith(
//       border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
//       borderRadius: BorderRadius.circular(8),
//     );

//     final submittedPinTheme = defaultPinTheme.copyDecorationWith();

//     final ProgressDialog pr = ProgressDialog(context,
//         type: ProgressDialogType.normal, isDismissible: false);
//     pr.style(
//         message: 'Please wait...',
//         borderRadius: 10.0,
//         backgroundColor: Colors.white,
//         progressWidget: const Center(
//           child: SizedBox(
//               width: 50, height: 50, child: CircularProgressIndicator()),
//         ),
//         elevation: 10.0,
//         insetAnimCurve: Curves.easeInOut,
//         progress: 0.0,
//         padding: const EdgeInsets.all(16),
//         maxProgress: 100.0,
//         progressTextStyle: const TextStyle(
//             color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
//         messageTextStyle: const TextStyle(
//             color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));

//     return Form(
//       key: _formKey,
//       child: Center(
//           child: Container(
//         margin: const EdgeInsets.all(40),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(height: SizeConfig.screenFieldSize20),
//             const Text("Enter Your OTP Here"),
//             SizedBox(height: SizeConfig.screenFieldSize10),
//             OTPAutofillWidget(
//               onOtpReceived: (otp) {
//                 setState(() {
//                   mobileOTPPin = otp;
//                 });
//               },
//             ),
//             SizedBox(height: SizeConfig.screenFieldSize10),
//             Visibility(
//               visible: widget.isEmailVisible,
//               child: Column(
//                 children: [
//                   Text(
//                     "We sent your code to ${widget.otpEmail}",
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: SizeConfig.screenFieldSize10),
//                   Pinput(
//                     length: 6,
//                     defaultPinTheme: defaultPinTheme,
//                     focusedPinTheme: focusedPinTheme,
//                     submittedPinTheme: submittedPinTheme,
//                     showCursor: true,
//                     onCompleted: (pin) {
//                       debugPrint('onComplete: $pin');
//                     },
//                     onChanged: (value) {
//                       debugPrint('onChanged: $value');
//                       emailOTPPin = value;
//                     },
//                   ),
//                   SizedBox(height: SizeConfig.screenFieldSize20),
//                 ],
//               ),
//             ),
//             FormError(errors: errors),
//             SizedBox(height: SizeConfig.screenFieldSize20),
//             buildTimer(),
//             GestureDetector(
//               onTap: () async {
//                 // OTP code resend
//                 if (enableResend) {
//                   await pr.show();
//                   int sCode = await generateOTP();
//                   setState(() {
//                     enableResend = false;
//                   });
//                   await pr.hide();
//                 } else {
//                   print("Resend is disabled!");
//                 }
//               },
//               child: const Text(
//                 "Resend",
//                 style: TextStyle(
//                   decoration: TextDecoration.underline,
//                   color: kPrimaryColor,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),
//               ),
//             ),
//             SizedBox(height: SizeConfig.screenFieldSize40),
//             DefaultButton(
//               text: "Continue",
//               isDisable: true,
//               press: () async {
//                 if (_formKey.currentState!.validate()) {
//                   _formKey.currentState!.save();

//                   await pr.show();
//                   int statusCode = await verifyOTP();
//                   await pr.hide();
//                   KeyboardUtil.hideKeyboard(context);
//                   if (statusCode == 200) {
//                     if (isActive) {
//                       setState(() {
//                         removeError(error: kPhoneOTPNullError);
//                         if (!widget.isEmailVisible) {
//                           moveToNext();
//                         }
//                       });

//                       if (widget.isEmailVisible) {
//                         setState(() {
//                           removeError(error: kEmailOTPNullError);
//                           moveToNext();
//                         });
//                       }
//                     } else {
//                       setState(() {
//                         addError(error: kPhoneOTPNullError);
//                       });
//                       if (widget.isEmailVisible) {
//                         setState(() {
//                           addError(error: kEmailOTPNullError);
//                         });
//                       }
//                     }
//                   }
//                 }
//               },
//             )
//           ],
//         ),
//       )),
//     );
//   }

//   Row buildTimer() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Text("You can resend OTP after "),
//         TweenAnimationBuilder(
//           tween: Tween(begin: 59.0, end: 00.0),
//           duration: const Duration(seconds: 59),
//           onEnd: () {
//             enableResend = true;
//             setState(() {});
//           },
//           builder: (_, dynamic value, child) => Text(
//             "00:${value.toInt()}",
//             style: const TextStyle(color: kPrimaryColor),
//           ),
//         ),
//       ],
//     );
//   }

//   Future<int> verifyOTP() async {
//     try {
//       if (!widget.isEmailVisible) {
//         emailOTPPin = mobileOTPPin;
//       }

//       var client = http.Client();
//       var uri = Uri.parse(
//           "${getApiBaseUrl()}/Registration/VerifyOTP?mobileNumber=${widget.otpNumber}&smsOTP=$mobileOTPPin&emailOTP=$emailOTPPin");
//       var response = await client.get(uri);
//       final body = json.decode(response.body);
//       isActive = body['isactive'];
//       return response.statusCode;
//     } catch (e) {
//       print("Exception in verifyOTP(): $e");
//       return 0;
//     }
//   }

//   Future<int> generateOTP() async {
//     try {
//       var client = http.Client();
//       var uri = Uri.parse(
//           "${getApiBaseUrl()}/Registration/GenerateOTP?mobileNumber=${widget.otpNumber}");
//       var response = await client.get(uri);
//       return response.statusCode;
//     } catch (e) {
//       print("Exception in generateOTP(): $e");
//       return -1;
//     }
//   }
// }



