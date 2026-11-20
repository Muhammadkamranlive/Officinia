import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/database/database_helper.dart';
import 'package:mobile_onboarding/font_styles_roboto.dart';
import 'package:mobile_onboarding/model/loan_request_information.dart';

import 'package:mobile_onboarding/screens/newDashboard/alerts_status_screen.dart';
import 'package:mobile_onboarding/screens/noorcard/noor_card_screen.dart';
import 'package:mobile_onboarding/screens/otp/newSingIn_OTP_Screen/SingIn_OTP_Form.dart';
import 'package:mobile_onboarding/screens/otp/newSingIn_OTP_Screen/getProposal.dart';
import 'package:mobile_onboarding/screens/otp/singUP_OTP_Screen/components/autofiller_handler.dart';
import 'package:mobile_onboarding/size_config.dart';
import 'package:mobile_onboarding/utilities/api_services/getTockenService.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';
import 'package:mobile_onboarding/utilities/core_banking_data/providerClass.dart';
import 'package:mobile_onboarding/utilities/dialog_boxes/dialog_class.dart';
import 'package:mobile_onboarding/utilities/notification_handler/in_app_notification.dart';

import 'package:mobile_onboarding/utilities/parameters/provider.dart';
import 'package:mobile_onboarding/utilities/securedData/secureDataHandler.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';

import 'package:mobile_onboarding/widgets/form_error.dart';

import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import 'package:pinput/pinput.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignUpOtpForm extends StatefulWidget {
  SignUpOtpForm(
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
  _SignUpOtpFormState createState() => _SignUpOtpFormState();
}

