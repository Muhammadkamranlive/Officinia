import 'package:client/AppColors/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void showCustomToast(String message,BuildContext context) {

  MotionToast(
    icon: Icons.error_outline,
    iconSize: 28,
    
    primaryColor: AppColors.greenCeladon,
    description: Text(
      message,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    toastAlignment: Alignment.bottomCenter,        // ✅ replaces position
    animationType: AnimationType.slideInFromBottom, // ✅ replaces fromBottom
    animationDuration: const Duration(milliseconds: 300),
    toastDuration: Duration(seconds: 6),
    width: double.infinity,
    height: 100,
    borderRadius: 16,
  ).show(context);
}

void showErrorToast(String message, {int seconds = 4}) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  MotionToast(
    icon: Icons.error_outline,
    primaryColor: Colors.redAccent,
    description: Text(
      message,
      style: const TextStyle(color: Colors.white, fontSize: 14),
    ),
    toastAlignment: Alignment.bottomCenter,
    animationType: AnimationType.slideInFromBottom,
    toastDuration: Duration(seconds: seconds),
    width: double.infinity,
    height: 60,
    borderRadius: 16,
  ).show(context);
}