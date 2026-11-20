import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_onboarding/screens/dashboard/dashboard_screen.dart';
import 'package:mobile_onboarding/screens/requests/request_status_screen.dart';
import 'package:mobile_onboarding/utilities/api_services/products_loctionChecker.dart';
import 'package:mobile_onboarding/utilities/parameters/provider.dart';

import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';
import '../../../model/form_field_data.dart';
import '../../../widgets/default_button.dart';
import '../../sign_up/sign_up_screen.dart';

class ProductDetailForm extends StatefulWidget {
  ProductDetailForm(
    this.itemDetails, {
    Key? key,
  }) : super(key: key);

  List<dynamic> itemDetails;

  @override
  _ProductDetailFormState createState() => _ProductDetailFormState();
}

class _ProductDetailFormState extends State<ProductDetailForm> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  bool isChecking = false;

  List<FormFieldData> formFields = [];

  Future<void> _loadFormDataFromArray() async {
    try {
      formFields.clear();
      for (var item in widget.itemDetails) {
        List<dynamic> l = item['itemsDetails'];
        List<String> listItems = [];
        if (!l.isEmpty) {
          for (var li in l) {
            listItems.add(li);
          }
        }

        formFields.add(FormFieldData(
            Type: item['type'],
            Title: item['title'],
            Description: item['description'],
            isRequired: item['isRequired'],
            ImageURL: item['imageURL'],
            listItemsDetails: listItems));
      }
      setState(() {});
    } catch (e) {
      print('Error loading JSON file: ${e.toString()}');
    }
  }

  Widget? buildFormField(BuildContext context, FormFieldData fieldData) {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: false);
    // isLoactionEnabled = false;
    pr.style(
        message: 'Please wait...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: const Center(
          child: SizedBox(
              width: 50, height: 50, child: CircularProgressIndicator()),
        ),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        //textDirection: TextDirection.rtl,
        padding: const EdgeInsets.all(16),
        maxProgress: 100.0,
        progressTextStyle: const TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: const TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));

    print("itemDetails Type: ${fieldData.Type}");
    if (fieldData.isRequired == true) {
      if (fieldData.Type == "Header") {
        return Container(
          margin: const EdgeInsets.only(left: 0, top: 20, right: 0, bottom: 10),
          child: Text(fieldData.Description, style: headingWhiteStyle),
        );
      }

      if (fieldData.Type == "Label") {
        return Container(
          margin: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
          child: Text(fieldData.Description, style: labelStyle),
        );
      }

      if (fieldData.Type == "Checkbox") {
        return Container(
          margin: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Checkbox(
              value: isChecking,
              onChanged: (bool? value) {
                setState(() {
                  isChecking = value ?? false;
                });
              },
            ),
            Flexible(
              child: Text(fieldData.Description, style: labelStyle),
            ),
          ]),
        );
      }

      if (fieldData.Type == "Feature") {
        return Container(
          margin: const EdgeInsets.only(left: 0, top: 5, right: 0, bottom: 0),
          child: Row(
            children: [
              Image.asset(
                "assets/images/arrow_icon.png",
                height: 14,
                width: 14,
              ),
              const SizedBox(
                width: 10,
              ),
              Flexible(
                child: Text(fieldData.Description, style: labelStyle),
              ),
            ],
          ),
        );
      }

      if (fieldData.Type == "Table") {
        List<TableRow> rows = [];
        rows.add(TableRow(children: [
          Text(fieldData.Title, style: labelStyle),
          Text(fieldData.Description, style: labelStyle),
        ]));
        return Table(children: rows);
      }

      if (fieldData.Type == "Button") {
        return Consumer<PolicyProvider>(builder: (context, provider, child) {
          return Container(
            margin:
                const EdgeInsets.only(left: 0, top: 25, right: 0, bottom: 20),
            child: DefaultButton(
              text: 'Continue',
              isDisable: isChecking,
              press: isChecking
                  ? () async {
                      if (provider.getPolicyValue("location_access")) {
                        print(
                            'Location Access ${provider.getPolicyValue("location_access")}');
                        try {
                          await pr.show();
                          bool? isLocationFetched = await _determinePosition();
                          if (isLocationFetched != null &&
                              isLocationFetched == true) {
                            await pr.hide();
                            final prefs = await SharedPreferences.getInstance();
                            final double? latitude = prefs.getDouble('lat');
                            final double? longitude = prefs.getDouble('long');
                            print(
                                'printing longitude:${longitude} and latitude: ${latitude}');
                            bool result = await checkProductByLocation(
                                context, longitude, latitude);
                            print('Product location access: ${result}');
                            //TODO: bypass location access

                            Navigator.pushNamed(
                                context, SignUpScreen.routeName);
                            // if(result){

                            //       Navigator.pushNamed(
                            // context, SignUpScreen.routeName);

                            // }else{

                            // }
                            // TODO: Bypass all the screens on the temporary bases.

                            // Navigator.pushNamedAndRemoveUntil(
                            //     context,
                            //     DashboardScreen.routeName,
                            //     (Route<dynamic> route) => false);
                            // Navigator.pushNamed(
                            //     context, RequestStatusScreen.routeName);
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
                      } else {
                        print('Location is not fetched...!');
                        // await pr.hide();
                        // Navigator.pushNamed(context, SignUpScreen.routeName);
                      }
                    }
                  : null,
            ),
          );
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    try {
      //_determinePosition();
      _getDeviceInfo();
    } catch (e) {
      print('Exception in getting position: $e');
    }
    _loadFormDataFromArray();
  }

  @override
  Widget build(BuildContext context) {
    print("itemDetails Length: ${formFields.length}");
    print("itemDetails Data: ${formFields.toString()}");
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: ListView.builder(
              padding: const EdgeInsets.only(
                  left: 16, top: 0, right: 16, bottom: 16),
              itemCount: formFields.length,
              itemBuilder: (context, index) {
                final fieldData = formFields[index];
                return buildFormField(context, fieldData);
              },
            ),
          );
  }

  // Future<void> _determinePosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //
  //   // Test if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled don't continue
  //     // accessing the position and request users of the
  //     // App to enable the location services.
  //     Fluttertoast.showToast(
  //         msg: "Location services are disabled.",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.CENTER,
  //         timeInSecForIosWeb: 1,
  //         backgroundColor: Colors.red,
  //         textColor: Colors.white,
  //         fontSize: 16.0);
  //     return Future.error('Location services are disabled.');
  //   }
  //
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       Fluttertoast.showToast(
  //           msg: "Location permissions are denied",
  //           toastLength: Toast.LENGTH_SHORT,
  //           gravity: ToastGravity.CENTER,
  //           timeInSecForIosWeb: 1,
  //           backgroundColor: Colors.red,
  //           textColor: Colors.white,
  //           fontSize: 16.0);
  //       return Future.error('Location permissions are denied');
  //     }
  //   }
  //
  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever, handle appropriately.
  //     Fluttertoast.showToast(
  //         msg:
  //             "Location permissions are permanently denied, we cannot request permissions.",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.CENTER,
  //         timeInSecForIosWeb: 1,
  //         backgroundColor: Colors.red,
  //         textColor: Colors.white,
  //         fontSize: 16.0);
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }
  //
  //   Position position = await Geolocator.getCurrentPosition();
  //   if (position != null) {
  //     print('Position of the device is $position');
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

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
      prefs.setDouble("lat", position.latitude);
      prefs.setDouble("long", position.longitude);
      return true;
    }
    return false;
  }
}
