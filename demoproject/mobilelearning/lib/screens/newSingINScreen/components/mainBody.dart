import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/io_client.dart';

import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/globlal_error_handler.dart';
import 'package:mobile_onboarding/helper/keyboard.dart';
import 'package:mobile_onboarding/screens/newSingInScreen/components/headingsSection.dart';
import 'package:mobile_onboarding/screens/otp/newSingIn_OTP_Screen/SingIn_OTP_Form.dart';
import 'package:mobile_onboarding/screens/otp/newSingIn_OTP_Screen/signIn_OTP_Screen.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';
import 'package:mobile_onboarding/utilities/dialog_boxes/dialog_class.dart';
import 'package:mobile_onboarding/utilities/otpExpiry/OtpExpiryChecker.dart';
import 'package:mobile_onboarding/utilities/securedData/secureDataHandler.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';

import 'package:mobile_onboarding/widgets/screen_arguments.dart';
import 'package:http/http.dart' as http;

import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../newSingInScreen/components/textFields.dart';

class MainBodyofSignIn extends StatefulWidget {
  const MainBodyofSignIn({super.key});

  @override
  _MainBodyofSignInState createState() => _MainBodyofSignInState();
}

class _MainBodyofSignInState extends State<MainBodyofSignIn> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String deviceId = "";
  bool _isConsentChecked = true;
  String? phoneNumber;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Future<int> callLoginAPI(String phoneNumber, String? deviceId) async {
  //   try {
  //     final header = await getGenericHeaders();
  //     final client = await createHttpClientWithPinnedCert();
  //     var uri = Uri.parse(
  //       "${getApiBaseUrl()}/Registration/CustomerLogin?mobileNumber=$phoneNumber&deviceID=$deviceId",
  //     );
  //     var response = await client.get(uri, headers: header);

  //     print("Complete API URL: $uri");
  //     print("Response received in callLoginAPI(): ${response.body}");

  //     if (response.statusCode == 200) {
  //       var data = jsonDecode(response.body);

  //       String? createdBy = data['createdby']?.toString();
  //       String? loginEmail = data['emailid'];
  //       print(loginEmail);
  //       // String? lastModified = data['lastmodifieddate']?.toString();

  //       // handle null safely

  //       SharedPreferences prefs = await SharedPreferences.getInstance();
  //       prefs.setString('loginEmail', loginEmail!);
  //       // SharedPreferences prefs = await SharedPreferences.getInstance();
  //       final storedCnic = await UserSecretStore.getCnic();
  //       final now = DateTime.now();
  //       print(now.toString());
  //       print("CreatedBy from API: $createdBy");
  //       print("Stored CNIC from SharedPreferences: $storedCnic");

  //       if (createdBy != null &&
  //           storedCnic != null &&
  //           createdBy == storedCnic) {
  //         return 200;
  //       } else {
  //         return 201;
  //       }
  //     } else {
  //       return response.statusCode;
  //     }
  //   } catch (e) {
  //     showError(e);
  //     print("Exception in callLoginAPI(): $e");
  //     return 0;
  //   } finally {
  //     // Always close the client to free up resources
  //   }
  // }
  Future<int> callLoginAPI(String phoneNumber, String? deviceId) async {
    IOClient? client;
    try {
      final baseHeaders = await getGenericHeaders();
      // Ensure JSON headers without breaking your existing ones
      final headers = Map<String, String>.from(baseHeaders)
        ..putIfAbsent('Accept', () => 'application/json')
        ..putIfAbsent('Content-Type', () => 'application/json');

      client = (await createHttpClientWithPinnedCert()) as IOClient?;

      // POST endpoint without query params
      final uri = Uri.parse("${getApiBaseUrl()}/Registration/Login");
      final storedCnic = await UserSecretStore.getCnic();

      // Sensitive values go in the body
      final body = {
        'mobileNumber': phoneNumber,
        if (deviceId != null) 'deviceID': deviceId, // keep same key as before
        'cnic': storedCnic
      };

      final response =
          await client!.post(uri, headers: headers, body: jsonEncode(body));

      print("Complete API URL: $uri"); // URL no longer contains sensitive data
      print("Response received in callLoginAPI(): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String? createdBy = data['createdby']?.toString();
        String? loginEmail = data['emailid'];
        print(loginEmail);

        final prefs = await SharedPreferences.getInstance();
        if (loginEmail != null) {
          prefs.setString('loginEmail', loginEmail);
        }

        final storedCnic = await UserSecretStore.getCnic();
        final now = DateTime.now();
        print(now.toString());
        print("CreatedBy from API: $createdBy");
        print("Stored CNIC from SharedPreferences: $storedCnic");

        if (createdBy != null &&
            storedCnic != null &&
            createdBy == storedCnic) {
          return 200;
        } else {
          return 201;
        }
      } else {
        return response.statusCode;
      }
    } catch (e) {
      showError(e);
      print("Exception in callLoginAPI(): $e");
      return 0;
    } finally {
      // Always close the client to free resources
      try {
        client?.close();
      } catch (_) {}
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: false);
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
        //textDirection: TextDirection.rtl,
        padding: const EdgeInsets.all(16),
        maxProgress: 100.0,
        progressTextStyle: const TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: const TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                const HeadingSection(),
                const SizedBox(height: 20),
                TextFieldsSection(
                  phoneController: _phoneController,
                  emailController: _emailController,
                ),
                const SizedBox(height: 20),
                // ConsentCheckboxSection(
                //   isChecked: _isConsentChecked,
                //   onChanged: (value) {
                //     setState(() {
                //       _isConsentChecked = value ?? false;
                //     });
                //   },
                // ),
              ],
            ),
            const Spacer(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 25.0, horizontal: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: newSecondaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    textStyle: circularboldButtonTitle20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10), // Rounded rectangular border
                    ),
                  ),
                  onPressed: _isConsentChecked
                      ? () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            KeyboardUtil.hideKeyboard(context);
                            String userNumber = _phoneController.text.trim();
                            if (!GlobalVars.isOtpAllowed) {
                              // If globally blocked, show message
                              ReusableDialogs.showErrorDialog(
                                context,
                                title: 'OTP Attempts Exceede',
                                message:
                                    'Your OTP attempts have been exceeded. Please retry after a minute.',
                              );
                              return;
                            }
                            // Add +92 when you need to use it
                            String fullNumber = '0$userNumber';
                            print("phone number with :${fullNumber}");

                            // await generateOTP(fullNumber);

                            final prefs = await SharedPreferences.getInstance();
                            String? deviceid = prefs.getString("device_id");

                            // if (deviceid == null || deviceid.isEmpty) {
                            //   Fluttertoast.showToast(
                            //     msg:
                            //         "Device ID not found. Please restart the app.",
                            //     toastLength: Toast.LENGTH_LONG,
                            //     gravity: ToastGravity.CENTER,
                            //     backgroundColor: Colors.red,
                            //     textColor: Colors.white,
                            //     fontSize: 16.0,
                            //   );
                            //   return;
                            // }
                            ReusableDialogs.showProgressDialog(context);
                            int statusCode =
                                await callLoginAPI(fullNumber, deviceid);
                            print("Status Code: $statusCode");

                            // callGetCustomerRegistrationAPI(fullNumber);
                            Navigator.pop(context);

                            if (statusCode == 200) {
                              // await prefs.setString(
                              //     'sign_in_number', fullNumber);
                              await UserSecretStore.saveSignNumber(fullNumber);
                              Navigator.pushNamed(
                                context,
                                SingInOtpScreen.routeName,
                                arguments: ScreenArguments(
                                  fullNumber,
                                  _emailController.text,
                                  false,
                                  [],
                                ),
                              );
                            } else if (statusCode == 201) {
                              Fluttertoast.showToast(
                                msg:
                                    "This number isn’t registered under CNIC you provided.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            } else if (statusCode == 401) {
                              Fluttertoast.showToast(
                                msg: "Un-Authorized User",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            } else if (statusCode == 404) {
                              Fluttertoast.showToast(
                                msg: "Kindly registered yourself",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            } else {
                              Fluttertoast.showToast(
                                msg: "Session Expire. please restart app",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                          } else {
                            print("Form validation failed");
                          }
                        }
                      : null,
                  child: Text(
                    "Continue",
                    style: _isConsentChecked
                        ? const TextStyle(color: Colors.white)
                        : TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
