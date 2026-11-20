// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:card_swiper/card_swiper.dart';
// import 'package:flutter/material.dart';
// import 'package:mobile_onboarding/screens/product_list/components/product_card.dart';
// import 'package:mobile_onboarding/screens/new_product_list/components/api_service/products_json.dart';
// import 'package:provider/provider.dart';


// class Product_list_body extends StatefulWidget {
//   const Product_list_body({super.key});

//   @override
//   State<Product_list_body> createState() => _Product_list_bodyState();
// }

// class _Product_list_bodyState extends State<Product_list_body> {
//   @override
//   void initState() {
//     super.initState();
//     // Fetch data when the app starts
//     Provider.of<ApiService>(context, listen: false).fetchData();
//   }

//   Uint8List? convertBase64Image(String base64String) {
//     try {
//       return base64Decode(base64String);
//     } catch (e) {
//       print('Error decoding base64 image: $e');
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final apiService = Provider.of<ApiService>(context); // Access the provider

//     return Column(
//       children: [
//         SizedBox(
//           height: MediaQuery.of(context).size.height * 0.7,
//           child: apiService.products.isNotEmpty
//               ? Swiper(
//                   itemCount: apiService.products.length,
//                   itemWidth: MediaQuery.of(context).size.width,
//                   itemHeight: MediaQuery.of(context).size.height,
//                   layout: SwiperLayout.TINDER,
//                   pagination: const SwiperPagination(
//                       builder: DotSwiperPaginationBuilder(
//                           color: Colors.grey,
//                           activeColor: Colors.white,
//                           activeSize: 12,
//                           space: 4)),
//                   itemBuilder: (context, index) {
//                     return Stack(
//                       children: [
//                         Column(
//                           children: [
//                             SizedBox(
//                               height: MediaQuery.of(context).size.height * 0.1,
//                             ),
//                             CustomCard(
//                               title: apiService.products[index]['title'] ?? 'no title',
//                               description: apiService.products[index]['description'] ?? 'no description',
//                               name: null,
//                               itemDetailList: apiService.products[index]['itemsDetails'] ?? [],
//                               press: () async {
//                                 // Handle product selection
//                                 print("Selected Product ID: ${apiService.products[index]['id']}");
//                               },
//                             ),
//                           ],
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(top: 100),
//                           child: Align(
//                             alignment: Alignment.topCenter,
//                             child: apiService.products[index]['imageBase64'] != null
//                                 ? Image.memory(
//                                     convertBase64Image(
//                                             apiService.products[index]['imageBase64']) ??
//                                         Uint8List(0),
//                                     width: 200,
//                                     height: 100,
//                                   )
//                                 : Image.asset(
//                                     'assets/default_image.png', // fallback image
//                                     width: 200,
//                                     height: 100,
//                                   ),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 )
//               : Center(
//                   child: CircularProgressIndicator(), // Show loading spinner until data is available
//                 ),
//         ),
//       ],
//     );
//   }
// }



// // class Product_list_body extends StatefulWidget {
// //   const Product_list_body({super.key});

// //   @override
// //   State<Product_list_body> createState() => _Product_list_bodyState();
// // }

// // class _Product_list_bodyState extends State<Product_list_body> {
// //   List<dynamic> categories = [];
// //   List<dynamic> accounts = [];
// //   List<dynamic> products = [];
// //   List<dynamic> selectedItems = [];

// //   @override
// //   void initState() {
// //     if (categories.isEmpty) {
// //       readJson();
// //     }
// //     super.initState();
// //   }

// //   void selectedTab(int selectedIndex) {
// //     debugPrint('Selected Tab: $selectedIndex');
// //     setState(() {
// //       if (selectedIndex == 0) {
// //         if (accounts.isNotEmpty) {
// //           selectedItems.clear();
// //           selectedItems.addAll(accounts);
// //         }
// //       } else {
// //         if (products.isNotEmpty) {
// //           selectedItems.clear();
// //           selectedItems.addAll(products);
// //         }
// //       }
// //     });
// //   }

