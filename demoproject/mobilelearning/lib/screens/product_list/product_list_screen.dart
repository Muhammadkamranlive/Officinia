// import 'package:flutter/material.dart';
// import 'package:mobile_onboarding/constants.dart';
// import 'package:mobile_onboarding/screens/product_list/components/body.dart';

// class ProductListScreen extends StatelessWidget {
//   static String routeName = "/product_list";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Container(
//               decoration: const BoxDecoration(color: Colors.white),
//               width: double.infinity,
//               height: MediaQuery.of(context).size.height / 8,
//               margin: EdgeInsets.only(
//                   bottom: MediaQuery.of(context).size.height * 0.005),
//               child: Image.asset(
//                 'assets/images/faisal_bank_banner.png',
//                 // height: MediaQuery.of(context).size.height / 1,
//               ),
//             ),
//             Expanded(
//               child: Container(
//                 decoration: const BoxDecoration(
//                     borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(30),
//                         topRight: Radius.circular(30)),
//                     gradient: LinearGradient(
//                         colors: [kPrimaryLightColor, kPrimaryColor],
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         stops: [0.1, 0.9])),
//                 child: const Product_list_body(),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
// // 