class _SignUpOtpFormState extends State<SignUpOtpForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  int _wrongOtpAttempts = 0;
  String mobileOTPPin = "";
  String emailOTPPin = "";
  List<String?> errors = [];
  bool enableResend = false;
  bool isActive = false;
  late ProgressDialog pr;
  int count = 0;
  late AnimationController _controller;
  List<LoanRequestInformation> loanRequests = [];
  @override
  void initState() {
    super.initState();
    getLoanRequestsFromDB();
    pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: false);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: otptimer == 0 ? 60 : otptimer),
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

  Future<void> getLoanRequestsFromDB() async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      loanRequests = await databaseHelper.getAllLoanRequestInformation();
      if (loanRequests.isNotEmpty) {
        count = loanRequests.length;
      }
      setState(() {});
    } catch (e) {
      return null;
    }
  }

  void moveToNext() async {
    int proposalLength = await getProposalStatus();
    if (proposalLength == 0 && count == 0) {
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, NoorCardScreen.routeName);
      print("Navigating to NoorCard...");
    } else {
      Navigator.pushReplacementNamed(context, AlertsStatusScreen.routeName);
      print("Navigating to AlertsStatusScreen...");
    }

    widget._notificationService.showCustomNotification(
      'Successfully Signed-up',
      'You have successfully signed up',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final policyProvider = Provider.of<PolicyProvider>(context);
    bool emailParameter = policyProvider.getPolicyValue('email_field_singUP');
    bool mobileNumberParameter =
        policyProvider.getPolicyValue('mobile_number_singUP');

    print('is email OTP: ${emailParameter}');
    print('is sms OTP: ${mobileNumberParameter}');

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(
          fontSize: 20, color: newSecondaryColor, fontWeight: FontWeight.w400),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white),
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
                visible: mobileNumberParameter,
                child: Column(
                  children: [
                    Text(
                      "Enter Your OTP Here",
                      style: circularbookOtpWhite14,
                    ),
                    SizedBox(height: 20.h),
                    OTPAutofillWidget(
                      // onOtpReceived: (otp) async {
                      //   setState(() {
                      //     mobileOTPPin = otp;
                      //   });

                      // print("otp verified:status code verifyOTP():${statusCode}");

                      // if (statusCode == 200) {
                      //   print(statusCode);
                      //   // moveToNext();
                      //   print("OTP completed: $otp");
                      // }
                      // },
                      onOtpComplete: (otp) async {
                        FocusScope.of(context).unfocus();

                        // 1) Check if user is blocked
                        if (!GlobalVars.isOtpAllowed) {
                          // If globally blocked, show message
                          await ReusableDialogs.showOtpExceededDialog(context);
                          return;
                        }

                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        print("OTP completed: $otp");

                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        final secureStorage = FlutterSecureStorage();
                        final cnic = await UserSecretStore.getCnic();

                        ReusableDialogs.showProgressDialog(context);
                        int statusCode = await verifyOTP(otp);
                        Navigator.pop(context);
                        if (statusCode == 200) {
                          FocusScope.of(context).unfocus();
                          ReusableDialogs.showProgressDialog(context);
                          // ignore: use_build_context_synchronously
                          getAuthTokenAndCache(context);
                          //to use fetch data from core banking
                          final policyProvider = Provider.of<PolicyProvider>(
                              context,
                              listen: false);
                          bool enableClientInfo =
                              policyProvider.getPolicyValue('cbs');
                          if (enableClientInfo) {
                            await Provider.of<ClientProvider>(context,
                                    listen: false)
                                .fetchClientData(cnic!);
                            final clientInfo = Provider.of<ClientProvider>(
                                    context,
                                    listen: false)
                                .clientInfo;
                            print(clientInfo?.clientName);
                          }
                          FocusScope.of(context).unfocus();
                          moveToNext();
                        } else {
                          _wrongOtpAttempts++;
                          FocusScope.of(context).unfocus();
                          if (_wrongOtpAttempts < 3) {
                            ReusableDialogs.showErrorDialog(
                              context,
                              title: 'Not Verified',
                              message: 'Incorrect OTP. Please try again.',
                            );
                          }
                          print('on completed: not verified-----');
                          if (_wrongOtpAttempts >= 3) {
                            GlobalVars.isOtpAllowed = false; // block

                            await ReusableDialogs.showOtpExceededDialog(
                                context);
                            print('User has been blocked for 1 minute.');

                            // Use a timer to re-allow OTP after 1 minute
                            Timer(const Duration(minutes: 1), () {
                              GlobalVars.isOtpAllowed =
                                  true; // unblock after 1 minute
                              _wrongOtpAttempts = 0; // reset attempts
                              print(
                                  'User is unblocked now. isOtpAllowed = true');
                            });
                          }
                        }
                        // moveToNext();
                        // Handle OTP completion logic here
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: SizeConfig.screenFieldSize10),
              Visibility(
                visible: emailParameter,
                child: Column(
                  children: [
                    Text(
                      "We sent your code to ${widget.otpEmail}",
                      textAlign: TextAlign.center,
                      style: circularbookOtpWhite14,
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
              SizedBox(height: 20.h),
              buildTimer(),
              SizedBox(height: 20.h),
              Text(
                " In case you have not received an OTP,\nplease tap on Resend after the time end",
                // 'Incase you have not recieved and OTP, \n please tap on resend after timer ends',
                style: AppTextStyles.robotoMedium14White,
              ),
              SizedBox(height: SizeConfig.screenFieldSize20),
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
                    fontFamily: 'Circular',
                    decoration: TextDecoration.underline,
                    decorationColor: enableResend ? Colors.white : Colors.grey,
                    color: enableResend ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.screenFieldSize40),
              // LoginSingupButton(
              //   text: "Continue",
              //   isDisable: true,
              //   press: () async {
              //     if (_formKey.currentState!.validate()) {
              //       _formKey.currentState!.save();
              //       moveToNext();
              //       await pr.show();
              //       int statusCode = await verifyOTP();
              //       await pr.hide();
              //       KeyboardUtil.hideKeyboard(context);
              //       if (statusCode == 200) {
              //         if (isActive) {
              //           setState(() {
              //             removeError(error: kPhoneOTPNullError);
              //             if (!widget.isEmailVisible) {
              //               moveToNext();
              //             }
              //           });

              //           if (widget.isEmailVisible) {
              //             setState(() {
              //               removeError(error: kEmailOTPNullError);
              //               moveToNext();
              //             });
              //           }
              //         } else {
              //           setState(() {
              //             addError(error: kPhoneOTPNullError);
              //           });
              //           if (widget.isEmailVisible) {
              //             setState(() {
              //               addError(error: kEmailOTPNullError);
              //             });
              //           }
              //         }
              //       }
              //     }
              //   },
              // ),
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
        SizedBox(
            height: 25.h, child: Image.asset('assets/icon_Images/OTP.png')),
        SizedBox(width: 8.w),
        AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            return Row(
              children: [
                Text("${(60 - _controller.value * 60).toInt()}",
                    style: circularbookOtpWhite14),
                const SizedBox(width: 5),
                Text("Seconds", style: circularbookOtpWhite14),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<int> verifyOTP(String otp) async {
    try {
      final headers = await getGenericHeaders();
      var client = http.Client();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/Registration/VerifyOTP?mobileNumber=${widget.otpNumber}&smsOTP=$otp&emailOTP=$otp");
      print('requet of verify otp:${uri.toString()}');
      var response = await client.get(uri, headers: headers);
      final body = json.decode(response.body);
      // isActive = body['isactive'];
      print("otp verify response:${response.body}");
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
      print("Exception in generateOTP():$e");
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



