import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:mobile_onboarding/model/customers_registration.dart';
import 'package:mobile_onboarding/screens/otp/singUP_OTP_Screen/otp_screen_singup.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';

import 'package:mobile_onboarding/widgets/account_login_text.dart';
import 'package:mobile_onboarding/widgets/login_singup_button.dart';
import 'package:mobile_onboarding/widgets/terms_condition.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';
import '../../../helper/keyboard.dart';
import '../../../size_config.dart';
import '../../../widgets/screen_arguments.dart';
import '../../../widgets/custom_surfix_icon.dart';
import '../../../widgets/form_error.dart';

import 'package:http/http.dart' as http;

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool _isChecked = false;
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? phoneNumber;
  List<String?> errors = [];
  String deviceid = "";

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

  @override
  void initState() {
    getDeviceId();
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

    return Form(
      key: _formKey,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              /*Image.asset(
                getCompanyLogo(),
                width: 300,
                //color: const Color(0xFFf3ca20),
              ),*/
              // SizedBox(height: SizeConfig.screenFieldSize30),
              // SizedBox(height: SizeConfig.screenFieldSize20),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom * 0.3,
                ),
                child: Column(
                  children: [
                    buildPhoneNumberFormField(),
                    SizedBox(height: SizeConfig.screenFieldSize20),
                    buildEmailFormField(),
                    FormError(errors: errors),
                    SizedBox(height: SizeConfig.screenFieldSize5),
                  ],
                ),
              ),
              TermsCheckbox(
                isChecked: _isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    _isChecked = value ?? false;
                  });
                },
              ),
              SizedBox(height: SizeConfig.screenFieldSize40),
              LoginSingupButton(
                text: "Continue",
                isDisable: _isChecked,
                press: _isChecked
                    ? () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          // if all are valid then go to success screen
                          KeyboardUtil.hideKeyboard(context);

                          await pr.show();
                          await generateOTP();
                          int statusCode = await registerCustomer();
                          print("Status Code: $statusCode");
                          await pr.hide();
                          // updated to 500 from 200
                          if (statusCode == 200) {
                            Navigator.pushNamed(
                                context, OtpSingUpScreen.routeName,
                                arguments: ScreenArguments(
                                    phoneNumber, email, true, []));
                          } else {
                            Fluttertoast.showToast(
                                msg: "Status Code: $statusCode",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        }
                      }
                    : null,
              ),
              SizedBox(height: SizeConfig.screenFieldSize20),
              const AccountLoginText(),
              // SizedBox(height: SizeConfig.screenFieldSize40),
              /*Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'By continuing your confirm that you agree \nwith our Term and Condition',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.caption,
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  TextFormField buildPhoneNumberFormField() {
    return TextFormField(
      keyboardType: TextInputType.phone,
      onSaved: (newValue) => phoneNumber = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPhoneNumberNullError);
          if (value.length == 11) {
            removeError(error: kPhoneLengthError);
          }
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPhoneNumberNullError);
          // return "";
        } else if (value.length < 11 || value.length > 11) {
          //print("Enter in length Error");
          addError(error: kPhoneLengthError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        fillColor: Colors.white,
        filled: true,

        // labelText: "Phone Number",
        hintText: "Enter your phone number",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Phone.svg"),
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kEmailNullError);
          if (emailValidatorRegExp.hasMatch(value)) {
            removeError(error: kInvalidEmailError);
          }
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kEmailNullError);
          return "";
        } else if (!emailValidatorRegExp.hasMatch(value)) {
          addError(error: kInvalidEmailError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        fillColor: Colors.white,
        filled: true,
        // labelText: "Email",
        hintText: "Enter your email",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
      ),
    );
  }

  Future<void> generateOTP() async {
    try {
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/Registration/GenerateOTP?mobileNumber=$phoneNumber");
      var response = await client.get(uri);
      print(
          "Complete API URL: ${getApiBaseUrl()}/Registration/GenerateOTP?mobileNumber=$phoneNumber");
      print("Response received in generateOTP(): ${response.body.toString()}");
    } catch (e) {
      print("Exception in generateOTP(): $e");
    }
  }

  void getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      deviceid = prefs.getString("device_id")!;
      print("Device ID: $deviceid");
    } catch (e) {
      print("Exception in getDeviceId(): $e");
    }
  }

  Future<int> registerCustomer() async {
    try {
      CustomersRegistration customersRegistration = CustomersRegistration(
          phoneNumber!,
          deviceid,
          email!,
          "",
          "",
          "2024-02-07T11:07:40.075Z",
          "2024-02-07T11:07:40.075Z",
          {},
          false,
          "");
      String requestBody = jsonEncode(customersRegistration);
      print("Request Body: $requestBody");
      /*
      var client = http.Client();
      var uri = Uri.parse("${getApiBaseUrl()}/Registration/CustomersRegistration");
      var response = await client.post(uri, body: requestBody);
      print("Complete API URL: ${uri.toString()}");
      print("Response Received: ${response.body.toString()}");
       */
      final request = http.Request('POST',
          Uri.parse("${getApiBaseUrl()}/Registration/CustomersRegistration"));
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'application/json';
      request.body = requestBody;
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print("Response Received: ${response.body.toString()}");
      return response.statusCode;
    } catch (e) {
      print("Exception in registerCustomer(): $e");
      return 0;
    }
  }
}
