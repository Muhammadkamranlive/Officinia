// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';

// import 'package:local_auth/local_auth.dart';
// import 'package:mobile_onboarding/globlal_error_handler.dart';

// import 'package:mobile_onboarding/screens/dashboard/dashboard_screen.dart';
// import 'package:mobile_onboarding/screens/otp/newSingUP_OTP_Screen/signUp_OTP_Screen.dart';

// import 'package:mobile_onboarding/utilities/parameters/provider.dart';
// import 'package:mobile_onboarding/utilities/securedData/secureDataHandler.dart';
// import 'package:mobile_onboarding/widgets/app_launcher.dart';
// import 'package:mobile_onboarding/widgets/login_singup_button.dart';
// import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../../../constants.dart';
// import '../../../helper/PreferenceUtils.dart';
// import '../../../helper/keyboard.dart';
// import '../../../size_config.dart';
// import '../../../widgets/custom_surfix_icon.dart';
// import '../../../widgets/default_button_with_image.dart';
// import '../../../widgets/form_error.dart';
// import '../../../widgets/no_account_text.dart';
// import '../../../widgets/screen_arguments.dart';

// import 'package:http/http.dart' as http;

// class SignInForm extends StatefulWidget {
//   @override
//   _SignInFormState createState() => _SignInFormState();
// }

// enum _SupportState {
//   unknown,
//   supported,
//   unsupported,
// }

// class _SignInFormState extends State<SignInForm> {
//   final _formKey = GlobalKey<FormState>();
//   String? phoneNumber;
//   bool biometricEnable = false;
//   List<String?> errors = [];
//   String deviceId = "";
//   String? email;
//   final LocalAuthentication auth = LocalAuthentication();
//   _SupportState _supportState = _SupportState.unknown;
//   bool? _canCheckBiometrics;
//   List<BiometricType>? _availableBiometrics;
//   String _authorized = 'Not Authorized';
//   bool _isAuthenticating = false;

//   void checkBiometricSettings() {
//     biometricEnable = PreferenceUtils.getBool(biometricLogin);
//     if (kDebugMode) {
//       print("Biometric Enables : ${biometricEnable}");
//     }
//   }

//   Future<void> _checkBiometrics() async {
//     late bool canCheckBiometrics;
//     try {
//       canCheckBiometrics = await auth.canCheckBiometrics;
//     } on PlatformException catch (e) {
//       canCheckBiometrics = false;
//       print(e);
//     }
//     if (!mounted) {
//       return;
//     }

//     setState(() {
//       _canCheckBiometrics = canCheckBiometrics;
//     });
//   }

//   Future<void> _getAvailableBiometrics() async {
//     late List<BiometricType> availableBiometrics;
//     try {
//       availableBiometrics = await auth.getAvailableBiometrics();
//     } on PlatformException catch (e) {
//       availableBiometrics = <BiometricType>[];
//       print(e);
//     }
//     if (!mounted) {
//       return;
//     }

//     setState(() {
//       _availableBiometrics = availableBiometrics;
//     });
//   }

//   // Future<void> _authenticate() async {
//   //   bool authenticated = false;
//   //   try {
//   //     setState(() {
//   //       _isAuthenticating = true;
//   //       _authorized = 'Authenticating';
//   //     });
//   //     authenticated = await auth.authenticate(
//   //       localizedReason: 'Let OS determine authentication method',
//   //       options: const AuthenticationOptions(
//   //         stickyAuth: true,
//   //       ),
//   //     );
//   //     setState(() {
//   //       _isAuthenticating = false;
//   //     });
//   //   } on PlatformException catch (e) {
//   //     print(e);
//   //     setState(() {
//   //       _isAuthenticating = false;
//   //       _authorized = 'Error - ${e.message}';
//   //     });
//   //     return;
//   //   }
//   //   if (!mounted) {
//   //     return;
//   //   }

//   //   setState(() {
//   //     _authorized = authenticated ? 'Authorized' : 'Not Authorized';
//   //     print("Authorized Status : ${_authorized}");
//   //     if (_authorized == "Authorized") {
//   //       Navigator.pushNamedAndRemoveUntil(context, DashboardScreen.routeName,
//   //           (Route<dynamic> route) => false);
//   //     }
//   //   });
//   // }

//   // Future<void> _cancelAuthentication() async {
//   //   await auth.stopAuthentication();
//   //   setState(() => _isAuthenticating = false);
//   // }

//   Future<void> _authenticate() async {
//     bool authenticated = false;

