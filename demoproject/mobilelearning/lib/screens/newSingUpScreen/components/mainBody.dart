import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/helper/keyboard.dart';
import 'package:mobile_onboarding/screens/newSingUpScreen/components/consentBox.dart';
import 'package:mobile_onboarding/screens/newSingUpScreen/components/headingsSection.dart';
import 'package:mobile_onboarding/screens/newSingUpScreen/components/textFields.dart';
import 'package:mobile_onboarding/screens/otp/newSingUP_OTP_Screen/signUp_OTP_Screen.dart';
import 'package:mobile_onboarding/screens/sign_up/components/utilities/api_service.dart';
import 'package:mobile_onboarding/utilities/parameters/otp_counter.dart';
import 'package:mobile_onboarding/utilities/securedData/secureDataHandler.dart';

import 'package:mobile_onboarding/widgets/account_login_text.dart';
import 'package:mobile_onboarding/widgets/screen_arguments.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainBodyofSignUP extends StatefulWidget {
  const MainBodyofSignUP({super.key});

  @override
  _MainBodyofSignUPState createState() => _MainBodyofSignUPState();
}

class _MainBodyofSignUPState extends State<MainBodyofSignUP> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String deviceId = "";
  bool _isConsentChecked = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                const AccountLoginText()
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: newSecondaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    textStyle: circularboldButtonTitle20,
                  ),
                  onPressed: _isConsentChecked
                      ? () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final prefs = await SharedPreferences.getInstance();
                            String userNumber = _phoneController.text.trim();

                            // Add 0 when you need to use it
                            String fullNumber = '0$userNumber';
                            print("phone number with +92:${fullNumber}");
                            // await prefs.setString('sign_in_number', fullNumber);
                            await UserSecretStore.saveSignNumber(fullNumber);
                            KeyboardUtil.hideKeyboard(context);

                            await pr.show();
                            // await generateOTP(fullNumber);

                            String deviceid = prefs.getString("device_id")!;
                            String? cnic = await UserSecretStore.getCnic();
                            prefs.setString(
                                'loginEmail', _emailController.text);
                            String statusMessage = await registerCustomer(
                                phoneNumber: fullNumber,
                                deviceId: deviceid,
                                email: _emailController.text,
                                createdBy: cnic!,
                                apiBaseUrl: getApiBaseUrl());
                            // print("Status Code: $statusCode");
                            // await pr.hide();
                            await pr.hide();
                            // // updated to 500 from 200
                            if (statusMessage == 'Old') {
                              print(statusMessage);
                              // await generateOTP(fullNumber);

                              Fluttertoast.showToast(
                                  msg: "Already Registed, Login please..",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } else if (statusMessage == 'OldC') {
                              Fluttertoast.showToast(
                                  msg: "CNIC Already Registered",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } else if (statusMessage == 'OldM') {
                              Fluttertoast.showToast(
                                  msg: "Mobile Number Already Registered",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } else if (statusMessage == 'New') {
                              Navigator.pushNamed(
                                context,
                                SingUpOtpScreen.routeName,
                                arguments: ScreenArguments(fullNumber,
                                    _emailController.text, true, []),
                              );
                              Fluttertoast.showToast(
                                  msg: "$statusMessage",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            }
                            // Navigator.pushNamed(
                            //   context,
                            //   SingUpOtpScreen.routeName,
                            //   arguments: ScreenArguments(_phoneController.text,
                            //       _emailController.text, true, []),
                            // );
                            // Perform actions like API calls
                            print("Form is valid");
                          } else {
                            print("Form validation failed");
                          }

                          // if all are valid then go to success screen
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
