import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_onboarding/database/database_helper.dart';
import 'package:mobile_onboarding/globlal_error_handler.dart';
import 'package:mobile_onboarding/model/loan_request_information.dart';
import 'package:mobile_onboarding/screens/newDashboard/alerts_status_screen.dart';
import 'package:mobile_onboarding/utilities/api_services/product_catagory_id_getter.dart';
import 'package:mobile_onboarding/screens/new_product_list/components/api_service/products_json.dart';
import 'package:mobile_onboarding/utilities/api_services/products_loctionChecker.dart';
import 'package:mobile_onboarding/widgets/circularAvatar/circularAvatar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';
import '../../noorcard/noor_card_screen.dart';
import '../../requests/request_status_screen.dart';
import 'custom_card.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _DashboardbodyState();
}

class _DashboardbodyState extends State<Body> {
  List<dynamic> categories = [];
  List<dynamic> accounts = [];
  List<dynamic> products = [];
  List<dynamic> selectedItems = [];
  List<dynamic> mandatoryFields = [];

  List<LoanRequestInformation> loanRequests = [];
  int count = 0;
  bool isEnable = false;

  get index => null;

  void handleNavigation(
    BuildContext context,
    Map<String, dynamic> selectedItem,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final double? latitude = prefs.getDouble('lat');
    final double? longitude = prefs.getDouble('long');
    if (selectedItem['id'] == "IJ") {
      // if (count > 0) {
      Navigator.pushNamed(context, RequestStatusScreen.routeName);
      // }
    } else if (selectedItem['id'] == "CC") {
      // if (count == 0) {
      // bool result =
      //     await checkProductByLocation(context, longitude, latitude);
      bool result = true;
      print(result);
      if (result) {
        productType = 0;
        Navigator.pushNamed(context, NoorCardScreen.routeName);
        // }
      }
    } else if (selectedItem['id'] == "CF") {
      productType = 2;
      Navigator.pushNamed(context, NoorCardScreen.routeName);
    } else if (selectedItem['id'] == "HF") {
      productType = 3;
      Navigator.pushNamed(context, NoorCardScreen.routeName);
    } else if (selectedItem['id'] == "CA") {
      productType = 4;
      Navigator.pushNamed(context, NoorCardScreen.routeName);
    } else if (selectedItem['id'] == "AnS") {
      Navigator.pushNamed(context, AlertsStatusScreen.routeName);
      print('Alert pressed');
    }
  }

  Future<void> readJson() async {
    ApiService apiService = ApiService();
    Map<String, dynamic>? data = await apiService.fetchApiResponse();

    categories = data?['fields_categories'];
    accounts = data?['fields_accounts'];
    products = data?['fields_products'];
    mandatoryFields = data?['fields_mandatory'];

    if (mounted) {
      setState(() {
        selectedItems =
            products.where((product) => product["isRequired"] == true).toList();
        selectedItems.addAll(mandatoryFields);
      });
    }
  }
  // Future<void> readJson() async {
  //   ApiService apiService = ApiService();

  //   // Parse the JSON string into a Map
  //   Map<String, dynamic>? data = await apiService.fetchApiResponse();

  //   // Access the parsed data
  //   categories = data?['fields_categories'];
  //   accounts = data?['fields_accounts'];
  //   products = data?['fields_products'];
  //   mandatoryFields = data?['fields_mandatory'];

  //   print("Category Length: ${categories.length}");
  //   setState(() {
  //     if (categories.length == 2) {
  //       if (products.isNotEmpty) {
  //         for (int i = 0; i < products.length; i++) {
  //           if (products[i]["isRequired"] == true) {
  //             selectedItems.add(products[i]);
  //           }
  //         }
  //         selectedItems.addAll(mandatoryFields);
  //         // selectedItems.addAll(products);
  //         print("Product Items Added");
  //       }
  //     } else {
  //       if (accounts.isNotEmpty) {
  //         selectedItems.addAll(accounts);
  //         print("Account Items Added");
  //       }
  //     }
  //   });

  //   if (kDebugMode) {
  //     print("Category Title: ${categories[0]['Title']}");
  //     print("Account Title: ${accounts[0]['Title']}");
  //     print("Product Title: ${products[0]['Title']}");
  //     print("Selected Title: ${selectedItems[0]['Title']}");
  //   }
  // }

  Future<void> getLoanRequestsFromDB() async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      loanRequests = await databaseHelper.getAllLoanRequestInformation();
      if (loanRequests.isNotEmpty) {
        count = loanRequests.length;

        isEnable = true;
      }

      setState(() {});
    } catch (e) {
      showError(e);
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    if (categories.isEmpty) {
      readJson();
    }
    getLoanRequestsFromDB();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          height: size.height * 0.2,
          decoration: const BoxDecoration(
            gradient: kPrimaryGradientColor,
          ),
          alignment: Alignment.topCenter,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Builder(builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    }),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      'Home',
                      style: headingHomeStyle,
                    ),
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.only(right: 20),
                      // child: CircleAvatar(
                      //   radius: 30,
                      //   backgroundImage: NetworkImage(
                      //       'https://st3.depositphotos.com/15648834/17930/v/450/depositphotos_179308454-stock-illustration-unknown-person-silhouette-glasses-profile.jpg'),
                      // ),
                      child: ProfileAvatar(),
                    )
                  ],
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                Flexible(
                  child: Container(
                    // height: 50,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40)),
                        color: Colors.grey.shade300),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 10),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: selectedItems.length,
                          itemBuilder: (context, index) {
                            return CustomCard(
                              Jcount: count,
                              productID: selectedItems[index]['id'] ?? "",
                              isEnabled:
                                  selectedItems[index]['isRequired'] ?? "",
                              heading: selectedItems[index]['title'] ?? "",
                              imagePath:
                                  selectedItems[index]['imageBase64'] ?? "",
                              subheading: selectedItems[index]['type'] ?? "",
                              onTap: () async {
                                product_attributes = selectedItems[index]['id'];
                                print(product_attributes);
                                // await getProductId(
                                //     selectedItems[index]['id'], context);
                                handleNavigation(context, selectedItems[index]);
                              },
                            );
                          },
                        )),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
