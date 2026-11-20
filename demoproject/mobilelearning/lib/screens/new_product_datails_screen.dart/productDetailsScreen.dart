import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/font_styles_roboto.dart';

import 'package:mobile_onboarding/screens/new_product_datails_screen.dart/components/FAQs_dropdown.dart';
import 'package:mobile_onboarding/screens/new_product_datails_screen.dart/components/appBar.dart';

import 'package:mobile_onboarding/screens/new_product_datails_screen.dart/components/productDetailsContent.dart';
import 'package:mobile_onboarding/screens/new_product_datails_screen.dart/components/youtube_player_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailScreen extends StatefulWidget {
  final String title;
  final List<dynamic> itemDetails;
  final String producID;

  // ignore: non_constant_identifier_names
  const ProductDetailScreen(
      {super.key,
      required this.title,
      required this.itemDetails,
      required this.producID});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool showApplyNow = false;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScaffoldBackground,
      appBar: CustomAppBar(),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            setState(() {
              showApplyNow = true;
            });
          } else if (scrollInfo.metrics.pixels <
              scrollInfo.metrics.maxScrollExtent - 50) {
            setState(() {
              showApplyNow = false;
            });
          }
          return true;
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: ElevatedButton(
            //     style: ButtonStyle(
            //       backgroundColor: MaterialStateProperty.all(newSecondaryColor),
            //     ),
            //     onPressed: () {},
            //     child: Text(
            //       widget.title,
            //       style: AppTextStyles.robotoMedium16WhiteButton,
            //     ),
            //   ),
            // ),
            // Embed YouTube video
            YoutubePlayerWidget(itemDetails: widget.itemDetails),
            Flexible(child: ItemDetailContent(itemDetails: widget.itemDetails)),

            ProductFAQWidget(
              productCode: widget.producID,
            ),
            const SizedBox(
              height: 15,
            ),
            // BottomActionButton(
            //     text: "Apply Now",
            //     onPressed: () async {
            //       _getDeviceInfo();
            //       // bool? isLocationFetched = await _determinePosition(context);
            //       Navigator.pushNamed(context, NewSignUpScreen.routeName);
            //     }),
          ],
        ),
      ),
    );
  }

  void _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    // print(
    // 'Device Information: ${androidDeviceInfo.device}, ${androidDeviceInfo.model}, ${androidDeviceInfo.androidId}, ${androidDeviceInfo.hardware}, Device ID: ${androidDeviceInfo.id}');
    final prefs = await SharedPreferences.getInstance();
    // prefs.setString("device_info",
    // 'Device Information: ${androidDeviceInfo.device}, ${androidDeviceInfo.model}, ${androidDeviceInfo.androidId}, ${androidDeviceInfo.hardware}');
    prefs.setString("device_id", '${androidDeviceInfo.id}');
    if (androidDeviceInfo != null) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool?> _determinePosition(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: const Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                  "Fetching location, please wait...",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Navigator.of(context).pop(); // Dismiss the loading dialog
        Fluttertoast.showToast(
          msg: "Location services are disabled.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Navigator.of(context).pop(); // Dismiss the loading dialog
          Fluttertoast.showToast(
            msg: "Location permissions are denied",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Navigator.of(context).pop(); // Dismiss the loading dialog
        Fluttertoast.showToast(
          msg:
              "Location permissions are permanently denied, we cannot request permissions.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      // When permissions are granted, get the current position
      Position position = await Geolocator.getCurrentPosition();
      Navigator.of(context).pop(); // Dismiss the loading dialog

      if (position != null) {
        print('Position of the device is $position');
        final prefs = await SharedPreferences.getInstance();
        prefs.setDouble("lat", position.latitude);
        prefs.setDouble("long", position.longitude);
        return true;
      }

      return false;
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss the loading dialog on error
      Fluttertoast.showToast(
        msg: "Error fetching location: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return Future.error('Error fetching location: $e');
    }
  }
}
