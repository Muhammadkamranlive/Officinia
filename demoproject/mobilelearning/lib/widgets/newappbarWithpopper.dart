import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';

class CustomAppBarWithPopup extends StatefulWidget
    implements PreferredSizeWidget {
  final String title; // Title for the AppBar
  final IconData icon; // Icon for the trailing button
  final Widget popupContent; // Custom content for the popup

  const CustomAppBarWithPopup({
    Key? key,
    required this.title,
    required this.icon,
    required this.popupContent,
  }) : super(key: key);

  @override
  _CustomAppBarWithPopupState createState() => _CustomAppBarWithPopupState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarWithPopupState extends State<CustomAppBarWithPopup> {
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
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: widget.popupContent,
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
    return AppBar(
      title: Text(widget.title, style: circularAppBarheading18),
      actions: [
        IconButton(
          icon: Icon(widget.icon, color: newSecondaryColor),
          onPressed: () {
            if (_popupOverlay == null) {
              _showPopup(context);
            } else {
              _hidePopup();
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _hidePopup();
    super.dispose();
  }
}
