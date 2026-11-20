import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:app_settings/app_settings.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/font_styles_roboto.dart';
import 'package:mobile_onboarding/screens/new_product_list/product_list_main.dart';
import 'package:mobile_onboarding/utilities/api_services/getTockenService.dart';

import 'package:mobile_onboarding/utilities/dialog_boxes/dialog_class.dart';
import 'package:mobile_onboarding/utilities/securedData/secureDataHandler.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LandingPageBody extends StatefulWidget {
  const LandingPageBody({super.key});

  @override
  _LandingPageBodyState createState() => _LandingPageBodyState();
}

class _LandingPageBodyState extends State<LandingPageBody> {
  final TextEditingController _cnicController = TextEditingController();
  String? _errorMessage;
//locations
  Future<bool?> _determinePosition(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final bool? turnedOn = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("Location Disabled"),
            content: const Text("Please enable location services to continue."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                  Navigator.pop(ctx, true);
                },
                child: const Text("Open Settings"),
              ),
            ],
          ),
        );

        if (turnedOn != true) {
          _showErrorAndExit(
              context, "Location services are required to proceed.");
          return null;
        }

        // Re-check after settings
        final bool nowEnabled = await Geolocator.isLocationServiceEnabled();
        if (!nowEnabled) {
          _showErrorAndExit(
              context, "Location is still disabled. Please try again.");
          return null;
        }
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Navigator.of(context).pop(); // Dismiss the loading dialog
          _showErrorAndExit(
            context,
            "Location permissions are denied. Please grant permissions to proceed.",
          );
          return null;
        }
      }
      if (!serviceEnabled) {
        final bool? turnedOn = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("Location Disabled"),
            content: const Text("Please enable location services to continue."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                  Navigator.pop(ctx, true);
                },
                child: const Text("Open Settings"),
              ),
            ],
          ),
        );

        if (turnedOn == true) {
          // Re-check after user returns from settings
          final bool nowEnabled = await Geolocator.isLocationServiceEnabled();
          if (!nowEnabled) {
            _showErrorAndExit(
                context, "Location is still disabled. Please try again.");
            return null;
          }
          // Continue to permission check
        } else {
          _showErrorAndExit(
              context, "Location services are required to proceed.");
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        Navigator.of(context).pop();
        // Dismiss the loading dialog
        _showErrorAndExit(
          context,
          "Location permissions are permanently denied. Please enable permissions in the app settings.",
        );
        return null;
      }

      Position position = await Geolocator.getCurrentPosition();

      if (position != null) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setDouble("lat", position.latitude);
        prefs.setDouble("long", position.longitude);
        return true;
      }

      _showErrorAndExit(
        context,
        "Unable to fetch the location. Please try again.",
      );
      return null;
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss the loading dialog on error
      _showErrorAndExit(
        context,
        "Error fetching location: $e",
      );
      return null;
    }
  }

  void _showErrorAndExit(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                AppSettings.openAppSettings(type: AppSettingsType.location);
                // exit(0); // Exit the app
              },
              child: const Text("Turn on Location"),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Icon(
            Icons.error,
            color: Colors.red,
            size: 50,
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onSubmit() async {
    FocusScope.of(context).unfocus();

    final cnic1 = _cnicController.text.trim();
    final cnic = cnic1.replaceAll('-', '');

    if (cnic.isEmpty || cnic.length != 13) {
      setState(
          () => _errorMessage = 'Please enter a valid 13-digit CNIC number.');
      return;
    }

    ReusableDialogs.showProgressDialog(context);

    bool? isLocationFetched = await _determinePosition(context);
    setState(() => _errorMessage = null);
    await UserSecretStore.saveCnic(cnic);

    Navigator.pop(context);

    if (!isLocationFetched!) {
      ReusableDialogs.showErrorDialog(context,
          title: "Location can't be fetched");
      return;
    }

    final tokenSuccess = await getTokenAndCache(cnic, context);

    if (tokenSuccess) {
      Navigator.pushNamed(context, NewProductListScreen.routeName);
    }
  }
  // Submit function
  // Future<void> _onSubmit() async {
  //   FocusScope.of(context).unfocus();

  //   final cnic1 = _cnicController.text.trim();
  //   final cnic = cnic1.replaceAll('-', '');
  //   print(cnic);

  //   // Validation check
  //   if (cnic.isEmpty || cnic.length != 13) {
  //     setState(() {
  //       _errorMessage = 'Please enter a valid 13-digit CNIC number.';
  //     });

  //     return;
  //   }
  //   ReusableDialogs.showProgressDialog(context);
  //   bool? isLocationFetched = await _determinePosition(context);

  //   setState(() {
  //     _errorMessage = null;
  //   });

  //   await UserSecretStore.saveCnic(cnic);
  //   // fatching data from connect 360
  //   // await Provider.of<CustomerProvider>(context, listen: false)
  //   //     .fetchCustomerData(context, cnic);
  //   // // for using data fetch from connect 360
  //   // final customerData = Provider.of<CustomerProvider>(context).customerData;
  //   // _cnicController.clear();
  //   Navigator.pop(context);
  //   // print(customerData!.companyName);
  //   if (isLocationFetched!) {
  //     await getTokenAndCache(cnic, context);
  //     Navigator.pushNamed(context, NewProductListScreen.routeName);
  //   } else {
  //     ReusableDialogs.showErrorDialog(context, title: "Location cant Fetched");
  //   }

  //   // Navigate to next screen
  //   // Navigator.push(
  //   //   context,
  //   //   MaterialPageRoute(builder: (context) => NextScreen()),
  //   // );
  // }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Padding(
          padding: EdgeInsets.only(left: 15, right: 15, bottom: bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // const ImageSlider(),
              // const HeadingText(),
              // const DescriptionText(),
              // NewCustomTextField(
              //   controller: _cnicController,
              //   errorMessage: _errorMessage,
              //   icon: const Icon(
              //     Icons.credit_card,
              //     color: newSecondaryColor,
              //   ),
              //   labelText: 'CNIC',
              //   hintText: 'Enter your CNIC number',
              //   inputType: TextInputType.number,
              // ),
              CNIC_textField(
                errorMessage: _errorMessage,
                controller: _cnicController,
              ),
              SubmitButton(
                onSubmit: _onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Banner Image Widget
class BannerImage extends StatelessWidget {
  const BannerImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Image.asset(
              'assets/icon_Images/FBL_lOGO _1.png',
              width: 200.w,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

// Image Slider Widget
class ImageSlider extends StatefulWidget {
  const ImageSlider({super.key});

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double sliderHeight = MediaQuery.of(context).size.height * 0.35;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: sliderHeight,
          width: 350,
          child: PageView(
            controller: _pageController,
            children: [
              Image.asset('assets/images/landingPage.png', fit: BoxFit.fill),
              Image.asset('assets/images/landingPage.png', fit: BoxFit.fill),
              Image.asset('assets/images/card_1.png', fit: BoxFit.fill),
            ],
          ),
        ),
        const SizedBox(height: 8), // Space between slider and indicators
        SmoothPageIndicator(
          controller: _pageController,
          count: 3,
          effect: const ExpandingDotsEffect(
            activeDotColor: newSecondaryColor,
            dotHeight: 10,
            dotWidth: 10,
            spacing: 8,
          ),
        ),
      ],
    );
  }
}

// Heading Text Widget
class HeadingText extends StatelessWidget {
  const HeadingText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Lets Begin Your Journey',
            // style: AppTextStyles.robotoBold24,
            style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor),
          )),
    );
  }
}

