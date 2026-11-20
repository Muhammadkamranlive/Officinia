import 'dart:convert'; // For base64 decoding
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_onboarding/utilities/criteriaCheckService/ApiService.dart';
import 'package:mobile_onboarding/utilities/instructionsTable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart'; // Import the skeletonizer package

import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/font_styles_roboto.dart';
import 'package:mobile_onboarding/screens/loan/components/dynamic_form.dart';
import 'package:mobile_onboarding/screens/noorcard/components/instructionsAPI.dart';
import 'package:mobile_onboarding/utilities/internet_checker/connectivity_checker.dart';

class Body extends StatefulWidget {
  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Uint8List? imageBytes;
  Uint8List? imageBytes2; // second image
  bool _isLoading = false;
  // Example function to load instructions and decode images
  Future<void> loadInstructions() async {
    await getProductInstructions(product_attributes);
    if (globalProductImageBase64 == null || globalProductImageBase64!.isEmpty) {
      throw Exception("Global image base64 is empty.");
    }
    if (globalProductInstructionImageBase64 == null ||
        globalProductInstructionImageBase64!.isEmpty) {
      throw Exception("Global instruction image base64 is empty.");
    }
    // Decode the base64
    imageBytes = base64Decode(globalProductImageBase64!);
    imageBytes2 = base64Decode(globalProductInstructionImageBase64!);

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadInstructions();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ConnectivityBanner(),
        // First image (or skeleton)
        Expanded(
          flex: 1,
          child: _buildImageOrSkeleton(imageBytes),
        ),
        // Second image (or skeleton)
        Text(
          "Before You Start, We Request You To",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: newSecondaryColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold),
        ),
        const Expanded(flex: 1, child: ResponsiveInstructionTable()),
        // Expanded(
        //   flex: 1,
        //   child: _buildImageOrSkeleton(imageBytes2),
        // ),
        SizedBox(height: 20.h),
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: SizedBox(
            height: 50.h,
            width: double.infinity,
            child: ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(newSecondaryColor),
                shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              onPressed: _isLoading
                  ? null // Disable button while loading
                  : () async {
                      setState(() => _isLoading = true); // Show loading

                      try {
                        bool hasCameraPermission =
                            await requestCameraPermission(context);
                        bool hasMicPermission =
                            await requestMicPermission(context);

                        if (hasCameraPermission && hasMicPermission) {
                          final prefs = await SharedPreferences.getInstance();
                          final double? latitude = prefs.getDouble('lat');
                          final double? longitude = prefs.getDouble('long');

                          bool isCriteriaMet =
                              await checkEligibilityAndLocationAndMaybeWarn(
                            context,
                            longitude: longitude,
                            latitude: latitude,
                          );

                          if (!isCriteriaMet) return;

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  DynamicForm(0, 0, false, productType),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Permission not granted')),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isLoading = false); // Hide loading
                        }
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Continue',
                      style: AppTextStyles.robotoBold24white,
                    ),
            ),
          ),
        )
      ],
    );
  }

  /// Show skeleton if [bytes] is null, otherwise show the image
  Widget _buildImageOrSkeleton(Uint8List? bytes) {
    if (bytes == null) {
      // Show a skeleton placeholder
      return Skeletonizer(
        child: Container(
          width: double.infinity,
          color: Colors.grey[300],
        ),
      );
    } else {
      // Display the actual image
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: MemoryImage(bytes),
            fit: BoxFit.scaleDown,
          ),
        ),
      );
    }
  }
}

Future<bool> requestCameraPermission(BuildContext context) async {
  // Check current camera permission status
  var statusC = await Permission.camera.status;

  if (statusC.isGranted) {
    // If permission is already granted, just return true
    return true;
  } else {
    // Request camera permission from user
    var result = await Permission.camera.request();

    if (result.isGranted) {
      // If the user granted permission this time
      return true;
    } else if (result.isPermanentlyDenied) {
      // Permission is permanently denied (user selected "Don't ask again" or similar).
      // Show a dialog that navigates the user to their system's app settings.
      _showCameraSettingsDialog(context);
    }
    // If permission is denied (not permanently), return false
    return false;
  }
}

Future<bool> requestMicPermission(BuildContext context) async {
  // Check current camera permission status
  var statusMic = await Permission.microphone.status;

  if (statusMic.isGranted) {
    // If permission is already granted, just return true
    return true;
  } else {
    // Request camera permission from user
    var result = await Permission.microphone.request();

    if (result.isGranted) {
      // If the user granted permission this time
      return true;
    } else if (result.isPermanentlyDenied) {
      // Permission is permanently denied (user selected "Don't ask again" or similar).
      // Show a dialog that navigates the user to their system's app settings.
      _showMicSettingsDialog(context);
    }
    // If permission is denied (not permanently), return false
    return false;
  }
}

void _showCameraSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Camera Permission'),
      content: const Text(
          'Camera permission is permanently denied. Please enable it from settings.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Close the dialog
            Navigator.of(ctx).pop();
            // Open app settings so the user can enable permissions manually
            openAppSettings();
          },
          child: const Text('Settings'),
        ),
      ],
    ),
  );
}

void _showMicSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Microphone Permission'),
      content: const Text(
          'Microphone permission is permanently denied. Please enable it from settings.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Close the dialog
            Navigator.of(ctx).pop();
            // Open app settings so the user can enable permissions manually
            openAppSettings();
          },
          child: const Text('Settings'),
        ),
      ],
    ),
  );
}
