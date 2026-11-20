import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/font_styles_roboto.dart';

class LocationTextField extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;

  LocationTextField({
    required this.controller,
    required this.placeholder,
    this.onChanged,
  });

  @override
  _LocationTextFieldState createState() => _LocationTextFieldState();
}

class _LocationTextFieldState extends State<LocationTextField> {
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceError();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionError();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionError();
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      String address =
          "${place.name},${place.street},${place.administrativeArea},${place.subAdministrativeArea},${place.locality}, ${place.country}";
      setState(() {
        widget.controller.text = address;
        if (widget.onChanged != null) {
          widget.onChanged!(address);
        }
      });
    }
  }

  void _showLocationServiceError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location services are disabled. Please enable them.'),
      ),
    );
  }

  void _showPermissionError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location permissions are denied. Please grant them.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // height: 72.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 22.0, left: 0, right: 0),
            child: TextFormField(
              // enableInteractiveSelection: false, // disables long-press menu
              // enableSuggestions:
              //     false, // optional: disables keyboard suggestions
              // autocorrect: false, // optional: disables auto-correct
              style: TextStyle(
                color: descriptionText,
                fontSize: 15.sp,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter ${widget.placeholder}';
                }
                return null;
              },
              onChanged: widget.onChanged,
              controller: widget.controller,
              decoration: InputDecoration(
                labelText: widget.placeholder,
                hintText: 'Please Enter ${widget.placeholder}',
                labelStyle: TextStyle(
                    color: newSecondaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 18.sp),
                hintStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500, // Medium weight
                    color: Colors.grey.shade400),
                border: _inputBorder(), // Consistent border behavior
                focusedBorder: _inputBorder(),
                enabledBorder: _inputBorder(),
                errorBorder: _inputBorder(),
                disabledBorder: _inputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 15.0,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.location_on_outlined),
                  onPressed: _getCurrentLocation,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _inputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none, // Keep the visual appearance of no border
    );
  }
}
