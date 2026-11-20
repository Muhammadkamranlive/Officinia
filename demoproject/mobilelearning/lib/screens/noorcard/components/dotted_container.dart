// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:dotted_border/dotted_border.dart';
// // import 'package:mobile_onboarding/constants.dart';
// // import 'package:mobile_onboarding/widgets/doted_separator.dart';

// // class ResponsiveDottedBorder extends StatefulWidget {
// //   const ResponsiveDottedBorder({Key? key}) : super(key: key);

// //   @override
// //   State<ResponsiveDottedBorder> createState() => _ResponsiveDottedBorderState();
// // }

// // class _ResponsiveDottedBorderState extends State<ResponsiveDottedBorder> {
// //   List<dynamic> sections = [];
// //   String? bannerImage;

// //   /// Load JSON data asynchronously
// //   Future<void> loadInstructions() async {
// //     String jsonString = await rootBundle.loadString('assets/json/noor_card_instructions.json');
// //     final jsonResponse = json.decode(jsonString);

// //     setState(() {
// //       bannerImage = jsonResponse['image'];
// //       sections = jsonResponse['sections'];
// //     });
// //   }

// //   @override
// //   void initState() {
// //     super.initState();
// //     loadInstructions();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     double screenHeight = MediaQuery.of(context).size.height;
// //     double adjustedHeight = screenHeight * 0.3;

// //     return SingleChildScrollView(
// //       child: Column(
// //         children: [

// //           DottedBorder(
// //             borderType: BorderType.RRect,
// //             radius: const Radius.circular(10),
// //             dashPattern: [8, 4],
// //             color: Colors.white,
// //             strokeWidth: 2,
// //             child: Column(
// //               children: sections.map((section) {
// //                 return Column(
// //                   children: [
// //                     paddingWidget(
// //                       getIconByName(section['iconBase64']),
// //                       section['title'],
// //                     ),
// //                     ...section['rows'].map<Widget>((row) {
// //                       return documentRow(row['description']);
// //                     }).toList(),
// //                     const MySeparator(),
// //                     ...section['rows'].map<Widget>((row) {
// //                       return documentRow(row['description']);
// //                     }).toList(),
// //                     const MySeparator(),
// //                   ],
// //                 );
// //               }).toList(),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   /// Map of icon names to IconData
// //   IconData getIconByName(String iconName) {
// //     const Map<String, IconData> iconsMap = {
// //       'info': Icons.info,
// //       'account_balance_wallet': Icons.account_balance_wallet,
// //       'security': Icons.security,
// //       'card_membership_outlined': Icons.card_membership_outlined,
// //       'photo_camera': Icons.photo_camera,
// //       'document_scanner_outlined': Icons.document_scanner_outlined,
// //       // Add more icons as needed
// //     };

// //     return iconsMap[iconName] ?? Icons.help_outline;
// //   }

// //   /// Widget for displaying an icon and a title with padding
// //   Widget paddingWidget(IconData icon, String text) {
// //     return Padding(
// //       padding: const EdgeInsets.all(15),
// //       child: Row(
// //         children: [
// //           Icon(icon, color: Colors.white),
// //           const SizedBox(width: 15),
// //           Expanded(
// //             child: Text(
// //               text,
// //               style: labelWhiteStyle,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   /// Widget for displaying individual document rows
// //   Widget documentRow(String text) {
// //     return Row(
// //       children: [
// //         const Icon(Icons.circle, size: 10, color: Colors.white),
// //         const SizedBox(width: 5),
// //         Flexible(
// //           child: Text(
// //             text,
// //             style: labelWhiteStyle,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// import 'dart:convert';

// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobile_onboarding/constants.dart';
// import 'package:mobile_onboarding/screens/noorcard/components/instructionsAPI.dart';
// import 'package:mobile_onboarding/widgets/doted_separator.dart';

// class ResponsiveDottedBorder extends StatefulWidget {
//   const ResponsiveDottedBorder({Key? key}) : super(key: key);

//   @override
//   State<ResponsiveDottedBorder> createState() => _ResponsiveDottedBorderState();
// }

// class _ResponsiveDottedBorderState extends State<ResponsiveDottedBorder> {
//   List<dynamic> sections = [];
//   String? bannerImage;

