import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/font_styles_roboto.dart';
import 'package:mobile_onboarding/screens/newSingUpScreen/newSingupMain.dart';
import 'package:mobile_onboarding/screens/new_product_datails_screen.dart/productDetailsScreen.dart';
import 'package:mobile_onboarding/screens/new_product_list/components/model/product_model.dart';
import 'package:mobile_onboarding/screens/new_product_list/components/widgets/moreInfo.dart';
import 'package:mobile_onboarding/utilities/api_services/product_catagory_id_getter.dart';
import 'package:mobile_onboarding/utilities/dialog_boxes/dialog_class.dart';
import 'package:mobile_onboarding/utilities/securedData/secureDataHandler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isLoading = true;

  void _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('device_id', androidInfo.id);
    setState(() => isLoading = false);
  }

  Uint8List? _decodeImage(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      debugPrint('Error decoding image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = _decodeImage(widget.product.base64Image);

    return Container(
      margin: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(15.r), bottom: Radius.circular(15.r)),
              child: imageBytes != null
                  ? AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.memory(
                        imageBytes,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Container(
                      height: 150.h,
                      width: double.infinity,
                      color: newSecondaryColor,
                      child: Center(
                        child: Text(
                          'No Image',
                          style:
                              TextStyle(fontSize: 14.sp, color: Colors.white),
                        ),
                      ),
                    ),
            ),
          ),

          // Details section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  widget.product.title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: newSecondaryColor,
                  ),
                ),
                SizedBox(height: 20.h),

                // Description
                Text(
                  widget.product.description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: descriptionText,
                  ),
                  textAlign: TextAlign.justify,
                ),

                SizedBox(height: 20.h),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    UnderlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                              title: widget.product.title,
                              itemDetails: widget.product.itemDetailList[0],
                              producID: widget.product.id.toString(),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: 45.h,
                      width: 140.w,
                      child: ElevatedButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final secureStorage = FlutterSecureStorage();
                          String? cnic = await UserSecretStore.getCnic();

                          ReusableDialogs.showProgressDialog(context);

                          if (Platform.isAndroid) {
                            _getDeviceInfo();
                          }
                          int? product_code =
                              await getProductId(widget.product.id, context);
                          Navigator.pop(context);
                          journeyType =
                              (cnic == '3520169566516') ? 'ETB' : 'NTB';
                          if (product_code != null) {
                            Navigator.pushNamed(
                                context, NewSignUpScreen.routeName);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: newSecondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Apply Now',
                          style: AppTextStyles.robotoMedium16WhiteButton,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}















// import 'dart:convert';

// import 'dart:typed_data';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:mobile_onboarding/constants.dart';
// import 'package:mobile_onboarding/font_styles_roboto.dart';
// import 'package:mobile_onboarding/screens/newSingUpScreen/newSingupMain.dart';
// import 'package:mobile_onboarding/screens/new_product_datails_screen.dart/productDetailsScreen.dart';
// import 'package:mobile_onboarding/screens/new_product_list/components/model/product_model.dart';
// import 'package:mobile_onboarding/screens/new_product_list/components/widgets/moreInfo.dart';

// import 'package:mobile_onboarding/utilities/api_services/product_catagory_id_getter.dart';
// import 'package:mobile_onboarding/utilities/api_services/statusUpdata.dart';

// import 'package:mobile_onboarding/utilities/dialog_boxes/dialog_class.dart';
// import 'package:mobile_onboarding/utilities/getC360_userInfo/getService.dart';

// import 'package:shared_preferences/shared_preferences.dart';

// class ProductCard extends StatefulWidget {
//   final Product product;

//   const ProductCard({super.key, required this.product});

//   @override
//   State<ProductCard> createState() => _ProductCardState();
// }

// class _ProductCardState extends State<ProductCard> {
//   bool isLoading = true;
//   void _getDeviceInfo() async {
//     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//     AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
//     // print(
//     // 'Device Information: ${androidDeviceInfo.device}, ${androidDeviceInfo.model}, ${androidDeviceInfo.androidId}, ${androidDeviceInfo.hardware}, Device ID: ${androidDeviceInfo.id}');
//     final prefs = await SharedPreferences.getInstance();
//     // prefs.setString("device_info",
//     // 'Device Information: ${androidDeviceInfo.device}, ${androidDeviceInfo.model}, ${androidDeviceInfo.androidId}, ${androidDeviceInfo.hardware}');
//     prefs.setString("device_id", '${androidDeviceInfo.id}');
//     print('Device: ${androidDeviceInfo.id}');
//     if (androidDeviceInfo != null) {
//       setState(() {
//         isLoading = false;
//       });
//     }
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
//     Uint8List? imageBytes = convertBase64Image(widget.product.base64Image);