//     try {
//       setState(() {
//         _isAuthenticating = true;
//         _authorized = 'Authenticating';
//       });

//       authenticated = await auth.authenticate(
//         localizedReason: 'Let OS determine authentication method',
//         options: AuthenticationOptions(
//           stickyAuth: true,
//           biometricOnly: false, // Optional but recommended
//         ),
//       );

//       setState(() {
//         _isAuthenticating = false;
//       });
//     } on PlatformException catch (e) {
//       print(e);
//       setState(() {
//         _isAuthenticating = false;
//         _authorized = 'Error - ${e.message}';
//       });
//       return;
//     }

//     if (!mounted) return;

//     setState(() {
//       _authorized = authenticated ? 'Authorized' : 'Not Authorized';
//       print("Authorized Status : $_authorized");

//       if (authenticated) {
//         Navigator.pushNamedAndRemoveUntil(
//           context,
//           DashboardScreen.routeName,
//           (Route<dynamic> route) => false,
//         );
//       }
//     });
//   }

//   Future<void> _cancelAuthentication() async {
//     await auth.stopAuthentication();
//     setState(() => _isAuthenticating = false);
//   }

// //Block ends here
//   @override
//   void initState() {
//     checkBiometricSettings();
//     _checkBiometrics();
//     _getAvailableBiometrics();
//     _getDeviceId();
//     auth.isDeviceSupported().then(
//           (bool isSupported) => setState(() => _supportState = isSupported
//               ? _SupportState.supported
//               : _SupportState.unsupported),
//         );
//     super.initState();
//   }

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
//   Widget build(BuildContext context) {
//     final policyProvider = Provider.of<PolicyProvider>(context);
//     bool emailParameter = policyProvider.getPolicyValue('email_field_singIN');
//     bool mobileNumberParameter =
//         policyProvider.getPolicyValue('mobile_number_singIN');
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
//         //textDirection: TextDirection.rtl,
//         padding: const EdgeInsets.all(16),
//         maxProgress: 100.0,
//         progressTextStyle: const TextStyle(
//             color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
//         messageTextStyle: const TextStyle(
//             color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));