//   // String variables for instructions
//   String instructionTxtOne = "";
//   String instructionTxtTwo = "";
//   String instructionTxtThree = "";
//   String instructionTxtFour = "";
//   String instructionTxtFive = "";
//   String instructionTxtSix = "";
  
//   String iconBase64Section1 = "";
//   String iconBase64Section2 = "";
//   String iconBase64Section3 = "";

//   Future<void> loadInstructions() async {
//   // Call the modified function to get product instructions
//   await getProductInstructions(product_attributes);

//   if (globalSections == null || globalSections!.isEmpty) {
//     throw Exception("Sections data is empty.");
//   }

//   setState(() {
//     // Extracting instructions and icons from the global sections variable
//     instructionTxtOne = globalSections![0]['rows'][0]['description'];
//     instructionTxtTwo = globalSections![1]['rows'][0]['description'];
//     instructionTxtThree = globalSections![2]['rows'][0]['description'];
//     instructionTxtFour = globalSections![2]['rows'][1]['description'];
//     instructionTxtFive = globalSections![2]['rows'][2]['description'];
    
//     iconBase64Section1 = globalSections![0]['iconBase64'];
//     iconBase64Section2 = globalSections![1]['iconBase64'];
//     iconBase64Section3 = globalSections![2]['iconBase64'];
//   });
// }
//   @override
//   void initState() {
//     super.initState();
//     loadInstructions();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Using MediaQuery to determine an appropriate height dynamically
//     double screenHeight = MediaQuery.of(context).size.height;
//     double adjustedHeight = screenHeight * 0.3; // 60% of the screen height

//     return SingleChildScrollView(
//       child: DottedBorder(
//         borderType: BorderType.RRect,
//         radius: const Radius.circular(10),
//         dashPattern: [8, 4],
//         color: Colors.white,
//         strokeWidth: 2,
//         child: Column(
//           children: [
//             paddingWidget(iconBase64Section1, instructionTxtOne),
//             const MySeparator(),
//             paddingWidget(iconBase64Section2, instructionTxtTwo),
//             const MySeparator(),
//             documentDetailsWidget(iconBase64Section3),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper to render image or fallback icon
//   Widget paddingWidget(String base64Image, String text) {
//     Uint8List? imageBytes;

//     if (base64Image.isNotEmpty) {
//       imageBytes = Base64Decoder().convert(base64Image);
//     }

//     return Padding(
//       padding: const EdgeInsets.all(15),
//       child: Row(
//         children: [
//           // If imageBytes is available, display image, else fallback to Icon
//           imageBytes != null
//               ? Image.memory(
//                   imageBytes,
//                   width: 40, // Set width for the image
//                   height: 40, // Set height for the image
//                   fit: BoxFit.cover, // Adjust the image to fit
//                 )
//               : const Icon(Icons.error, color: Colors.white), // Fallback icon if image is null
//           const SizedBox(width: 15),
//           Expanded(
//             child: Text(
//               text,
//               style: labelWhiteStyle,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget to display document instructions with base64 image
//   Widget documentDetailsWidget(String base64Image) {
//     Uint8List? imageBytes;

//     if (base64Image.isNotEmpty) {
//       imageBytes = Base64Decoder().convert(base64Image);
//     }

//     return Padding(
//       padding: const EdgeInsets.all(15),
//       child: Row(
//         children: [
//           // Display the decoded image if available
//           imageBytes != null
//               ? Image.memory(
//                   imageBytes,
//                   width: 40, // Set width for the image
//                   height: 40, // Set height for the image
//                   fit: BoxFit.cover, // Adjust the image to fit
//                 )
//               : const Icon(Icons.error, color: Colors.white), // Fallback icon if image is null
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 documentRow(instructionTxtThree),
//                 documentRow(instructionTxtFour),
//                 documentRow(instructionTxtFive),
//                 documentRow(instructionTxtSix),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget documentRow(String text) {
//     return Row(
//       children: [
//         const Icon(Icons.circle, size: 10, color: Colors.white),
//         const SizedBox(width: 5),
//         Flexible(
//           child: Text(
//             text,
//             style: labelWhiteStyle,
//           ),
//         ),
//       ],
//     );
//   }
// }

