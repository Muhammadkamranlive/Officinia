import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_onboarding/screens/product_list/product_list_screen.dart';
import 'package:mobile_onboarding/screens/products/products_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';
import '../../../widgets/default_button.dart';
import '../../../widgets/screen_arguments.dart';
import '../../productdetails/product_detail_screen.dart';
import '../../sign_in/SignInScreen.dart';

class ProductCardDesign extends StatelessWidget {
  ProductCardDesign({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.assetName,
    required this.itemDetailList,
    required this.press,
  });

  final int id;
  final String title;
  final String description;
  final String assetName;
  List<dynamic> itemDetailList = [];
  final Function press;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20 / 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [kDefaultShadow],
      ),
      child: ListTile(
        onTap: () {},
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: size.width - 160,
              child: Text(
                title,
                style: headingStyleNew,
              ),
            ),
            SizedBox(
              height: 50,
              child: Image.asset('assets/images/$assetName'),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
/*            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: labelStyle,
            ),*/

            RichText(
              text: TextSpan(
                style: const TextStyle(color: kPrimaryLightColor),
                children: [
                  TextSpan(
                    text: description,
                    style: labelStyle,
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: 'Learn more',
                    style: learnMoreStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Navigator.pushNamed(context, ProductListScreen.routeName);
                        // List<dynamic> itemDetails = itemDetailList[0];
                        // Navigator.pushNamedAndRemoveUntil(
                        //     context,
                        //     ProductDetailScreen.routeName,
                        //     arguments:
                        //         ScreenArguments("", "", false, itemDetails),
                        // (Route<dynamic> route) => true);
                      },
                  )
                ],
              ),
              //maxLines: 4,
              //overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            DefaultButton(
              text: "Apply Now",
              isDisable: true,
              press: () async {
                try {
                  List<dynamic> itemDetails = itemDetailList[0];
                  Navigator.pushNamedAndRemoveUntil(
                      context,
                      ProductsDetailScreen.routeName,
                      arguments: ScreenArguments("", "", false, itemDetails),
                      (Route<dynamic> route) => true);
                } catch (e) {
                  // print('Exception in fetching location: $e');
                  // if (pr.isShowing()) {
                  //   await pr.hide();
                  // }
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void moveToNext() {}

  Future<bool?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      Fluttertoast.showToast(
          msg: "Location services are disabled.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        Fluttertoast.showToast(
            msg: "Location permissions are denied",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      Fluttertoast.showToast(
          msg:
              "Location permissions are permanently denied, we cannot request permissions.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();
    if (position != null) {
      print('Position of the device is $position');
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("lat", position.latitude.toString());
      prefs.setString("long", position.longitude.toString());
      return true;
    }
    return false;
  }
}