//     return Form(
//       key: _formKey,
//       child: Center(
//         child: Container(
//           margin: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               /*Image.asset(
//                 getCompanyLogo(),
//                 width: 300,
//                 //color: const Color(0xFFf3ca20),
//               ),*/
//               SizedBox(height: SizeConfig.screenFieldSize25),
//               Visibility(
//                 visible: mobileNumberParameter,
//                 child: buildPhoneNumberFormField(),
//               ),
//               SizedBox(height: SizeConfig.screenFieldSize20),
//               Visibility(visible: emailParameter, child: buildEmailFormField()),
//               FormError(errors: errors),
//               SizedBox(height: SizeConfig.screenFieldSize25),
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: LoginSingupButton(
//                   text: "Continue",
//                   isDisable: true,
//                   press: () async {
//                     if (_formKey.currentState!.validate()) {
//                       _formKey.currentState!.save();

//                       KeyboardUtil.hideKeyboard(context);

//                       // await pr.show();
//                       // int statusCode = await callLoginAPI();
//                       // print("Status Code: $statusCode");
//                       // await pr.hide();
//                       //
//                       // if (statusCode == 200) {
//                       // if(Customer device has changed, kindly register yourself){
//                       //
//                       // }
//                       final prefs = await SharedPreferences.getInstance();
//                       await UserSecretStore.saveSignNumber(phoneNumber!);
//                       // if all are valid then go to success screen
//                       Navigator.pushNamedAndRemoveUntil(
//                           context,
//                           SingUpOtpScreen.routeName,
//                           arguments:
//                               ScreenArguments(phoneNumber, "", false, []),
//                           (Route<dynamic> route) => false);
//                       /* Navigator.pushNamedAndRemoveUntil(context,
//                         HomeScreen.routeName, (Route<dynamic> route) => false);*/
//                       // } else {
//                       //   Fluttertoast.showToast(
//                       //       msg: "Status Code: $statusCode",
//                       //       toastLength: Toast.LENGTH_SHORT,
//                       //       gravity: ToastGravity.CENTER,
//                       //       timeInSecForIosWeb: 1,
//                       //       backgroundColor: Colors.red,
//                       //       textColor: Colors.white,
//                       //       fontSize: 16.0);
//                       // }
//                     }
//                   },
//                 ),
//               ),
//               SizedBox(
//                 height: SizeConfig.screenFieldSize10,
//               ),
//               const NoAccountText(),
//               SizedBox(height: SizeConfig.screenFieldSize20),
//               AppLauncher(),
//               Visibility(
//                 visible: biometricEnable,
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       height: SizeConfig.screenFieldSize20,
//                     ),
//                     const Text("Authenticate using your fingerprint",
//                         style: labelStyleforauthentication),
//                     SizedBox(height: SizeConfig.screenFieldSize5),
//                     DefaultImageButton(
//                       text: "Authenticate",
//                       icon: "assets/icons/ic_fingerprint.svg",
//                       press: () {
//                         _authenticate();
//                       },
//                     ),
//                     SizedBox(height: SizeConfig.screenFieldSize10),
//                     if (_supportState == _SupportState.unknown)
//                       const CircularProgressIndicator()
//                     else if (_supportState == _SupportState.supported)
//                       const Text('This device is supported',
//                           style: TextStyle(
//                             fontSize: 15,
//                             color: Colors.green,
//                           ))
//                     else
//                       const Text(
//                         'This device is not supported',
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: Colors.red,
//                         ),
//                       ),
//                     SizedBox(height: SizeConfig.screenFieldSize40),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   TextFormField buildPhoneNumberFormField() {
//     return TextFormField(
//       keyboardType: TextInputType.phone,
//       onSaved: (newValue) => phoneNumber = newValue,
//       onChanged: (value) {
//         if (value.isNotEmpty) {
//           removeError(error: kPhoneNumberNullError);
//           if (value.length == 11) {
//             removeError(error: kPhoneLengthError);
//           }
//         }
//         return null;
//       },
//       validator: (value) {
//         if (value!.isEmpty) {
//           addError(error: kPhoneNumberNullError);
//           return "";
//         } else if (value.length < 11 || value.length > 11) {
//           //print("Enter in length Error");
//           addError(error: kPhoneLengthError);
//           return "";
//         }
//         return null;
//       },
//       decoration: const InputDecoration(
//         fillColor: Colors.white,
//         filled: true,

//         hintText: "Enter your phone number",
//         // If  you are using latest version of flutter then lable text and hint text shown like this
//         // if you r using flutter less then 1.20.* then maybe this is not working properly
//         floatingLabelBehavior: FloatingLabelBehavior.always,
//         suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Phone.svg"),
//       ),
//     );
//   }

//   TextFormField buildEmailFormField() {
//     return TextFormField(
//       keyboardType: TextInputType.emailAddress,
//       onSaved: (newValue) => email = newValue,
//       onChanged: (value) {
//         if (value.isNotEmpty) {
//           removeError(error: kEmailNullError);
//           if (emailValidatorRegExp.hasMatch(value)) {
//             removeError(error: kInvalidEmailError);
//           }
//         }
//         return null;
//       },
//       validator: (value) {
//         if (value!.isEmpty) {
//           addError(error: kEmailNullError);
//           return "";
//         } else if (!emailValidatorRegExp.hasMatch(value)) {
//           addError(error: kInvalidEmailError);
//           return "";
//         }
//         return null;
//       },
//       decoration: const InputDecoration(
//         fillColor: Colors.white,
//         filled: true,
//         // labelText: "Email",
//         hintText: "Enter your email",
//         // If  you are using latest version of flutter then lable text and hint text shown like this
//         // if you r using flutter less then 1.20.* then maybe this is not working properly
//         floatingLabelBehavior: FloatingLabelBehavior.always,
//         suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
//       ),
//     );
//   }

//   void _getDeviceId() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       deviceId = prefs.getString("device_id")!;
//       print("Device ID: $deviceId");
//     } catch (e) {
//       print("Exception in getDeviceId(): $e");
//     }
//   }

//   Future<int> callLoginAPI() async {
//     try {
//       var client = http.Client();
//       var uri = Uri.parse(
//           "${getApiBaseUrl()}/Registration/CustomerLogin?mobileNumber=$phoneNumber&deviceID=$deviceId");
//       var response = await client.get(uri);
//       print(
//           "Complete API URL: ${getApiBaseUrl()}/Registration/CustomerLogin?mobileNumber=$phoneNumber&deviceID=$deviceId");
//       print("Response received in verifyOTP(): ${response.body.toString()}");

//       return response.statusCode;
//     } catch (e) {
//       showError(e);
//       print("Exception in verifyOTP(): $e");
//       return 0;
//     }
//   }
// }
