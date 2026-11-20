import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_onboarding/constants.dart';

class TopRow extends StatefulWidget {
  @override
  State<TopRow> createState() => _TopRowState();
}

class _TopRowState extends State<TopRow> {
  OverlayEntry? _popupOverlay;
  void _showPopup(BuildContext context) {
    final overlay = Overlay.of(context);
    if (_popupOverlay != null) return;

    _popupOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _hidePopup, // Dismiss the popup when tapping anywhere
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                  color: Colors.transparent), // Transparent background
            ),
            Positioned(
              top: kToolbarHeight,
              right: 10,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                          "Please select a product and start your journey with us",
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay?.insert(_popupOverlay!);
  }

  void _hidePopup() {
    _popupOverlay?.remove();
    _popupOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Adjust padding as needed
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left image icon
          // IconButton(
          //   icon: const Icon(
          //     Icons.arrow_back_ios_new,
          //     color: newSecondaryColor,
          //   ),
          //   onPressed: () {
          //     Navigator.pop(context);
          //   },
          // ),
          Image.asset('assets/images/landingIcon.png',
              width: 45.w, height: 45.h),
          // GestureDetector(
          //     onTap: () {
          //       if (_popupOverlay == null) {
          //         _showPopup(context);
          //       } else {
          //         _hidePopup();
          //       }
          //     },
          //     child: Image.asset('assets/icon_Images/Help.png',
          //         width: 45.w, height: 45.h)),
        ],
      ),
    );
  }
}
