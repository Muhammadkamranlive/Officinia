import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_onboarding/constants.dart';

import '../model/cnic_model.dart';
import 'custom_dialog.dart';

class CNICDemoPage extends StatefulWidget {
  @override
  _CNICDemoPageState createState() => _CNICDemoPageState();
}

class _CNICDemoPageState extends State<CNICDemoPage> {
  TextEditingController nameTEController = TextEditingController(),
      cnicTEController = TextEditingController(),
      dobTEController = TextEditingController(),
      doiTEController = TextEditingController(),
      doeTEController = TextEditingController();

  /// you're required to initialize this model class as method you used
  /// from this package will return a model of CnicModel type
  CnicModel _cnicModel = CnicModel();

  Future<void> scanCnic(ImageSource imageSource) async {
    /// you will need to pass one argument of "ImageSource" as shown here
    CnicModel cnicModel =
        await CnicScanner().scanImage(imageSource: imageSource);
    if (cnicModel == null) return;
    setState(() {
      _cnicModel = cnicModel;
      nameTEController.text = _cnicModel.cnicHolderName;
      cnicTEController.text = _cnicModel.cnicNumber;
      dobTEController.text = _cnicModel.cnicHolderDateOfBirth;
      doiTEController.text = _cnicModel.cnicIssueDate;
      doeTEController.text = _cnicModel.cnicExpiryDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            const Text('Enter ID Card Details',
                style: TextStyle(
                    color: kPrimaryLightColor,
                    fontSize: 23.0,
                    fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 5,
            ),
            const Text(
                'To verify your Account, please enter your CNIC details.',
                style: TextStyle(
                    color: kSecondaryColor,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500)),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(0),
                shrinkWrap: true,
                children: [
                  _dataField(
                      text: 'Name', textEditingController: nameTEController),
                  _cnicField(textEditingController: cnicTEController),
                  _dataField(
                      text: 'Date of Birth',
                      textEditingController: dobTEController),
                  _dataField(
                      text: 'Date of Card Issue',
                      textEditingController: doiTEController),
                  _dataField(
                      text: 'Date of Card Expire',
                      textEditingController: doeTEController),
                  const SizedBox(
                    height: 20,
                  ),
                  _getScanCNICBtn(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// these are my custom designs you can use according to your ease
  Widget _cnicField({required TextEditingController textEditingController}) {
    return Card(
      elevation: 7,
      margin: const EdgeInsets.only(top: 2.0, bottom: 5.0),
      child: Container(
        margin:
            const EdgeInsets.only(top: 2.0, bottom: 1.0, left: 0.0, right: 0.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 3,
                height: 45,
                margin: const EdgeInsets.only(left: 3.0, right: 7.0),
                decoration: BoxDecoration(
                  gradient: kPrimaryGradientColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CNIC Number',
                    style: TextStyle(
                        color: kPrimaryLightColor,
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Image.asset("assets/images/cnic.png",
                          width: 40, height: 30),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 15.0,
                            top: 5,
                            bottom: 5,
                            right: 15.0,
                          ),
                          child: TextField(
                            controller: textEditingController,
                            decoration: const InputDecoration(
                              hintText: '41000-0000000-0',
                              hintStyle: TextStyle(color: kSecondaryColor),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.all(10),
                            ),
                            style: const TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dataField(
      {required String text,
      required TextEditingController textEditingController}) {
    return Card(
        shadowColor: kSecondaryColor,
        elevation: 5,
        margin: const EdgeInsets.only(
          top: 10,
          bottom: 5,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Icon(
                (text == "Name") ? Icons.person : Icons.date_range,
                color: kPrimaryColor,
                size: 17,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15.0, top: 3, bottom: 3),
                    child: Text(
                      text.toUpperCase(),
                      style: const TextStyle(
                          color: kPrimaryLightColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15.0,
                      top: 5,
                      bottom: 5,
                      right: 15.0,
                    ),
                    child: TextField(
                      controller: textEditingController,
                      decoration: InputDecoration(
                        hintText: (text == "Name") ? "User Name" : 'DD/MM/YYYY',
                        border: InputBorder.none,
                        isDense: true,
                        hintStyle: const TextStyle(
                            color: kSecondaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                        contentPadding: const EdgeInsets.all(10),
                      ),
                      style: const TextStyle(
                          color: kPrimaryColor, fontWeight: FontWeight.bold),
                      textInputAction: TextInputAction.done,
                      keyboardType: (text == "Name")
                          ? TextInputType.text
                          : TextInputType.number,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _getScanCNICBtn() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 5,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        textStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.all(0.0),
      ),
      onPressed: () {
        /// this is the custom dialog that takes 2 arguments "Camera" and "Gallery"
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialogBox(onCameraBTNPressed: () {
                scanCnic(ImageSource.camera);
              }, onGalleryBTNPressed: () {
                scanCnic(ImageSource.gallery);
              });
            });
      },
      // textColor: Colors.white,
      // padding: EdgeInsets.all(0.0),
      child: Container(
        alignment: Alignment.center,
        width: 500,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          gradient: LinearGradient(colors: <Color>[
            kPrimaryColor,
            kPrimaryLightColor,
            kPrimaryColor,
          ]),
        ),
        padding: const EdgeInsets.all(12.0),
        child: const Text('Scan CNIC', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

class CnicScanner {
  /// it will pick your image either form Gallery or from Camera
  final ImagePicker _picker = ImagePicker();

  /// it will check the image source
  late ImageSource source;

  /// a model class to store cnic data
  CnicModel _cnicDetails = CnicModel();

  /// this var track record which side has been scanned
  /// and which needed to be scanned and prompt user accordingly
  bool isFrontScan = false;

  /// this method will be called when user uses this package
  Future<CnicModel> scanImage({required ImageSource imageSource}) async {
    source = imageSource;
    XFile? image = await _picker.pickImage(source: imageSource);
    if (image == null) {
      return Future.value(_cnicDetails);
    } else {
      return await scanCnic(imageToScan: InputImage.fromFilePath(image.path));
    }
  }

  /// this method will process the images and extract information from the card
  Future<CnicModel> scanCnic({required InputImage imageToScan}) async {
    List<String> cnicDates = [];
    // GoogleMlKit.vision.languageModelManager();
    TextRecognizer textDetector = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognisedText =
        await textDetector.processImage(imageToScan);
    bool isNameNext = false;
    bool isFatherNameNext = false;


    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        if (isNameNext) {
          _cnicDetails.cnicHolderName = line.text;
          isNameNext = false;
        }

        if (isFatherNameNext) {
          _cnicDetails.cnicHolderFatherName = line.text;
          isFatherNameNext = false;
        }

        if (line.text.toLowerCase() == "name" ||
            line.text.toLowerCase() == "nane" ||
            line.text.toLowerCase() == "nam" ||
            line.text.toLowerCase() == "ame") {
          isNameNext = true;
        }

        if (line.text.toLowerCase() == "father" ||
            line.text.toLowerCase() == "Father" ||
            line.text.toLowerCase() == "fath" ||
            line.text.toLowerCase() == "husb" ||
            line.text.toLowerCase() == "husband" ||
            line.text.toLowerCase() == "Husband" ) {
          isFatherNameNext = true;
        }

        for (TextElement element in line.elements) {
          String selectedText = element.text;
          if (selectedText.length == 15 &&
              selectedText.contains("-", 5) &&
              selectedText.contains("-", 13)) {
            _cnicDetails.cnicNumber = selectedText;
          } else if (selectedText.length == 10 &&
              ((selectedText.contains("/", 2) &&
                      selectedText.contains("/", 5)) ||
                  (selectedText.contains(".", 2) &&
                      selectedText.contains(".", 5)))) {
            cnicDates.add(selectedText.replaceAll(".", "/"));
          }
        }
      }
    }
    if (cnicDates.length > 0 &&
        _cnicDetails.cnicExpiryDate.length == 10 &&
        !cnicDates.contains(_cnicDetails.cnicExpiryDate)) {
      cnicDates.add(_cnicDetails.cnicExpiryDate);
    }
    if (cnicDates.length > 0 &&
        _cnicDetails.cnicIssueDate.length == 10 &&
        !cnicDates.contains(_cnicDetails.cnicIssueDate)) {
      cnicDates.add(_cnicDetails.cnicIssueDate);
    }
    if (cnicDates.length > 0 &&
        _cnicDetails.cnicExpiryDate.length == 10 &&
        !cnicDates.contains(_cnicDetails.cnicExpiryDate)) {
      cnicDates.add(_cnicDetails.cnicExpiryDate);
    }
    if (cnicDates.length > 1) {
      cnicDates = sortDateList(dates: cnicDates);
    }
    if (cnicDates.length == 1 &&
        _cnicDetails.cnicHolderDateOfBirth.length != 10) {
      _cnicDetails.cnicHolderDateOfBirth = cnicDates[0];
      isFrontScan = true;
      Fluttertoast.showToast(
          msg: "Scan Back Side Now",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (cnicDates.length == 2) {
      _cnicDetails.cnicIssueDate = cnicDates[0];
      _cnicDetails.cnicExpiryDate = cnicDates[1];
      if (!isFrontScan) {
        Fluttertoast.showToast(
            msg: "Scan Front Side Now",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else if (cnicDates.length == 3) {
      _cnicDetails.cnicHolderDateOfBirth = cnicDates[0].replaceAll(".", "/");
      _cnicDetails.cnicIssueDate = cnicDates[1].replaceAll(".", "/");
      _cnicDetails.cnicExpiryDate = cnicDates[2].replaceAll(".", "/");
    }
    textDetector.close();
    if (_cnicDetails.cnicNumber.length > 0 &&
        _cnicDetails.cnicHolderDateOfBirth.length > 0 &&
        _cnicDetails.cnicIssueDate.length > 0 &&
        _cnicDetails.cnicExpiryDate.length > 0) {
      print('==================== SMART CARD DETAILS $_cnicDetails');
      return Future.value(_cnicDetails);
    } else {
      print('==================== OLD CARD DETAILS $_cnicDetails');
      return await scanImage(imageSource: source);
    }
  }

  /// it will sort the dates
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
}
