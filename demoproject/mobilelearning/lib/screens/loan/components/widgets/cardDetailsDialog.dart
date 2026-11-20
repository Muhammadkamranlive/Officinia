import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_onboarding/constants.dart';

class InfoDialogButton extends StatelessWidget {
  final String label;
  final String title;
  final String annualFee;
  final String fed;
  final String spendingReversal;
  final String duration;

  const InfoDialogButton({
    Key? key,
    required this.label,
    required this.title,
    required this.annualFee,
    required this.fed,
    required this.spendingReversal,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
          decoration: TextDecoration.underline,
        ),
      ),
      onPressed: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
            backgroundColor: Colors.transparent,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      top: 60, left: 20, right: 20, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Fee & reversal details
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Annual Fee + FED : ',
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            color: kPrimaryColor),
                                      ),
                                      Text(
                                        'PKR $annualFee + $fed',
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: kPrimaryColor),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12.h),
                                  Row(
                                    children: [
                                      Text(
                                        'Spending Reversal : ',
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            color: kPrimaryColor),
                                      ),
                                      Text(
                                        'PKR $spendingReversal in $duration',
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: kPrimaryColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              width: double.infinity,
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: disclaimerBG,
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16.sp,
                                    color: newSecondaryColor,
                                  ),
                                  SizedBox(width: 6.w),
                                  Flexible(
                                    child: Text(
                                      'Selected Card to be approved as per eligibility ',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Disclaimer box

                      const SizedBox(height: 20),

                      // Close button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: newSecondaryColor,
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -50,
                  left: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 50.h,
                    child: FaIcon(FontAwesomeIcons.idCard,
                        size: 50.h, color: newSecondaryColor),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Text(
        label,
        style: const TextStyle(
          color: descriptionText,
        ),
      ),
    );
  }
}
