import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_onboarding/constants.dart';

class CustomAppBarWithPopup extends StatefulWidget
    implements PreferredSizeWidget {
  final String? title; // Optional title for the AppBar
  final IconData? icon; // Optional icon for the trailing popup button
  final Widget? popupContent; // Optional custom content for the popup

  const CustomAppBarWithPopup({
    Key? key,
    this.title,
    this.icon,
    this.popupContent,
  }) : super(key: key);

  @override
  _CustomAppBarWithPopupState createState() => _CustomAppBarWithPopupState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarWithPopupState extends State<CustomAppBarWithPopup> {
  OverlayEntry? _popupOverlay;

  void _showPopup(BuildContext context) {
    // Only show the popup if popupContent is provided.
    if (widget.popupContent == null) return;

    final overlay = Overlay.of(context);
    if (_popupOverlay != null) return;

    _popupOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _hidePopup, // Dismiss the popup when tapping anywhere
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.transparent, // Transparent background
              ),
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
      backgroundColor: Colors.transparent,
      // Back button as the leading widget:
      leading: IconButton(
        icon:
            const FaIcon(FontAwesomeIcons.chevronLeft, color: descriptionText),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Text(
        widget.title ?? '',
        style: TextStyle(color: Colors.grey.shade700),
      ),
      // Only display the trailing popup icon if both icon and popupContent are provided.
      actions: (widget.icon != null && widget.popupContent != null)
          ? [
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
            ]
          : null,
    );
  }

  @override
  void dispose() {
    _hidePopup();
    super.dispose();
  }
}
