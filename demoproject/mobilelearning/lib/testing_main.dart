// import 'dart:io';

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:mobile_onboarding/model/cnic_model.dart';

// void main() {
//   runApp(MaterialApp(
//     home: CnicCaptureWidget(),
//   ));
// }

// class CnicCaptureWidget extends StatefulWidget {
//   @override
//   _CnicCaptureWidgetState createState() => _CnicCaptureWidgetState();
// }

// class _CnicCaptureWidgetState extends State<CnicCaptureWidget> {
//   final ImagePicker _picker = ImagePicker();
//   List<CameraDescription>? cameras;
//   CameraController? _cameraController;
//   File? _frontImage;
//   File? _backImage;
//   bool _isFrontCaptured = false;
//   bool _isBackCaptured = false;
//   bool _isCameraInitialized = false;
//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     cameras = await availableCameras();
//     if (cameras != null && cameras!.isNotEmpty) {
//       _cameraController = CameraController(cameras![0], ResolutionPreset.high);
//       await _cameraController?.initialize();
//       setState(() {
//         _isCameraInitialized = true;
//       });
//     }
//   }

//   Future<void> _selectImageFromGallery(bool isFront) async {
//     try {
//       final ImagePicker picker = ImagePicker();
//       final XFile? image = await picker.pickImage(source: ImageSource.gallery);

//       if (image != null) {
//         final File imageFile = File(image.path);
//         final InputImage inputImage = InputImage.fromFilePath(imageFile.path);
//         final cnicModel = await _scanCnic(inputImage);

//         if (cnicModel != null) {
//           setState(() {
//             if (isFront) {
//               _frontImage = imageFile;
//               _isFrontCaptured = true;
//             } else {
//               _backImage = imageFile;
//               _isBackCaptured = true;
//             }
//           });
//           _showExtractedDataDialog(cnicModel);
//           // Print extracted data
//           print("Extracted Data:");
//           print("Name: ${cnicModel.cnicHolderName}");
//           print("Father/Husband Name: ${cnicModel.cnicHolderFatherName}");
//           print("CNIC Number: ${cnicModel.cnicNumber}");
//         } else {
//           _showRetryDialog();
//         }
//       }
//     } catch (e) {
//       _showRetryDialog();
//     }
//   }

//   Future<void> _captureImage(bool isFront) async {
//     if (_cameraController != null && _cameraController!.value.isInitialized) {
//       try {
//         final XFile image = await _cameraController!.takePicture();
//         final File imageFile = File(image.path);

//         final InputImage inputImage = InputImage.fromFilePath(imageFile.path);
//         final cnicModel = await _scanCnic(inputImage);

//         if (cnicModel != null) {
//           setState(() {
//             if (isFront) {
//               _frontImage = imageFile;
//               _isFrontCaptured = true;
//             } else {
//               _backImage = imageFile;
//               _isBackCaptured = true;
//             }
//           });
//           _showExtractedDataDialog(cnicModel);
//           // Print extracted data
//           print("Extracted Data:");
//           print("Name: ${cnicModel.cnicHolderName}");
//           print("Father/Husband Name: ${cnicModel.cnicHolderFatherName}");
//           print("CNIC Number: ${cnicModel.cnicNumber}");
//         } else {
//           _showRetryDialog();
//         }
//       } catch (e) {
//         _showRetryDialog();
//       }
//     }
//   }
//   // Future<void> _captureImage(ImageSource source, bool isFront) async {
//   //   try {
//   //     final XFile? pickedFile = await _picker.pickImage(source: source);
//   //     if (pickedFile != null) {
//   //       final File imageFile = File(pickedFile.path);

//   //       final InputImage inputImage = InputImage.fromFilePath(imageFile.path);
//   //       final cnicModel = await _scanCnic(inputImage);