// Description Text Widget
class DescriptionText extends StatelessWidget {
  const DescriptionText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.0),
      child: Text(
        'Get the best loan options tailored to your needs. Fill out the form below to apply for a bank loan with ease and security.',
        style: AppTextStyles.robotoRegular13,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class CNIC_textField extends StatelessWidget {
  // final FocusNode myFocusNode = FocusNode();
  final TextEditingController controller;
  final String? errorMessage;

  CNIC_textField({required this.controller, this.errorMessage});

  // void _formatCNIC(String value) {
  //   // Remove any existing dashes
  //   String formatted = value.replaceAll('-', '');

  //   if (formatted.length > 5 && formatted.length <= 12) {
  //     formatted = '${formatted.substring(0, 5)}-${formatted.substring(5)}';
  //   } else if (formatted.length > 12) {
  //     formatted =
  //         '${formatted.substring(0, 5)}-${formatted.substring(5, 12)}-${formatted.substring(12)}';
  //   }

  //   // Update the controller value and cursor position
  //   controller.value = TextEditingValue(
  //     text: formatted,
  //     selection: TextSelection.collapsed(offset: formatted.length),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, left: 0, right: 0),
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.08,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white, // White background
              border: Border.all(color: Colors.white), // White borders
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: TextField(
              enableInteractiveSelection: false,
              enableSuggestions: false,
              autocorrect: false,
              inputFormatters: [CNICTextInputFormatter()],
              controller: controller,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/icon_Images/CNIC.png',
                    height: 15.h,
                  ),
                ), // CNIC icon at the start
                labelText: 'CNIC',
                // "CNIC" text inside the field
                labelStyle: AppTextStyles
                    .robotoMedium16TFleble, // Grey label color for contrast
                hintText: 'XXXXX-XXXXXXX-X',
                hintStyle: AppTextStyles.robotoMedium16TFhint,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none, // No visible outline
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
              ),
              buildCounter: (context,
                      {required int currentLength,
                      required bool isFocused,
                      required int? maxLength}) =>
                  null,
              keyboardType: TextInputType.number,
              maxLength: 15,
              style: const TextStyle(fontSize: 16),
              // focusNode: myFocusNode,
              // onTap: () => myFocusNode.requestFocus(),
              onChanged: (value) {
                // _formatCNIC(value);
              },
            ),
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class SubmitButton extends StatefulWidget {
  final VoidCallback onSubmit;

  SubmitButton({required this.onSubmit});

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 15.0,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.07,
        decoration: BoxDecoration(
          color: newSecondaryColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: widget.onSubmit,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: newSecondaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            textStyle: const TextStyle(fontSize: 18),
          ),
          child: Text(
            'Lets Begin!',
            style: AppTextStyles.robotoMedium20White,
          ),
        ),
      ),
    );
  }
}

class CNICTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Get only digits
    String digitsOnly = newValue.text.replaceAll('-', '');

    // 2. Build the new formatted string
    String formatted;
    if (digitsOnly.length > 12) {
      formatted =
          '${digitsOnly.substring(0, 5)}-${digitsOnly.substring(5, 12)}-${digitsOnly.substring(12)}';
    } else if (digitsOnly.length > 5) {
      formatted = '${digitsOnly.substring(0, 5)}-${digitsOnly.substring(5)}';
    } else {
      formatted = digitsOnly;
    }

    // 3. Return a new TextEditingValue with the same selection offset
    //    adjusted for any added dashes.
    int offset =
        formatted.length - (newValue.text.length - newValue.selection.end);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
