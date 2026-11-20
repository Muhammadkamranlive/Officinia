import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_onboarding/constants.dart';

class SimpleProgressBar extends StatelessWidget {
  final List<String> processes; // Steps in the process
  final int currentIndex; // Current step index

  SimpleProgressBar({required this.processes, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    // Ensure processes is not empty to avoid division by zero
    double progressValue =
        processes.isNotEmpty ? (currentIndex + 1) / processes.length : 0.0;

    // Clamp the progress value between 0.0 and 1.0
    progressValue = progressValue.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Display progress bar
        Padding(
          padding: EdgeInsets.only(top: 15.h, right: 16, left: 16),
          child: LinearProgressIndicator(
            minHeight: 6.h,
            value: progressValue, // Safe progress ratio
            backgroundColor: descriptionText, // Background color of the bar
            valueColor: const AlwaysStoppedAnimation<Color>(
                newSecondaryColor), // Progress color
          ),
        ),
        // Display current step below the progress bar
        Padding(
          padding: EdgeInsets.only(right: 13.w, top: 5), // Add some spacing
          child: Align(
            alignment: Alignment.topRight,
            child: Text(
              processes.isNotEmpty
                  ? 'Step ${currentIndex + 1}/${processes.length}'
                  : 'No steps available',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: descriptionText, // Customize text color
              ),
            ),
          ),
        ),
      ],
    );
  }
}
