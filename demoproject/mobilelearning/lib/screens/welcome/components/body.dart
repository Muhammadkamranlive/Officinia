import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_onboarding/screens/welcome/components/product_card_design.dart';
import 'package:mobile_onboarding/utilities/internet_checker/connectivity_checker.dart';
import 'dart:convert';

import '../../../constants.dart';

class WelcomeViewWidget extends StatefulWidget {
  @override
  _WelcomeViewWidgetState createState() => _WelcomeViewWidgetState();
}

class _WelcomeViewWidgetState extends State<WelcomeViewWidget> {
  List<dynamic> categories = [];
  List<dynamic> accounts = [];
  List<dynamic> products = [];
  List<dynamic> selectedItems = [];

  @override
  void initState() {
    if (categories.isEmpty) {
      readJson();
    }
    super.initState();
  }

  void selectedTab(int selectedIndex) {
    debugPrint('Selected Tab: $selectedIndex');
    setState(() {
      if (selectedIndex == 0) {
        if (accounts.isNotEmpty) {
          selectedItems.clear();
          selectedItems.addAll(accounts);
        }
      } else {
        if (products.isNotEmpty) {
          selectedItems.clear();
          selectedItems.addAll(products);
        }
      }
    });
  }

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/json/productfields.json');
    // Parse the JSON string into a Map
    Map<String, dynamic> data = jsonDecode(response);

    // Access the parsed data
    categories = data['fields_categories'];
    accounts = data['fields_accounts'];
    products = data['fields_products'];

    print("Category Length: ${categories.length}");
    setState(() {
      if (categories.length == 2) {
        if (products.isNotEmpty) {
          for (int i = 0; i < products.length; i++) {
            if (products[i]["isRequired"] == true) {
              selectedItems.add(products[i]);
            }
          }
          // selectedItems.addAll(products);
          print("Product Items Added");
        }
      } else {
        if (accounts.isNotEmpty) {
          selectedItems.addAll(accounts);
          print("Account Items Added");
        }
      }
    });

    if (kDebugMode) {
      print("Category Title: ${categories[0]['Title']}");
      print("Account Title: ${accounts[0]['Title']}");
      print("Product Title: ${products[0]['Title']}");
      print("Selected Title: ${selectedItems[0]['Title']}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          ConnectivityBanner(),
          Expanded(
            child: Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: kBackgroundColor,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  child: Image.asset(
                    'assets/images/faisal_bank_banner.png',
                    height: 110,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 120),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                        bottom: kFloatingActionButtonMargin + 48),
                    itemCount: selectedItems.length,
                    itemBuilder: (context, index) => ProductCardDesign(
                      id: index,
                      title: selectedItems[index]['Title'],
                      description: selectedItems[index]['Description'],
                      assetName: 'digital_account.jpg',
                      itemDetailList: selectedItems[index]['ItemsDetails'],
                      press: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
