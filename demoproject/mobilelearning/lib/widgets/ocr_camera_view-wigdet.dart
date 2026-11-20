import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/model/cnic_model.dart';
import 'package:mobile_onboarding/screens/loan/components/utilities/CnicGetandUploadService/CnicGetandUploadService.dart';
import 'package:mobile_onboarding/utilities/api_services/product_catagory_id_getter.dart';
import 'package:mobile_onboarding/utilities/dialog_boxes/dialog_class.dart';
import 'package:mobile_onboarding/utilities/securedData/secureDataHandler.dart';
import 'package:mobile_onboarding/widgets/newDocumentsUpload/apiService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CnicCaptureWidget extends StatefulWidget {
  final Function(CnicModel) onDataFetched;
  final Function() onMovedtoNext;

  const CnicCaptureWidget(
      {Key? key, required this.onDataFetched, required this.onMovedtoNext})
      : super(key: key);

  @override
  _CnicCaptureWidgetState createState() => _CnicCaptureWidgetState();
}

class _CnicCaptureWidgetState extends State<CnicCaptureWidget> {
  final ImagePicker _picker = ImagePicker();
  List<CameraDescription>? cameras;
  CameraController? _cameraController;
  File? _frontImage;
  File? _backImage;
  bool _isFrontCaptured = false;
  bool _isBackCaptured = false;
  bool _isCameraInitialized = false;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(cameras![0], ResolutionPreset.high);
      await _cameraController?.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _fetchAndUploadCnicDocs() async {
    setState(() => _isLoading = true);
    ReusableDialogs.showProgressDialog(context);
    try {
      // 3) Fetch the Dobcnic documentId
      await fetchAndSetDobcnicId(
        productCodeId: globalProductValue!,
        employmentTypeId: '0',
      );
      Navigator.pop(context);
      if (dobcnicDocumentId == null) {
        throw Exception('Dobcnic documentId not found');
      }

      // 4) Pull CNIC & mobile# from prefs
      final secureStorage = FlutterSecureStorage();
      final prefs = await SharedPreferences.getInstance();
      final cnic = await UserSecretStore.getCnic();
      final mobNo = await UserSecretStore.getSignNumber();

      // 5) Upload both files
      ReusableDialogs.showProgressDialog(context, barrierDismissible: false);
      final uploadId = await uploadDocuments(
        documentTypeId: dobcnicDocumentId!,
        cnic: cnic!,
        mobileNo: mobNo!,
        files: [_frontImage!, _backImage!],
      );
      Navigator.pop(context);
      if (uploadId.isEmpty) {
        throw Exception('Upload failed');
      }
      // 6) Save globally
      dobcnicUploadId = uploadId;
      final box = await Hive.openBox<List<int>>('uploadsBox');
      await box.put('dobcnicUploadId', uploadId);
      // finally, advance
      widget.onMovedtoNext();
    } catch (e) {
      print(e.toString());
      _showRetryDialog();
      // _showErrorDialog(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

// keep your other imports…

  Future<void> _selectImageFromGallery(bool isFront) async {
    try {
      // 👉 Replace picker call with FilePicker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: false,
      );
      if (result == null) return; // user cancelled

      final path = result.files.single.path!;
      final File pickedFile = File(path);
      final isPdf = path.toLowerCase().endsWith('.pdf');

      if (!isPdf && isFront) {
        // image + front → OCR
        final inputImage = InputImage.fromFilePath(path);
        final cnicModel = await _scanCnic(inputImage);
        if (cnicModel == null) {
          _showRetryDialog();
          return;
        }
        setState(() {
          _frontImage = pickedFile;
          _isFrontCaptured = true;
        });
        widget.onDataFetched(cnicModel);
      } else if (!isPdf) {
        // image + back
        setState(() {
          _backImage = pickedFile;
          _isBackCaptured = true;
        });
      } else {
        // PDF branch (front or back)
        setState(
          () {
            if (isFront) {
              _frontImage = pickedFile; // reuse same variable
              _isFrontCaptured = true;
            } else {
              _backImage = pickedFile;
              _isBackCaptured = true;
            }
          },
        );
      }

      if (_isFrontCaptured && _isBackCaptured) {
        await _fetchAndUploadCnicDocs();
        print('doc id:$dobcnicDocumentId doc upload id: $dobcnicUploadId ');
        // widget.onMovedtoNext();
      }
    } catch (e) {
      _showRetryDialog();
    }
  }

  // Future<void> _selectImageFromGallery(bool isFront) async {
  //   try {
  //     final XFile? picked =
  //         await _picker.pickImage(source: ImageSource.gallery);
  //     if (picked == null) return; // user canceled

  //     final File imageFile = File(picked.path);

  //     if (isFront) {
  //       // Perform OCR on the front
  //       final InputImage inputImage = InputImage.fromFilePath(imageFile.path);
  //       final cnicModel = await _scanCnic(inputImage);

  //       if (cnicModel != null) {
  //         setState(() {
  //           _frontImage = imageFile;
  //           _isFrontCaptured = true;
  //         });
  //         widget.onDataFetched(cnicModel);
  //       } else {
  //         _showRetryDialog();
  //         return;
  //       }
  //     } else {
  //       // For back side, simply store the image (no OCR)
  //       setState(() {
  //         _backImage = imageFile;
  //         _isBackCaptured = true;
  //       });
  //     }

  //     // If both sides captured, navigate next
  //     if (_isFrontCaptured && _isBackCaptured) {
  //       widget.onMovedtoNext();
  //     }
  //   } catch (e) {
  //     _showRetryDialog();
  //   }
  // }

  Future<void> _captureImage(bool isFront) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      final XFile image = await _cameraController!.takePicture();
      final File imageFile = File(image.path);

      if (isFront) {
        // Perform OCR on the front
        final InputImage inputImage = InputImage.fromFilePath(imageFile.path);
        final cnicModel = await _scanCnic(inputImage);

        if (cnicModel != null) {
          // Mark front as captured and return data to parent
          setState(() {
            _frontImage = imageFile;
            _isFrontCaptured = true;
          });
          widget.onDataFetched(cnicModel);
        } else {
          _showRetryDialog();
          return;
        }
      } else {
        // For back side, simply store the image (no OCR)
        setState(() {
          _backImage = imageFile;
          _isBackCaptured = true;
        });
      }

      // If both front & back are captured, move on
      if (_isFrontCaptured && _isBackCaptured) {
        await _fetchAndUploadCnicDocs();
        print('doc id:$dobcnicDocumentId doc upload id: $dobcnicUploadId ');
      }
    } catch (e) {
      print(e.toString());
      _showRetryDialog();
    }
  }

  Future<CnicModel?> _scanCnic(InputImage imageToScan) async {
    try {
      List<String> cnicDates = [];
      TextRecognizer textDetector = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognisedText =
          await textDetector.processImage(imageToScan);
      bool isNameNext = false;
      bool isFatherNameNext = false;

      CnicModel cnicDetails = CnicModel();

      for (TextBlock block in recognisedText.blocks) {
        for (TextLine line in block.lines) {
          if (isNameNext) {
            cnicDetails.cnicHolderName = line.text;
            isNameNext = false;
          }

          if (isFatherNameNext) {
            cnicDetails.cnicHolderFatherName = line.text;
            isFatherNameNext = false;
          }

          if (line.text.toLowerCase() == "name" ||
              line.text.toLowerCase() == "nane" ||
              line.text.toLowerCase() == "nam" ||
              line.text.toLowerCase() == "ame") {
            isNameNext = true;
          }

          if (line.text.toLowerCase() == "father name" ||
              line.text.toLowerCase() == "Father Name" ||
              line.text.toLowerCase() == "fath" ||
              line.text.toLowerCase() == "husb" ||
              line.text.toLowerCase() == "husband" ||
              line.text.toLowerCase() == "Husband") {
            isFatherNameNext = true;
          }

          for (TextElement element in line.elements) {
            String selectedText = element.text;
            if (selectedText.length == 15 &&
                selectedText.contains("-", 5) &&
                selectedText.contains("-", 13)) {
              String cnic = selectedText.replaceAll('-', '');
              cnicDetails.cnicNumber = cnic;
            } else if (selectedText.length == 10 &&
                ((selectedText.contains("/", 2) &&
                        selectedText.contains("/", 5)) ||
                    (selectedText.contains(".", 2) &&
                        selectedText.contains(".", 5)))) {
              cnicDates.add(selectedText.replaceAll(".", "/"));
            } else if (selectedText == "M" || selectedText == "F") {
              String gender = selectedText;
              print('gender Type: ${gender}');
              cnicDetails.genderType = gender;
            }
          }
        }
      }
      if (cnicDates.length > 0 &&
          cnicDetails.cnicExpiryDate.length == 10 &&
          !cnicDates.contains(cnicDetails.cnicExpiryDate)) {
        cnicDates.add(cnicDetails.cnicExpiryDate);
      }
      if (cnicDates.length > 0 &&
          cnicDetails.cnicIssueDate.length == 10 &&
          !cnicDates.contains(cnicDetails.cnicIssueDate)) {
        cnicDates.add(cnicDetails.cnicIssueDate);
      }
      if (cnicDates.length > 0 &&
          cnicDetails.cnicExpiryDate.length == 10 &&
          !cnicDates.contains(cnicDetails.cnicExpiryDate)) {
        cnicDates.add(cnicDetails.cnicExpiryDate);
      }
      if (cnicDates.length > 1) {
        cnicDates = sortDateList(dates: cnicDates);
      }
      if (cnicDates.length == 1 &&
          cnicDetails.cnicHolderDateOfBirth.length != 10) {
        cnicDetails.cnicHolderDateOfBirth = cnicDates[0];
      } else if (cnicDates.length == 2) {
        cnicDetails.cnicIssueDate = cnicDates[0];
        cnicDetails.cnicExpiryDate = cnicDates[1];
      } else if (cnicDates.length == 3) {
        cnicDetails.cnicHolderDateOfBirth = cnicDates[0].replaceAll(".", "/");
        cnicDetails.cnicIssueDate = cnicDates[1].replaceAll(".", "/");
        cnicDetails.cnicExpiryDate = cnicDates[2].replaceAll(".", "/");
      }
      textDetector.close();

      return cnicDetails;
    } catch (e) {
      return null;
    }
  }

  static List<String> sortDateList({required List<String> dates}) {
    List<DateTime> tempList = [];
    DateFormat format = DateFormat("dd/MM/yyyy");
    for (int i = 0; i < dates.length; i++) {
      tempList.add(format.parse(dates[i]));
    }
    tempList.sort((a, b) => a.compareTo(b));
    dates.clear();
    for (int i = 0; i < tempList.length; i++) {
      dates.add(format.format(tempList[i]));
    }
    return dates;
  }

  void _showExtractedDataDialog(CnicModel cnicModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Extracted CNIC Data"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${cnicModel.cnicHolderName}"),
            Text("Father/Husband Name: ${cnicModel.cnicHolderFatherName}"),
            Text("CNIC Number: ${cnicModel.cnicNumber}"),
            Text("Date of Birth: ${cnicModel.cnicHolderDateOfBirth}"),
            Text("Issue Date: ${cnicModel.cnicIssueDate}"),
            Text("Expiry Date: ${cnicModel.cnicExpiryDate}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("OCR Failed"),
        content: const Text("Unable to extract data. Please try again."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
    setState(() {
      _isFrontCaptured = false;
      _isBackCaptured = false;
      _frontImage = null;
      _backImage = null;
    });
  }

  void _showRetryDialogCNIC() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("CNIC not Matched"),
        content: const Text("Provided CNIC is Different"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
    setState(() {
      _isFrontCaptured = false;
      _isBackCaptured = false;
      _frontImage = null;
      _backImage = null;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: _isFrontCaptured && _isBackCaptured
                    ? const Icon(Icons.check_circle,
                        color: Colors.green, size: 80)
                    : _isCameraInitialized
                        ? CameraPreview(_cameraController!)
                        : const Center(child: CircularProgressIndicator()),
              ),
              Positioned(
                top: 20.h,
                child: Text(
                  _isFrontCaptured
                      ? "Back"
                      : _isBackCaptured
                          ? ""
                          : "Front",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Positioned(
              //   child: SizedBox(
              //     width: MediaQuery.of(context).size.width *
              //         0.7, // 60% of the screen width
              //     height: MediaQuery.of(context).size.height *
              //         0.20, // 20% of the screen height

              //     child: CustomPaint(
              //       painter: DottedBoxPainter(),
              //       child: Container(), // Empty container for CustomPaint
              //     ),
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: (_isFrontCaptured && _isBackCaptured)
                    ? null // Disable button if both sides are captured
                    : () => _captureImage(!_isFrontCaptured),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12), // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Adjust size to content
                  children: [
                    const Icon(
                      Icons.camera_alt, // Left-side icon
                      size: 20,
                      color: kPrimaryColor,
                    ),
                    const SizedBox(width: 8), // Spacing between icon and text
                    Text(
                      _isFrontCaptured
                          ? "Capture Back Side"
                          : "Capture Front Side",
                      style:
                          const TextStyle(fontSize: 16, color: kPrimaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: (_isFrontCaptured && _isBackCaptured)
                    ? null // Disable button if both sides are captured
                    : () => _selectImageFromGallery(!_isFrontCaptured),
                icon: const FaIcon(FontAwesomeIcons.images),
                // child: const Text("Add from Gallery"),
              ),
            ],
          ),
          const SizedBox(height: 40),
          if (_isFrontCaptured || _isBackCaptured)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_frontImage != null) _buildPreview(_frontImage!),
                const SizedBox(width: 15),
                if (_backImage != null) _buildPreview(_backImage!),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPreview(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png'].contains(ext);

    if (isImage) {
      return Image.file(
        file,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _pdfPlaceholder(), // fallback just in case
      );
    } else {
      return _pdfPlaceholder(fileName: file.path.split('/').last);
    }
  }

  Widget _pdfPlaceholder({String fileName = 'PDF'}) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              fileName,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
