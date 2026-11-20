import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';
import '../../../widgets/default_button.dart';
import '../../../widgets/screen_arguments.dart';
import '../../productdetails/product_detail_screen.dart';
import 'app_scroll_behavior.dart';

class SlidingCardsView extends StatefulWidget {
  SlidingCardsView({super.key, required this.selectedItems});

  List<dynamic> selectedItems = [];

  @override
  _SlidingCardsViewState createState() => _SlidingCardsViewState();
}

class _SlidingCardsViewState extends State<SlidingCardsView> {
  late PageController pageController;
  double pageOffset = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(viewportFraction: 0.8);
    pageController.addListener(() {
      setState(() => pageOffset = pageController.page!);
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        height: 560,
        child: PageView(
          controller: pageController,
          scrollBehavior: AppScrollBehavior(),
          children: <Widget>[
            for (int i = 0; i < widget.selectedItems.length; i++)
              SlidingCard(
                id: i,
                title: widget.selectedItems[i]['Title'],
                description: widget.selectedItems[i]['Description'],
                assetName: 'digital_account.jpg',
                itemDetailList: widget.selectedItems[i]['ItemsDetails'],
                offset: pageOffset - i,
              ),
          ],
        ),
      ),
    );
  }
}

class SlidingCard extends StatelessWidget {
  final int id;
  final String title;
  final String description;
  final String assetName;
  List<dynamic> itemDetailList = [];
  final double offset;

  SlidingCard(
      {super.key,
      required this.id,
      required this.title,
      required this.description,
      required this.assetName,
      required this.itemDetailList,
      required this.offset});

  @override
  Widget build(BuildContext context) {
    double gauss = math.exp(-(math.pow((offset.abs() - 0.5), 2) / 0.08));
    return Transform.translate(
      offset: Offset(-35 * gauss * offset.sign, 0),
      child: Card(
        margin: const EdgeInsets.only(left: 8, right: 8, bottom: 24),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.asset(
                'assets/images/$assetName',
                //height: MediaQuery.of(context).size.height * 0.30,
                height: 225,
                alignment: Alignment(-offset.abs(), 0),
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: CardContent(
                id: id,
                title: title,
                description: description,
                itemDetailList: itemDetailList,
                offset: gauss,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const kDefaultShadow = BoxShadow(
  offset: Offset(0, 4),
  blurRadius: 4,
  color: Colors.black26,
);

class CardContent extends StatelessWidget {
  final int id;
  final String title;
  final String description;
  List<dynamic> itemDetailList = [];
  final double offset;

  CardContent(
      {super.key,
      required this.id,
      required this.title,
      required this.description,
      required this.itemDetailList,
      required this.offset});

  @override
  Widget build(BuildContext context) {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: false);
    pr.style(
        message: 'Please wait...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: Center(
          child: SizedBox(
              width: 50, height: 50, child: CircularProgressIndicator()),
        ),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        //textDirection: TextDirection.rtl,
        padding: const EdgeInsets.all(16),
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Transform.translate(
              offset: Offset(8 * offset, 0),
              child: SizedBox(
                height: 40.0,
                child: Text(title, style: headingWhiteStyle),
              )),
          const SizedBox(height: 8),
          Transform.translate(
            offset: Offset(32 * offset, 0),
            child: SizedBox(
              height: 160.0,
              child: Text(
                description,
                style: labelStyle,
              ),
            ),
          ),
          //const Spacer(),
          Transform.translate(
            offset: Offset(32 * offset, 0),
            child: DefaultButton(
              text: "Apply Now",
              isDisable: true,
              press: () async {
                try {
                  await pr.show();
                  bool? isLocationFetched = await _determinePosition();
                  if (isLocationFetched != null && isLocationFetched == true) {
                    List<dynamic> itemDetails = itemDetailList[0];
                    await pr.hide();
                    // TODO: Bypass all the screens on the temporary bases.
                    Navigator.pushNamedAndRemoveUntil(
                        context,
                        ProductsDetailScreen.routeName,
                        arguments: ScreenArguments("", "", false, itemDetails),
                        (Route<dynamic> route) => true);
                    //Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (Route<dynamic> route) => false);
                    //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SampleDesignScreen()));
                    //Navigator.pushNamed(context, SignInScreen.routeName);
                  } else {
                    print('Location is not fetched...!');
                    await pr.hide();
                  }
                } catch (e) {
                  print('Exception in fetching location: $e');
                  if (pr.isShowing()) {
                    await pr.hide();
                  }
                }
              },
            ),
          ),
          //const Spacer(),
        ],
      ),
    );
  }

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