//   //       if (cnicModel != null) {
//   //         setState(() {
//   //           if (isFront) {
//   //             _frontImage = imageFile;
//   //             _isFrontCaptured = true;
//   //           } else {
//   //             _backImage = imageFile;
//   //             _isBackCaptured = true;
//   //           }
//   //         });

//   //         // Print extracted data
//   //         print("Extracted Data:");
//   //         print("Name: ${cnicModel.cnicHolderName}");
//   //         print("Father/Husband Name: ${cnicModel.cnicHolderFatherName}");
//   //         print("CNIC Number: ${cnicModel.cnicNumber}");
//   //         print("CNIC Number: ${cnicModel.cnicExpiryDate}");
//   //         print("CNIC data: ${cnicModel.cnicIssueDate}");
//   //       } else {
//   //         _showRetryDialog();
//   //       }
//   //     }
//   //   } catch (e) {
//   //     _showRetryDialog();
//   //   }
//   // }

//   Future<CnicModel?> _scanCnic(InputImage imageToScan) async {
//     try {
//       List<String> cnicDates = [];
//       TextRecognizer textDetector = GoogleMlKit.vision.textRecognizer();
//       final RecognizedText recognisedText =
//           await textDetector.processImage(imageToScan);
//       bool isNameNext = false;
//       bool isFatherNameNext = false;

//       CnicModel cnicDetails = CnicModel();

//       for (TextBlock block in recognisedText.blocks) {
//         for (TextLine line in block.lines) {
//           if (isNameNext) {
//             cnicDetails.cnicHolderName = line.text;
//             isNameNext = false;
//           }

//           if (isFatherNameNext) {
//             cnicDetails.cnicHolderFatherName = line.text;
//             isFatherNameNext = false;
//           }

//           if (line.text.toLowerCase() == "name" ||
//               line.text.toLowerCase() == "nane" ||
//               line.text.toLowerCase() == "nam" ||
//               line.text.toLowerCase() == "ame") {
//             isNameNext = true;
//           }

//           if (line.text.toLowerCase() == "father name" ||
//               line.text.toLowerCase() == "Father Name" ||
//               line.text.toLowerCase() == "fath" ||
//               line.text.toLowerCase() == "husb" ||
//               line.text.toLowerCase() == "husband" ||
//               line.text.toLowerCase() == "Husband") {
//             isFatherNameNext = true;
//           }

//           for (TextElement element in line.elements) {
//             String selectedText = element.text;
//             if (selectedText.length == 15 &&
//                 selectedText.contains("-", 5) &&
//                 selectedText.contains("-", 13)) {
//               cnicDetails.cnicNumber = selectedText;
//             } else if (selectedText.length == 10 &&
//                 ((selectedText.contains("/", 2) &&
//                         selectedText.contains("/", 5)) ||
//                     (selectedText.contains(".", 2) &&
//                         selectedText.contains(".", 5)))) {
//               cnicDates.add(selectedText.replaceAll(".", "/"));
//             }
//           }
//         }
//       }
//       if (cnicDates.length > 0 &&
//           cnicDetails.cnicExpiryDate.length == 10 &&
//           !cnicDates.contains(cnicDetails.cnicExpiryDate)) {
//         cnicDates.add(cnicDetails.cnicExpiryDate);
//       }
//       if (cnicDates.length > 0 &&
//           cnicDetails.cnicIssueDate.length == 10 &&
//           !cnicDates.contains(cnicDetails.cnicIssueDate)) {
//         cnicDates.add(cnicDetails.cnicIssueDate);
//       }
//       if (cnicDates.length > 0 &&
//           cnicDetails.cnicExpiryDate.length == 10 &&
//           !cnicDates.contains(cnicDetails.cnicExpiryDate)) {
//         cnicDates.add(cnicDetails.cnicExpiryDate);
//       }
//       if (cnicDates.length > 1) {
//         cnicDates = sortDateList(dates: cnicDates);
//       }
//       if (cnicDates.length == 1 &&
//           cnicDetails.cnicHolderDateOfBirth.length != 10) {
//         cnicDetails.cnicHolderDateOfBirth = cnicDates[0];
//       } else if (cnicDates.length == 2) {
//         cnicDetails.cnicIssueDate = cnicDates[0];
//         cnicDetails.cnicExpiryDate = cnicDates[1];
//       } else if (cnicDates.length == 3) {
//         cnicDetails.cnicHolderDateOfBirth = cnicDates[0].replaceAll(".", "/");
//         cnicDetails.cnicIssueDate = cnicDates[1].replaceAll(".", "/");
//         cnicDetails.cnicExpiryDate = cnicDates[2].replaceAll(".", "/");
//       }
//       textDetector.close();

