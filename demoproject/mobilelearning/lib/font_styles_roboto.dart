import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_onboarding/constants.dart';

class AppTextStyles {
  static TextStyle robotoBold24 = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 24.sp,
      fontWeight: FontWeight.bold,
      color: kPrimaryColor);

  static TextStyle robotoBold24white = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 24.sp,
      // fontWeight: FontWeight.bold,
      color: Colors.white);

  static TextStyle robotoMedium16TFleble = TextStyle(
      fontSize: 17.sp,
      fontWeight: FontWeight.w500, // Medium weight
      color: newSecondaryColor);
  static TextStyle robotoMedium18PH = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 18.sp,
      fontWeight: FontWeight.w700, // Medium weight
      color: newSecondaryColor);
  static TextStyle robotoMedium19PHblack = TextStyle(
      fontSize: 19.sp,
      fontWeight: FontWeight.w500, // Medium weight
      color: descriptionText);
  static TextStyle robotoMedium19PHSubBlack = TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w500, // Medium weight
      color: descriptionText);
  static TextStyle robotoMedium16TFhint = TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500, // Medium weight
      color: Colors.grey.shade400);

  static const TextStyle robotoMedium = TextStyle(
    fontWeight: FontWeight.w500, // Medium weight
  );

  static TextStyle robotoRegular13 = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.normal, // Regular weight
      color: descriptionText);

  static const TextStyle robotoMedium12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500, // Medium weight
  );
  static TextStyle robotoMedium13White = TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500, // Medium weight
      color: Colors.white);
  static TextStyle robotoMedium14White = TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500, // Medium weight
      color: Colors.white);
  static TextStyle robotoMedium18AppbarHeading = TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w500, // Medium weight
      color: Colors.grey);
  static TextStyle robotoMedium20White = TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w500, // Medium weight
      color: Colors.white);
  static TextStyle robotoMedium16WhiteButton = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 16.sp,
      fontWeight: FontWeight.w500, // Medium weight
      color: Colors.white);
  static TextStyle robotoBold16white = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 16.sp,
      fontWeight: FontWeight.bold,
      color: Colors.white);

  static const TextStyle robotoMedium18 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 18,
    fontWeight: FontWeight.w500, // Medium weight
  );

  static const TextStyle robotoMedium11 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 11,
    fontWeight: FontWeight.w500, // Medium weight
  );

  static const TextStyle robotoBold18 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
}
