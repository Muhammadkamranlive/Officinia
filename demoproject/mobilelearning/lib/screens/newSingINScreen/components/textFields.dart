import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/utilities/parameters/provider.dart';
import 'package:mobile_onboarding/widgets/newUITextField.dart';
import 'package:provider/provider.dart';

class TextFieldsSection extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController emailController;

  const TextFieldsSection({
    Key? key,
    required this.phoneController,
    required this.emailController,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    final policyProvider = Provider.of<PolicyProvider>(context);

    if (policyProvider.isLoading) {
      // If still fetching policies, show a loading indicator
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    otptimer = policyProvider.getIntPolicies('otp_timer');
    print('otp timer : ${otptimer}');
    bool emailParameter = policyProvider.getPolicyValue('email_field_singIN');
    bool mobileNumberParameter =
        policyProvider.getPolicyValue('mobile_number_singIN');

    return Column(
      children: [
        // Phone Number Field
        Visibility(
          visible: mobileNumberParameter,
          child: NewCustomTextField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
              FilteringTextInputFormatter.digitsOnly
            ],
            icon: Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+92',
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 15.sp),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 20,
                    width: 1,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            controller: phoneController,
            labelText: 'Mobile Number',
            hintText: 'Enter your Mobile Number',
            inputType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Mobile number is required';
              }
              if (value.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                return 'Enter a valid 10-digit mobile number';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        Visibility(
          visible: emailParameter,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                labelText: 'Email',
                labelStyle: PoppinRegular16,
                hintText: 'Enter your Email',
                hintStyle: PoppinRegular14,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 14.0, horizontal: 16.0),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}