//       return cnicDetails;
//     } catch (e) {
//       return null;
//     }
//   }

//   static List<String> sortDateList({required List<String> dates}) {
//     List<DateTime> tempList = [];
//     DateFormat format = DateFormat("dd/MM/yyyy");
//     for (int i = 0; i < dates.length; i++) {
//       tempList.add(format.parse(dates[i]));
//     }
//     tempList.sort((a, b) => a.compareTo(b));
//     dates.clear();
//     for (int i = 0; i < tempList.length; i++) {
//       dates.add(format.format(tempList[i]));
//     }
//     return dates;
//   }

//   void _showExtractedDataDialog(CnicModel cnicModel) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Extracted CNIC Data"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Name: ${cnicModel.cnicHolderName}"),
//             Text("Father/Husband Name: ${cnicModel.cnicHolderFatherName}"),
//             Text("CNIC Number: ${cnicModel.cnicNumber}"),
//             Text("Date of Birth: ${cnicModel.cnicHolderDateOfBirth}"),
//             Text("Issue Date: ${cnicModel.cnicIssueDate}"),
//             Text("Expiry Date: ${cnicModel.cnicExpiryDate}"),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: const Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showRetryDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("OCR Failed"),
//         content: const Text("Unable to extract data. Please try again."),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: const Text("Retry"),
//           ),
//         ],
//       ),
//     );
//     setState(() {
//       _isFrontCaptured = false;
//       _isBackCaptured = false;
//       _frontImage = null;
//       _backImage = null;
//     });
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("CNIC Capture")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: MediaQuery.of(context).size.width * 0.8,
//               height: MediaQuery.of(context).size.height * 0.6,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.0),
//                 border: Border.all(color: Colors.grey),
//               ),
//               child: _isFrontCaptured && _isBackCaptured
//                   ? const Icon(Icons.check_circle,
//                       color: Colors.green, size: 80)
//                   : _isCameraInitialized
//                       ? CameraPreview(_cameraController!)
//                       : const Center(child: CircularProgressIndicator()),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: (_isFrontCaptured && _isBackCaptured)
//                       ? null // Disable button if both sides are captured
//                       : () => _captureImage(!_isFrontCaptured),
//                   child: Text(_isFrontCaptured
//                       ? "Capture Back Side"
//                       : "Capture Front Side"),
//                 ),
//                 const SizedBox(width: 10),
//                 IconButton(
//                   onPressed: (_isFrontCaptured && _isBackCaptured)
//                       ? null // Disable button if both sides are captured
//                       : () => _selectImageFromGallery(!_isFrontCaptured),
//                   icon: Icon(Icons.photo_album),
//                   // child: const Text("Add from Gallery"),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             if (_isFrontCaptured || _isBackCaptured)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   if (_frontImage != null)
//                     Image.file(
//                       _frontImage!,
//                       width: 100,
//                       height: 100,
//                       fit: BoxFit.cover,
//                     ),
//                   SizedBox(
//                     width: 15,
//                   ),
//                   if (_backImage != null)
//                     Image.file(
//                       _backImage!,
//                       width: 100,
//                       height: 100,
//                       fit: BoxFit.cover,
//                     ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