//     return Container(
//       margin: const EdgeInsets.all(10.0),
//       decoration: const BoxDecoration(
//           borderRadius: BorderRadius.all(Radius.circular(15)),
//           color: Colors.white),
//       child: Card(
//         elevation: 0,
//         child: Column(
//           children: [
//             // Product image (40% of card height)
//             Expanded(
//               flex: 7,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: newSecondaryColor,
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   clipBehavior: Clip.antiAlias, // or Clip.hardEdge
//                   child: imageBytes != null
//                       ? Image.memory(
//                           imageBytes,
//                           fit: BoxFit.fitWidth,
//                           width: double.infinity,
//                         )
//                       : const Center(child: Text("No Image")),
//                 ),
//               ),
//             ),
//             // Product details (60% of card height)
//             Expanded(
//               flex: 8,
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Title
//                     Text(
//                       widget.product.title,
//                       // style: AppTextStyles.robotoMedium18PH,
//                       style: TextStyle(
//                           fontSize: 20.sp,
//                           fontWeight: FontWeight.w700,
//                           color: newSecondaryColor),
//                     ),
//                     SizedBox(height: 8.0.h),
//                     // Description (limited to 3 lines)
//                     SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.09,
//                       child: Text(
//                         widget.product.description,
//                         maxLines: 4,
//                         textAlign: TextAlign.justify,
//                         overflow: TextOverflow.ellipsis,
//                         // style: AppTextStyles.robotoRegular13,
//                         style:
//                             TextStyle(color: descriptionText, fontSize: 13.sp),
//                       ),
//                     ),
//                     const Spacer(),
//                     // "Apply Now" button
//                     LayoutBuilder(
//                       builder: (context, constraints) {
//                         return Row(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(4.0),
//                               child: UnderlinedButton(
//                                 onPressed: () {
//                                   // Handle apply action
//                                   print(
//                                       "Selected Product ID: ${widget.product.id}");
//                                   List<dynamic> itemDetails =
//                                       widget.product.itemDetailList[0];
//                                   print(itemDetails);
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => ProductDetailScreen(
//                                         title: widget.product.title,
//                                         itemDetails: itemDetails,
//                                         producID: widget.product.id
//                                             .toString(), // Replace with actual itemDetails data
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                             SizedBox(
//                               height: 45.h,
//                               width: constraints.maxWidth *
//                                   0.4, // Ensure button width is responsive
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   elevation: 0,
//                                   backgroundColor: newSecondaryColor,
//                                 ),
//                                 onPressed: () async {
//                                   final prefs =
//                                       await SharedPreferences.getInstance();
//                                   String? cnic = prefs.getString('cnic');
//                                   ReusableDialogs.showProgressDialog(context);
//                                   _getDeviceInfo();
//                                   await getProductId(
//                                       widget.product.id, context);
//                                   Navigator.pop(context);
//                                   if (cnic == "3520169566516") {
//                                     journeyType = "ETB";
//                                   } else {
//                                     journeyType = "NTB";
//                                   }
//                                   // ReusableDialogs.showProgressDialog(context,
//                                   //     message: "Fetching Customer Data",
//                                   //     title: "Fetching Data");
//                                   // C360data = await getC360UserData(
//                                   //     cnic: cnic,
//                                   //     productType:
//                                   //         "Diminishing Musharkah Home");
//                                   if (journeyType == "ETB") {
//                                     // updateStatus();
//                                   }
//                                   // await fetchUserInformation(
//                                   //         cnic, globalProductname)
//                                   //     .then((response) {
//                                   //   // Store the response in the provider
//                                   //   Provider.of<ApiResponseProvider>(context,
//                                   //           listen: false)
//                                   //       .setApiResponse(response);
//                                   // });
//                                   print(globalProductname);

//                                   Navigator.pop(context);
//                                   // bool? isLocationFetched = await _determinePosition(context);
//                                   Navigator.pushNamed(
//                                       context, NewSignUpScreen.routeName);
//                                   // // Handle apply action
//                                   // print("Selected Product ID: ${product.id}");
//                                   // List<dynamic> itemDetails =
//                                   //     product.itemDetailList[0];
//                                   // print(itemDetails);
//                                   // Navigator.push(
//                                   //   context,
//                                   //   MaterialPageRoute(
//                                   //     builder: (context) => ProductDetailScreen(
//                                   //       title: product.title,
//                                   //       itemDetails: itemDetails,
//                                   //       producID: product.id
//                                   //           .toString(), // Replace with actual itemDetails data
//                                   //     ),
//                                   //   ),
//                                   // );
//                                 },
//                                 child: Text(
//                                   'Apply Now',
//                                   style:
//                                       AppTextStyles.robotoMedium16WhiteButton,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
