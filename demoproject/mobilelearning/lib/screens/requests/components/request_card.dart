import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants.dart';

class RequestCard extends StatelessWidget {
  RequestCard(
      {super.key,
      required this.id,
      required this.status,
      required this.productName,
      required this.press,
      // required this.expiry,
      required this.showExpiry});

  final int id;
  final String status;
  final String productName;
  final VoidCallback press;
  // final String expiry;
  final bool showExpiry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 10, right: 20, left: 20, bottom: 10),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: kHeadingWhiteColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 23.h),
                    child: Text(
                      'Application Status',
                      style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Divider(color: kDividerColor, thickness: 0.5),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15, top: 10, right: 15, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Application ID',
                            style: requestLabelLeftStyle),
                        Text("$id", style: requestLabelRightStyle),
                      ],
                    ),
                  ),
                  const Divider(color: kDividerColor, thickness: 0.5),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15, top: 10, right: 15, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Product Applied',
                            style: requestLabelLeftStyle),
                        //Text(productName, style: requestLabelRightStyle),
                        Flexible(
                            child: Text(productName,
                                style: requestLabelRightStyle))
                      ],
                    ),
                  ),
                  const Divider(color: kDividerColor, thickness: 0.5),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15, top: 10, right: 15, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status', style: requestLabelLeftStyle),
                        Text(status, style: requestLabelRightStyle),
                      ],
                    ),
                  ),
                  // Visibility(
                  //     visible: showExpiry,
                  //     child:
                  //         const Divider(color: kDividerColor, thickness: 0.5)),
                  // Visibility(
                  //   visible: showExpiry,
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(
                  //         left: 15, top: 10, right: 15, bottom: 20),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         const Text('Expiry', style: requestLabelLeftStyle),
                  //         // Text('$expiry Days Left',
                  //         //     style: requestLabelRightStyle),
                  //       ],
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
