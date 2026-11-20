import 'package:flutter/material.dart';
import 'package:mobile_onboarding/screens/account/account_request_screen.dart';
import 'package:mobile_onboarding/screens/contact_us/contact_us_screen.dart';
import 'package:mobile_onboarding/screens/dashboard/dashboard_screen.dart';
import 'package:mobile_onboarding/screens/profile/profile_screen.dart';
import 'package:mobile_onboarding/screens/requests/request_status_screen.dart';

import 'package:mobile_onboarding/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String lat = "";
  String long = "";
  String deviceInfo = "";

  @override
  Widget build(BuildContext context) {
    getDeviceLocation();
    getDeviceInfo();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20, top: 50, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, ProfileScreen.routeName);
                }, // Image tapped
                child: Image.asset(
                  "assets/images/ic_user_icon.png",
                  width: 24,
                  color: kPrimaryColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(greeting(), style: headingStyle),
            const Text("Welcome to Mobile Onboarding\nYour Journey Begins!",
                style: labelStyle),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, DashboardScreen.routeName);
                // Navigator.of(context).push(MaterialPageRoute(
                //     builder: (context) => DynamicForm(0, 0, false)));
              }, // Image tapped
              child: Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: kTileColorOne,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 6), // Shadow position
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text("Noor Cards", style: headingHomeStyle),
                    Image.asset(
                      "assets/images/loan_request.png",
                      width: 40,
                      height: 40,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AccountScreen.routeName);
              }, // Image tapped
              child: Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: kTileColorTwo,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 6), // Shadow position
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text("Personal Finance", style: headingHomeStyle),
                    Image.asset(
                      "assets/images/account_request.png",
                      width: 40,
                      height: 40,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, RequestStatusScreen.routeName);
              }, // Image tapped
              child: Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: kTileColorThree,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 6), // Shadow position
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text("Car Finance", style: headingHomeStyle),
                    Image.asset(
                      "assets/images/validation_icon.png",
                      width: 40,
                      height: 40,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, ContactScreen.routeName);
              }, // Image tapped
              child: Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: kTileColorFour,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 6), // Shadow position
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text("Housing Finance", style: headingHomeStyle),
                    Image.asset(
                      "assets/images/approval_icon.png",
                      width: 40,
                      height: 40,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, ContactScreen.routeName);
              }, // Image tapped
              child: Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: kTileColorFour,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 6), // Shadow position
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text("Faysal Takmeel", style: headingHomeStyle),
                    Image.asset(
                      "assets/images/approval_icon.png",
                      width: 40,
                      height: 40,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, ContactScreen.routeName);
              }, // Image tapped
              child: Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: kTileColorFour,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 6), // Shadow position
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text("Solar Solution", style: headingHomeStyle),
                    Image.asset(
                      "assets/images/approval_icon.png",
                      width: 40,
                      height: 40,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
                child: Align(
              alignment: FractionalOffset.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Device Location: Lat: $lat, Long: $long",
                      style: labelStyle),
                  Text("$deviceInfo", style: labelStyle),
                  const SizedBox(height: 15),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Hey, Good Morning';
    }
    if (hour < 17) {
      return 'Hey, Good Afternoon';
    }
    return 'Hey, Good Evening';
  }

  void getDeviceLocation() async {
    final prefs = await SharedPreferences.getInstance();
    lat = prefs.getString("lat")!;
    long = prefs.getString("long")!;
    setState(() {});
  }

  void getDeviceInfo() async {
    final prefs = await SharedPreferences.getInstance();
    deviceInfo = prefs.getString("device_info")!;
    setState(() {});
  }
}