// //   Future<void> readJson() async {
// //     final String response =
// //         await rootBundle.loadString('assets/json/productfields.json');
// //     // Parse the JSON string into a Map
// //     Map<String, dynamic> data = jsonDecode(response);

// //     // Access the parsed data
// //     categories = data['fields_categories'];
// //     accounts = data['fields_accounts'];
// //     products = data['fields_products'];

// //     print("Category Length: ${categories.length}");
// //     setState(() {
// //       if (categories.length == 2) {
// //         if (products.isNotEmpty) {
// //           for (int i = 0; i < products.length; i++) {
// //             if (products[i]["isRequired"] == true) {
// //               selectedItems.add(products[i]);
// //             }
// //           }
// //           // selectedItems.addAll(products);
// //           print("Product Items Added");
// //         }
// //       } else {
// //         if (accounts.isNotEmpty) {
// //           selectedItems.addAll(accounts);
// //           print("Account Items Added");
// //         }
// //       }
// //     });

// //     if (kDebugMode) {
// //       print("Category Title: ${categories[0]['Title']}");
// //       print("Account Title: ${accounts[0]['Title']}");
// //       print("Product Title: ${products[0]['Title']}");
// //       print("Selected Title: ${selectedItems[0]['Title']}");
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       children: [
// //         // Expanded(
// //         //   child: Container(
// //         //     margin: const EdgeInsets.only(top: 120),
// //         //     child: ListView.builder(
// //         //       padding: const EdgeInsets.only(
// //         //           bottom: kFloatingActionButtonMargin + 48),
// //         //       itemCount: selectedItems.length,
// //         //       itemBuilder: (context, index) => CustomCard(
// //         //         title: selectedItems[index]['Title'],
// //         //         description: selectedItems[index]['Description'],
// //         //         imagePath: 'assets/images/card_1.png',
// //         //       ),
// //         //     ),
// //         //   ),
// //         // ),
// //         SizedBox(
// //           height: MediaQuery.of(context).size.height * 0.7,
// //           child: Swiper(
// //             itemCount: selectedItems.length,
// //             itemWidth: MediaQuery.of(context).size.width,
// //             itemHeight: MediaQuery.of(context).size.height,
// //             layout: SwiperLayout.TINDER,
// //             pagination: const SwiperPagination(
// //                 builder: DotSwiperPaginationBuilder(
// //                     color: Colors.grey,
// //                     activeColor: Colors.white,
// //                     activeSize: 12,
// //                     space: 4)),
// //             itemBuilder: (context, index) {
// //               return Stack(
// //                 children: [
// //                   Column(
// //                     children: [
// //                       SizedBox(
// //                         height: MediaQuery.of(context).size.height * 0.1,
// //                       ),
// //                       CustomCard(
// //                         title: selectedItems[index]['Title'],
// //                         description: selectedItems[index]['Description'],
// //                         // imagePath: 'assets/images/card_1.png',
// //                         name: null,
// //                         itemDetailList: selectedItems[index]['ItemsDetails'],
// //                         press: () async{
// //                           await getProductId(selectedItems[index]['ID'],context);
// //                           print("  selected Product ID ${globalProductValue}");
// //                         },
// //                       ),
// //                     ],
// //                   ),
// //                   Padding(
// //                     padding: const EdgeInsets.only(top: 20),
// //                     child: Align(
// //                       alignment: Alignment.topCenter,
// //                       // child: Image.asset(
// //                       //   'assets/images/card_1.png',
// //                       //   width: 250,
// //                       // ),
// //                       child: Image.asset(
// //                         selectedItems[index]['ImageURL'],
// //                         width: 250,
// //                       ),
// //                     ),
// //                   )
// //                 ],
// //               );
// //             },
// //           ),
// //         )
// //       ],
// //     );
// //   }
// // }
