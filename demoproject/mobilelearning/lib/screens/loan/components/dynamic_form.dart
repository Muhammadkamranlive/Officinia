import 'dart:convert';
import 'dart:io';

import 'package:digital_signature_flutter/digital_signature_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobile_onboarding/database/database_helper.dart';
import 'package:mobile_onboarding/globlal_error_handler.dart';
import 'package:mobile_onboarding/model/base64_image.dart';
import 'package:mobile_onboarding/model/customer_data.dart';
import 'package:mobile_onboarding/model/documents_data.dart';

import 'package:mobile_onboarding/model/form_field_data_new.dart';
import 'package:mobile_onboarding/model/form_value.dart';
import 'package:mobile_onboarding/model/loan_request_information.dart';
import 'package:mobile_onboarding/model/parameters_data.dart';
import 'package:mobile_onboarding/model/picker_state.dart';
import 'package:mobile_onboarding/model/product.dart';
import 'package:mobile_onboarding/model/switch_state.dart';

import 'package:mobile_onboarding/screens/loan/components/checkbox_withValidator.dart';
import 'package:mobile_onboarding/screens/loan/components/newProgress_bar.dart';
import 'package:mobile_onboarding/screens/loan/components/utilities/CnicGetandUploadService/CnicGetandUploadService.dart';
import 'package:mobile_onboarding/screens/loan/components/utilities/jouneyJsonApiService.dart';

import 'package:mobile_onboarding/screens/loan/components/widgets/Auto_debit_widget.dart';
import 'package:mobile_onboarding/screens/loan/components/widgets/CF1.dart';
import 'package:mobile_onboarding/screens/loan/components/widgets/CNIC_instructions_table.dart';
import 'package:mobile_onboarding/screens/loan/components/widgets/NewImageSlider.dart';
import 'package:mobile_onboarding/screens/loan/components/widgets/discription_box.dart';

import 'package:mobile_onboarding/screens/loan/components/widgets/hyperLinkedCheckBox.dart';
import 'package:mobile_onboarding/screens/loan/components/widgets/selfie_instruction_table.dart';

import 'package:mobile_onboarding/screens/loan/components/widgets/sliderWidgets.dart';
import 'package:mobile_onboarding/screens/noorcard/components/appBar.dart';
import 'package:mobile_onboarding/theme_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_onboarding/utilities/Nadra_finger_varification/NadraAPIService.dart';
import 'package:mobile_onboarding/utilities/Nadra_finger_varification/NadraAPiModel.dart';

import 'package:mobile_onboarding/utilities/Nadra_finger_varification/model_SKD.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';

import 'package:mobile_onboarding/utilities/api_services/product_catagory_id_getter.dart';
import 'package:mobile_onboarding/utilities/api_services/tokenEnc/tokenClass.dart';
import 'package:mobile_onboarding/utilities/core_banking_data/client_info_model.dart';
import 'package:mobile_onboarding/utilities/core_banking_data/providerClass.dart';
import 'package:mobile_onboarding/utilities/dialog_boxes/dialog_class.dart';

import 'package:mobile_onboarding/utilities/parameters/provider.dart';
import 'package:mobile_onboarding/utilities/securedData/secureDataHandler.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';
import 'package:mobile_onboarding/widgets/adress_radio_button.dart';

import 'package:mobile_onboarding/widgets/checkBoxResidential.dart';
import 'package:mobile_onboarding/widgets/cnic_type_radia.dart';
import 'package:mobile_onboarding/widgets/customDropDown.dart';

import 'package:mobile_onboarding/widgets/date_picker.dart';
import 'package:mobile_onboarding/widgets/form_submitterd_form.dart';

import 'package:mobile_onboarding/widgets/nadra_verification_button.dart';
import 'package:mobile_onboarding/widgets/newDocumentsUpload/DocumentUpload.dart';
import 'package:mobile_onboarding/widgets/newDocumentsUpload/DocumetsMain.dart';
import 'package:mobile_onboarding/widgets/newPDFBox.dart';
import 'package:mobile_onboarding/widgets/newUIDataPicker.dart';

import 'package:mobile_onboarding/widgets/newUI_TF_DF.dart';
import 'package:mobile_onboarding/widgets/ocr_camera_view-wigdet.dart';
import 'package:mobile_onboarding/widgets/selfie_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../constants.dart';
import '../../../model/cnic_model.dart';
import '../../../model/parameters_data_new.dart';
import '../../../model/picker_id.dart';
import '../../../model/reference_data.dart';
import '../../../widgets/cnic_demo_section.dart';

import '../../../widgets/location_text_field.dart';

// ignore: must_be_immutable
class DynamicForm extends StatefulWidget {
  int loanRequestId;
  int stepsCompleted;
  int isProductType;
  bool showData;

  DynamicForm(this.loanRequestId, this.stepsCompleted, this.showData,
      this.isProductType,
      {super.key});

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final Map<String, TextEditingController> _controllers = {};
  TextEditingController _getController(String id) {
    return _controllers.putIfAbsent(id, () {
      final c = TextEditingController();
      c.text = formValues[id] ?? '';
      return c;
    });
  }

  Future<void> _safeNext() async {
    if (_isNavigating) return; // prevents stacked pushes
    _isNavigating = true;
    try {
      // If next() only increments state, call it directly:
      // next();

      // If it navigates, do it here instead to keep the guard local:
      // await Navigator.of(context).push(MaterialPageRoute(builder: (_) => NextScreen()));

      // If you must call your existing next():
      await Future.sync(() => next());
    } finally {
      _isNavigating = false;
    }
  }

  Future<void> _onContinue() async {
    if (_busy) return; // hard guard (extra safety)
    setState(() => _busy = true);

    try {
      // 1) Upload Documents gate
      if (newcurrentStep == 'Upload Documents') {
        final allDone = _docWidgetKey.currentState
                ?.areAllMandatoryDocsSelectedAndUploaded() ??
            false;
        if (!allDone) {
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Upload Required'),
              content:
                  const Text('Please upload all mandatory documents first.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
          return; // stop here
        }
      }

      // 2) If forward step (non-upload)
      if (forwardVisible && newcurrentStep != 'Upload Documents') {
        try {
          await _safeNext(); // guarded next/navigation
        } finally {}
        return;
      }

      // 3) Final submit path
      // await pr.show();
      // if (journeyType == 'NTB') { bool? bioservice = await fingerBiometric(context); }
      // updateLoanRequestInfoInDB();
      convertMapsIntoJson();
      // await pr.hide();
      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => RequestStatusScreen()));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool _busy = false; // blocks double taps
  bool _isNavigating = false; // blocks stacked Navigator pushes
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<DocumentUploadWidgetState> _docWidgetKey =
      GlobalKey<DocumentUploadWidgetState>();

  final _radioKey = GlobalKey<DynamicRadioWidgetState>();
  Map<String, dynamic> fieldsJson = {};
  String subHeadingText = "";
  List<String> fieldsSteps = [];
  String? selectedMonth = '';
  String? selectedYear = '';
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic> fieldsStepsData = {};
  List<FormFieldDataNew> formFields = [];
  int stepNo = 0;
  Map<String, dynamic> formValues = {};
  Color lableclr = const Color(0xFF079889);
  bool backVisible = false;
  bool forwardVisible = true;
  Map<String, bool?> switchStates = {};
  Map<String, int> pickerStates = {};
  XFile? _imageFile;
  Map<String, XFile> imageSelector = {};
  Map<String, List<File>> multiImageSelector = {};
  Map<String, List<File>> fileSelector = {};
  Map<String, String> pickerIds = {};
  Map<String, String> pickerAttributes = {};
  List<dynamic> globalProducts = [];
  List<String> stepNames = [];
  List<String> continueButtonVisibilitylist = [];
  String newcurrentStep = '';
  String continueButtonEnable = '';
  int currentIndex = -1;

  int currentStep = 1;
  int stepLength = 5;
  bool complete = false;
  bool isPDMVerify = false;
  CnicModel _cnicModel = CnicModel();

  String? phoneNumber = '';
  String? cnic = '';
  String? brInfoId = '';
  String? relationId = '';

  SignatureController? signatureController;
  Uint8List? signature;
  Uint8List? selectedSignature;

  int requestId = 0;
  bool newRequestIdReceived = false;

  final String identyChannel = "identy";

  Map<String, TextEditingController> controllers = {};

  bool fetchingCountries = true;
  bool fetchingNationalityType = true;
  bool fetchingEmploymentType = true;
  bool fetchingEmploymentStatus = true;
  bool fetchingTypeOfCompany = true;
  bool fetchingTypeOfBusiness = true;
  bool fetchingProfessionType = true;
  bool fetchingProductType = true;
  bool fetchingCardType = false;
  bool fetchingCnicTypes = true;
  bool fetchingOtherFacilities = true;
  bool fetchingAssetData = false;
  bool fetchingCustomerData = false;
  bool fetchingTenor = false;
  bool fetchingInstallmentFrequency = true;
  bool fetchingVehicleType = true;
  bool fetchingFacilityTypes = true;
  bool fetchingEmiTypes = true;
  bool fetchingInstallmentDueDates = true;
  bool fetchingTakafulCompanies = true;
  bool fetchingGenderTypes = true;
  bool fetchingDocumentsData = false;

  bool fetchingCities = true;
  bool fetchingMaritalType = true;
  bool fetchingEducationType = true;
  bool fetchingResidentialStatus = true;
  bool fetchingAccommodationTypes = true;
  bool fetchingRelationshipTypes = true;

  List<ParametersData> countries = [];
  List<ParametersData> nationalityType = [];
  List<ParametersData> employmentTypes = [];
  List<ParametersData> employmentStatus = [];
  List<ParametersData> typesOfCompany = [];
  List<ParametersData> typesOfBusiness = [];
  List<ParametersData> professionTypes = [];
  List<ParametersData> productTypes = [];
  List<ParametersData> cardType = [];
  List<ParametersData> cnicTypes = [];
  List<ParametersData> otherFacilities = [];
  List<ParametersData> manufacturerBrInfoList = [];
  List<ParametersData> tenor = [];
  List<ParametersData> installmentFrequency = [];
  List<ParametersData> vehicleTypes = [];
  List<ParametersData> facilityTypes = [];
  List<ParametersData> emiTypes = [];
  List<ParametersData> installmentDueDates = [];
  List<ParametersData> takafulCompanies = [];
  List<ParametersData> genderTypes = [];

  List<ParametersData> cities = [];
  List<ParametersData> maritalType = [];
  List<ParametersData> educationType = [];
  List<ParametersData> residentialStatus = [];
  List<ParametersData> accommodationTypes = [];
  List<ParametersData> relationshipTypes = [];

  //List<ParametersData> customerProductTypes = [];
  List<ParametersDataNew> customerProductTypes = [];
  List<DocumentsData> documentsData = [];

  late CustomerData customerData;

  int activeIndex = 0;
  List<String> assetPaths = [
    'assets/images/card_1.png',
    'assets/images/card_2.png',
    'assets/images/card_3.png',
    'assets/images/card_4.png',
    'assets/images/card_5.png',
    'assets/images/card_6.png',
  ];

  String currentText = '';

  final List<Map<String, String>> imagesWithText = [
    {'image': 'assets/images/card_1.png', 'text': ''},
    {'image': 'assets/images/card_4.png', 'text': ''},
    {'image': 'assets/images/card_3.png', 'text': ''},
  ];

  //final PageController _controller = PageController();
  late final PageController _controller;

  bool disableNextButton = false;
  bool enableCheckboxValidation = false;

  String cardMinLimit = '';
  String _cardLable = '';
  String _pValue = '';
  String cardMaxLimit = '';
  String _annualFee = '';
  String _fed = '';
  String _spendingReversal = '';
  String _duration = '';

  Future<void> _loadFormDataFromJson() async {
    try {
      final secureStorage = FlutterSecureStorage();
      final prefs = await SharedPreferences.getInstance();
      phoneNumber = await UserSecretStore.getSignNumber();
      String? cnic = await UserSecretStore.getCnic();
      late String response = "";
      // response = await rootBundle.loadString('assets/form_data.json');
      response = await getProductJson("CC", journeyType);

      // response = await rootBundle.loadString('assets/json/etb_form_data.json');
      String? Email = prefs.getString('loginEmail');
      formValues['user_email'] = Email;
      formValues['journey_type'] = journeyType;
      // if (cnic == '35201-6956651-6') {
      // response = await rootBundle.loadString('assets/json/etb_form_data.json');
      //   formValues['journey_type'] = 'ETB';
      // } else if (widget.isProductType == 2) {
      //   response =
      //       await rootBundle.loadString('assets/json/auto_data_form.json');
      // } else if (widget.isProductType == 3) {
      //   response =
      //       await rootBundle.loadString('assets/json/home_data_form.json');
      // } else if (widget.isProductType == 4) {
      //   response =
      //       await rootBundle.loadString('assets/json/deposite_side.json');
      // } else {
      //   response = await rootBundle.loadString('assets/form_data.json');
      //   formValues['journey_type'] = 'NTB';
      // }

      if (!kIsWeb) {
        //final File file = File('${await _localPath}/form_data.json');
        //String jsonData = await file.readAsString();
        fieldsJson = json.decode(response);
      } else {
        fieldsJson = jsonDecode(response);
      }
      parseJsonAndSetSteps(response);

      for (String key in fieldsJson.keys) {
        fieldsSteps.add(key);
        fieldsStepsData[key] = fieldsJson[key];
        print(fieldsStepsData[key]);
      }
      print('Data Length: ${fieldsStepsData.length}');
      _loadStepFields(fieldsSteps[stepNo]);
      stepLength = fieldsSteps.length;
    } catch (e) {
      showError(e);
      print('Error loading JSON file: ${e.toString()}');
    }
  }

  // void parseJsonAndSetSteps(String jsonString) {
  //   try {
  //     if (jsonString.isEmpty) {
  //       print("JSON string is empty.");
  //       return;
  //     }

  //     print("JSON String: $jsonString");

  //     // Parse the JSON string into a Map
  //     Map<String, dynamic> jsonData = json.decode(jsonString);

  //     print("Parsed JSON: $jsonData");

  //     // Initialize stepNames
  //     stepNames = [];

  //     // Iterate through each key in the JSON object
  //     jsonData.forEach((key, value) {
  //       print("Processing Key: $key");

  //       if (value is List) {
  //         for (var item in value) {
  //           if (item is Map<String, dynamic>) {
  //             if (item.containsKey('fieldType') &&
  //                 item['fieldType'] == 'AppBarHeading') {
  //               String fieldPlaceholder = item['fieldPlaceholder'] ?? '';
  //               stepNames.add(fieldPlaceholder);
  //               print("AppBarHeading Found: $fieldPlaceholder");
  //             }
  //           }
  //         }
  //       } else {
  //         print("Value for $key is not a List.");
  //       }
  //     });

  //     // Set the first step as the initial currentStep
  //     setState(() {
  //       newcurrentStep = stepNames.isNotEmpty ? stepNames[0] : '';
  //       print("newcurrentStep set to: $newcurrentStep");
  //     });
  //   } catch (e) {
  //     print('Error parsing JSON or setting steps: $e');
  //     setState(() {
  //       stepNames = [];
  //       newcurrentStep = '';
  //     });
  //   }
  // }

  void parseJsonAndSetSteps(String jsonString) {
    try {
      if (jsonString.isEmpty) {
        print("JSON string is empty.");
        return;
      }

      print("JSON String: $jsonString");

      // Parse the JSON string into a Map
      Map<String, dynamic> jsonData = json.decode(jsonString);

      print("Parsed JSON: $jsonData");

      // Initialize stepNames
      stepNames = [];
      continueButtonVisibilitylist = [];

      // Iterate through each key in the JSON object
      jsonData.forEach((key, value) {
        print("Processing Key: $key");

        if (value is List) {
          for (var item in value) {
            if (item is Map<String, dynamic>) {
              if (item.containsKey('fieldType') &&
                  item['fieldType'] == 'AppBarHeading') {
                String fieldPlaceholder = item['fieldPlaceholder'] ?? '';
                String fieldValue = item['fieldValue'] ?? '';
                stepNames.add(fieldPlaceholder);
                continueButtonVisibilitylist.add(fieldValue);
                print("AppBarHeading Found: $fieldPlaceholder");
                print(
                    "Continue Button Visibility: $continueButtonVisibilitylist");
              }
            }
          }
        } else {
          print("Value for $key is not a List.");
        }
      });

      // Set the first step as the initial currentStep
      setState(() {
        currentIndex = 0; // Initialize currentIndex to the first step
        print('Resume step: ${widget.stepsCompleted}');
        newcurrentStep =
            stepNames.isNotEmpty ? stepNames[widget.stepsCompleted] : '';
        continueButtonEnable = continueButtonVisibilitylist.isNotEmpty
            ? continueButtonVisibilitylist[widget.stepsCompleted]
            : 'true';
        print("newcurrentStep set to: $newcurrentStep");
        print("continue visibility: $continueButtonEnable");
      });
    } catch (e) {
      showError(e);
      print('Error parsing JSON or setting steps: $e');
      setState(() {
        stepNames = [];
        // newcurrentStep = '';
        continueButtonVisibilitylist = [];

        widget.stepsCompleted = -1; // Reset currentIndex
      });
    }
  }

  // void parseJsonAndSetSteps(String jsonString) {
  //   // Parse the JSON string into a Map
  //   Map<String, dynamic> jsonData = json.decode(jsonString);

  //   // Extract all the keys (steps) from the JSON object
  //   stepNames = jsonData.keys.toList();

  //   // Set the first step as the initial currentStep
  //   setState(() {
  //     newcurrentStep = stepNames.isNotEmpty ? stepNames[0] : '';
  //   });
  // }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  void _loadStepFields(String step) {
    try {
      formFields.clear();
      // print('Step No: $stepNo');
      List<dynamic> list = fieldsStepsData[step];
      for (var item in list) {
        List<dynamic> l = item['listItems'];
        List<String> listItems = [];
        if (!l.isEmpty) {
          for (var li in l) {
            listItems.add(li);
          }
        }
        //   print('List => ${listItems.toString()}');
        formFields.add(FormFieldDataNew(
            isRequired: item['isRequired'],
            fieldType: item['fieldType'],
            fieldKeyboardType: item['fieldKeyboardType'],
            fieldPlaceholder: item['fieldPlaceholder'],
            fieldValue: item['fieldValue'],
            fieldClassID: item['fieldClassID'],
            fieldIsRequired: item['fieldIsRequired'],
            listItems: listItems,
            listItemsDetails: item['listItemsDetails']));
      }
      //   print('No of Fields: ${formFields.length}');
      setState(() {}); // Refresh the UI with the dynamic form fields
    } catch (e) {
      print('Exception in _loadStepFields(): $e');
    }
  }

  Future<void> _selectDate(
      BuildContext context, FormFieldDataNew fieldData) async {
    DateTime selectedDate =
        DateTime.now(); // Set the initial date to the current date

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1947), // Set the start date for the date picker
      lastDate: DateTime(2101), // Set the end date for the date picker
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        formValues[fieldData.fieldClassID] =
            DateFormat('dd-MM-yyyy').format(selectedDate);
      });
    }
  }

  Future<XFile?> _pickImage(ImageSource source, String key) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);
      return pickedFile;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Future<void> _pickImages(String selector) async {
    List<File> selectedImages = [];
    final picker = ImagePicker();
    try {
      List<XFile> pickedFile = await picker.pickMultiImage();
      if (pickedFile.isNotEmpty) {
        for (int i = 0; i < pickedFile.length; i++) {
          selectedImages.add(File(pickedFile[i].path));
        }
        setState(() {
          imageSelector.remove(selector);
          multiImageSelector[selector] = selectedImages;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Future<void> _pickImages(String selector, Map<String, dynamic> formValues,
  //     dynamic fieldData) async {
  //   List<File> selectedImages = [];
  //   final picker = ImagePicker();

  //   try {
  //     List<XFile> pickedFile = await picker.pickMultiImage();
  //     if (pickedFile.isNotEmpty) {
  //       for (int i = 0; i < pickedFile.length; i++) {
  //         selectedImages.add(File(pickedFile[i].path));
  //       }

  //       setState(() {
  //         imageSelector.remove(selector);
  //         multiImageSelector[selector] = selectedImages;
  //       });

  //       // Convert images to Base64 and store in formValues
  //       List<String> base64Images = [];
  //       for (var image in selectedImages) {
  //         List<int> imageBytes = await image.readAsBytes();
  //         String base64String = base64Encode(imageBytes);
  //         base64Images.add(base64String);
  //       }

  //       // Store the base64 images in the formValues map under the field placeholder
  //       // formValues[fieldData] = base64Images;
  //       print('uploaded document in base 64: ${formValues[fieldData]}');
  //     }
  //   } catch (e) {
  //     print('Error picking image: $e');
  //     return null;
  //   }
  // }

  Future<void> _pickFiles(String selector) async {
    try {
      List<File> selectedFiles = [];
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Specify the types of files you want to pick
        allowMultiple: true, // Allow the selection of multiple files
      );

      if (result != null) {
        setState(() {
          selectedFiles = result.paths.map((path) => File(path!)).toList();
          fileSelector[selector] = selectedFiles;
        });
      }
    } catch (e) {
      print('Exception in _pickFiles(): $e');
    }
  }

  Future<void> _showPickImageDialog(
    BuildContext context,
    String selector,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an option'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Pick from Gallery'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    // _pickImages('your_selector', formValues, selector);
                    _pickImages(selector);
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Take a Photo'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final image =
                        await _pickImage(ImageSource.camera, selector);
                    if (image != null) {
                      setState(() {
                        _imageFile = image;
                        imageSelector[selector] = _imageFile!;
                        multiImageSelector.remove(selector);
                      });
                    }
                  },
                ),
                /*
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Select File'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    _pickFiles(selector);
                  },
                ),
                 */
              ],
            ),
          ),
        );
      },
    );
  }

  next() async {
    if (newcurrentStep == 'Upload Documents') {
      final allDone = _docWidgetKey.currentState
              ?.areAllMandatoryDocsSelectedAndUploaded() ??
          false;
      if (!allDone) {
        // Show an error and do NOT navigate forward
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Upload Required'),
            content: const Text('Please upload all mandatory documents first.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        );
        return; // Stop here — don’t proceed
      }
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final error = _radioKey.currentState?.validateAll();
      if (error == null) {
        _formKey.currentState!.save();

        if (currentStep <= stepLength) {
          if (!newRequestIdReceived) {
            await getNewRequestId();
          }
          await insertFormValueIntoDB();
          await insertPickerIndexIntoDB();
          await insertPickerIdIntoDB();
          await insertSwitchStateIntoDB();
          await insertBase64ImageIntoDB();
          await updateLoanRequestInfoInDB();
          goToNextStep();
          goTo(currentStep + 1);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          });

          _submitForm();
        }
      } // Save form values
    }
  }

  back() {
    if (currentStep > 1) {
      goTo(currentStep - 1);
      goBackToPreviousStep();
      _backForm();
    }
  }

  goTo(int step) {
    setState(() => currentStep = step);
    if (currentStep > stepLength) {
      setState(() => complete = true);
    }
  }

  void goToNextStep() {
    setState(() {
      if (stepNames.isNotEmpty) {
        if (widget.stepsCompleted < stepNames.length - 1) {
          widget.stepsCompleted++; // Move to the next index
          newcurrentStep = stepNames[widget.stepsCompleted];
          continueButtonEnable =
              continueButtonVisibilitylist[widget.stepsCompleted];
          print("Moved to next step: $newcurrentStep");
          print("visibility on current step:$continueButtonEnable");
        } else {
          print("Already at the last step.");
        }
      } else {
        print("No steps available.");
      }
    });
  }

  // void goToNextStep() {
  //   setState(() {
  //     if (stepNames.isNotEmpty) {
  //       int currentIndex = stepNames.indexOf(newcurrentStep);
  //       if (currentIndex >= 0 && currentIndex < stepNames.length - 1) {
  //         newcurrentStep = stepNames[currentIndex + 1];
  //         print("Moved to next step: $newcurrentStep");
  //       } else {
  //         print("Already at the last step.");
  //       }
  //     } else {
  //       print("No steps available.");
  //     }
  //   });
  // }
  void goBackToPreviousStep() {
    setState(() {
      if (stepNames.isNotEmpty) {
        if (widget.stepsCompleted > 0) {
          widget.stepsCompleted--; // Move to the previous index
          newcurrentStep = stepNames[widget.stepsCompleted];
          continueButtonEnable =
              continueButtonVisibilitylist[widget.stepsCompleted];
          print("Moved to previous step: $newcurrentStep");
          print("Moved to previous step: $continueButtonEnable");
        } else {
          print("Already at the first step.");
        }
      } else {
        print("No steps available.");
      }
    });
  }
  // void goBackToPreviousStep() {
  //   setState(() {
  //     if (stepNames.isNotEmpty) {
  //       int currentIndex = stepNames.indexOf(newcurrentStep);
  //       if (currentIndex > 0) {
  //         newcurrentStep = stepNames[currentIndex - 1];
  //         print("Moved to previous step: $newcurrentStep");
  //       } else if (currentIndex == 0) {
  //         print("Already at the first step.");
  //       } else {
  //         print("Invalid current step.");
  //       }
  //     } else {
  //       print("No steps available.");
  //     }
  //   });
  // }

  Widget buildFormField(BuildContext context, FormFieldDataNew fieldData) {
    //  bool NadraVerificationIsEnabled = Provider.of<PolicyProvider>(context).getPolicyValue('nardar_verification_parameter');
    //  print('Nadraverification is enabled: ${NadraVerificationIsEnabled}');

    final themeProvider = Provider.of<ThemeProvider>(context);
    if (fieldData.fieldType == 'Entry' &&
        fieldData.fieldKeyboardType == 'text') {
      final textEditingController = _getController(fieldData.fieldClassID);
      textEditingController.text = formValues[fieldData.fieldClassID] ?? "";

      if (fieldData.fieldClassID == "permanent_address" ||
          fieldData.fieldClassID == "current_address") {
        return Container(
            margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: LocationTextField(
              onChanged: (value) {
                formValues[fieldData.fieldClassID] = value;
                currentText = value;
              },
              controller: textEditingController,
              placeholder: fieldData.fieldPlaceholder,
            ));
      } else {
        // return Container(
        //   margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        //   child: TextFormField(
        //     controller: textEditingController,
        //     keyboardType: TextInputType.text,
        //     onChanged: (value) {
        //       formValues[fieldData.fieldClassID] = value;
        //       // update the here
        //       currentText = value;
        //     },
        //     validator: (value) {
        //       if (value == null || value.isEmpty) {
        //         return 'Please enter ${fieldData.fieldPlaceholder}';
        //       }
        //       return null;
        //     },
        //     decoration: InputDecoration(
        //       labelText: fieldData.fieldPlaceholder,
        //       hintText: fieldData.fieldPlaceholder,
        //       hintStyle: TextStyle(color: Colors.grey.shade400),
        //       floatingLabelBehavior: FloatingLabelBehavior.always,
        //     ),
        //   ),
        // );
        return Container(
          margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Builder(
            builder: (context) {
              // Check if formValues contains a non-empty value
              final storedValue = formValues[fieldData.fieldClassID];
              if (storedValue != null && storedValue.toString().isNotEmpty) {
                // Populate controller with storedValue
                textEditingController.text = storedValue.toString();
              } else {
                // Otherwise, clear or leave it blank
                textEditingController.text = '';
              }

              return NewCustomTextField_DF(
                inputFormatters: getTextInputFormatters(
                    fieldData.fieldKeyboardType, fieldData.fieldClassID),
                controller: textEditingController,
                labelText: fieldData.fieldPlaceholder,
                hintText: fieldData.fieldValue,
                inputType: TextInputType.text,
                onChanged: (value) {
                  formValues[fieldData.fieldClassID] = value;
                  // Possibly update DB or other logic here
                },
                validator: (value) {
                  if (fieldData.fieldClassID == "other_source_income" ||
                      fieldData.fieldClassID == "company_type_other" ||
                      fieldData.fieldClassID == 'designation_profession' ||
                      fieldData.fieldClassID == 'current_designation') {
                    return null;
                  }
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Your ${fieldData.fieldPlaceholder}';
                  }
                  return null;
                },
                // validator: (value) => validateInputTF(
                //   value,
                //   fieldData.isRequired,
                //   fieldData.fieldPlaceholder,
                // ),
              );
            },
          ),
        );
      }
    } else if (fieldData.fieldClassID == "product_type") {
      return RemoteImageSliderWidget(
        items: globalProducts
            .map((p) => {
                  'label': p.label,
                  'value': p.value.toString(),
                  'minAmount': p.minAmount,
                  'maxAmount': p.maxAmount,
                  'annualFee': p.annualFee,
                  'fed': p.fed,
                  'spendingReversal': p.spendingReversal,
                  'duration': p.duration,
                  'image': p.imageBase64,
                })
            .toList(),
        onMinMaxChanged: (cardLabel, min, max, fee, fed, rev, dur, pVal) {
          setState(() {
            _cardLable = cardLabel;
            cardMinLimit = min;
            cardMaxLimit = max;
            _annualFee = fee;
            _fed = fed;
            _spendingReversal = rev;
            _duration = dur;
            _pValue = pVal;
          });
          formValues['customer_product_type_id'] = pVal;
          formValues['customer_product_type'] = cardLabel;
        },
      );
    } else if (fieldData.fieldClassID == "Set_user_limit") {
      final double minLimit = double.tryParse(cardMinLimit) ?? 0.0;

      formValues.putIfAbsent(
        fieldData.fieldClassID,
        () => minLimit.toString(),
      );

      final raw = formValues[fieldData.fieldClassID] as String?;

      final double selected = double.tryParse(raw ?? '') ?? minLimit;

      // ---- 3. Build the slider ----
      return SetCardLimitWidget(
        minRange: cardMinLimit,
        maxRange: cardMaxLimit,
        selectedValue: selected,
        cardTitle: _cardLable,
        annualFee: _annualFee,
        spendingRev: _spendingReversal,
        duration: _duration,
        fed: _fed,
        onChanged: (double newVal) {
          setState(() {
            formValues[fieldData.fieldClassID] = newVal.toString();
            print('selcted value: ${formValues[fieldData.fieldClassID]}');
          });
        },
      );
    } else if (fieldData.fieldClassID == "Discription_box") {
      return InfoRow(
        text: fieldData.fieldPlaceholder,
      );
    } else if (fieldData.fieldClassID == 'limit_info') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Container(
          // height: 35.h,
          width: 320.w,
          decoration: const BoxDecoration(
            color: Color(0xFFE2EAEC),
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // RichText(
                //   text: TextSpan(
                //     style: const TextStyle(
                //         fontSize: 16,
                //         //color: AppColors.secoundryColor2
                //         color: kPrimaryColor),
                //     children: <TextSpan>[
                //       const TextSpan(
                //           text: 'Card Limit: ',
                //           style: TextStyle(
                //               fontWeight: FontWeight.bold, fontSize: 16)),
                //       //TextSpan(text: ' PKR 700,000 to PKR 1000,000'),
                //       TextSpan(
                //           text: ' PKR $cardMinLimit to PKR $cardMaxLimit',
                //           style: const TextStyle(
                //               fontSize: 14, fontWeight: FontWeight.w400)),
                //     ],
                //   ),
                // ),
                // // RichText(
                // //   text: const TextSpan(
                // //     style: TextStyle(fontSize: 16, color: kPrimaryColor),
                // //     children: <TextSpan>[
                // //       TextSpan(
                // //           text: 'Annual Fee: ',
                // //           style: TextStyle(
                // //               fontWeight: FontWeight.bold, fontSize: 16)),
                // //       TextSpan(
                // //           text: ' PKR 500+Taxes',
                // //           style: TextStyle(
                // //               fontSize: 14, fontWeight: FontWeight.w400)),
                // //     ],
                // //   ),
                // // ),
              ],
            ),
          ),
        ),
      );
    } else if (fieldData.fieldClassID == 'date_of_birth' ||
        fieldData.fieldClassID == 'id_issue_date' ||
        fieldData.fieldClassID == 'id_expiry_date') {
      return NewCustomDatePicker_DF(
        classID: fieldData.fieldClassID,
        icon: const Icon(
          Icons.calendar_month_outlined,
          color: newSecondaryColor,
        ),
        hint: fieldData.fieldValue,
        label: fieldData.fieldPlaceholder,
        selectedValue: formValues[fieldData.fieldClassID],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select ${fieldData.fieldPlaceholder}';
          }
          return null;
        },
        // validator: (value) => validateInputTF(
        //     value, fieldData.isRequired, fieldData.fieldPlaceholder),
        onChanged: (String? value) {
          setState(() {
            formValues[fieldData.fieldClassID] = value;
            print(formValues[fieldData.fieldClassID]);
          });
        },
      );
    } else if (fieldData.fieldType == 'Picker') {
      print(
          '${fieldData.fieldClassID} (Form Value): ${formValues[fieldData.fieldClassID]}');
      print(
          '${fieldData.fieldClassID} (Option Index): ${pickerStates[fieldData.fieldClassID]}');
      List<String> options = fieldData.listItems;
      List<String> pIds = [];
      if (fieldData.fieldClassID == "country_type") {
        List<String> localValues = [];
        localValues.addAll(fieldData.listItems);
        options.clear();
        for (ParametersData item in countries) {
          if (item.label != "") {
            options.add(item.label);
            pIds.add(item.value);
          }
        }
        return Container(
          margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: DropDownBu(
            // validator: (value) => validateInputTF(
            //     value, fieldData.isRequired, fieldData.fieldPlaceholder),
            validator: (value) {
              // if (fieldData.fieldClassID == 'country_type') {
              //   return null; // No validation required
              // }
              if (value == null || value.isEmpty) {
                return 'Please select ${fieldData.fieldPlaceholder}';
              }
              return null;
            },

            items: options,
            hint: fieldData.fieldValue,
            label: fieldData.fieldPlaceholder,
            onChanged: (String? value) {
              setState(() {
                formValues[fieldData.fieldClassID] = value;
                pickerStates[fieldData.fieldClassID] = options.indexOf(value!);
                print(
                    'selected value id:${getPickerId(fieldData.fieldClassID, value)}');
                if (fieldData.fieldClassID == 'product_type') {
                  String? limitTypeId =
                      getPickerId(fieldData.fieldClassID, value);

                  if (limitTypeId != null) {
                    getCustomerProductTypes(limitTypeId);
                  }
                } else if (fieldData.fieldClassID == 'customer_product_type') {
                  String? pAttribute =
                      getPickerAttribute(fieldData.fieldClassID, value);
                  if (pAttribute != null) {
                    pickerAttributes[fieldData.fieldClassID] = pAttribute;
                  }
                }
              });
            },
            selectedValue: formValues[fieldData.fieldClassID],
          ),
        );
        // return Container(
        //   margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        //   child: DropdownButtonFormField<String>(
        //     items: cList
        //         .map((option) => DropdownMenuItem<String>(
        //               value: option.trim(),
        //               child: Text(option.trim()),
        //             ))
        //         .toList(),
        //     value: formValues[fieldData.fieldClassID],
        //     onChanged: (value) {
        //       setState(() {
        //         formValues[fieldData.fieldClassID] = value;
        //         pickerStates[fieldData.fieldClassID] = cList.indexOf(value!);
        //         //pickerIds[fieldData.fieldClassID] = cListIds[cList.indexOf(value)];
        //       });
        //     },
        //     decoration: InputDecoration(
        //       labelText: fieldData.fieldPlaceholder,
        //       labelStyle: TextStyle(
        //           color:
        //               themeProvider.currentTheme.brightness == Brightness.light
        //                   ? const Color(0xFF079889)
        //                   : Colors.white),
        //       hintStyle: TextStyle(
        //           color:
        //               themeProvider.currentTheme.brightness == Brightness.light
        //                   ? const Color(0xFF079889)
        //                   : Colors.white),
        //       filled: true,
        //       fillColor:
        //           themeProvider.currentTheme.brightness == Brightness.light
        //               ? Colors.white
        //               : Colors.grey,
        //       border: const OutlineInputBorder(
        //         borderRadius: BorderRadius.all(Radius.circular(4.0)),
        //       ),
        //       contentPadding:
        //           const EdgeInsets.symmetric(vertical: 05, horizontal: 10),
        //       focusedBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(8.0),
        //         borderSide: const BorderSide(
        //           color: Color(0xFF079889),
        //         ),
        //       ),
        //       enabledBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(8.0),
        //         borderSide: const BorderSide(
        //           color: Color(0xFFe4eae8),
        //           width: 2.0,
        //         ),
        //       ),
        //     ),
        //     validator: (value) {
        //       if (value == null || value.isEmpty) {
        //         return 'Please select an option for ${fieldData.fieldPlaceholder}';
        //       }
        //       return null;
        //     },
        //   ),
        // );
      } else {
        if (fieldData.listItemsDetails.isNotEmpty) {
          if (fieldData.fieldClassID == 'nationality_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in nationalityType) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'country_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in countries) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'employment_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in employmentTypes) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'employment_status') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in employmentStatus) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'company_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in typesOfBusiness) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'business_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in typesOfBusiness) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'profession_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in professionTypes) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'id_card_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in cnicTypes) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'other_facilities') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in otherFacilities) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'car_finance_tenor_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in tenor) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'car_vehicle_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in vehicleTypes) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'car_facility_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in facilityTypes) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'car_emi_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in emiTypes) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'car_maker_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in manufacturerBrInfoList) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.id);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'car_takaful_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in takafulCompanies) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'product_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in productTypes) {
              if (item.label != "") {
                options.add(item.label);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'gender_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in genderTypes) {
              if (item.label != "") {
                options.add(item.label);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'customer_product_type') {
            options.clear();
            for (ParametersDataNew item in customerProductTypes) {
              if (item.label != "") {
                options.add(item.label);
              }
            }
          } else if (fieldData.fieldClassID == 'business_nature') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in professionTypes) {
              if (item.label != "") {
                options.add(item.label);
              }
            }
          } else if (fieldData.fieldClassID == 'business_nature_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in typesOfCompany) {
              if (item.label != "") {
                options.add(item.label);
              }
            }
          } else if (fieldData.fieldClassID == 'current_city' ||
              fieldData.fieldClassID == 'office_city') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in cities) {
              if (item.label != "") {
                options.add(item.label);
              }
            }
          } else if (fieldData.fieldClassID == 'marital_status') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in maritalType) {
              if (item.label != "") {
                options.add(item.label);
              }
            }
          } else if (fieldData.fieldClassID == 'educational_qualification') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in educationType) {
              if (item.label != "") {
                options.add(item.label);
              }
            }
          } else if (fieldData.fieldClassID == 'residential_status') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in residentialStatus) {
              if (item.label != "") {
                options.add(item.label);
              }
            }
          } else if (fieldData.fieldClassID == 'type_of_accommodation') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in accommodationTypes) {
              if (item.label != "") {
                options.add(item.label);
              }
            }
          } else if (fieldData.fieldClassID == 'reference_relationship_1') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in relationshipTypes) {
              if (item.label != "") {
                options.add(item.label);
              }
            }
          } else if (fieldData.fieldClassID == 'reference_relationship_2') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in relationshipTypes) {
              if (item.label != "") {
                options.add(item.label);
              }
            }
          }

          List<Widget> widgets = [];
          // Updated
          widgets.add(Visibility(
            visible: fieldData.fieldClassID == 'product_type' ||
                    fieldData.fieldClassID == 'customer_product_type'
                ? false
                : true,
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: DropDownBu(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select ${fieldData.fieldPlaceholder}';
                  }
                  return null;
                },
                items: options,
                hint: fieldData.fieldValue,
                label: fieldData.fieldPlaceholder,
                onChanged: (String? value) {
                  setState(() {
                    formValues[fieldData.fieldClassID] = value;
                    pickerStates[fieldData.fieldClassID] =
                        options.indexOf(value!);
                    print(
                        'selected value id:${getPickerId(fieldData.fieldClassID, value)}');
                    getPickerId(fieldData.fieldClassID, value);
                    if (fieldData.fieldClassID == 'employment_type') {
                      globalUploadedDocIdsMap.clear();
                      employmentTypeId =
                          getPickerId(fieldData.fieldClassID, value);
                      print("emploment id:${employmentTypeId}");
                      formValues["employment_type_id"] =
                          employmentTypeId.toString();
                    }
                    if (fieldData.fieldClassID == 'product_type' ||
                        fieldData.fieldClassID == 'employment_type') {
                      String? limitTypeId =
                          getPickerId(fieldData.fieldClassID, value);
                      if (limitTypeId != null) {
                        getCustomerProductTypes(limitTypeId);
                      }
                    } else if (fieldData.fieldClassID ==
                        'customer_product_type') {
                      String? pAttribute =
                          getPickerAttribute(fieldData.fieldClassID, value);
                      if (pAttribute != null) {
                        pickerAttributes[fieldData.fieldClassID] = pAttribute;
                      }
                    }
                  });
                },
                selectedValue: formValues[fieldData.fieldClassID],
              ),
            ),
          ));
          //older

          // widgets.add(Visibility(
          //     visible: fieldData.fieldClassID == 'product_type' ||
          //             fieldData.fieldClassID == 'customer_product_type'
          //         ? false
          //         : true,
          //     child: Container(
          //       margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          //       child: DropdownButtonFormField<String>(
          //         value: formValues[fieldData.fieldClassID],
          //         items: options
          //             .map((option) => DropdownMenuItem<String>(
          //                   value: option.trim(),
          //                   child: Text(option.trim()),
          //                 ))
          //             .toList(),
          //         onChanged: (String? value) {
          //           setState(() {
          //             formValues[fieldData.fieldClassID] = value;
          //             pickerStates[fieldData.fieldClassID] =
          //                 options.indexOf(value!);
          //             if (fieldData.fieldClassID == 'product_type') {
          //               String? limitTypeId =
          //                   getPickerId(fieldData.fieldClassID, value);
          //               if (limitTypeId != null) {
          //                 getCustomerProductTypes(limitTypeId);
          //               }
          //             } else if (fieldData.fieldClassID ==
          //                 'customer_product_type') {
          //               String? pAttribute =
          //                   getPickerAttribute(fieldData.fieldClassID, value);
          //               if (pAttribute != null) {
          //                 pickerAttributes[fieldData.fieldClassID] = pAttribute;
          //               }
          //               // TODO: Enable this code when card limits are fixed in the API.
          //               /// Card limits are hardcoded due to issue in API.
          //               /*
          //           Map<String, String>? cardLimits = getCardLimits(fieldData.fieldClassID, value);
          //           if(cardLimits != null) {
          //             cardMinLimit = cardLimits['min']!;
          //             cardMaxLimit = cardLimits['max']!;
          //           }
          //            */
          //             }
          //           });
          //         },
          //         //    decoration: InputDecoration(labelText: fieldData.fieldPlaceholder),
          //         decoration: InputDecoration(
          //           labelText: fieldData.fieldPlaceholder,
          //           //labelStyle: const TextStyle(color: Color(0xFF079889)),
          //           //hintStyle: const TextStyle(color: Color(0xFF079889)),
          //           labelStyle: TextStyle(
          //               color: themeProvider.currentTheme.brightness ==
          //                       Brightness.light
          //                   ? Color(0xFF079889)
          //                   : Colors.white),
          //           hintStyle: TextStyle(
          //               color: themeProvider.currentTheme.brightness ==
          //                       Brightness.light
          //                   ? Color(0xFF079889)
          //                   : Colors.white),
          //           //  hintText: fieldData.fieldPlaceholder,
          //           filled: true,
          //           //fillColor: Colors.white,
          //           fillColor: themeProvider.currentTheme.brightness ==
          //                   Brightness.light
          //               ? Colors.white
          //               : Colors.grey,
          //           border: const OutlineInputBorder(
          //             borderRadius: BorderRadius.all(Radius.circular(4.0)),
          //           ),
          //           contentPadding: const EdgeInsets.symmetric(
          //               vertical: 05, horizontal: 10),
          //           focusedBorder: OutlineInputBorder(
          //             borderRadius: BorderRadius.circular(8.0),
          //             borderSide: const BorderSide(
          //               color: Color(0xFF079889),
          //             ),
          //           ),
          //           enabledBorder: OutlineInputBorder(
          //             borderRadius: BorderRadius.circular(8.0),
          //             borderSide: const BorderSide(
          //               color: Color(0xFFe4eae8),
          //               width: 2.0,
          //             ),
          //           ),
          //         ),
          //         validator: (value) {
          //           if (value == null || value.isEmpty) {
          //             return 'Please select an option for ${fieldData.fieldPlaceholder}';
          //           }
          //           return null;
          //         },
          //       ),
          //     )));
          if (pickerStates[fieldData.fieldClassID] != null) {
            try {
              /*
              for (int i = 0; i < fieldData.listItemsDetails.length; i++) {
                List<dynamic> subFields = fieldData.listItemsDetails[i];
                for (var item in subFields) {
                  List<dynamic> dl = item['listItems'];
                  List<String> listItems = [];
                  if (!dl.isEmpty) {
                    for (var li in dl) {
                      listItems.add(li);
                    }
                  }
                  widgets.add(Visibility(
                      visible: pickerStates[fieldData.fieldClassID] == i
                          ? true
                          : false,
                      child: buildFormField(
                          context,
                          FormFieldDataNew(
                              fieldType: item['fieldType'],
                              fieldKeyboardType: item['fieldKeyboardType'],
                              fieldPlaceholder: item['fieldPlaceholder'],
                              fieldValue: item['fieldValue'],
                              fieldClassID: item['fieldClassID'],
                              fieldIsRequired: item['fieldIsRequired'] != null
                                  ? true
                                  : false,
                              listItems: listItems,
                              listItemsDetails: item['listItemsDetails']))));
                }
              }
               */
              if (fieldData.fieldClassID == 'customer_product_type' &&
                  pickerAttributes[fieldData.fieldClassID]?.trim() == 'CC') {
                // changeCreditCard();
                // widgets.add(SizedBox(
                //   height: 250,
                //   child: PageView.builder(
                //       controller: _controller,
                //       onPageChanged: (int pageNo) {
                //         print('Card Name: ${options[pageNo]}');
                //         setState(() {
                //           formValues[fieldData.fieldClassID] = options[pageNo];
                //           pickerStates[fieldData.fieldClassID] = pageNo;
                //         });
                //       },
                //       //itemCount: imagesWithText.length,
                //       itemCount: options.length,
                //       itemBuilder: (context, index) {
                //         return Stack(
                //           children: [
                //             Padding(
                //               padding: const EdgeInsets.all(15.0),
                //               child: Image.asset(
                //                   imagesWithText[index]['image']!,
                //                   fit: BoxFit.contain),
                //             ),
                //             Positioned(
                //               bottom: 30,
                //               left: 35,
                //               child: Text(
                //                 imagesWithText[index]['text']!,
                //                 style: const TextStyle(
                //                   color: Colors.white,
                //                   fontSize: 20,
                //                 ),
                //               ),
                //             ),
                //           ],
                //         );
                //       }),
                // ));
                // widgets.add(
                //   Center(
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       children: [
                //         RemoteImageSliderWidget(
                //           items: globalProducts,
                //           onMinMaxChanged: (minAmount, maxAmount) {
                //             setState(() {
                //               cardMinLimit = minAmount;
                //               cardMaxLimit = maxAmount;
                //             });
                //           },
                //         ),
                //         // ImageSliderWidget(
                //         //   apiResponseString: productData,
                //         //   initialMinAmount: cardMinLimit,
                //         //   initialMaxAmount: cardMaxLimit,
                //         // ),
                //         // CarouselSlider.builder(
                //         //   itemCount: assetPaths.length,
                //         //   itemBuilder:
                //         //       (BuildContext context, int index, int realIndex) {
                //         //     final assetImage = assetPaths[index];
                //         //     return buildImage(assetImage, index, currentText);
                //         //   },
                //         //   options: CarouselOptions(
                //         //     height: 200,
                //         //     initialPage: 3,
                //         //     enableInfiniteScroll: false,
                //         //     enlargeCenterPage: false,
                //         //     enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                //         //     onPageChanged: (index, reason) {
                //         //       setState(() {
                //         //         activeIndex = index;
                //         //         print(activeIndex);
                //         //       });
                //         //     },
                //         //   ),
                //         // ),
                //         // const SizedBox(height: 2),
                //         // buildIndicator(),
                //       ],
                //     ),
                //   ),
                // );

                // widgets.add(
                //   Padding(
                //     padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                //     child: Container(
                //       height: 70.h,
                //       width: 320.w,
                //       decoration: const BoxDecoration(
                //         color: Color(0xFFE2EAEC),
                //         borderRadius: BorderRadius.all(
                //           Radius.circular(10),
                //         ),
                //       ),
                //       child: Padding(
                //         padding: const EdgeInsets.symmetric(horizontal: 20),
                //         child: Column(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             RichText(
                //               text: TextSpan(
                //                 style: const TextStyle(
                //                     fontSize: 16,
                //                     //color: AppColors.secoundryColor2
                //                     color: kPrimaryColor),
                //                 children: <TextSpan>[
                //                   const TextSpan(
                //                       text: 'Card Limit: ',
                //                       style: TextStyle(
                //                           fontWeight: FontWeight.bold,
                //                           fontSize: 16)),
                //                   //TextSpan(text: ' PKR 700,000 to PKR 1000,000'),
                //                   TextSpan(
                //                       text:
                //                           ' PKR $cardMinLimit to PKR $cardMaxLimit',
                //                       style: const TextStyle(
                //                           fontSize: 14,
                //                           fontWeight: FontWeight.w400)),
                //                 ],
                //               ),
                //             ),
                //             RichText(
                //               text: const TextSpan(
                //                 style: TextStyle(
                //                     fontSize: 16, color: kPrimaryColor),
                //                 children: <TextSpan>[
                //                   TextSpan(
                //                       text: 'Annual Fee: ',
                //                       style: TextStyle(
                //                           fontWeight: FontWeight.bold,
                //                           fontSize: 16)),
                //                   TextSpan(
                //                       text: ' PKR 500+Taxes',
                //                       style: TextStyle(
                //                           fontSize: 14,
                //                           fontWeight: FontWeight.w400)),
                //                 ],
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                // );
                // widgets.add(const Padding(
                //   padding: EdgeInsets.only(left: 15, bottom: 10),
                //   child: Align(
                //     alignment: Alignment.topLeft,
                //     child: Text(
                //       'Set your card Limit',
                //       style: labelStyle,
                //     ),
                //   ),
                // ));
                // widgets.add(Container(
                //   height: 70,
                //   width: 360,
                //   decoration: const BoxDecoration(
                //     color: Color(0xFFE2EAEC),
                //     borderRadius: BorderRadius.all(
                //       Radius.circular(15),
                //     ),
                //   ),
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       const Text(
                //         'Set Limit',
                //         style: TextStyle(
                //             fontSize: 16,
                //             //color: AppColors.secoundryColor2
                //             color: kPrimaryColor),
                //       ),
                //       Text(
                //         //'PKR | ${_currentSliderValue.round()}',
                //         //'PKR | ${formValues['Set_user_limit'] != null ? double.parse(formValues['Set_user_limit']).round() : 80000}',
                //         'PKR | ${formValues['Set_user_limit'] != null ? double.parse(formValues['Set_user_limit']).round() : double.parse(cardMinLimit)}',
                //         style: const TextStyle(
                //             fontSize: 16,
                //             //color: AppColors.secoundryColor2,
                //             color: kPrimaryColor,
                //             fontWeight: FontWeight.bold),
                //       )
                //     ],
                //   ),
                // ));
                // widgets.add(
                //   SetCardLimitWidget(
                //     minRange: cardMinLimit,
                //     maxRange: cardMaxLimit,
                //     selectedValue: formValues['Set_user_limit'],
                //   ),
                // );
                // widgets.add(CustomSlider(
                //   //value: 80000,
                //   //value: formValues['Set_user_limit'] != null ? double.parse(formValues['Set_user_limit']) : 80000,
                //   value: formValues['Set_user_limit'] != null
                //       ? double.parse(formValues['Set_user_limit'])
                //       : double.parse(cardMinLimit),
                //   //max: 300000,
                //   //min: 80000,
                //   max: double.parse(cardMaxLimit),
                //   min: double.parse(cardMinLimit),
                //   divisions: 6,
                //   onChanged: (double value) {
                //     setState(() {
                //       formValues['Set_user_limit'] = '$value';
                //     });
                //   },
                // ));
                // widgets.add(const DisclaimerContainer(
                //   disclaimerText:
                //       'Disclaimer: The Offered Noor Card and variant is subject to eligibility criteria',
                // ));
                // widgets.add(buildFormField(
                //     context,
                //     FormFieldDataNew(
                //         fieldType: 'Note',
                //         fieldKeyboardType: 'text',
                //         fieldPlaceholder:
                //             'Your name as you would like to appear on Card (19 characters allowed)',
                //         fieldValue: '',
                //         fieldClassID: '',
                //         fieldIsRequired: true,
                //         listItems: [],
                //         listItemsDetails: [])));
                // widgets.add(buildFormField(
                //     context,
                //     FormFieldDataNew(
                //         isRequired: 'true',
                //         fieldType: 'Entry',
                //         fieldKeyboardType: 'text',
                //         fieldPlaceholder: 'Your name on Card',
                //         fieldValue: 'Enter your name on Card',
                //         fieldClassID: 'card_name',
                //         fieldIsRequired: true,
                //         listItems: [],
                //         listItemsDetails: [])));
                // widgets.add(buildFormField(
                //     context,
                //     FormFieldDataNew(
                //         fieldType: 'Radio',
                //         fieldKeyboardType: 'text',
                //         fieldPlaceholder: 'Do you want to receive E-Statement?',
                //         fieldValue: '',
                //         fieldClassID: 'e_statement',
                //         fieldIsRequired: true,
                //         listItems: ["Yes", "No"],
                //         listItemsDetails: [])));
              } else {
                for (int i = 0; i < fieldData.listItemsDetails.length; i++) {
                  List<dynamic> subFields = fieldData.listItemsDetails[i];
                  for (var item in subFields) {
                    List<dynamic> dl = item['listItems'];
                    List<String> listItems = [];
                    if (!dl.isEmpty) {
                      for (var li in dl) {
                        listItems.add(li);
                      }
                    }
                    widgets.add(
                      Visibility(
                        visible: pickerStates[fieldData.fieldClassID] == i
                            ? true
                            : false,
                        child: buildFormField(
                          context,
                          FormFieldDataNew(
                            fieldType: item['fieldType'],
                            fieldKeyboardType: item['fieldKeyboardType'],
                            fieldPlaceholder: item['fieldPlaceholder'],
                            fieldValue: item['fieldValue'],
                            fieldClassID: item['fieldClassID'],
                            fieldIsRequired:
                                item['fieldIsRequired'] != null ? true : false,
                            listItems: listItems,
                            listItemsDetails: item['listItemsDetails'],
                          ),
                        ),
                      ),
                    );
                  }
                }
              }
            } catch (e) {
              print('Exception in inserting a field: $e');
            }
          }
          return Column(
            children: widgets,
          );
        } else {
          //List<String> pIds = [];
          if (fieldData.fieldClassID == 'nationality_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in nationalityType) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'employment_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in employmentTypes) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'employment_status') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in employmentStatus) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'company_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in typesOfBusiness) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'business_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in typesOfBusiness) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'profession_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in professionTypes) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'id_card_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in cnicTypes) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'other_facilities') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in otherFacilities) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'car_finance_tenor_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in tenor) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'car_vehicle_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in vehicleTypes) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'car_facility_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in facilityTypes) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'car_emi_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in emiTypes) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'car_maker_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in manufacturerBrInfoList) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.id);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'car_takaful_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in takafulCompanies) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'product_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in productTypes) {
              if (item.label != "") {
                options.add(item.label);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'gender_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in genderTypes) {
              if (item.label != "") {
                options.add(item.label);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'customer_product_type') {
            //List<String> localValues = [];
            //localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersDataNew item in customerProductTypes) {
              if (item.label != "") {
                options.add(item.label);
              }
            }
            /*
            if(options.isEmpty) {
              options = localValues;
            }
             */
          } else if (fieldData.fieldClassID == 'business_nature') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in professionTypes) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'business_nature_type') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in typesOfCompany) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'current_city') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in cities) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'place_of_birth') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in cities) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'office_city') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in cities) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'marital_status') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in maritalType) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'educational_qualification') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in educationType) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'residential_status') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in residentialStatus) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'type_of_accommodation') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in accommodationTypes) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'reference_relationship_1') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in relationshipTypes) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          } else if (fieldData.fieldClassID == 'reference_relationship_2') {
            List<String> localValues = [];
            localValues.addAll(fieldData.listItems);
            options.clear();
            for (ParametersData item in relationshipTypes) {
              if (item.label != "") {
                options.add(item.label);
                pIds.add(item.value);
              }
            }
            if (options.isEmpty) {
              options = localValues;
            }
          }

          if (fieldData.fieldClassID == 'car_maker_type') {
            print("car_maker_type list: ${options.toString()}");
          }

          return Visibility(
              visible: fieldData.fieldClassID == 'product_type' ||
                      fieldData.fieldClassID == 'customer_product_type'
                  ? false
                  : true,
              child: Container(
                decoration: const BoxDecoration(
                  // color: Colors.black,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: DropDownBu(
                  classID: fieldData.fieldClassID,
                  validator: (value) {
                    if (formValues[fieldData.fieldClassID] == null ||
                        formValues[fieldData.fieldClassID].isEmpty) {
                      return 'Please select ${fieldData.fieldPlaceholder}';
                    }
                    return null;
                  },
                  items: options,
                  hint: fieldData.fieldValue,
                  label: fieldData.fieldPlaceholder,
                  onChanged: (String? value) {
                    setState(() {
                      formValues[fieldData.fieldClassID] = value;
                      pickerStates[fieldData.fieldClassID] =
                          options.indexOf(value!);
                      print(
                          'selected value id:${getPickerId(fieldData.fieldClassID, value)}');
                      if (fieldData.fieldClassID == 'product_type') {
                        String? limitTypeId =
                            getPickerId(fieldData.fieldClassID, value);
                        if (limitTypeId != null) {
                          getCustomerProductTypes(limitTypeId);
                        }
                      } else if (fieldData.fieldClassID ==
                          'customer_product_type') {
                        String? pAttribute =
                            getPickerAttribute(fieldData.fieldClassID, value);
                        if (pAttribute != null) {
                          pickerAttributes[fieldData.fieldClassID] = pAttribute;
                        }
                      }
                    });
                  },
                  selectedValue: formValues[fieldData.fieldClassID],
                ),
              ));
        }
      }
    } else if (fieldData.fieldType == 'Date') {
      if (fieldData.fieldClassID == 'present_experience' ||
          fieldData.fieldClassID == 'overall_work_experience' ||
          fieldData.fieldClassID == 'residence_since') {
        return DateSelectorWidget(
          initialDate: formValues[fieldData.fieldClassID],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select ${fieldData.fieldPlaceholder}';
            }
            return null;
          },
          label: fieldData.fieldPlaceholder,
          onDateSelected: (String selectedDate) {
            setState(() {
              print('experienc selected value ${selectedDate}');
              formValues[fieldData.fieldClassID] = selectedDate;
              print(formValues);
            });
          },
        );
      } else {
        return Container();
      }
      // Old Code
      // return Container(
      //     margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      //     // width: MediaQuery.of(context).size.width - 22,
      //     //color: Colors.white,
      //     height: 65,
      //     child: ElevatedButton(
      //       style: ButtonStyle(
      //           backgroundColor:
      //               themeProvider.currentTheme.brightness == Brightness.light
      //                   ? MaterialStateProperty.all<Color>(Colors.white)
      //                   : MaterialStateProperty.all<Color>(Colors.grey),
      //           /*shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      //               RoundedRectangleBorder(
      //                   borderRadius: BorderRadius.circular(4.0),
      //                   side: const BorderSide(color: Color(0xffdee7e4))))*/
      //           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      //               RoundedRectangleBorder(
      //                   borderRadius: BorderRadius.circular(15.0),
      //                   //side: const BorderSide(color: Color(0x00007078))))
      //                   side: const BorderSide(color: kLabelColor)))),
      //       child: Row(
      //         mainAxisAlignment: MainAxisAlignment.start,
      //         children: [
      //           const Icon(
      //             Icons.date_range_rounded,
      //             size: 24.0,
      //             color: Color(0xffcfcfcf),
      //           ),
      //           const SizedBox(
      //             width: 10,
      //           ),
      //           Text(
      //             '${formValues[fieldData.fieldClassID] == null || formValues[fieldData.fieldClassID] == "" ? fieldData.fieldPlaceholder : formValues[fieldData.fieldClassID]}',
      //             style: TextStyle(
      //               color: themeProvider.currentTheme.brightness ==
      //                       Brightness.light
      //                   ? const Color(0xff00948b)
      //                   : Colors.white,
      //             ),
      //           ),
      //         ],
      //       ),
      //       onPressed: () {
      //         _selectDate(context, fieldData);
      //       },
      //     ));
    } else if (fieldData.fieldType == 'Entry' &&
        fieldData.fieldKeyboardType == 'number') {
      final textEditingController = _getController(fieldData.fieldClassID);
      textEditingController.text = formValues[fieldData.fieldClassID] ?? "";
      // return Container(
      //   margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      //   child: TextFormField(
      //     controller: textEditingController,
      //     keyboardType: TextInputType.number,
      //     onChanged: (value) {
      //       formValues[fieldData.fieldClassID] = value;

      //       // lableclr = const Color(0xFF079889);
      //       if (fieldData.fieldClassID == "id_number") {
      //         String idCardNumber = formValues[fieldData.fieldClassID];
      //         print('Length of CNIC NO: ${idCardNumber.length}');
      //         if (idCardNumber.contains('-')) {
      //           idCardNumber = idCardNumber.replaceAll("-", "");
      //         }
      //         if (idCardNumber.length == 13) {
      //           getCustomerData(idCardNumber);
      //         }
      //       }
      //     },
      //     validator: (value) {
      //       if (fieldData.fieldClassID == "id_number") {
      //         if (value == null || value.isEmpty) {
      //           return 'Please enter ${fieldData.fieldPlaceholder}';
      //         } else if (value.length != 13) {
      //           return 'CNIC number should be 13 digits';
      //         }
      //       } else {
      //         if (value == null || value.isEmpty) {
      //           return 'Please enter ${fieldData.fieldPlaceholder}';
      //         }
      //       }
      //       return null;
      //     },
      //     decoration: InputDecoration(
      //       labelText: fieldData.fieldPlaceholder,
      //       hintText: fieldData.fieldPlaceholder,
      //       hintStyle: TextStyle(color: Colors.grey.shade400),
      //       floatingLabelBehavior: FloatingLabelBehavior.always,
      //     ),
      //   ),
      // );
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: NewCustomTextField_DF(
          inputFormatters: getTextInputFormatters(
              fieldData.fieldKeyboardType, fieldData.fieldClassID),
          controller: textEditingController,
          labelText: fieldData.fieldPlaceholder,
          hintText: fieldData.fieldValue,
          inputType: TextInputType.number,
          onChanged: (value) {
            formValues[fieldData.fieldClassID] = value;

            // lableclr = const Color(0xFF079889);
            if (fieldData.fieldClassID == "id_number") {
              String idCardNumber = formValues[fieldData.fieldClassID];
              print('Length of CNIC NO: ${idCardNumber.length}');
              if (idCardNumber.contains('-')) {
                idCardNumber = idCardNumber.replaceAll("-", "");
              }
              if (idCardNumber.length == 13) {
                // getCustomerData(idCardNumber);
              }
            }
          },
          // validator: (value) => validateInputTF(
          //     value, fieldData.isRequired, fieldData.fieldPlaceholder),
          validator: (value) {
            if (fieldData.fieldClassID == "telephone_number" ||
                fieldData.fieldClassID == "other_income") {
              return null;
            }

            if (fieldData.fieldClassID == "id_number" ||
                fieldData.fieldClassID == "reference_cnic_1" ||
                fieldData.fieldClassID == "reference_cnic_2") {
              if (value == null || value.isEmpty) {
                return 'Please Enter ${fieldData.fieldPlaceholder}';
              } else if (value.length != 15) {
                return 'CNIC number should be 13 digits';
              }
            }
            if (fieldData.fieldClassID == "reference_cnic_2") {
              final r1 = (formValues['reference_cnic_1'] ?? '')
                  .toString()
                  .replaceAll('-', '');
              final r2 = value?.replaceAll('-', '');
              if (r1.isNotEmpty && r1 == r2) {
                return 'Reference CNICs must be different';
              }
            } else if (fieldData.fieldClassID == "reference_mobile_2" ||
                fieldData.fieldClassID == "reference_mobile_1") {
              if (value == null || value.isEmpty) {
                return 'Please Enter ${fieldData.fieldPlaceholder}';
              } else if (value.length != 11) {
                return 'Number should be 11 digits';
              }
              if (fieldData.fieldClassID == "reference_mobile_2") {
                final m1 = (formValues['reference_mobile_1'] ?? '')
                    .toString()
                    .replaceAll(RegExp(r'\D'), ''); // strip non-digits
                final m2 = value.replaceAll(RegExp(r'\D'), '');
                if (m1.isNotEmpty && m1 == m2) {
                  return 'Reference Mobile Numbers must be different';
                }
              }
            } else if (fieldData.fieldClassID == "other_source_income") {
              if (value == null || value.isEmpty) {
                return null;
              }
            } else {
              if (value == null || value.isEmpty) {
                return 'Please Enter ${fieldData.fieldPlaceholder}';
              }
            }

            return null;
          },
        ),
      );
    } else if (fieldData.fieldType == 'Header') {
      if (fieldData.fieldClassID == 'txt_id_number') {
        return Text(
          'CNIC: ${cnic ?? "Not Provided!"}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      } else if (fieldData.fieldClassID == 'txt_mobile_number') {
        return Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            'Mobile Number: $phoneNumber',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      } else {
        return Text(fieldData.fieldPlaceholder,
            textAlign: TextAlign.center, style: subHeading);
      }
    } else if (fieldData.fieldType == 'subHeading') {
      return Text(fieldData.fieldPlaceholder,
          textAlign: TextAlign.center, style: DynamicsFormHeadingStyle);
    } else if (fieldData.fieldType == 'AppBarHeading') {
      return const Text('');
    } else if (fieldData.fieldType == 'Label') {
      return Text(
        fieldData.fieldPlaceholder,
        style: labelStyle,
      );
    } else if (fieldData.fieldType == 'Note') {
      return Html(data: '''<div>${fieldData.fieldPlaceholder}</div>''');
    } else if (fieldData.fieldType == 'Checkbox') {
      /*
      return CheckboxListTile(
          activeColor: const Color(0xff00948b),
          title: Text(fieldData.fieldPlaceholder),
          value: formValues[fieldData.fieldClassID] == null ||
                  formValues[fieldData.fieldClassID] == false
              ? false
              : true,
          onChanged: (bool? value) {
            print('Value: $value');
            formValues[fieldData.fieldClassID] = value;
            setState(() {});
          });
       */
      // if (fieldData.fieldIsRequired) {
      //   enableCheckboxValidation = true;
      //   disableNextButton = formValues[fieldData.fieldClassID] != null
      //       ? !formValues[fieldData.fieldClassID]
      //       : true;
      // }
      return HyperlinkedCheckbox(
        onChanged: (bool value) {
          formValues[fieldData.fieldClassID] = value;
          disableNextButton = !value;
          setState(() {}); // To update UI (e.g., button enabled state)
        },
      );
      // return Row(
      //   mainAxisAlignment: MainAxisAlignment.start,
      //   children: [
      //     Checkbox(
      //       value: formValues[fieldData.fieldClassID] == null ||
      //               formValues[fieldData.fieldClassID] == false
      //           ? false
      //           : true,
      //       onChanged: (bool? value) {
      //         print('Value: $value');
      //         formValues[fieldData.fieldClassID] = value;
      //         disableNextButton = !value!;
      //         print('Disable Next Button: $disableNextButton');
      //         setState(() {});
      //       },
      //     ),
      //     Flexible(
      //       child: Text(
      //         fieldData.fieldPlaceholder,
      //         style: const TextStyle(
      //           color: Colors.black,
      //           fontSize: 13,
      //           fontWeight: FontWeight.w500,
      //         ),
      //       ),
      //     )
      //   ],
      // );
    } else if (fieldData.fieldType == 'Button') {
      if (fieldData.fieldClassID == 'income' ||
          fieldData.fieldClassID == 'statement' ||
          fieldData.fieldClassID == 'business_prof' ||
          fieldData.fieldClassID == 'residential' ||
          fieldData.fieldClassID == 'signature') {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: newSecondaryColor,
                ),
                onPressed: () {
                  _showPickImageDialog(context, fieldData.fieldClassID);
                },
                child: Text(
                  fieldData.fieldPlaceholder,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            imageSelector[fieldData.fieldClassID] != null
                ? Image.file(
                    File(imageSelector[fieldData.fieldClassID]!.path),
                    height: 200.0,
                    width: 200.0,
                  )
                : multiImageSelector[fieldData.fieldClassID] != null
                    ? SizedBox(
                        height: 300,
                        child: ListView.builder(
                            itemCount:
                                multiImageSelector[fieldData.fieldClassID]
                                    ?.length,
                            itemBuilder: (context, index) {
                              return Image.file(
                                multiImageSelector[fieldData.fieldClassID]![
                                    index],
                                height: 200.0,
                                width: 200.0,
                              );
                            }),
                      )
                    : fileSelector[fieldData.fieldClassID] != null
                        ? SizedBox(
                            height: 150,
                            child: ListView.builder(
                                itemCount: fileSelector[fieldData.fieldClassID]
                                    ?.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(fileSelector[
                                            fieldData.fieldClassID]![index]
                                        .path),
                                  );
                                }),
                          )
                        : const Text('No Image/File is selected')
          ],
        );
      } else if (fieldData.fieldPlaceholder == 'Bank Statement *') {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: newSecondaryColor,
                ),
                onPressed: () {
                  _showPickImageDialog(context, fieldData.fieldClassID);
                },
                child: Text(
                  fieldData.fieldPlaceholder,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            imageSelector[fieldData.fieldClassID] != null
                ? Image.file(
                    File(imageSelector[fieldData.fieldClassID]!.path),
                    height: 200.0,
                    width: 200.0,
                  )
                : multiImageSelector[fieldData.fieldClassID] != null
                    ? SizedBox(
                        height: 300,
                        child: ListView.builder(
                            itemCount:
                                multiImageSelector[fieldData.fieldClassID]
                                    ?.length,
                            itemBuilder: (context, index) {
                              return Image.file(
                                multiImageSelector[fieldData.fieldClassID]![
                                    index],
                                height: 200.0,
                                width: 200.0,
                              );
                            }),
                      )
                    : fileSelector[fieldData.fieldClassID] != null
                        ? SizedBox(
                            height: 150,
                            child: ListView.builder(
                                itemCount: fileSelector[fieldData.fieldClassID]
                                    ?.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(fileSelector[
                                            fieldData.fieldClassID]![index]
                                        .path),
                                  );
                                }),
                          )
                        : const Text('No Image/File is selected')
          ],
        );
      } else if (fieldData.fieldClassID == 'digital_signature') {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: newSecondaryColor,
                ),
                onPressed: () {
                  print('Digital Signature button is clicked...!');
                  signatureDialog(context);
                },
                child: Text(
                  fieldData.fieldPlaceholder,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            selectedSignature != null
                ? Column(
                    children: [
                      Center(child: Image.memory(selectedSignature!)),
                      const SizedBox(height: 10),
                    ],
                  )
                : Container(child: const Text('No Signatures!')),
          ],
        );
      } else if (fieldData.fieldClassID == 'selfie') {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Spacer(),
            SelfieButton(
                fieldData: fieldData,
                onPressed: () async {
                  ReusableDialogs.showProgressDialog(context);
                  final policyProvider =
                      Provider.of<PolicyProvider>(context, listen: false);
                  bool selfie_liveliness =
                      policyProvider.getPolicyValue('selfie_liveliness');
                  if (selfie_liveliness) {
                    bool selfiLiveliness = await callFace(context);
                    if (selfiLiveliness) {
                      next();
                      Navigator.of(context).pop();
                      setState(() {});
                      await getclientInfoandPopulate();
                    } else {
                      Navigator.of(context).pop();
                    }

                    // next();
                  } else {
                    next();
                    Navigator.of(context).pop();
                  }
                }),
          ],
        );
      } else if (fieldData.fieldClassID == "nadra_verification") {
        return NadraVerificationButton(
            fieldData: fieldData,
            onPressed: () async {
              fingerBiometric(context);
            });
      } else if (fieldData.fieldClassID == "agreements_box") {
        return const AgreementContainer();
      }
      // else if (fieldData.fieldClassID == "pmd") {
      //   return NadraVerificationButton(
      //       fieldData: fieldData,
      //       onPressed: () async {
      //         final prefs = await SharedPreferences.getInstance();
      //         String? mobile = prefs.getString('sign_in_number');
      //         String? cnic = prefs.getString('cnic');
      //         // getPMDVerification(mobile!, "1234567890");
      //         // final policyProvider = Provider.of<PolicyProvider>(context);
      //         // bool emailParameter = policyProvider.getPolicyValue('pmd');
      //         // if (emailParameter) {
      //         //   formValues[fieldData.fieldClassID] = await PMDPostRequest(
      //         //     mobile,
      //         //     cnic,
      //         //   );
      //         // } else {}
      //       });
      // }
      // else if (fieldData.fieldClassID == 'income_upload_documents' ||
      //     fieldData.fieldClassID == 'statement_upload_documents' ||
      //     fieldData.fieldClassID == 'business_prof_upload_documents' ||
      //     fieldData.fieldClassID == 'residential_upload_documents') {
      //   if (fieldData.fieldClassID == 'income_upload_documents') {
      //     for (DocumentsData item in documentsData) {
      //       if (item.value == 25) {
      //         return generateDocumentPicker('25', item.label);
      //       }
      //     }
      //   } else if (fieldData.fieldClassID == 'statement_upload_documents') {
      //     // for (DocumentsData item in documentsData) {
      //     //   if (item.value == 24) {
      //     //     return generateDocumentPicker('24', item.label);
      //     //   }
      //     // }
      //     return const DocumentUploadPage(
      //       token: '4a44c7c4eaa088f9c7ce3f35550eb15d',
      //       productId: 39646,
      //       employmentTypeId: 11844,
      //     );
      //   }
      //   return Container();
      // }
      else if (fieldData.fieldClassID == "Documents_Upload") {
        print(employmentTypeId ?? "empty");
        return DocumentUploadPage(
          docWidgetKey: _docWidgetKey,
          productId: globalProductValue!,
          employmentTypeId: formValues["employment_type_id"],
        );
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: kPrimaryColor,
                ),
                onPressed: () {},
                child: Text(
                  fieldData.fieldPlaceholder,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            )
          ],
        );
      }
    } else if (fieldData.fieldClassID == 'Feature') {
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
              child: Text(fieldData.fieldPlaceholder, style: labelStyle),
            ),
          ],
        ),
      );
    } else if (fieldData.fieldType == 'Switch') {
      if (fieldData.listItemsDetails.isNotEmpty) {
        List<Widget> widgets = [];
        List<dynamic> listsL2 = [];
        if (fieldData.listItemsDetails[0].runtimeType == List<dynamic>) {
          for (var l in fieldData.listItemsDetails) {
            listsL2.add(l);
          }
        }
        widgets.add(
          Row(
            children: [
              Expanded(child: Text(fieldData.fieldPlaceholder)),
              CupertinoSwitch(
                activeColor: kPrimaryColor,
                thumbColor: (formValues[fieldData.fieldClassID] == null ||
                            formValues[fieldData.fieldClassID] == false
                        ? false
                        : true)
                    ? kPrimaryLightColor
                    : kPrimaryColor,
                //trackColor: kPrimaryLightColor,
                value: formValues[fieldData.fieldClassID] == null ||
                        formValues[fieldData.fieldClassID] == false
                    ? false
                    : true,
                onChanged: (value) => setState(() {
                  formValues[fieldData.fieldClassID] = value;
                  switchStates[fieldData.fieldClassID] = value;
                  setState(() {});
                }),
              )
            ],
          ),
        );
        /*
          if(switchStates[fieldData.fieldClassID] != null && switchStates[fieldData.fieldClassID] == true) {
            widgets.add(
                Visibility(
                    visible: true,
                    child: Text('${fieldData.fieldClassID} is ${switchStates[fieldData.fieldClassID]}, Total Level 2 Lists: ${listsL2.length}')
                )
            );
          } else if(switchStates[fieldData.fieldClassID] != null && switchStates[fieldData.fieldClassID] == false) {
            widgets.add(
                Visibility(
                    visible: false,
                    child: Text('${fieldData.fieldClassID} is ${switchStates[fieldData.fieldClassID]}, Total Level 2 Lists: ${listsL2.length}')
                )
            );
          }
           */
        if (switchStates[fieldData.fieldClassID] != null &&
            switchStates[fieldData.fieldClassID] == true) {
          for (int i = 0; i < listsL2.length; i++) {
            List<dynamic> l = listsL2[i];
            for (var item in l) {
              List<dynamic> dl = item['listItems'];
              List<String> listItems = [];
              if (!dl.isEmpty) {
                for (var li in dl) {
                  listItems.add(li);
                }
              }
              widgets.add(Visibility(
                  visible: true,
                  child: buildFormField(
                      context,
                      FormFieldDataNew(
                          fieldType: item['fieldType'],
                          fieldKeyboardType: item['fieldKeyboardType'],
                          fieldPlaceholder: item['fieldPlaceholder'],
                          fieldValue: item['fieldValue'],
                          fieldClassID: item['fieldClassID'],
                          fieldIsRequired: item['fieldIsRequired'],
                          listItems: listItems,
                          listItemsDetails: item['listItemsDetails']))));
            }
          }
        } else if (switchStates[fieldData.fieldClassID] != null &&
            switchStates[fieldData.fieldClassID] == false) {
          for (int i = 0; i < listsL2.length; i++) {
            List<dynamic> l = listsL2[i];
            for (var item in l) {
              List<dynamic> dl = item['listItems'];
              List<String> listItems = [];
              if (!dl.isEmpty) {
                for (var li in dl) {
                  listItems.add(li);
                }
              }
              widgets.add(Visibility(
                  visible: false,
                  child: buildFormField(
                      context,
                      FormFieldDataNew(
                          fieldType: item['fieldType'],
                          fieldKeyboardType: item['fieldKeyboardType'],
                          fieldPlaceholder: item['fieldPlaceholder'],
                          fieldValue: item['fieldValue'],
                          fieldClassID: item['fieldClassID'],
                          fieldIsRequired: item['fieldIsRequired'],
                          listItems: listItems,
                          listItemsDetails: item['listItemsDetails']))));
            }
          }
        }
        return Column(children: widgets);
      } else {
        return Row(
          children: [
            Expanded(child: Text(fieldData.fieldPlaceholder)),
            CupertinoSwitch(
              activeColor: kPrimaryColor,
              thumbColor: (formValues[fieldData.fieldClassID] == null ||
                          formValues[fieldData.fieldClassID] == false
                      ? false
                      : true)
                  ? kPrimaryLightColor
                  : kPrimaryColor,
              //trackColor: kPrimaryLightColor,
              value: formValues[fieldData.fieldClassID] == null ||
                      formValues[fieldData.fieldClassID] == false
                  ? false
                  : true,
              onChanged: (value) => setState(() {
                formValues[fieldData.fieldClassID] = value;
                switchStates[fieldData.fieldClassID] = value;
                setState(() {});
              }),
            )
          ],
        );
      }
    } else if (fieldData.fieldType == 'Radio') {
      if (fieldData.fieldClassID == "Availing_Financial") {
        return DynamicRadioWidget(
          label: fieldData.fieldPlaceholder,
          key: _radioKey,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "This field cannot be empty.";
            }
            return null;
          },
          rawListItems: fieldData.listItems,
          rawListItemsDetails: fieldData.listItemsDetails,
        );
      }
      /*
      List<String> options = fieldData.listItems;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(fieldData.fieldPlaceholder),
          Column(
            children: options
                .map((option) => RadioListTile<String>(
                      activeColor: const Color(0xFF079889),
                      title: Text(option.trim()),
                      value: option.trim(),
                      groupValue: formValues[fieldData.fieldClassID],
                      onChanged: (String? value) {
                        setState(() {
                          //formValues[fieldData.fieldId] = value;
                          formValues[fieldData.fieldClassID] = value;
                        });
                      },
                    ))
                .toList(),
          ),
        ],
      );
       */
      try {
        // TODO: Implement the new logic for radio button.
        List<String> options = fieldData.listItems;
        if (fieldData.fieldClassID == 'permanet_or_residential_address') {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: RadioWithConditionalTextField(
              fieldData: fieldData,
              initialRadioValue:
                  formValues['permanet_or_residential_address'] as String?,
              initialText: formValues['current_address'] as String?,
              onRadioChanged: (val) =>
                  formValues['permanet_or_residential_address'] = val,
              onTextChanged: (val) => formValues['current_address'] = val,
            ),
          );
        } else if (fieldData.fieldClassID == 'Auto_Debit_Authority') {
          return CustomSelectionWidget(
            heading: fieldData.fieldPlaceholder,
            dropdownItems: fieldData.listItemsDetails,
            radioButtonTexts: fieldData.listItems,
            onDropdownChanged: (String) {},
            onRadioChanged: (String) {},
          );
        } else if (fieldData.fieldClassID == "id_card_type") {
          return CnicTypeCustomRadioWidget(
            initialSelectedValue: formValues[fieldData.fieldClassID] ?? '',
            onSelectionChanged: (selected) {
              setState(() {
                formValues['id_card_type'] =
                    selected; // Update the selected item
                print(
                    'Radio button id card type: ${formValues[fieldData.fieldClassID]}');
                print(
                    'CNIC id:${getPickerId(fieldData.fieldClassID, selected)}');
                formValues['id_card_type_id'] =
                    getPickerId(fieldData.fieldClassID, selected);
              });
            },
            listItems: fieldData.listItems,
          );
        } else if (fieldData.listItemsDetails.isNotEmpty) {
          return DeliveryAddressCheckboxWidget(
            listItems: fieldData.listItems,
            listItemsDetails: fieldData.listItemsDetails,
          );
          // List<Widget> widgets = [];
          // widgets.add(Padding(
          //   padding: const EdgeInsets.only(top: 5.0, bottom: 8),
          //   child: Container(
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(10),
          //       color: Colors.black,
          //     ),
          //     child: Padding(
          //       padding: const EdgeInsets.only(
          //         left: 12,
          //         right: 37,
          //         top: 10,
          //       ),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: <Widget>[
          //           Text(
          //             fieldData.fieldPlaceholder,
          //             style: const TextStyle(
          //               color: newSecondaryColor,
          //               fontSize: 14,
          //               fontWeight: FontWeight.w500,
          //             ),
          //           ),
          //           Wrap(
          //             spacing: 8.0, // Horizontal spacing between items
          //             runSpacing:
          //                 8.0, // Vertical spacing when wrapping to next line
          //             children: options.map((option) {
          //               return Container(
          //                   // You can adjust constraints or remove them to let Wrap handle the spacing
          //                   constraints: const BoxConstraints(
          //                     minWidth: 100,
          //                     maxWidth:
          //                         200, // Enforce a max width so text can wrap
          //                   ),
          //                   child: Row(
          //                     mainAxisSize: MainAxisSize.min,
          //                     mainAxisAlignment: MainAxisAlignment.start,
          //                     children: [
          //                       Transform.scale(
          //                         scale:
          //                             1.0, // Adjust the size of the checkbox (optional)
          //                         child: Checkbox(
          //                           value: formValues[fieldData.fieldClassID] ==
          //                               option.trim(),
          //                           activeColor: const Color(0xFF079889),
          //                           shape: RoundedRectangleBorder(
          //                             borderRadius: BorderRadius.circular(
          //                                 50), // Circular shape
          //                           ),
          //                           onChanged: (bool? isChecked) {
          //                             setState(() {
          //                               if (isChecked ?? false) {
          //                                 formValues[fieldData.fieldClassID] =
          //                                     option.trim();
          //                                 pickerStates[fieldData.fieldClassID] =
          //                                     options.indexOf(option.trim());
          //                               } else {
          //                                 formValues[fieldData.fieldClassID] =
          //                                     null;
          //                                 pickerStates[fieldData.fieldClassID] =
          //                                     -1; // Or some other logic for unchecking
          //                               }
          //                             });
          //                           },
          //                         ),
          //                       ),
          //                       // Wrap text if it exceeds available space
          //                       Flexible(
          //                         child: Text(
          //                           option.trim(),
          //                           softWrap: true,
          //                         ),
          //                       ),
          //                     ],
          //                   ));
          //             }).toList(),
          //           )
          //         ],
          //       ),
          //     ),
          //   ),
          // ));
          // if (pickerStates[fieldData.fieldClassID] != null) {
          //   int? index = pickerStates[fieldData.fieldClassID];
          //   List<dynamic> subFields = fieldData.listItemsDetails[index!];
          //   for (var item in subFields) {
          //     List<dynamic> dl = item['listItems'];
          //     List<String> listItems = [];
          //     if (!dl.isEmpty) {
          //       for (var li in dl) {
          //         listItems.add(li);
          //       }
          //     }
          //     widgets.add(buildFormField(
          //         context,
          //         FormFieldDataNew(
          //             fieldType: item['fieldType'],
          //             fieldKeyboardType: item['fieldKeyboardType'],
          //             fieldPlaceholder: item['fieldPlaceholder'],
          //             fieldValue: item['fieldValue'],
          //             fieldClassID: item['fieldClassID'],
          //             fieldIsRequired:
          //                 item['fieldIsRequired'] != null ? true : false,
          //             listItems: listItems,
          //             listItemsDetails: item['listItemsDetails'])));
          //   }
          // }
          // return Column(
          //   children: widgets,
          // );
        } else {
          return CustomCheckboxValidator(
            placeholder: fieldData.fieldPlaceholder,
            options: options,
            selectedValue: formValues[fieldData.fieldClassID],
            onValueChanged: (value) {
              setState(() {
                formValues[fieldData.fieldClassID] = value;
              });
            },
            validator: (value) {
              // if (fieldData.fieldClassID == 'own_car') {
              //   return null;
              // }
              if (value == null || value.isEmpty) {
                return "Please select an option.";
              }
              return null;
            },
          );
          // return Padding(
          //     padding: const EdgeInsets.only(top: 10.0),
          //     child: Container(
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(10),
          //         color: Colors.white,
          //       ),
          //       child: Padding(
          //         padding: const EdgeInsets.all(8.0),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: <Widget>[
          //             Text(
          //               fieldData.fieldPlaceholder,
          //               style: const TextStyle(
          //                 color: newSecondaryColor,
          //                 fontSize: 14,
          //                 fontWeight: FontWeight.w500,
          //               ),
          //             ),
          //             // Use Row for two options displayed horizontally
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.start,
          //               children: options.map((option) {
          //                 final trimmedOption = option.trim();
          //                 return Row(
          //                   children: [
          //                     Checkbox(
          //                       shape: const CircleBorder(),
          //                       activeColor: const Color(0xFF079889),
          //                       value: formValues[fieldData.fieldClassID] ==
          //                           trimmedOption,
          //                       onChanged: (bool? selected) {
          //                         setState(() {
          //                           formValues[fieldData.fieldClassID] =
          //                               selected == true ? trimmedOption : null;
          //                         });
          //                       },
          //                     ),
          //                     const SizedBox(
          //                         width:
          //                             8), // normal small space between checkbox and text
          //                     Text(trimmedOption),
          //                     const SizedBox(width: 16),
          //                     const SizedBox(
          //                         width:
          //                             50), // normal spacing before next checkbox+text pair
          //                   ],
          //                 );
          //               }).toList(),
          //             )
          //           ],
          //         ),
          //       ),
          //     ));
        }
      } catch (e) {
        print('Exception in inserting Radio Button field! $e');
        return Text(
            'Type: ${fieldData.fieldType}, Class ID: ${fieldData.fieldClassID}');
      }
    }
    //else if (fieldData.fieldType == 'OCR') {
    //   return Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       SizedBox(
    //         width: double.infinity,
    //         height: 46,
    //         child: TextButton(
    //           style: TextButton.styleFrom(
    //             foregroundColor: Colors.white,
    //             shape: RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(10)),
    //             backgroundColor: kPrimaryColor,
    //           ),
    //           onPressed: () {
    //             showDialog(
    //                 context: context,
    //                 builder: (BuildContext context) {
    //                   return CustomDialogBox(onCameraBTNPressed: () {
    //                     scanCnic(ImageSource.camera);
    //                   }, onGalleryBTNPressed: () {
    //                     scanCnic(ImageSource.gallery);
    //                   });
    //                 });
    //           },
    //           child: Text(
    //             fieldData.fieldPlaceholder,
    //             style: const TextStyle(
    //               fontSize: 18,
    //               color: Colors.white,
    //             ),
    //           ),
    //         ),
    //       ),
    //       const SizedBox(
    //         height: 16,
    //       ),
    //     ],
    //   );
    // }
    else if (fieldData.fieldClassID == 'cnic_ocr') {
      return CnicCaptureWidget(
        onDataFetched: (CnicModel) {
          setState(() {
            _cnicModel = CnicModel;
            if (_cnicModel.cnicHolderName.isNotEmpty) {
              formValues['full_name'] = _cnicModel.cnicHolderName;
              formValues['father_name'] = _cnicModel.cnicHolderFatherName;
              formValues['id_number'] = _cnicModel.cnicNumber;
              formValues['date_of_birth'] = _cnicModel.cnicHolderDateOfBirth;
              formValues['id_issue_date'] = _cnicModel.cnicIssueDate;
              formValues['id_expiry_date'] = _cnicModel.cnicExpiryDate;
              // formValues["gender_type"] =
              //     _cnicModel.genderType == "M" ? "Male" : "Female";
            } else {
              formValues['full_name'] = "";
              formValues['father_name'] = "";
              formValues['id_number'] = "";
              formValues['date_of_birth'] = "";
              formValues['id_issue_date'] = "";
              formValues['id_expiry_date'] = "";
              getclientInfoandPopulate();
            }
            print("ID Number: ${formValues['id_number']}");
            // next();
          });
        },
        onMovedtoNext: () async {
          await next();
        },
      );
    } else if (fieldData.fieldClassID == 'Product_code') {
      formValues[fieldData.fieldClassID] = fieldData.fieldValue;
      return const Text('');
    } else if (fieldData.fieldType == 'Image') {
      if (fieldData.fieldClassID == 'selfie_instructions') {
        return const ResponsiveSelfieInstructionTable();

        // return Column(
        //   mainAxisAlignment: MainAxisAlignment.end,
        //   children: [
        //     SizedBox(
        //       height: 50.h,
        //     ),
        //     SizedBox(
        //       width: MediaQuery.of(context).size.width,
        //       height: MediaQuery.of(context).size.height * 0.2,
        //       child: FittedBox(
        //         fit: BoxFit.cover,
        //         child: Image.asset(
        //           fieldData.fieldPlaceholder,
        //         ),
        //       ),
        //     ),
        //     SizedBox(height: 100.h),
        //   ],
        // );
      } else if (fieldData.fieldClassID == 'cnic_Instructions_image') {
        return const ResponsiveCnicInstructionTable();
      } else {
        return Text(fieldData.fieldType);
      }
    } else {
      return Text(fieldData.fieldType);
    }
  }

  Future<void> scanCnic(ImageSource imageSource) async {
    /// you will need to pass one argument of "ImageSource" as shown here
    CnicModel cnicModel =
        await CnicScanner().scanImage(imageSource: imageSource);
    if (cnicModel == null) return;
    setState(() {
      _cnicModel = cnicModel;
      formValues['full_name'] = _cnicModel.cnicHolderName;
      formValues['father_name'] = _cnicModel.cnicHolderFatherName;
      formValues['id_number'] = _cnicModel.cnicNumber;
      formValues['date_of_birth'] = _cnicModel.cnicHolderDateOfBirth;
      formValues['id_issue_date'] = _cnicModel.cnicIssueDate;
      formValues['id_expiry_date'] = _cnicModel.cnicExpiryDate;

      print("ID Number: ${formValues['id_number']}");
      next();
    });
  }

  List<Widget> generateSteps() {
    List<Widget> steps = [];
    //List<String> stepNames = ['Personal Information', 'Selfie Assessment', 'Profession Information', 'Customer Address', 'Required Documents', 'Step 6'];
    for (int i = 0; i < fieldsSteps.length; i++) {
      steps.add(Column(
        children: [
          Text(
            '',
            style: TextStyle(
                fontWeight: i == stepNo ? FontWeight.bold : FontWeight.normal,
                color: i == stepNo ? Colors.white : Colors.black),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: i == stepNo
                  ? const Color(0xff71bf45)
                  : const Color(0xff757c99),
              //  borderRadius: const BorderRadius.all(Radius.circular(8)),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${i + 1}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20),
            ),
          ),
        ],
      ));
    }
    return steps;
  }

  Future<void> _loadLocalDBData() async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();

      // Retrieve previously saved form values
      List<FormValue> savedFormValues =
          await databaseHelper.getFormValues(widget.loanRequestId);
      for (FormValue fv in savedFormValues) {
        // For each saved form value, update formValues map
        formValues[fv.fieldClassID] = fv.fieldValue;
      }

      // Retrieve previously saved picker indexes
      List<PickerState> savedPickerStates =
          await databaseHelper.getPickerIndexes(widget.loanRequestId);
      for (PickerState ps in savedPickerStates) {
        pickerStates[ps.fieldClassID] = int.parse(ps.pickerIndex);
      }

      // Retrieve previously saved picker IDs
      List<PickerID> savedPickerIds =
          await databaseHelper.getPickerIds(widget.loanRequestId);
      for (PickerID pid in savedPickerIds) {
        pickerIds[pid.fieldClassID] = pid.pickerId;
      }

      // Retrieve previously saved switch states
      List<SwitchState> savedSwitchStates =
          await databaseHelper.getSwitchStates(widget.loanRequestId);
      for (SwitchState ss in savedSwitchStates) {
        switchStates[ss.fieldClassID] = bool.parse(ss.state);
      }

      // Retrieve previously saved images (if you want to show them)
      // You may need to convert them back from base64 to XFile/File if needed

      setState(() {
        // Now the local DB data is merged into in-memory maps:
        // formValues, pickerStates, pickerIds, switchStates, etc.
        // The UI can read from these.
      });
    } catch (e) {
      print("Error loading local DB data: $e");
    }
  }

  void _submitForm() {
    stepNo++;
    if (stepNo == 0) {
      backVisible = false;
    } else {
      backVisible = true;
    }
    if (stepNo == fieldsSteps.length - 1) {
      forwardVisible = false;
    } else {
      forwardVisible = true;
    }
    if (stepNo < fieldsSteps.length) {
      _loadStepFields(fieldsSteps[stepNo]);
    }
  }

  void _backForm() {
    stepNo--;
    if (stepNo == 0) {
      backVisible = false;
    } else {
      backVisible = true;
    }

    if (stepNo < fieldsSteps.length) {
      forwardVisible = true;
      _loadStepFields(fieldsSteps[stepNo]);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProductsData().then((products) {
      setState(() {
        globalProducts = products;
        if (products.isNotEmpty) {
          _applyProduct(products[0]);
        }
      });
    });
    signatureController =
        SignatureController(penStrokeWidth: 2, penColor: Colors.black);
    clearAllDocs();
    callApis();
    if (widget.showData) {
      if (widget.stepsCompleted != -1) {
        stepNo = widget.stepsCompleted;
        currentStep = stepNo + 1;
        if (stepNo > 0) {
          backVisible = true;
        }
      }
      newRequestIdReceived = true;
      requestId = widget.loanRequestId;
      getFormValuesFromDB();
      getPickerIndexesFromDB();
      getPickerIdsFromDB();
      getSwitchStatesFromDB();
      // getBase64ImagesFromDB();
    }
    _loadFormDataFromJson();
    _loadLocalDBData();
    _controller = PageController();
  }

  @override
  Widget build(BuildContext context) {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: false);
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

    print('Step Number: $stepNo');
    print('Current Step: $currentStep');

    // print('Current Step: $fetchingCountries');
    // print('Current Step: $fetchingNationalityType');
    // print('Current Step: $fetchingEmploymentType');
    // print('Current Step: $fetchingEmploymentStatus');
    // print('Current Step: $fetchingTypeOfCompany');
    // print('Current Step: $fetchingTypeOfBusiness');
    //
    // print('Current Step: $fetchingProfessionType');
    // print('Current Step: $fetchingProductType');
    // print('Current Step: $fetchingCardType');
    // print('Current Step: $fetchingCnicTypes');
    // print('Current Step: $fetchingOtherFacilities');
    // print('Current Step: $fetchingAssetData');
    //
    // print('Current Step: $fetchingCustomerData');
    // print('Current Step: $fetchingTenor');
    // print('Current Step: $fetchingInstallmentFrequency');
    // print('Current Step: $fetchingVehicleType');
    // print('Current Step: $fetchingFacilityTypes');
    // print('Current Step: $fetchingEmiTypes');
    //
    // print('Current Step: $fetchingInstallmentDueDates');
    // print('Current Step: $fetchingTakafulCompanies');
    // print('Current Step: $fetchingGenderTypes');
    // print('fetchingDocumentsData: $fetchingDocumentsData');
    // print('fetchingCities: $fetchingCities');
    // print('fetchingMaritalType: $fetchingMaritalType');
    //
    // print('fetchingEducationType: $fetchingEducationType');
    // print('fetchingResidentialStatus: $fetchingResidentialStatus');
    // print('fetchingAccommodationTypes: $fetchingAccommodationTypes');
    // print('fetchingRelationshipTypes: $fetchingRelationshipTypes');

    final themeProvider = Provider.of<ThemeProvider>(context);
    return fetchingCountries ||
            fetchingNationalityType ||
            fetchingEmploymentType ||
            fetchingEmploymentStatus ||
            fetchingTypeOfCompany ||
            fetchingTypeOfBusiness ||
            fetchingProfessionType ||
            fetchingProductType ||
            fetchingCardType ||
            fetchingCnicTypes ||
            fetchingOtherFacilities ||
            fetchingAssetData ||
            fetchingCustomerData ||
            fetchingTenor ||
            fetchingInstallmentFrequency ||
            fetchingVehicleType ||
            fetchingFacilityTypes ||
            fetchingEmiTypes ||
            fetchingInstallmentDueDates ||
            fetchingTakafulCompanies ||
            fetchingGenderTypes ||
            fetchingDocumentsData ||
            fetchingCities ||
            fetchingMaritalType ||
            fetchingEducationType ||
            fetchingResidentialStatus ||
            fetchingAccommodationTypes ||
            fetchingRelationshipTypes
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : Scaffold(
            bottomNavigationBar: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              //color: const Color(0xFFf0f0f0),
              height: MediaQuery.of(context).size.height * 0.09,
              child: Visibility(
                visible: (continueButtonEnable.toLowerCase() == 'true'),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  // Visibility(
                  //   visible: backVisible,
                  //   child: SizedBox(
                  //       width: 60,
                  //       height: 40,
                  //       child: TextButton(
                  //         style: TextButton.styleFrom(
                  //           foregroundColor: Colors.white,
                  //           shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(20)),
                  //           backgroundColor: newSecondaryColor,
                  //         ),
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           crossAxisAlignment: CrossAxisAlignment.center,
                  //           children: [
                  //             Center(
                  //               child: Icon(
                  //                 Icons.keyboard_arrow_left,
                  //                 //color: Colors.white,
                  //                 color: themeProvider
                  //                             .currentTheme.brightness ==
                  //                         Brightness.light
                  //                     ? Colors.white
                  //                     : Colors.black,
                  //                 //size: 30,
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //         onPressed: () {
                  //           //_backForm();
                  //           back();
                  //         },
                  //       )),
                  // ),
                  SizedBox(
                    height: 60.h,
                    width: 300.w,
                    child: Visibility(
                      //visible: forwardVisible,
                      visible: true,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          //backgroundColor: kPrimaryColor,
                          backgroundColor: !disableNextButton
                              ? newSecondaryColor
                              : kTextColor,
                          padding: EdgeInsets.symmetric(
                            vertical: 14.h, // Responsive vertical padding
                            horizontal: 24.w, // Responsive horizontal padding
                          ),
                        ),
                        child: Center(
                            child: _busy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : Text(
                                    forwardVisible &&
                                            newcurrentStep != 'Upload Documents'
                                        ? 'Continue'
                                        : 'Submit',
                                    style: TextStyle(
                                        //color: Colors.white,
                                        color: Colors.white,
                                        fontSize: 18.sp,
                                        fontFamily: 'Circular',
                                        fontWeight: FontWeight.bold),
                                  )),
                        onPressed:
                            (_busy || disableNextButton) ? null : _onContinue,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            resizeToAvoidBottomInset: true,

            backgroundColor: ScaffoldBackground,
            // appBar: CustomAppBar(true, false),
            // backgroundColor:
            //     themeProvider.currentTheme.brightness == Brightness.light
            //         ? Colors.white
            //         : const Color(0x303030),
            appBar: CustomAppBarwithHeadingIcon(
              appBarHeading: newcurrentStep,
              appBarIcon: Icons.info_outline_rounded,
              onBackButtonPressed: () {
                if (backVisible) {
                  disableNextButton = false;
                  back();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
            body: Stack(children: [
              Column(
                children: [
                  SizedBox(
                    height: 50.h,
                    child: Container(
                      // child: ProcessTimelineNew(
                      //   processes: fieldsSteps,
                      //   currentIndex: stepNo,
                      // ),
                      child: SimpleProgressBar(
                        processes: fieldsSteps,
                        currentIndex: stepNo,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: Scrollbar(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(
                              top: 0.0, right: 16, bottom: 5, left: 16),
                          itemCount: formFields.length,
                          itemBuilder: (context, index) {
                            final fieldData = formFields[index];
                            return buildFormField(context, fieldData);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Positioned(
              //   bottom: 0,
              //   left: 0,
              //   right: 0,
              //   child: Container(
              //     color: Colors.transparent,
              //     padding: const EdgeInsets.symmetric(horizontal: 16),
              //     //color: const Color(0xFFf0f0f0),
              //     height: MediaQuery.of(context).size.height * 0.07,
              //     child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           // Visibility(
              //           //   visible: backVisible,
              //           //   child: SizedBox(
              //           //       width: 60,
              //           //       height: 40,
              //           //       child: TextButton(
              //           //         style: TextButton.styleFrom(
              //           //           foregroundColor: Colors.white,
              //           //           shape: RoundedRectangleBorder(
              //           //               borderRadius: BorderRadius.circular(20)),
              //           //           backgroundColor: newSecondaryColor,
              //           //         ),
              //           //         child: Row(
              //           //           mainAxisAlignment: MainAxisAlignment.center,
              //           //           crossAxisAlignment: CrossAxisAlignment.center,
              //           //           children: [
              //           //             Center(
              //           //               child: Icon(
              //           //                 Icons.keyboard_arrow_left,
              //           //                 //color: Colors.white,
              //           //                 color: themeProvider
              //           //                             .currentTheme.brightness ==
              //           //                         Brightness.light
              //           //                     ? Colors.white
              //           //                     : Colors.black,
              //           //                 //size: 30,
              //           //               ),
              //           //             )
              //           //           ],
              //           //         ),
              //           //         onPressed: () {
              //           //           //_backForm();
              //           //           back();
              //           //         },
              //           //       )),
              //           // ),
              //           SizedBox(
              //             width: 300,
              //             height: MediaQuery.of(context).size.height * 0.06,
              //             child: Visibility(
              //               //visible: forwardVisible,
              //               visible: true,
              //               child: SizedBox(
              //                 width: 100,
              //                 height: 40,
              //                 child: TextButton(
              //                   style: TextButton.styleFrom(
              //                     foregroundColor: Colors.white,
              //                     shape: RoundedRectangleBorder(
              //                         borderRadius: BorderRadius.circular(10)),
              //                     //backgroundColor: kPrimaryColor,
              //                     backgroundColor: !disableNextButton
              //                         ? newSecondaryColor
              //                         : kTextColor,
              //                   ),
              //                   child: Center(
              //                       child: Text(
              //                     forwardVisible ? 'Continue' : 'Submit',
              //                     style: const TextStyle(
              //                         //color: Colors.white,
              //                         color: Colors.white,
              //                         fontSize: 18,
              //                         fontFamily: 'Circular',
              //                         fontWeight: FontWeight.bold),
              //                   )),
              //                   onPressed: () async {
              //                     // _submitForm();
              //                     if (disableNextButton) {
              //                       return null;
              //                     }
              //                     if (forwardVisible) {
              //                       await pr.show();
              //                       next();

              //                       await pr.hide();
              //                     } else {
              //                       // TODO: Submit the form!

              //                       // await pr.show();
              //                       updateLoanRequestInfoInDB();
              //                       convertMapsIntoJson();
              //                       // await pr.hide();
              //                       // Navigator.of(context).pushReplacement(
              //                       //     MaterialPageRoute(
              //                       //         builder: (context) =>
              //                       //             RequestStatusScreen()));
              //                     }
              //                   },
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ]),
              //   ),
              // ),
            ]),
          );
  }

  buttonWidgets(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () async {
            if (signatureController!.isNotEmpty) {
              final sign = await exportSignature();
              setState(() {
                signature = sign;
                selectedSignature = signature;
                Navigator.pop(context);
              });
            } else {
              //showMessage
              // Please put your signature;
            }
          },
          child: const Text("OK",
              style: TextStyle(fontSize: 20, color: Colors.green)),
        ),
        TextButton(
          onPressed: () {
            if (signatureController!.isNotEmpty) {
              signatureController?.clear();
              Navigator.pop(context);
            } else {
              setState(() {
                signature = null;
                Navigator.pop(context);
              });
            }
          },
          child: Text(signatureController!.isNotEmpty ? 'Clear' : "Cancel",
              style: const TextStyle(fontSize: 20, color: Colors.red)),
        ),
      ],
    );
  }

  Future<void> signatureDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please put the signature here',
              style: TextStyle(fontSize: 20, color: Colors.black)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 15),
                const SizedBox(height: 15),
                Card(
                  child: Center(
                    child: Signature(
                      //height: 200,
                      //width: 350,
                      height: 300,
                      width: 450,
                      controller: signatureController!,
                      backgroundColor: Colors.white,
                    ),
                    // ),
                  ),
                ),
                buttonWidgets(context)!,
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Uint8List?> exportSignature() async {
    final exportController = SignatureController(
      penStrokeWidth: 2,
      exportBackgroundColor: Colors.white,
      penColor: Colors.black,
      points: signatureController!.points,
    );

    final signature = exportController.toPngBytes();

    //clean up the memory
    exportController.dispose();

    return signature;
  }

  Future<void> insertFormValueIntoDB() async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      for (var key in formValues.keys) {
        List<FormValue> fValues =
            await databaseHelper.getFormValue(key, requestId);
        if (fValues.isNotEmpty) {
          FormValue v = fValues[0];
          if (v.fieldValue == 'true') {
            bool checkBoxValue = true;
            if (formValues[key] != checkBoxValue) {
              int rowId = await databaseHelper.updateFormValue(
                  FormValue(key, false.toString(), widget.loanRequestId),
                  key,
                  requestId);
              print('Row ID: $rowId');
            }
          } else if (v.fieldValue == 'false') {
            bool checkBoxValue = false;
            if (formValues[key] != checkBoxValue) {
              int rowId = await databaseHelper.updateFormValue(
                  FormValue(key, true.toString(), widget.loanRequestId),
                  key,
                  requestId);
              print('Row ID: $rowId');
            }
          } else if (formValues[key] != v.fieldValue) {
            int rowId = await databaseHelper.updateFormValue(
                FormValue(key, formValues[key], requestId), key, requestId);
            print('Row ID: $rowId');
          }
        } else {
          if (formValues[key] == true) {
            var fValue = FormValue(key, true.toString(), requestId);
            int rowId = await databaseHelper.insertFormValue(fValue);
            print('Row ID: $rowId');
          } else if (formValues[key] == false) {
            var fValue = FormValue(key, false.toString(), requestId);
            int rowId = await databaseHelper.insertFormValue(fValue);
            print('Row ID: $rowId');
          } else {
            var fValue = FormValue(key, formValues[key], requestId);
            int rowId = await databaseHelper.insertFormValue(fValue);
            print('Row ID: $rowId');
          }
        }
      }
    } catch (e) {
      print('Exception in insertFormValueIntoDB(): $e');
    }
  }

  Future<void> getFormValuesFromDB() async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      List<FormValue> fValues = await databaseHelper.getFormValues(requestId);
      if (fValues.isNotEmpty) {
        for (FormValue fValue in fValues) {
          if (fValue.fieldValue == 'true') {
            formValues[fValue.fieldClassID] = true;
          } else if (fValue.fieldValue == 'false') {
            formValues[fValue.fieldClassID] = false;
          } else {
            formValues[fValue.fieldClassID] = fValue.fieldValue;
          }
        }
        setState(() {});
      }
    } catch (e) {
      print('Exception in getFormValuesFromDB(): $e');
    }
  }

  Future<void> insertPickerIndexIntoDB() async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      for (var key in pickerStates.keys) {
        List<PickerState> pValues =
            await databaseHelper.getPickerIndex(key, requestId);
        if (pValues.isNotEmpty) {
          PickerState pValue = pValues[0];
          if (pickerStates[key] != int.parse(pValue.pickerIndex)) {
            int rowId = await databaseHelper.updatePickerIndex(
                PickerState(key, pickerStates[key].toString(), requestId),
                key,
                requestId);
            print("Row ID: $rowId");
          }
        } else {
          int rowId = await databaseHelper.insertPickerIndex(
              PickerState(key, pickerStates[key].toString(), requestId));
          print("Row ID: $rowId");
        }
      }
    } catch (e) {
      print("Exception in insertPickerIndexIntoDB(): $e");
    }
  }

  Future<void> insertPickerIdIntoDB() async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      populatePickerIds();
      for (var key in pickerIds.keys) {
        List<PickerID> pValues =
            await databaseHelper.getPickerId(key, requestId);
        if (pValues.isNotEmpty) {
          PickerID pValue = pValues[0];
          if (pickerIds[key] != pValue.pickerId) {
            int rowId = await databaseHelper.updatePickerId(
                PickerID(key, pickerIds[key]!, requestId), key, requestId);
            print("Row ID: $rowId");
          }
        } else {
          int rowId = await databaseHelper
              .insertPickerId(PickerID(key, pickerIds[key]!, requestId));
          print("Row ID: $rowId");
        }
      }
    } catch (e) {
      print("Exception in insertPickerIdIntoDB(): $e");
    }
  }

  Future<void> getPickerIndexesFromDB() async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      List<PickerState> pValues =
          await databaseHelper.getPickerIndexes(requestId);
      if (pValues.isNotEmpty) {
        for (PickerState pValue in pValues) {
          pickerStates[pValue.fieldClassID] = int.parse(pValue.pickerIndex);
        }
      }
    } catch (e) {
      print("Exception in getPickerIndexesFromDB(): $e");
    }
  }

  Future<void> getPickerIdsFromDB() async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      List<PickerID> pValues = await databaseHelper.getPickerIds(requestId);
      if (pValues.isNotEmpty) {
        for (PickerID pValue in pValues) {
          pickerIds[pValue.fieldClassID] = pValue.pickerId;
        }
      }
    } catch (e) {
      print("Exception in getPickerIdsFromDB(): $e");
    }
  }

  Future<void> insertSwitchStateIntoDB() async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      for (var key in switchStates.keys) {
        List<SwitchState> sValues =
            await DatabaseHelper().getSwitchState(key, requestId);
        if (sValues.isNotEmpty) {
          SwitchState pValue = sValues[0];
          if (switchStates[key] != bool.parse(pValue.state)) {
            int rowId = await databaseHelper.updateSwitchState(
                SwitchState(key, switchStates[key].toString(), requestId),
                key,
                requestId);
            print("Row ID: $rowId");
          }
        } else {
          int rowId = await databaseHelper.insertSwitchSate(
              SwitchState(key, switchStates[key].toString(), requestId));
          print("Row ID: $rowId");
        }
      }
    } catch (e) {
      print("Exception in insertSwitchStateIntoDB(): $e");
    }
  }

  Future<void> getSwitchStatesFromDB() async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      List<SwitchState> sValues =
          await databaseHelper.getSwitchStates(requestId);
      if (sValues.isNotEmpty) {
        for (SwitchState sValue in sValues) {
          switchStates[sValue.fieldClassID] = bool.parse(sValue.state);
        }
      }
    } catch (e) {
      print("Exception in getSwitchStatesFromDB(): $e");
    }
  }

  Future<void> insertBase64ImageIntoDB() async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      if (imageSelector.isNotEmpty) {
        print('Length of imageSelector{}: ${imageSelector.length}');
        for (var key in imageSelector.keys) {
          String? base64String = await convertToBase64(imageSelector[key]!);
          List<Base64Image> images =
              await databaseHelper.getBase64Image(key, requestId);
          if (images.isNotEmpty) {
            int noOfRowsDeleted =
                await databaseHelper.delBase64Image(key, requestId);
            print("Rows Deleted: $noOfRowsDeleted");
            int rowId = await databaseHelper
                .insertBase64Image(Base64Image(key, base64String!, requestId));
            print("Row ID: $rowId");
          } else {
            int rowId = await databaseHelper
                .insertBase64Image(Base64Image(key, base64String!, requestId));
            print("Row ID: $rowId");
          }
        }
      }
      if (multiImageSelector.isNotEmpty) {
        print('Length of multiImageSelector{}: ${multiImageSelector.length}');
        for (var key in multiImageSelector.keys) {
          List<File>? imageFiles = multiImageSelector[key];
          if (imageFiles != null && imageFiles.isNotEmpty) {
            List<Base64Image> images =
                await databaseHelper.getBase64Image(key, requestId);
            if (images.isNotEmpty) {
              int noOfRowsDeleted =
                  await databaseHelper.delBase64Image(key, requestId);
              print("Rows Deleted: $noOfRowsDeleted");
              for (File imageFile in imageFiles) {
                String? base64String = await convertToBase64New(imageFile);
                int rowId = await databaseHelper.insertBase64Image(
                    Base64Image(key, base64String!, requestId));
                print("Row ID: $rowId");
              }
            } else {
              for (File imageFile in imageFiles) {
                String? base64String = await convertToBase64New(imageFile);
                int rowId = await databaseHelper.insertBase64Image(
                    Base64Image(key, base64String!, requestId));
                print("Row ID: $rowId");
              }
            }
          }
        }
      }
    } catch (e) {
      print("Exception in insertBase64ImageIntoDB(): $e");
    }
  }

  // Future<void> getBase64ImagesFromDB() async {
  //   try {
  //     DatabaseHelper databaseHelper = DatabaseHelper();
  //     List<Base64Image> b64Images =
  //         await databaseHelper.getBase64Images(requestId);
  //     List<String> singleImageKey = [];
  //     List<String> multiImageKey = [];
  //     if (b64Images.isNotEmpty) {
  //       for (Base64Image b64Image in b64Images) {
  //         int keyFound = 0;
  //         String key = b64Image.fieldClassID;
  //         for (Base64Image img in b64Images) {
  //           if (key == img.fieldClassID) {
  //             keyFound++;
  //           }
  //         }
  //         if (keyFound > 1) {
  //           if (!multiImageKey.contains(key)) {
  //             multiImageKey.add(key);
  //           }
  //         } else {
  //           singleImageKey.add(key);
  //         }
  //       }
  //       for (String key in multiImageKey) {
  //         List<File> imageFiles = [];
  //         for (Base64Image img2 in b64Images) {
  //           if (key == img2.fieldClassID) {
  //             imageFiles
  //                 .add(await decodeBase64AndSaveImageNew(img2.base64String));
  //           }
  //         }
  //         multiImageSelector[key] = imageFiles;
  //       }
  //       for (String key in singleImageKey) {
  //         for (Base64Image img3 in b64Images) {
  //           if (key == img3.fieldClassID) {
  //             imageSelector[key] =
  //                 await decodeBase64AndSaveImage(img3.base64String);
  //           }
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print("Exception in getBase64ImagesFromDB(): $e");
  //   }
  // }

  Future<void> updateLoanRequestInfoInDB() async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      String? loanRequestStatus = await getLoanRequestStatus(requestId);
      if (loanRequestStatus != null) {
        if (loanRequestStatus != 'complete') {
          print(
              'Loan request status is incomplete, So updating the loan request information in DB!');
          if (forwardVisible) {
            int rowsUpdated = await databaseHelper.updateLoanRequestInformation(
                LoanRequestInformation(requestId, stepNo, "incomplete"),
                requestId);
            print(
                "DEBUG CHECK=> forwardVisible: $forwardVisible, rowsUpdated: $rowsUpdated");
          } else {
            int rowsUpdated = await databaseHelper.updateLoanRequestInformation(
                LoanRequestInformation(requestId, stepNo, "complete"),
                requestId);
            print(
                "DEBUG CHECK=> forwardVisible: $forwardVisible, rowsUpdated: $rowsUpdated");
          }
        } else {
          print(
              'Loan request status is complete, So no information in updated in DB!');
        }
      } else {
        print('Loan request status is not found!');
      }
    } catch (e) {
      print("Exception in updateLoanRequestInfoInDB(): $e");
    }
  }

  Future<String?> getLoanRequestStatus(int rId) async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      List<LoanRequestInformation> requests =
          await databaseHelper.getLoanRequestInformation(rId);
      if (requests.isNotEmpty) {
        return requests[0].status;
      } else {
        return null;
      }
    } catch (e) {
      print('Exception in getLoanRequestStatus(): $e');
      return null;
    }
  }

  Future<String?> convertToBase64(XFile xFile) async {
    try {
      // Read the file as bytes
      List<int> fileBytes = await xFile.readAsBytes();

      // Encode the bytes to base64
      String base64String = base64Encode(fileBytes);

      return base64String;
    } catch (e) {
      print("Exception in convertToBase64(): $e");
      return null;
    }
  }

  Future<String?> convertToBase64New(File file) async {
    try {
      // Read the file as bytes
      List<int> fileBytes = await file.readAsBytes();

      // Encode the bytes to base64
      String base64String = base64Encode(fileBytes);

      return base64String;
    } catch (e) {
      print("Exception in convertToBase64(): $e");
      return null;
    }
  }

  Future<XFile> decodeBase64AndSaveImage(String base64String) async {
    Uint8List bytes = base64.decode(base64String);

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    File imageFile =
        File('$tempPath/image_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await imageFile.writeAsBytes(bytes);

    //return imageFile;
    return XFile(imageFile.path);
  }

  Future<File> decodeBase64AndSaveImageNew(String base64String) async {
    Uint8List bytes = base64.decode(base64String);

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    File imageFile =
        File('$tempPath/image_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await imageFile.writeAsBytes(bytes);

    return imageFile;
  }

  Future<void> getNewRequestId() async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      int rowId = await databaseHelper.insertLoanRequestInformation(
          LoanRequestInformation(0, 0, "incomplete"));
      List<LoanRequestInformation> requests =
          await databaseHelper.getAllLoanRequestInformation();
      requestId = requests[requests.length - 1].requestId;
      newRequestIdReceived = true;
      print("New Request ID: $requestId");
    } catch (e) {
      print("Exception in getNewRequestId(): $e");
    }
  }

  Future<void> getPMDVerification(String mobile, String cnic) async {
    try {
      final headers = await getGenericHeaders();
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: false);
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
              color: Colors.black,
              fontSize: 19.0,
              fontWeight: FontWeight.w600));
      // await pr.show();

      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/TPI/getPMDVerified?mobileNumber=$mobile&cnic=$cnic");
      var response = await client.get(uri, headers: headers);
      print("Response getPMDVerification(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonMap = jsonDecode(response.body.toString());
        String message = jsonMap['message'];
        String responseCode = jsonMap['responseCode'];
        String status = jsonMap['status'];
        if (message == "PMD Successfully performed") {
          isPDMVerify = true;
          formValues['PMD'] = isPDMVerify.toString();
        }
      }
      setState(() {});
      await pr.hide();
    } catch (e) {
      print("Exception in getETBCustomerData(): $e");
    }
  }

  Future<void> sendFingerPrintVerification(String fingerIndex, String r1,
      String r2, String r3, String r4, String r5) async {
    // Define the API URL
    var url = Uri.parse("${getApiBaseUrl()}/TPI/FingerPrintVerification");

    // Create the request body
    Map<String, dynamic> body = {
      "strAppID": "your_app_id",
      "strADC_TranCode": "your_transaction_code",
      "strDelimiter": "|",
      "strDate": "2024-09-08",
      "strTime": "12:00:00",
      "strNetID": "your_net_id",
      "intRefNum": "your_reference_number",
      "intSTAN": "your_stan_number",
      "strTranMsg": "your_transaction_message",
      "strMerName": "your_merchant_name",
      "strMCC": "your_mcc_code",
      "strToken": "your_token",
      "citizenNumber": "your_citizen_number",
      "contactNumber": "your_contact_number",
      "fingerIndex": fingerIndex,
      "fingerTemplate": "your_finger_template",
      "templateType": "your_template_type",
      "areaName": "your_area_name",
      "reasonCode": "your_reason_code",
      "r1": r1,
      "r2": r2,
      "r3": r3,
      "r4": r4,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("Success: ${response.body}");
        formValues['biometric_fingure'] = 'true';
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Exception caught: $e");
    }
  }

  String? PgetSelfieImage(dynamic data) {
    try {
      String strData = data['data'];
      Map<String, dynamic> jsonData =
          jsonDecode(strData) as Map<String, dynamic>;
      Map<String, dynamic> iData = jsonData['templates'];
      String selfieImage = iData['PNG'];
      print('Selfie Data: $selfieImage');
      return selfieImage;
    } catch (e) {
      print('Exception in getSelfieImage(): $e');
      return null;
    }
  }
//new logic statrts

  Future<bool?> fingerBiometric(BuildContext context) async {
    final platform = MethodChannel(identyChannel);

    // Make sure the camera permission is granted if needed
    if (!await Permission.camera.status.isGranted) {
      await Permission.camera.request();
    }
    try {
      // 1) Capture fingerprints from the device
      final result = await platform.invokeMethod('finger_capture');
      final Map<String, dynamic> fingerMap = jsonDecode(result);
      if (fingerMap.isEmpty) {
        // ReusableDialogs.showErrorDialog(context,
        //     message: 'Biometric Services Currently not Available');
        return false;
      }
      final fingerCaptureResponse = FingerCaptureResponse.fromJson(fingerMap);

      print("DEBUG: Captured finger data => $fingerMap");

      // 2) Retrieve CNIC & Mobile from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      // final cnic = prefs.getString('cnic') ?? "";
      // final mobile = prefs.getString('sign_in_number') ?? "";
      final secureStorage = FlutterSecureStorage();
      String? cnic = await UserSecretStore.getCnic();
      final mobile = await UserSecretStore.getSignNumber();
      // 3) Check if Right Thumb data is present
      final rightThumbData = fingerCaptureResponse.data?["rightthumb"];
      if (rightThumbData == null) {
        // ReusableDialogs.showErrorDialog(
        //   context,
        //   title: "No Right Thumb",
        //   message: "No 'rightthumb' data found in the captured response.",
        // );
        return false;
      }

      // 4) Encode the Right Thumb template
      final rightThumbTemplate = encodeFingerTemplate(
        rightThumbData.templates?.iso197942?.defaultValue,
      );
      if (rightThumbTemplate == null) {
        ReusableDialogs.showErrorDialog(
          context,
          title: "Right Thumb Error",
          message: "Unable to encode 'rightthumb' template.",
        );
        return false;
      }

      // 5) Show a "Verifying from NADRA" dialog
      // showDialog(
      //   context: context,
      //   barrierDismissible: false,
      //   builder: (_) {
      //     return const AlertDialog(
      //       title: Text("Please Wait"),
      //       content: Column(
      //         mainAxisSize: MainAxisSize.min,
      //         children: [
      //           CircularProgressIndicator(),
      //           SizedBox(height: 16),
      //           Text("Verifying Right Thumb with NADRA..."),
      //         ],
      //       ),
      //     );
      //   },
      // );

      // 6) Send Right Thumb to NADRA (fingerIndex=1)
      final defaultResponse = await sendNadraVerification(
        cnic: cnic!,
        mobile: mobile!,
        fingerIndex: "1", // 1 => Right Thumb in your NADRA logic
        fingerTemplate: rightThumbTemplate,
        fingerNameForLog: "rightthumb",
      );

      // Dismiss the "Please Wait" dialog
      // Navigator.of(context).pop();

      // 7) Parse the response from NADRA
      final defaultJson = jsonDecode(defaultResponse);
      print("Right Thumb Verification => $defaultJson");

      if (defaultJson["code"] == "100") {
        formValues['biomatric_status'] = defaultJson["code"];
        // 7a) If code=100, success => no need to check other fingers
        // ReusableDialogs.showSuccessDialog(context,
        //     title: "Right Thumb Verified!");
        return true;
      } else {
        // 7b) If code != 100 => we only then check other fingers

        // Extract finger indexes from the response
        final fingerIndexMap = defaultJson["finger_Index"];
        if (fingerIndexMap == null || fingerIndexMap is! Map<String, dynamic>) {
          // If no extra finger indexes provided => final failure
          // ReusableDialogs.showErrorDialog(
          //   context,
          //   title: "Verification Failed",
          //   message:
          //       "${formValues["full_name"] ?? ""},\n We are currently processing your request. Unfortunately, your biometric verification was unsuccessful. A sales representative will reach out to you shortly to complete the verification process. For further assistance, feel free to contact us at 021-111-060606.",
          // );
          return false;
        }

        // We'll track if any subsequent finger passes
        bool anyFingerSuccess = false;

        // 8) Loop over the returned indexes from NADRA
        for (final entry in fingerIndexMap.entries) {
          final key = entry.key; // e.g. "fingerIndex2", "fingerIndex3"
          final value = entry.value; // e.g. "2", "3", or null

          if (value == null || value.toString().isEmpty) {
            // Skip empty indexes
            continue;
          }

          final nadraIndex = value.toString(); // e.g. "2"
          // Map NADRA’s "2" => local finger key (e.g. "rightindex")
          final localFingerKey = nadraToLocalFingerMapping[nadraIndex];
          if (localFingerKey == null) {
            print("No local mapping for NADRA index=$nadraIndex");
            continue;
          }

          final nextFingerData = fingerCaptureResponse.data?[localFingerKey];
          if (nextFingerData == null) {
            print("No local data for finger=$localFingerKey");
            continue;
          }

          // Encode the template
          final nextTemplate = encodeFingerTemplate(
            nextFingerData.templates?.iso197942?.defaultValue,
          );
          if (nextTemplate == null) {
            print("No template found for $localFingerKey");
            continue;
          }

          // (Optional) Show a new "Verifying from NADRA" dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const AlertDialog(
              title: Text("Please Wait"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Verifying Other Finger..."),
                ],
              ),
            ),
          );

          // Send NADRA request for this finger
          final nextResponse = await sendNadraVerification(
            cnic: cnic,
            mobile: mobile,
            fingerIndex: nadraIndex,
            fingerTemplate: nextTemplate,
            fingerNameForLog: localFingerKey,
          );

          Navigator.of(context).pop();

          final nextJson = jsonDecode(nextResponse);
          if (nextJson["code"] == "100") {
            // Found a successful finger
            formValues['biomatric_status'] = defaultJson["code"];
            anyFingerSuccess = true;
            ReusableDialogs.showSuccessDialog(
              context,
              title: "Verified",
              message: "Finger Index $nadraIndex ($localFingerKey) verified!",
            );

            // Stop checking others once one is successful
            break;
          } else {
            print("Finger $localFingerKey => code=${nextJson["code"]}");
          }
        }

        // 9) If we never had a success, show an overall failure dialog
        if (!anyFingerSuccess) {
          formValues['biomatric_status'] = defaultJson["code"];
          ReusableDialogs.showErrorDialogSendProposal(
            context,
            title: "Verification Failed",
            message:
                "Dear ${formValues["full_name"] ?? ""},\n We are currently processing your request. Unfortunately, your biometric verification was unsuccessful. A sales representative will reach out to you shortly to complete the verification process.\n For further assistance, feel free to contact us at 021-111-060606.",
          );
        }
      }
    } on PlatformException catch (e) {
      print("PlatformException => ${e.message}");
      ReusableDialogs.showErrorDialog(
        context,
        title: "Biome",
        message: e.message!,
      );
      return false;
    } catch (e) {
      print("General Error => $e");
      ReusableDialogs.showErrorDialog(
        context,
        title: "Service not available",
        message: e.toString(),
      );
    }
    return false;
  }

  /// Sample helper to encode the fingerprint template
  String? encodeFingerTemplate(dynamic input) {
    if (input == null) return null;

    if (input is String) {
      return base64Encode(utf8.encode(input));
    }
    if (input is Map<String, dynamic>) {
      final rawString = input['rawTemplate'];
      if (rawString is String) {
        return base64Encode(utf8.encode(rawString));
      }
    }
    return null;
  }

  /// Sample mapping from NADRA’s numeric index ("2", "3", etc.) to your local finger keys.
  final Map<String, String> nadraToLocalFingerMapping = {
    "1": "rightthumb",
    "2": "rightindex",
    "3": "rightmiddle",
    "4": "leftthumb",
    "5": "leftindex",
    "6": "leftmiddle",
    // etc...
  };

  /// Sends the verification request to NADRA
  Future<String> sendNadraVerification({
    required String cnic,
    required String mobile,
    required String fingerIndex,
    required String? fingerTemplate,
    required String? fingerNameForLog,
  }) async {
    final requestModel = FingerPrintVerificationRequest(
      strAppID: "",
      strADC_TranCode: fingerNameForLog ?? "",
      strDelimiter: "",
      strDate: "",
      strTime: "",
      strNetID: "",
      intRefNum: "",
      intSTAN: "",
      strTranMsg: "",
      strMerName: "",
      strMCC: "",
      strToken: "",
      citizenNumber: cnic,
      contactNumber: mobile,
      fingerIndex: fingerIndex,
      fingerTemplate: fingerTemplate,
      templateType: "ISO_19794_2",
      areaName: "Punjab",
      reasonCode: "",
      r1: "",
      r2: "",
      r3: "",
      r4: "",
    );

    final rawResponse = await sendVerificationRequest(requestModel);
    print(
      "[sendNadraVerification] fingerIndex=$fingerIndex "
      "(local=$fingerNameForLog) => $rawResponse",
    );
    return rawResponse;
  }

// ended

  // Future<void> fingerBiometric(BuildContext fingerContext) async {
  //   // Creates an instance of platform channel with Identy Channel name
  //   final platform = MethodChannel(identyChannel);
  //   if (!await Permission.camera.status.isGranted) {
  //     await Permission.camera.request();
  //   }

  //   dynamic response;

  //   try {
  //     final result = await platform.invokeMethod('finger_capture');
  //     final Map<String, dynamic> fingerMap = jsonDecode(result);
  //     response = "success ${result}";
  //    setState(() {
  //         // e.g. _fingerVerificationResult = finalResponse;
  //       });
  //     print("DEBUG: OBTAINED RESPONSE for finger prints: $response");
  //     final map = jsonDecode(result) as Map<String, dynamic>;

  //     final fingerCaptureResponse = await FingerCaptureResponse.fromJson(map);

  //     final finalResponse =
  //         await verifyFingersOneByOne(fingerCaptureResponse, fingerContext);

  //     // Navigator.pop(context);

  //     // final parsedResponse = parseStringResponseToModel(finalResponse!);
  //     // if (parsedResponse.code == 122) {
  //     //   ReusableDialogs.showSuccessDialog(context, title: 'Varified');
  //     // } else {
  //     //   ReusableDialogs.showErrorDialog(context, title: 'Failed');
  //     // }

  //     // formValues['biomatric_status'] = parsedResponse.code;

  //     print('===== Final Response =====');
  //     print(finalResponse);

  //     // sendFingerPrintVerification(
  //     //     "1", "finger_1", "finger_2", "finger_3", "finger_4", "finger_5");
  //   } on PlatformException catch (e) {
  //     response = e.message ?? 'error sin mensaje';
  //   }

  //   // showDialog(
  //   //   context: context,
  //   //   builder: (context) {
  //   //     var okButton = TextButton(
  //   //       child: const Text('OK'),
  //   //       onPressed: () {
  //   //         Navigator.of(context).pop();
  //   //       },
  //   //     );

  //   //     print(
  //   //         "DEBUG:  response.toString().length ${response.toString().length}");
  //   //     final message = response.toString().length > 200
  //   //         ? response.substring(0, 200)
  //   //         : response;

  //   //     return AlertDialog(title: Text(message), actions: [okButton]);
  //   //   },
  //   // );
  // }

  Future<bool> callFace(BuildContext context) async {
    // Creates an instance of platform channel with Identy Channel name
    final platform = MethodChannel(identyChannel);
    if (!await Permission.camera.status.isGranted) {
      await Permission.camera.request();
    }

    dynamic response;

    try {
      final result = await platform.invokeMethod('face_capture');
      // response = "success ${result}";
      // handleResponse(response);
      if (result.toString().isNotEmpty) {
        print(result.toString());
        // next();
        return true;
      } else {
        print(result.toString());
        return false;
      }

      // print("DEBUG: OBTAINED RESPONSE $response");
      // String? sImage = getSelfieImage(result);
      // formValues['selfie_spoof_score'] = getspoofScore(result);
      // if (sImage != null) {
      //   // formValues['selfie_assessment'] = sImage;
      // }
    } on PlatformException catch (e) {
      /**** Uncomment followimg line to check errors ****/
      ReusableDialogs.showErrorDialog(
        context,
        title: "Service not Avaiable",
        message: 'Selfie Liveliness is not available right now',
      );
      // print("DEBUG Error in flutter $e");
      response = e.message ?? 'error sin mensaje';
      return false;
    }

    // ignore: use_build_context_synchronously
    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     var okButton = TextButton(
    //       child: const Text('OK'),
    //       onPressed: () {
    //         Navigator.of(context).pop();
    //       },
    //     );

    //     return AlertDialog(title: Text(response), actions: [okButton]);
    //   },
    // );
  }

  int? getspoofScore(dynamic data) {
    try {
      String strData = data['data'];
      // String Spoof_score = data['spoof_score']
      Map<String, dynamic> jsonData =
          jsonDecode(strData) as Map<String, dynamic>;
      // Map<String, dynamic> iData = jsonData['templates'];
      int Spoof_score = jsonData['spoof_score'] * 100;
      print('Spoof Score: ${Spoof_score}');
      // String selfieImage = iData['PNG'];
      // print('Selfie Data: $selfieImage');
      return Spoof_score;
    } catch (e) {
      print('Exception in getspoofScore: $e');
      return null;
    }
  }

  String? getSelfieImage(dynamic data) {
    try {
      String strData = data['data'];
      // String Spoof_score = data['spoof_score']
      Map<String, dynamic> jsonData =
          jsonDecode(strData) as Map<String, dynamic>;
      Map<String, dynamic> iData = jsonData['templates'];
      int Spoof_score = jsonData['spoof_score'];
      print('Spoof Score: ${Spoof_score}');
      String selfieImage = iData['PNG'];
      print('Selfie Data: $selfieImage');
      return selfieImage;
    } catch (e) {
      print('Exception in getSelfieImage(): $e');
      return null;
    }
  }

  @override
  void dispose() {
    signatureController!.dispose();
    _scrollController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> getCountryList() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri =
          Uri.parse("${getApiBaseUrl()}/LOS/getParametersData?code=Country");
      print("Complete API URL: ${uri.toString()}");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getCountryList(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> countriesList =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = countriesList['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          //countries.add(ParametersData(item['id'] ?? "", item['label'] ?? "", item['labelValue'] ?? "", item['value'] ?? "0", item['attribute'] ?? "", item['dataType'] ?? "", item['group'] ?? ""));
          countries.add(ParametersData(
              item['id'] ?? "",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Countries Fetch: ${countries.length}");
        for (ParametersData country in countries) {
          print("Country: ${country.label}");
        }
        setState(() {
          fetchingCountries = false;
        });
      }
    } catch (e) {
      print("Exception in getCountryList(): $e");
    }
  }

  Future<void> getNationalityTypes() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/LOS/getParametersData?code=Nationality");
      print(
          "Complete API URL: ${getApiBaseUrl()}/LOS/getParametersData?code=Nationality");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getNationalityTypes(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> nTypes =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = nTypes['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          //nationalityType.add(ParametersData(item['id'] ?? "", item['label'] ?? "", item['labelValue'] ?? "", item['value'] ?? "0", item['attribute'] ?? "", item['dataType'] ?? "", item['group'] ?? ""));
          nationalityType.add(ParametersData(
              item['id'] ?? "",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Nationality Types: ${nationalityType.length}");
        for (ParametersData type in nationalityType) {
          print("Nationality Type: ${type.label}");
        }
        setState(() {
          fetchingNationalityType = false;
        });
      }
    } catch (e) {
      print("Exception in getNationalityTypes(): $e");
    }
  }

  Future<void> getEmploymentTypes() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/LOS/getParameterMappingData?mappingCode=BRCategory_BRSubCatType&paramCode=INDV");
      print(
          "Complete API URL: ${getApiBaseUrl()}/LOS/getParameterMappingData?mappingCode=BRCategory_BRSubCatType&paramCode=INDV");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getEmploymentTypes(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> nTypes =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = nTypes['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          //employmentTypes.add(ParametersData(item['id'] ?? "", item['label'] ?? "", item['labelValue'] ?? "", item['value'] ?? "", item['attribute'] ?? "", item['dataType'] ?? "", item['group'] ?? ""));
          employmentTypes.add(ParametersData(
              item['id'] ?? "",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Employment Types: ${employmentTypes.length}");
        for (ParametersData type in employmentTypes) {
          print("Employment Type: ${type.label}");
        }
        setState(() {
          fetchingEmploymentType = false;
        });
      }
    } catch (e) {
      print("Exception in getEmploymentTypes(): $e");
    }
  }

  Future<void> getEmploymentStatus() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/LOS/getStaticParametersData?classCode=SubProposalProfessionDetail&attribute=empStatus");
      print(
          "Complete API URL: ${getApiBaseUrl()}/LOS/getStaticParametersData?classCode=SubProposalProfessionDetail&attribute=empStatus");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getEmploymentStatus(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> nTypes =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = nTypes['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          //employmentStatus.add(ParametersData(item['id'] ?? "", item['label'] ?? "", item['labelValue'] ?? "", item['value'] ?? "", item['attribute'] ?? "", item['dataType'] ?? "", item['group'] ?? ""));
          employmentStatus.add(ParametersData(
              item['id'] ?? "",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Employment Status: ${employmentStatus.length}");
        for (ParametersData type in employmentStatus) {
          print("Employment Status: ${type.label}");
        }
        setState(() {
          fetchingEmploymentStatus = false;
        });
      }
    } catch (e) {
      print("Exception in getEmploymentStatus(): $e");
    }
  }

  Future<void> getTypesOfCompany() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/LOS/getParametersData?code=EmployeerNature");
      print(
          "Complete API URL: ${getApiBaseUrl()}/LOS/getParametersData?code=EmployeerNature");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getTypesOfCompany(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> nTypes =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = nTypes['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          //typesOfCompany.add(ParametersData(item['id'] ?? "", item['label'] ?? "", item['labelValue'] ?? "", item['value'] ?? "", item['attribute'] ?? "", item['dataType'] ?? "", item['group'] ?? ""));
          typesOfCompany.add(ParametersData(
              item['id'] ?? "",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Types of Company: ${typesOfCompany.length}");
        for (ParametersData type in typesOfCompany) {
          print("Type of Company: ${type.label}");
        }
        setState(() {
          fetchingTypeOfCompany = false;
        });
      }
    } catch (e) {
      print("Exception in getTypesOfCompany(): $e");
    }
  }

  Future<void> getTypesOfBusiness() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/LOS/getParametersData?code=BusinessType");
      print(
          "Complete API URL: ${getApiBaseUrl()}/LOS/getParametersData?code=BusinessType");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getTypesOfBusiness(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> nTypes =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = nTypes['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          //typesOfBusiness.add(ParametersData(item['id'] ?? "", item['label'] ?? "", item['labelValue'] ?? "", item['value'] ?? "", item['attribute'] ?? "", item['dataType'] ?? "", item['group'] ?? ""));
          typesOfBusiness.add(ParametersData(
              item['id'] ?? "",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Types of Business: ${typesOfBusiness.length}");
        for (ParametersData type in typesOfBusiness) {
          print("Type of Business: ${type.label}");
        }
        setState(() {
          fetchingTypeOfBusiness = false;
        });
      }
    } catch (e) {
      print("Exception in getTypesOfBusiness(): $e");
    }
  }

  Future<void> getProfessionTypes() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/LOS/getParametersData?code=BusinessNature");
      print(
          "Complete API URL: ${getApiBaseUrl()}/LOS/getParametersData?code=BusinessNature");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getProfessionTypes(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> nTypes =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = nTypes['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          //professionTypes.add(ParametersData(item['id'] ?? "", item['label'] ?? "", item['labelValue'] ?? "", item['value'] ?? "", item['attribute'] ?? "", item['dataType'] ?? "", item['group'] ?? ""));
          professionTypes.add(ParametersData(
              item['id'] ?? "",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Profession Types: ${professionTypes.length}");
        for (ParametersData type in professionTypes) {
          print("Profession Type: ${type.label}");
        }
        setState(() {
          fetchingProfessionType = false;
        });
      }
    } catch (e) {
      print("Exception in getProfessionTypes(): $e");
    }
  }

  Future<void> getProductTypes() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse("${getApiBaseUrl()}/LOS/getLimitTypeData");
      print("Complete API URL: ${getApiBaseUrl()}/LOS/getLimitTypeData");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getProductTypes(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> nTypes =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = nTypes['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          //productTypes.add(ParametersData(item['id'] ?? "", item['label'] ?? "", item['labelValue'] ?? "", item['value'] ?? "0", item['attribute'] ?? "", item['dataType'] ?? "", item['group'] ?? ""));
          productTypes.add(ParametersData(
              item['.'] ?? "",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Product Types: ${productTypes.length}");
        for (ParametersData type in productTypes) {
          print("Product Type: ${type.label}");
        }

        /// New modification according to the requirement.
        /// Customer Product Types are fetched by default by using Product Id: 13106 (Credit Card).
        await getCustomerProductTypes(globalProductValue.toString());
        print('custttoooo:${globalProductValue.toString()}');
        pickerAttributes['customer_product_type'] = 'CC';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (formValues['product_type'] == null &&
              pickerStates['product_type'] == null) {
            formValues['product_type'] = productTypes[1].label;
            formValues['customer_product_type'] = customerProductTypes[0].label;
            pickerStates['product_type'] = 0;
            pickerStates['customer_product_type'] = 0;
          }
        });

        setState(() {
          fetchingProductType = false;
        });
      }
    } catch (e) {
      print("Exception in getProductTypes(): $e");
    }
  }

  // Future<void> getCardTypes() async {
  //   try {
  //     var client = http.Client();
  //     var uri =
  //         Uri.parse("${getApiBaseUrl()}/LOS/getProductsData?limitTypeId=0");
  //     print(
  //         "Complete API URL: ${getApiBaseUrl()}/LOS/getProductsData?limitTypeId=0");
  //     var response = await client.get(uri);
  //     print("Response received in getCardTypes(): ${response.body.toString()}");
  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> nTypes =
  //           jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  //       List<dynamic> dataList = nTypes['data'];
  //       print("Length of Data List: ${dataList.length}");
  //       print("Data List: ${dataList.toString()}");
  //       for (var item in dataList) {
  //         //cardType.add(ParametersData(item['id'] ?? "", item['label'] ?? "", item['labelValue'] ?? "", item['value'] ?? "", item['attribute'] ?? "", item['dataType'] ?? "", item['group'] ?? ""));
  //         cardType.add(ParametersData(
  //             item['id'] ?? "",
  //             item['label'] ?? "",
  //             item['labelValue'] ?? "",
  //             "${item['value']}" ?? "0",
  //             item['attribute'] ?? "",
  //             item['dataType'] ?? "",
  //             item['group'] ?? ""));
  //       }
  //       print("Total Card Types: ${cardType.length}");
  //       for (ParametersData type in cardType) {
  //         print("Card Type: ${type.label}");
  //       }
  //       setState(() {
  //         fetchingCardType = false;
  //       });
  //     }
  //   } catch (e) {
  //     print("Exception in getCardTypes(): $e");
  //   }
  // }

  Future<void> getCnicTypes() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse("${getApiBaseUrl()}/LOS/getCnicTypes");
      print("Complete API URL: ${getApiBaseUrl()}/LOS/getCnicTypes");
      var response = await client.get(uri, headers: headers);
      print("Response received in getCnicTypes(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> nTypes =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = nTypes['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          //cnicTypes.add(ParametersData(item['id'] ?? "", item['label'] ?? "", item['labelValue'] ?? "", item['value'] ?? "", item['attribute'] ?? "", item['dataType'] ?? "", item['group'] ?? ""));
          cnicTypes.add(ParametersData(
              item['id'] ?? "",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Cnic Types: ${cnicTypes.length}");
        for (ParametersData type in cnicTypes) {
          print("Cnic Type: ${type.label}");
        }
        setState(() {
          fetchingCnicTypes = false;
        });
      }
    } catch (e) {
      print("Exception in getCnicTypes(): $e");
    }
  }

//not in used
  Future<void> getOtherFacilities() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse("${getApiBaseUrl()}/LOS/getOTCRData");
      print("Complete API URL: ${getApiBaseUrl()}/LOS/getOTCRData");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getOtherFacilities(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> nTypes =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = nTypes['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          //otherFacilities.add(ParametersData(item['id'] ?? "", item['label'] ?? "", item['labelValue'] ?? "", item['value'] ?? "0", item['attribute'] ?? "", item['dataType'] ?? "", item['group'] ?? ""));
          otherFacilities.add(ParametersData(
              item['id'] ?? "",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Other Facilities: ${otherFacilities.length}");
        for (ParametersData type in otherFacilities) {
          print("Other Facility: ${type.label}");
        }
        setState(() {
          fetchingOtherFacilities = false;
        });
      }
    } catch (e) {
      print("Exception in getOtherFacilities(): $e");
    }
  }

  // Future<void> getAssetData() async {
  //   try {
  //     var client = http.Client();
  //     var uri = Uri.parse(
  //         "${getApiBaseUrl()}/LOS/getAssetHierarchy?assetCategoryId=38420");
  //     print("Complete API URL: ${uri.toString()}");
  //     var response = await client.get(uri);
  //     print("Response received in getAssetData(): ${response.body.toString()}");
  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> nTypes =
  //           jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  //       Map<String, dynamic> data = nTypes['data'];
  //       //print("Data: ${data.toString()}");
  //       List<dynamic> assetData = data['DATA'];
  //       print("Size of Asset Data: ${assetData.length}");
  //       for (var item in assetData) {
  //         manufacturerBrInfoList.add(ParametersData(
  //             item['id'] ?? "",
  //             item['label'] ?? "",
  //             item['labelValue'] ?? "",
  //             item['value'] ?? "",
  //             item['attribute'] ?? "",
  //             item['dataType'] ?? "",
  //             item['group'] ?? ""));
  //       }
  //       for (ParametersData type in manufacturerBrInfoList) {
  //         print("Asset Data: ${type.label}");
  //       }
  //       setState(() {
  //         fetchingAssetData = false;
  //       });
  //     } else {
  //       print("Status Code in getAssetData(): ${response.statusCode}");
  //       setState(() {
  //         fetchingAssetData = false;
  //       });
  //     }
  //   } catch (e) {
  //     print("Exception in getAssetData(): $e");
  //   }
  // }

  // Future<void> getTenor() async {
  //   try {
  //     var client = http.Client();
  //     var uri = Uri.parse(
  //         "${getApiBaseUrl()}/LOS/getTenor?limitTypeId=12299&productCodeId=39662");
  //     print("Complete API URL: ${uri.toString()}");
  //     var response = await client.get(uri);
  //     print("Response received in getTenor(): ${response.body.toString()}");
  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> nTypes =
  //           jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  //       Map<String, dynamic> data = nTypes['data'];
  //       print("Data: ${data.toString()}");
  //       List<dynamic> tenorList = data['tenorList'];
  //       print("Size of tenorList: ${tenorList.length}");
  //       for (var item in tenorList) {
  //         tenor.add(ParametersData(
  //             "${item['id']}" ?? "0",
  //             item['label'] ?? "",
  //             item['labelValue'] ?? "",
  //             "${item['value']}" ?? "0",
  //             item['attribute'] ?? "",
  //             item['dataType'] ?? "",
  //             item['group'] ?? ""));
  //       }
  //       for (ParametersData type in tenor) {
  //         print("Tenor: ${type.label}");
  //       }
  //       setState(() {
  //         fetchingTenor = false;
  //       });
  //     } else {
  //       print("Status Code in getTenor(): ${response.statusCode}");
  //       setState(() {
  //         fetchingTenor = false;
  //       });
  //     }
  //   } catch (e) {
  //     print("Exception in getTenor(): $e");
  //   }
  // }
//not in used
  Future<void> getInstallmentFrequency() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/LOS/getInstallmentFrequency?tenorTypeId=36");
      print("Complete API URL: ${uri.toString()}");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getInstallmentFrequency(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> nTypes =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = nTypes['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          installmentFrequency.add(ParametersData(
              "${item['id']}" ?? "0",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Installments: ${installmentFrequency.length}");
        for (ParametersData type in installmentFrequency) {
          print("Installment: ${type.label}");
        }
        setState(() {
          fetchingInstallmentFrequency = false;
        });
      }
    } catch (e) {
      print("Exception in getInstallmentFrequency(): $e");
    }
  }

//not in used
  Future<void> getVehicleTypes() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/LOS/getParametersData?code=VehicleType");
      print("Complete API URL: ${uri.toString()}");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getVehicleTypes(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> nTypes =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = nTypes['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          vehicleTypes.add(ParametersData(
              "${item['id']}" ?? "0",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Vehicle Types: ${vehicleTypes.length}");
        for (ParametersData type in vehicleTypes) {
          print("Vehicle Type: ${type.label}");
        }
        setState(() {
          fetchingVehicleType = false;
        });
      }
    } catch (e) {
      print("Exception in getVehicleTypes(): $e");
    }
  }

//not in used
  Future<void> getFacilityTypes() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/LOS/getStaticParametersData?classCode=AssetMain&attribute=bookDelFlag");
      print("Complete API URL: ${uri.toString()}");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getFacilityTypes(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> nTypes =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = nTypes['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          facilityTypes.add(ParametersData(
              "${item['id']}" ?? "0",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Facility Types: ${vehicleTypes.length}");
        for (ParametersData type in facilityTypes) {
          print("Facility Type: ${type.label}");
        }
        setState(() {
          fetchingFacilityTypes = false;
        });
      }
    } catch (e) {
      print("Exception in getFacilityTypes(): $e");
    }
  }

//not in used
  Future<void> getEmiType() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/LOS/getStaticParametersData?classCode=LimitTypeDefinition&attribute=repaymentType");
      print("Complete API URL: ${uri.toString()}");
      var response = await client.get(uri, headers: headers);
      print("Response received in getEmiType(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> nTypes =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = nTypes['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          emiTypes.add(ParametersData(
              "${item['id']}" ?? "0",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total EMI Types: ${emiTypes.length}");
        for (ParametersData type in emiTypes) {
          print("EMI Type: ${type.label}");
        }
        setState(() {
          fetchingEmiTypes = false;
        });
      }
    } catch (e) {
      print("Exception in getEmiType(): $e");
    }
  }

//not in used
  Future<void> getInstallmentDueDates() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/LOS/getParametersData?code=BillingCycle");
      print("Complete API URL: ${uri.toString()}");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getInstallmentDueDates(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> nTypes =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = nTypes['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          installmentDueDates.add(ParametersData(
              "${item['id']}" ?? "0",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Installment Due Dates: ${installmentDueDates.length}");
        for (ParametersData type in installmentDueDates) {
          print("Installment Due Date: ${type.label}");
        }
        setState(() {
          fetchingInstallmentDueDates = false;
        });
      }
    } catch (e) {
      print("Exception in getInstallmentDueDates(): $e");
    }
  }

//not in used
  Future<void> getTakafulCompanies() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse("${getApiBaseUrl()}/LOS/getTakafulCompanies");
      print("Complete API URL: ${uri.toString()}");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getTakafulCompanies(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> nTypes =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = nTypes['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          takafulCompanies.add(ParametersData(
              "${item['id']}" ?? "0",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Takaful Compamies: ${takafulCompanies.length}");
        for (ParametersData type in takafulCompanies) {
          print("Takaful Company: ${type.label}");
        }
        setState(() {
          fetchingTakafulCompanies = false;
        });
      }
    } catch (e) {
      print("Exception in getTakafulCompanies(): $e");
    }
  }

  Future<void> getGenderTypes() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/LOS/getStaticParametersData?classCode=BRIndividualDetail&attribute=gender");
      print("Complete API URL: ${uri.toString()}");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getGenderTypes(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> nTypes =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = nTypes['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          genderTypes.add(ParametersData(
              "${item['id']}" ?? "0",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Gender Types: ${genderTypes.length}");
        for (ParametersData type in genderTypes) {
          print("Gender Type: ${type.label}");
        }
        setState(() {
          fetchingGenderTypes = false;
        });
      } else {
        print('Gender types not found!');
      }
    } catch (e) {
      print("Exception in getGenderTypes(): $e");
    }
  }

//not in used
  Future<void> getDocuments() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse("${getApiBaseUrl()}/LOS/getDocuments");
      print("Complete API URL: ${uri.toString()}");
      var response = await client.get(uri, headers: headers);
      print("Response received in getDocuments(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = jsonData['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          documentsData.add(DocumentsData(
              item['value'] ?? 0,
              item['label'] ?? '',
              item['mandetoryFlag'] ?? '',
              item['waiveFlag'] ?? '',
              item['expiryFlag'] ?? '',
              item['noOfDocument'] ?? ''));
        }
        print("Total Documents Data: ${documentsData.length}");
        for (DocumentsData type in documentsData) {
          print("Document Data: ${type.label}");
        }
        setState(() {
          fetchingDocumentsData = false;
        });
      } else {
        print('Documents Data not found!');
      }
    } catch (e) {
      print("Exception in getDocuments(): $e");
    }
  }

//Need to update
  Future<void> getCustomerProductTypes(String limitTypeId) async {
    try {
      final headers = await getGenericHeaders();
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: false);
      // pr.style(
      //     message: 'Please wait...',
      //     borderRadius: 10.0,
      //     backgroundColor: Colors.white,
      //     progressWidget: const Center(
      //       child: SizedBox(
      //           width: 50, height: 50, child: CircularProgressIndicator()),
      //     ),
      //     elevation: 10.0,
      //     insetAnimCurve: Curves.easeInOut,
      //     progress: 0.0,
      //     //textDirection: TextDirection.rtl,
      //     padding: const EdgeInsets.all(16),
      //     maxProgress: 100.0,
      //     progressTextStyle: const TextStyle(
      //         color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      //     messageTextStyle: const TextStyle(
      //         color: Colors.black,
      //         fontSize: 19.0,
      //         fontWeight: FontWeight.w600));
      // await pr.show();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/LOS/getProductsData?limitTypeId=$limitTypeId");
      print("Complete API URL: ${uri.toString()}");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getCustomerProductTypes(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> nTypes =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = nTypes['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          /*
          customerProductTypes.add(ParametersData(
              "${item['id']}" ?? "0",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
           */
          customerProductTypes.add(ParametersDataNew(
              "${item['id']}" ?? "0",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? "",
              item['minAmount'] ?? "",
              item['maxAmount'] ?? "",
              item['images'] ?? "",
              item['discription'] ?? ""));
        }
        print("Total Customer Product Types: ${customerProductTypes.length}");
        for (ParametersDataNew type in customerProductTypes) {
          print("Customer Product Type: ${type.label}");
        }
        setState(() {});
        await pr.hide();
      } else {
        print('Customer Product types are not found!');
      }
    } catch (e) {
      print("Exception in getCustomerProductTypes(): $e");
    }
  }

  // Future<void> postCustomerData(String data) async {
  //   try {
  //     var client = http.Client();
  //     var uri = Uri.parse("${getApiBaseUrl()}/LOS/sendProposal?jsonData=$data");
  //     print("Complete API URL: ${uri.toString()}");
  //     var response = await client.get(uri);
  //     if (response.statusCode == 200) {
  //       print('Customer Data posted successfully!');
  //     } else {
  //       print('Response Status Code: ${response.statusCode}');
  //       print('Response in posting customer data: ${response.body}');
  //       print('There is an error on posting customer data!');
  //     }
  //   } catch (e) {
  //     print('Exception in postCustomerData(): $e');
  //   }
  // }

  Future<void> makePostRequestLogAPI({
    required String uiUxName,
    required String uiUxPkJson,
    required String uiUxJsonDesc,
    required DateTime createdOn,
    required DateTime modifiedOn,
    required String operationType,
    required String oldValue,
    required String newValue,
    required String? mobileNumber,
    required String sessionId,
  }) async {
    // API endpoint
    var url = Uri.parse('${getApiBaseUrl()}/DynamicUIUX/DynamicUIInsert');

    // JSON body
    Map<String, dynamic> requestBody = {
      "uI_UX_NAME": uiUxName,
      "uI_UX_PK_JSON": uiUxPkJson,
      "uI_UX_JSON_DESC": uiUxJsonDesc,
      "createD_ON": createdOn.toIso8601String(),
      "modifieD_ON": modifiedOn.toIso8601String(),
      "operationtype": operationType,
      "oldvalue": oldValue,
      "newvalue": newValue,
      "mobilE_NUMBER": mobileNumber,
      "sessioN_ID": sessionId,
    };

    try {
      // Make the POST request
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );
      print('logs request Request successful: ${response.body}');
      // Check the response status
      if (response.statusCode == 200) {
        print('Request successful: ${response.body}');
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  // Future<void> postCustomerDataNew(String data) async {
  //   debugPrint(data.toString(), wrapWidth: 1024);

  //   try {
  //     var client = http.Client();
  //     var uri = Uri.parse("${getApiBaseUrl()}/LOS/sendProposal");
  //     print("Complete API URL: ${uri.toString()}");
  //     Map<String, String> headers = {};
  //     headers['Content-Type'] = 'application/json;charset=UTF-8';
  //     headers['Accept'] = '*/*';
  //     final prefs = await SharedPreferences.getInstance();
  //     String? singInMObilenumber = prefs.getString('sign_in_number');
  //     var response = await client.post(uri, body: data, headers: headers);
  //     await makePostRequestLogAPI(
  //       uiUxName: "send proposal Request",
  //       uiUxPkJson: data,
  //       uiUxJsonDesc: response.statusCode.toString(),
  //       createdOn: DateTime.now(),
  //       modifiedOn: DateTime.now(),
  //       operationType: "s",
  //       oldValue: "string",
  //       newValue: "string",
  //       mobileNumber: singInMObilenumber,
  //       sessionId: "string",
  //     );
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> responseBody = json.decode(response.body);
  //       print(responseBody['data']);
  //       if (responseBody['data'] == '200') {
  //         showSuccessDialog(context);
  //         print('Response Status Code: ${response.statusCode}');
  //         print('Customer Data posted successfully!');
  //         debugPrint(response.body.toString(), wrapWidth: 1024);
  //         print('Response: ${response.body.toString()}');
  //       } else {
  //         print('Response Status Code: ${response.statusCode}');
  //         print('Response in posting customer data: ${response.body}');
  //         print('There is an error on posting customer data!');
  //       }
  //     } else {}
  //   } catch (e) {
  //     print('Exception in postCustomerData(): $e');
  //   }
  // }
  Future<void> postCustomerDataNew(
      String data, BuildContext context, bool nadrabioStatus) async {
    debugPrint(data.toString(), wrapWidth: 1024);

    // showDialog(
    //   context: context,
    //   barrierDismissible: true,
    //   builder: (BuildContext context) {
    //     return Dialog(
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(20.0),
    //       ),
    //       child: const Padding(
    //         padding: EdgeInsets.all(20.0),
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             CircularProgressIndicator(),
    //             SizedBox(height: 20),
    //             Text(
    //               "Please wait...",
    //               style: TextStyle(fontSize: 16, color: Colors.black87),
    //             ),
    //           ],
    //         ),
    //       ),
    //     );
    //   },
    // );
    ReusableDialogs.showProgressDialogproposal(context);
    bool? nadraStatus = nadrabioStatus;
    print('is biomatric: ${nadraStatus}');
    try {
      final headers = await getGenericHeaders();
      final client = http.Client();
      var uri = Uri.parse("${getApiBaseUrl()}/LOS/sendProposal");
      print("Complete API URL: ${uri.toString()}");
      // Map<String, String> headers = {
      //   'Content-Type': 'application/json;charset=UTF-8',
      //   'Accept': '*/*',
      // };
      // final prefs = await SharedPreferences.getInstance();
      // String? singInMObilenumber = prefs.getString('sign_in_number');

      var response = await client.post(uri, body: data, headers: headers);

      // await makePostRequestLogAPI(
      //   uiUxName: "send proposal Request",
      //   uiUxPkJson: data,
      //   uiUxJsonDesc: response.statusCode.toString(),
      //   createdOn: DateTime.now(),
      //   modifiedOn: DateTime.now(),
      //   operationType: "s",
      //   oldValue: "string",
      //   newValue: "string",
      //   mobileNumber: singInMObilenumber,
      //   sessionId: "string",
      // );

      // Navigator.of(context).pop(); // Dismiss the loading indicator
      Navigator.pop(context);
      if (response.statusCode == 200) {
        print(response.body.toString());
        if (response.body == '200') {
          if (journeyType == "NTB") {
            await DatabaseHelper().deleteAllLoanRequests();
            if (nadraStatus != null && nadraStatus) {
              showSuccessDialog(formValues["full_name"], context);
            } else {
              ReusableDialogs.showErrorDialogSendProposal(
                context,
                title: "Verification Failed",
                message:
                    "Dear ${formValues["full_name"] ?? ""},\n we are processing your request, however as your Biometric verification was unsuccessful, a sales representative shall get in touch with you shortly to complete the same. For any further assistance, please feel free to contact us at 021-111-06-06-06",
              );
            }
            // showSuccessDialog(formValues["full_name"], context);
          } else {
            showSuccessDialog(formValues["card_name"] ?? "", context);
          }
        } else {
          ReusableDialogs.showErrorDialog(context,
              title: "Missing", message: response.body.toString());
        }
        // final Map<String, dynamic> responseBody = json.decode(response.body);
        // print(responseBody['data']);
        // showFailDialog(context, responseBody['data']);

        // // showSuccessDialog(formValues['full_name'], context);
        // print('Response Status Code: ${response.statusCode}');
        // print('Customer Data posted successfully!');
        // debugPrint(response.body.toString(), wrapWidth: 1024);
        // print('Response: ${response.body.toString()}');

        // print('Response Status Code: ${response.statusCode}');
        // print('Response in posting customer data: ${response.body}');
        // print('There is an error on posting customer data!');
      } else {
        print('Failed with Status Code: ${response.statusCode}');
        ReusableDialogs.showErrorDialog(context,
            title: "Session Expired", message: 'Please, Restart App');
      }
    } catch (e) {
      // Navigator.pop(context); // Dismiss the loading indicator on error
      print('Exception in postCustomerData(): $e');
      showError(e);
      ReusableDialogs.showErrorDialog(context,
          title: "Session Expired", message: 'Please, Restart App');
    }
  }

  Future<void> getclientInfoandPopulate() async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: false);
    // pr.style(
    //     message: 'Please wait...',
    //     borderRadius: 10.0,
    //     backgroundColor: Colors.white,
    //     progressWidget: const Center(
    //       child: SizedBox(
    //           width: 50, height: 50, child: CircularProgressIndicator()),
    //     ),
    //     elevation: 10.0,
    //     insetAnimCurve: Curves.easeInOut,
    //     progress: 0.0,
    //     //textDirection: TextDirection.rtl,
    //     padding: const EdgeInsets.all(16),
    //     maxProgress: 100.0,
    //     progressTextStyle: const TextStyle(
    //         color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
    //     messageTextStyle: const TextStyle(
    //         color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
    try {
      // await pr.show();
      late ClientInfoModel? clientInfo =
          Provider.of<ClientProvider>(context, listen: false).clientInfo;
      print(clientInfo?.clientName);
      // customerData.displayCustomerData();
      if (clientInfo?.clientName == null) {
        print("No Customer Data Found!");
      } else {
        print("Customer Data Found");

        print('client info name : ${formValues["full_name"]}');
        formValues["full_name"] = clientInfo?.clientName;

        formValues["father_name"] = clientInfo?.fatherName;
        // formValues["gender_type"] =
        //     customerData.gender == "M" ? "Male" : "Female";
        formValues["gender_type"] = clientInfo?.gender;
        pickerStates["gender_type"] = 0;
        formValues["id_number"] = clientInfo?.globalID;
        // formValues["country_type"]="Pakistan";
        // pickerStates["country_type"] = 0;
        formValues["permanent_address"] = clientInfo?.address;
        formValues["current_State"] = clientInfo?.province;
        pickerStates["current_State"] = 0;
        // for (int i = 0; i < cnicTypes.length; i++) {
        //   ParametersData item = cnicTypes[i];
        //   if (item.label.toLowerCase() ==
        //       customerData.cardTypeName.toLowerCase()) {
        //     pickerStates["id_card_type"] = i;
        //     formValues["id_card_type"] = customerData.cardTypeName;
        //   }
        // }
        // formValues["mother_name"] = customerData.motherName;
        // if (customerData.countryName != "") {
        //   for (int i = 0; i < countries.length; i++) {
        //     ParametersData item = countries[i];
        //     if (item.label.toLowerCase() ==
        //         customerData.countryName.toLowerCase()) {
        //       pickerStates["country_type"] = i;
        //       formValues["country_type"] = customerData.countryName;
        //     }
        //   }
        // }
        formValues["play_of_birth"] = customerData.birthPlace;
        if (customerData.nationalityName != "") {
          for (int i = 0; i < nationalityType.length; i++) {
            ParametersData item = nationalityType[i];
            if (item.label.toLowerCase() ==
                customerData.nationalityName.toLowerCase()) {
              pickerStates["nationality_type"] = i;
              formValues["nationality_type"] = customerData.nationalityName;
            }
          }
        }
        // final dateOfBirth =
        //     DateTime.fromMicrosecondsSinceEpoch(customerData.dateofBirth);
        // print("Date of Birth: ${DateFormat('dd-MM-yyyy').format(dateOfBirth)}");
        // formValues["date_of_birth"] =
        //     DateFormat('dd-MM-yyyy').format(dateOfBirth);
        // final cnicIssuanceDate =
        //     DateTime.fromMicrosecondsSinceEpoch(customerData.cnicIssuanceDate);
        // print(
        //     "CNIC Issuance Date: ${DateFormat('dd-MM-yyyy').format(cnicIssuanceDate)}");
        // formValues["id_issue_date"] =
        //     DateFormat('dd-MM-yyyy').format(cnicIssuanceDate);
        // final cnicExpiryDate =
        //     DateTime.fromMicrosecondsSinceEpoch(customerData.cnicExpiryDate);
        // print(
        //     "CNIC Expiry Date: ${DateFormat('dd-MM-yyyy').format(cnicExpiryDate)}");
        // formValues['id_expiry_date'] =
        //     DateFormat('dd-MM-yyyy').format(cnicExpiryDate);
      }

      setState(() {
        //fetchingCustomerData = false;
      });
      await pr.hide();
    } catch (e) {
      print("Exception in getCustomerData(): $e");
      await pr.hide();
    }
  }

  // Future<void> getCustomerData(String cnic) async {
  //   final ProgressDialog pr = ProgressDialog(context,
  //       type: ProgressDialogType.normal, isDismissible: false);
  //   pr.style(
  //       message: 'Please wait...',
  //       borderRadius: 10.0,
  //       backgroundColor: Colors.white,
  //       progressWidget: const Center(
  //         child: SizedBox(
  //             width: 50, height: 50, child: CircularProgressIndicator()),
  //       ),
  //       elevation: 10.0,
  //       insetAnimCurve: Curves.easeInOut,
  //       progress: 0.0,
  //       //textDirection: TextDirection.rtl,
  //       padding: const EdgeInsets.all(16),
  //       maxProgress: 100.0,
  //       progressTextStyle: const TextStyle(
  //           color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
  //       messageTextStyle: const TextStyle(
  //           color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
  //   try {
  //     await pr.show();
  //     var client = http.Client();
  //     //var uri = Uri.parse("${getApiBaseUrl()}/LOS/getCustomerData?cnic=1111111111111");
  //     var uri = Uri.parse("${getApiBaseUrl()}/LOS/getCustomerData?cnic=$cnic");
  //     print("Complete API URL: ${uri.toString()}");
  //     var response = await client.get(uri);
  //     print(
  //         "Response received in getCustomerData(): ${response.body.toString()}");
  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> nTypes =
  //           jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  //       Map<String, dynamic> cData = nTypes['data'];
  //       customerData = CustomerData(
  //           cData["brInfoId"] ?? "",
  //           cData["relationId"] ?? "",
  //           cData["firstName"] ?? "",
  //           cData["middleName"] ?? "",
  //           cData["lastName"] ?? "",
  //           cData["fatherName"] ?? "",
  //           cData["gender"] ?? "",
  //           cData["dateofBirth"] ?? 0,
  //           cData["cardTypeId"] ?? "",
  //           cData["cardTypeName"] ?? "",
  //           cData["cnic"] ?? "",
  //           cData["cnicIssuanceDate"] ?? 0,
  //           cData["cnicExpiryDate"] ?? 0,
  //           cData["motherName"] ?? "",
  //           cData["countryName"] ?? "",
  //           cData["birthPlace"] ?? "",
  //           cData["nationalityName"] ?? "");
  //       print("<=======Customer Data=======>");
  //       customerData.displayCustomerData();
  //       if (customerData.firstName == "") {
  //         print("No Customer Data Found!");
  //       } else {
  //         formValues['brInfoId'] = customerData.brInfoId;

  //         formValues['relationId'] = customerData.relationId;
  //         formValues["first_name"] = customerData.firstName;
  //         formValues["middle_name"] = customerData.middleName;
  //         formValues["last_name"] = customerData.lastName;
  //         formValues["full_name"] = "${customerData.firstName} "
  //             " ${customerData.middleName} "
  //             " ${customerData.lastName}";
  //         formValues["father_name"] = customerData.fatherName;
  //         formValues["gender_type"] =
  //             customerData.gender == "M" ? "Male" : "Female";
  //         pickerStates["gender_type"] = 0;
  //         for (int i = 0; i < cnicTypes.length; i++) {
  //           ParametersData item = cnicTypes[i];
  //           if (item.label.toLowerCase() ==
  //               customerData.cardTypeName.toLowerCase()) {
  //             pickerStates["id_card_type"] = i;
  //             formValues["id_card_type"] = customerData.cardTypeName;
  //           }
  //         }
  //         formValues["mother_name"] = customerData.motherName;
  //         if (customerData.countryName != "") {
  //           for (int i = 0; i < countries.length; i++) {
  //             ParametersData item = countries[i];
  //             if (item.label.toLowerCase() ==
  //                 customerData.countryName.toLowerCase()) {
  //               pickerStates["country_type"] = i;
  //               formValues["country_type"] = customerData.countryName;
  //             }
  //           }
  //         }
  //         formValues["play_of_birth"] = customerData.birthPlace;
  //         if (customerData.nationalityName != "") {
  //           for (int i = 0; i < nationalityType.length; i++) {
  //             ParametersData item = nationalityType[i];
  //             if (item.label.toLowerCase() ==
  //                 customerData.nationalityName.toLowerCase()) {
  //               pickerStates["nationality_type"] = i;
  //               formValues["nationality_type"] = customerData.nationalityName;
  //             }
  //           }
  //         }
  //         final dateOfBirth =
  //             DateTime.fromMicrosecondsSinceEpoch(customerData.dateofBirth);
  //         print(
  //             "Date of Birth: ${DateFormat('dd-MM-yyyy').format(dateOfBirth)}");
  //         formValues["date_of_birth"] =
  //             DateFormat('dd-MM-yyyy').format(dateOfBirth);
  //         final cnicIssuanceDate = DateTime.fromMicrosecondsSinceEpoch(
  //             customerData.cnicIssuanceDate);
  //         print(
  //             "CNIC Issuance Date: ${DateFormat('dd-MM-yyyy').format(cnicIssuanceDate)}");
  //         formValues["id_issue_date"] =
  //             DateFormat('dd-MM-yyyy').format(cnicIssuanceDate);
  //         final cnicExpiryDate =
  //             DateTime.fromMicrosecondsSinceEpoch(customerData.cnicExpiryDate);
  //         print(
  //             "CNIC Expiry Date: ${DateFormat('dd-MM-yyyy').format(cnicExpiryDate)}");
  //         formValues['id_expiry_date'] =
  //             DateFormat('dd-MM-yyyy').format(cnicExpiryDate);
  //       }
  //     } else {
  //       print("Status Code in getCustomerData(): ${response.statusCode}");
  //     }
  //     setState(() {
  //       //fetchingCustomerData = false;
  //     });
  //     await pr.hide();
  //   } catch (e) {
  //     print("Exception in getCustomerData(): $e");
  //     await pr.hide();
  //   }
  // }

  void _applyProduct(Product_new p) {
    _cardLable = p.label;
    _pValue = p.value.toString();
    cardMinLimit = p.minAmount;
    cardMaxLimit = p.maxAmount;
    _annualFee = p.annualFee;
    _fed = p.fed;
    _spendingReversal = p.spendingReversal;
    _duration = p.duration;

    formValues['customer_product_type_id'] = _pValue;
    formValues['customer_product_type'] = _cardLable;
  }

  Future<List<Product_new>> fetchProductsData() async {
    final headers = await getGenericHeaders();
    final client = await createHttpClientWithPinnedCert();
    final resp = await client.get(
      Uri.parse(
          '${getApiBaseUrl()}/LOS/getProductsData?limitTypeId=$globalProductValue'),
      headers: headers,
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to load products');
    }
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final rawList = (body['data'] as List<dynamic>);
    return rawList
        .cast<Map<String, dynamic>>()
        .map((e) => Product_new.fromJson(e))
        .toList();
  }

  Future<void> getCitiesList() async {
    try {
      final client = await createHttpClientWithPinnedCert();
      final headers = await getGenericHeaders();
      var uri = Uri.parse("${getApiBaseUrl()}/LOS/getCitiesData");
      print("Complete API URL: ${uri.toString()}");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getCitiesList(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> citiesList =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = citiesList['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          cities.add(ParametersData(
              item['id'] ?? "",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Cities Fetch: ${cities.length}");
        for (ParametersData city in cities) {
          print("Cities: ${city.label}");
        }
        setState(() {
          fetchingCities = false;
        });
      }
    } catch (e) {
      print("Exception in getCountryList(): $e");
    }
  }

  Future<void> getMaritalTypeList() async {
    try {
      final client = await createHttpClientWithPinnedCert();
      final headers = await getGenericHeaders();

      var uri = Uri.parse(
          "${getApiBaseUrl()}/LOS/getStaticParametersData?classCode=BRIndividualDetail&attribute=maritalStatus");
      print(
          "Complete API URL: ${getApiBaseUrl()}/LOS/getStaticParametersData?classCode=BRIndividualDetail&attribute=maritalStatus");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getEmploymentStatus(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> mTypes =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = mTypes['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          maritalType.add(ParametersData(
              item['id'] ?? "",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Marital Status: ${maritalType.length}");
        for (ParametersData type in maritalType) {
          print("Marital Status: ${type.label}");
        }
        setState(() {
          fetchingMaritalType = false;
        });
      }
    } catch (e) {
      print("Exception in getMaritalStatus(): $e");
    }
  }

  Future<void> getEducationTypeList() async {
    try {
      final client = await createHttpClientWithPinnedCert();
      final headers = await getGenericHeaders();

      var uri = Uri.parse(
          "${getApiBaseUrl()}/LOS/getParametersData?code=AcademicTitleType");
      print("Complete API URL: ${uri.toString()}");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getEducationList(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> educationList =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = educationList['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          educationType.add(ParametersData(
              item['id'] ?? "",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Education Fetch: ${educationType.length}");
        for (ParametersData education in educationType) {
          print("Education: ${education.label}");
        }
        setState(() {
          fetchingEducationType = false;
        });
      }
    } catch (e) {
      print("Exception in getEducationList(): $e");
    }
  }

  Future<void> getResidentialStatusList() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/LOS/getParametersData?code=ResidenceStatus");
      print("Complete API URL: ${uri.toString()}");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getResidentialList(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> residentialList =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = residentialList['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          residentialStatus.add(ParametersData(
              item['id'] ?? "",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Residential Fetch: ${residentialStatus.length}");
        for (ParametersData residential in residentialStatus) {
          print("Residential: ${residential.label}");
        }
        setState(() {
          fetchingResidentialStatus = false;
        });
      }
    } catch (e) {
      print("Exception in getEducationList(): $e");
    }
  }

  Future<void> getAccommodationTypeList() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/LOS/getParametersData?code=DwellingType");
      print("Complete API URL: ${uri.toString()}");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getAccommodationList(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> accommodationList =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = accommodationList['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          accommodationTypes.add(ParametersData(
              item['id'] ?? "",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Education Fetch: ${accommodationTypes.length}");
        for (ParametersData accommodation in accommodationTypes) {
          print("Accommodation: ${accommodation.label}");
        }
        setState(() {
          fetchingAccommodationTypes = false;
        });
      }
    } catch (e) {
      print("Exception in getEducationList(): $e");
    }
  }

  Future<void> getRelationshipTypeList() async {
    try {
      final headers = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      var uri = Uri.parse(
          "${getApiBaseUrl()}/LOS/getParametersData?code=RelationshipType");
      print("Complete API URL: ${uri.toString()}");
      var response = await client.get(uri, headers: headers);
      print(
          "Response received in getRelationshipList(): ${response.body.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> relationList =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        List<dynamic> dataList = relationList['data'];
        print("Length of Data List: ${dataList.length}");
        print("Data List: ${dataList.toString()}");
        for (var item in dataList) {
          relationshipTypes.add(ParametersData(
              item['id'] ?? "",
              item['label'] ?? "",
              item['labelValue'] ?? "",
              "${item['value']}" ?? "0",
              item['attribute'] ?? "",
              item['dataType'] ?? "",
              item['group'] ?? ""));
        }
        print("Total Relationship Fetch: ${relationshipTypes.length}");
        for (ParametersData relation in relationshipTypes) {
          print("Relationship: ${relation.label}");
        }
        setState(() {
          fetchingRelationshipTypes = false;
        });
      }
    } catch (e) {
      print("Exception in getEducationList(): $e");
    }
  }

  // Runs all needed API calls in parallel instead of sequentially.
// Comments are preserved as in the original code, so you can easily
// uncomment or modify calls as needed.
  // Future<void> callApis() async {
  //   final fetchProductsFuture = fetchProductsData().then((data) {
  //     globalProducts = data;
  //   });
  //   await Future.wait([
  //     getCountryList(),
  //     getCitiesList(),
  //     getNationalityTypes(),
  //     getEmploymentTypes(),
  //     getEmploymentStatus(),

  //     getTypesOfCompany(),
  //     getTypesOfBusiness(),
  //     getProfessionTypes(),
  //     getProductTypes(),
  //     // getCardTypes();
  //     getCnicTypes(),
  //     getOtherFacilities(),
  //     // getCustomerData();
  //     // getTenor();
  //     getInstallmentFrequency(),
  //     getVehicleTypes(),
  //     getFacilityTypes(),
  //     getEmiType(),
  //     getInstallmentDueDates(),
  //     // getAssetData();
  //     getTakafulCompanies(),
  //     getGenderTypes(),
  //     getMaritalTypeList(),

  //     getEducationTypeList(),
  //     getResidentialStatusList(),
  //     getAccommodationTypeList(),
  //     getRelationshipTypeList(),
  //     fetchProductsFuture
  //   ]);

  //   /*
  // if (formValues['customer_product_type'] != null &&
  //     pickerStates['product_type'] != null &&
  //     pickerIds['product_type'] != null) {
  //   if (formValues['product_type'] == 'Credit Card') {
  //     pickerAttributes['customer_product_type'] = 'CC';
  //   }
  //   await getCustomerProductTypes(pickerIds['product_type']!);
  // }
  // */
  //   // await getDocuments();
  // }

  void callApis() async {
    // final fetchProductsFuture = fetchProductsData().then((data) {
    //   globalProducts = data;
    // });
    await getCountryList();
    await getCitiesList();
    await getNationalityTypes();
    await getEmploymentTypes();
    await getEmploymentStatus();

    await getTypesOfCompany();
    await getTypesOfBusiness();
    await getProfessionTypes();
    await getProductTypes();
    // await getCardTypes();
    await getCnicTypes();
    await getOtherFacilities();
    // await getCustomerData();
    // await getTenor();
    await getInstallmentFrequency();
    await getVehicleTypes();
    await getFacilityTypes();
    await getEmiType();
    await getInstallmentDueDates();
    // await getAssetData();
    await getTakafulCompanies();
    await getGenderTypes();
    await getMaritalTypeList();

    await getEducationTypeList();
    await getResidentialStatusList();
    await getAccommodationTypeList();
    await getRelationshipTypeList();

    /*
    if(formValues['customer_product_type'] != null && pickerStates['product_type'] != null && pickerIds['product_type'] != null) {
      if(formValues['product_type'] == 'Credit Card') {
        pickerAttributes['customer_product_type'] = 'CC';
      }
      await getCustomerProductTypes(pickerIds['product_type']!);
    }
     */
    // await getDocuments();
  }

  void convertMapsIntoJson() async {
    try {
      addPickerIdsIntoFormValues();

      ///formValues['approved_limit'] = "0";

      // if (widget.isProductType == 10) {
      //   formValues['employment_type'] = "Salaried";
      //   formValues['company_name'] = "Autosoft";

      //   formValues['company_type'] = "Electronics";
      //   formValues['employment_status'] = "3rd Party Contractual";
      //   formValues['current_designation'] = "Software Developer";
      //   formValues['current_department'] = "Research and Development";
      //   formValues['overall_work_experience'] = "06-05-2024";
      //   formValues['present_experience'] = "06-05-2024";
      //   formValues['designation_profession'] = "Manager";
      //   formValues['nature_of_business'] = "Software House";

      //   formValues['name_of_company'] = "Autosoft";
      //   formValues['office_city'] = "Lahore";
      //   formValues['office_number'] = "0123456789";
      //   formValues['monthly_gross_income'] = "1000000";
      //   formValues['monthly_net_income'] = "30000000";
      //   formValues['other_income'] = "500000";
      //   formValues['other_source_income'] = "Freelance";

      //   formValues['full_name'] = "Full Name";
      //   formValues['father_name'] = "Father Name";
      //   formValues['gender_type'] = "Male";
      //   formValues['id_number'] = "3520276004205";
      //   formValues['date_of_birth'] = "06-05-2024";
      //   formValues['id_card_type'] = "CNIC";
      //   formValues['id_issue_date'] = "06-05-2024";
      //   formValues['id_expiry_date'] = "06-05-2024";

      //   formValues['mother_name'] = "Mother Name";
      //   formValues['country_type'] = "Pakistan";
      //   formValues['nationality_type'] = "PAKISTANI";
      //   formValues['own_car'] = "Flat";
      //   formValues['current_city'] = "Lahore";
      //   formValues['play_of_birth'] = "Lahore";
      //   formValues['selfie_assessment'] = "";
      //   formValues['permanent_address'] = "Lahore";

      //   formValues['current_city'] = "Lahore";
      //   formValues['telephone_number'] = "13456789";
      //   formValues['residential_status'] = "Rent";
      //   formValues['type_of_accommodation'] = "Flat";

      //   formValues['reference_name_1'] = "Muhammad Raees";
      //   formValues['reference_cnic_1'] = "35202752345342";
      //   formValues['reference_mobile_1'] = "03111454560";
      //   formValues['reference_relationship_1'] = "Father";
      //   formValues['reference_address_1'] = "DHA Lahore";

      //   formValues['reference_name_2'] = "Muhammad Khizar";
      //   formValues['reference_cnic_2'] = "35202752345342";
      //   formValues['reference_mobile_2'] = "03111454560";
      //   formValues['reference_relationship_2'] = "Brother";
      //   formValues['reference_address_2'] = "Modal Town Lahore";

      //   formValues['consent_checkbox'] = true;
      //   formValues['biometric_fingure'] = "";

      //   formValues['employment_type_id'] = "11844";
      //   formValues['company_type_id'] = "7331";
      //   formValues['employment_status_id'] = "";
      //   formValues['gender_type_id'] = "M";
      //   formValues['id_card_type_id'] = "C";

      //   formValues['country_type_id'] = "71";
      //   formValues['material_status_id'] = "";
      //   formValues['number_of_dependents_id'] = "";
      //   formValues['educational_qualification_id'] = "";
      //   formValues['nationality_type_id'] = "161";

      //   formValues['residential_status_id'] = "";
      //   formValues['type_of_accommodation_id'] = "";
      //   formValues['card_delivery_id'] = "";
      //   formValues['reference_relationship_1_id'] = "";
      //   formValues['reference_relationship_2_id'] = "";
      // }

      final List<int> allUploadIds =
          globalUploadedDocIdsMap.values.expand((ids) => ids).toList();

      // 2) Ensure we have a dobcnic list: prefer the in-memory one, else load from Hive
      final box = await Hive.openBox<List<int>>('uploadsBox');
      final List<int> persistedDobIds =
          dobcnicUploadId ?? box.get('dobcnicUploadId') ?? <int>[];

      // 3) Append, if there’s anything to add
      if (persistedDobIds.isNotEmpty) {
        allUploadIds.addAll(persistedDobIds);
      }

      // 4) Use in your form
      formValues["upload_documents_id"] = allUploadIds;
      List<ReferenceData> references = [];
      for (int i = 1; i < 5; i++) {
        late ReferenceData referenceData;
        if (formValues["reference_name_$i"] != null &&
            formValues["reference_name_$i"] != "") {
          referenceData = ReferenceData(
              "$i",
              formValues["reference_name_$i"],
              formValues["reference_cnic_$i"],
              formValues["reference_mobile_$i"],
              formValues["reference_relationship_$i"],
              formValues["reference_address_$i"] ?? '',
              formValues["reference_relationship_${i}_id"]);

          references.add(referenceData);
        }
      }

      formValues['references'] = references;
      // String referenceStr = jsonEncode(references);

      print("JSON of Reference Data: $formValues['references']");
      // formValues['references'] = referenceStr;
      print('srialize Json: ${formValues['references']}');
      final prefs = await SharedPreferences.getInstance();
      final secureStorage = FlutterSecureStorage();
      formValues['country_type'] = "Pakistan";
      formValues['country_type_id'] = '71';
      formValues['pmd'] = 'N';
      formValues['mobile_no'] = await UserSecretStore.getSignNumber();
      formValues['longitude'] = prefs.getDouble("long");
      formValues['latitude'] = prefs.getDouble("lat");
      // formValues['city_id'] = '3';
      formValues['id_number'] = await UserSecretStore.getCnic();
      // formValues['id_number'] = '3520199566515';
      // formValues['office_city_id'] = '3';
      // formValues['company_type_id'] = '12366';
      ReusableDialogs.showProgressDialogproposal(context);
      // formValues['marital_status_id'] = 'M';
      bool? biomatricStatus = await fingerBiometric(context);
      Navigator.pop(context);
      if (biomatricStatus!) {
        formValues['nadra'] = 'Y';
      } else {
        formValues['nadra'] = 'N';
      }
      if (C360data != null) {
        formValues.addAll(C360data!);
      }
      // formValues.addAll(cf1Values);
      // formValues['cf1'] = cf1Values;
      String jsonStr = jsonEncode(formValues);
      print("Jsonstr:${jsonStr}");
      print("JSON of Data Collected: $jsonStr");
      await writeUserDataJson(jsonStr);
      //await postCustomerData(jsonStr);
      await postCustomerDataNew(jsonStr, context, biomatricStatus);
    } catch (e) {
      print("Exception in convertMapsIntoJson(): $e");
    }
  }

  Future<String?> get _localPathForOutputJson async {
    final directory = await getExternalStorageDirectory();
    return directory?.path;
  }

  Future<File> get _localFile async {
    final path = await _localPathForOutputJson;
    return File('$path/requestId_$requestId.json');
  }

  Future<File> writeUserDataJson(String data) async {
    final file = await _localFile;
    // Write the file
    return file.writeAsString(data);
  }

  String? getPickerId(String classId, String value) {
    try {
      if (classId == 'nationality_type') {
        for (var item in nationalityType) {
          if (item.label == value) {
            return item.value;
          }
        }
      } else if (classId == 'employment_type') {
        for (var item in employmentTypes) {
          if (item.label == value) {
            return item.value;
          }
        }
      } else if (classId == 'employment_status') {
        print('Value: $value');
        for (var item in employmentStatus) {
          if (item.label.trim() == value) {
            if (item.value != "" && item.value != 'null') {
              return item.value;
            } else {
              return item.attribute;
            }
          }
        }
      } else if (classId == 'company_type') {
        print('Value: $value');
        for (var item in typesOfBusiness) {
          if (item.label.trim() == value) {
            print("${classId}_id: ${item.value}");
            return item.value;
          }
        }
      } else if (classId == 'business_type') {
        for (var item in typesOfBusiness) {
          if (item.label.trim() == value) {
            if (item.value != "" && item.value != 'null') {
              return item.value;
            } else {
              return item.attribute;
            }
          }
        }
      } else if (classId == 'profession_type') {
        for (var item in professionTypes) {
          if (item.label == value) {
            print("${classId}_id: ${item.value}");
            return item.value;
          }
        }
      } else if (classId == 'id_card_type') {
        for (var item in cnicTypes) {
          if (item.label.trim() == value) {
            if (item.value != "" && item.value != 'null') {
              return item.value;
            } else {
              return item.attribute;
            }
          }
        }
      } else if (classId == 'other_facilities') {
        for (var item in otherFacilities) {
          if (item.label == value) {
            print("${classId}_id: ${item.value}");
            return item.value;
          }
        }
      } else if (classId == 'car_finance_tenor_type') {
        for (var item in tenor) {
          if (item.label == value) {
            return item.value;
          }
        }
      } else if (classId == 'car_vehicle_type') {
        for (var item in vehicleTypes) {
          if (item.label == value) {
            return item.value;
          }
        }
      } else if (classId == 'car_facility_type') {
        for (var item in facilityTypes) {
          if (item.label == value) {
            return item.value;
          }
        }
      } else if (classId == 'car_emi_type') {
        for (var item in emiTypes) {
          if (item.label == value) {
            return item.value;
          }
        }
      } else if (classId == 'car_maker_type') {
        for (var item in manufacturerBrInfoList) {
          if (item.label.trim() == value) {
            if (item.label == value) {
              return item.value;
            }
          }
        }
      } else if (classId == 'car_takaful_type') {
        for (var item in takafulCompanies) {
          if (item.label.trim() == value) {
            if (item.label == value) {
              return item.value;
            }
          }
        }
      } else if (classId == 'country_type') {
        for (var item in countries) {
          if (item.label.trim() == value) {
            if (item.label == value) {
              print("${classId}_id: ${item.value}");
              return item.value;
            }
          }
        }
      } else if (classId == 'product_type') {
        for (var item in productTypes) {
          if (item.label == value) {
            return item.value;
          }
        }
      } else if (classId == 'gender_type') {
        for (var item in genderTypes) {
          if (item.label.trim() == value) {
            if (item.value != "" && item.value != 'null') {
              return item.value;
            } else {
              return item.attribute;
            }
          }
        }
      } else if (classId == 'customer_product_type') {
        for (var item in customerProductTypes) {
          if (item.label.trim() == value) {
            if (item.value != "" && item.value != 'null') {
              return item.value;
            } else {
              return item.attribute;
            }
          }
        }
      } else if (classId == 'educational_qualification') {
        for (var item in educationType) {
          if (item.label.trim() == value) {
            if (item.value != "" && item.value != 'null') {
              return item.value;
            } else {
              return item.attribute;
            }
          }
        }
      } else if (classId == 'marital_status') {
        for (var item in maritalType) {
          if (item.label.trim() == value) {
            if (item.value != "" && item.value != 'null') {
              return item.value;
            } else {
              return item.attribute;
            }
          }
        }
      } else if (classId == 'business_nature') {
        for (var item in typesOfCompany) {
          if (item.label.trim() == value) {
            if (item.value != "" && item.value != 'null') {
              return item.value;
            } else {
              return item.attribute;
            }
          }
        }
      } else if (classId == 'business_nature_type') {
        for (var item in typesOfCompany) {
          if (item.label.trim() == value) {
            if (item.value != "" && item.value != 'null') {
              return item.value;
            } else {
              return item.attribute;
            }
          }
        }
      } else if (classId == 'current_city') {
        for (var item in cities) {
          if (item.label.trim() == value) {
            if (item.value != "" && item.value != 'null') {
              return item.value;
            } else {
              return item.attribute;
            }
          }
        }
      } else if (classId == 'office_city') {
        for (var item in cities) {
          if (item.label.trim() == value) {
            if (item.value != "" && item.value != 'null') {
              return item.value;
            } else {
              return item.attribute;
            }
          }
        }
      } else if (classId == 'residential_status') {
        for (var item in residentialStatus) {
          if (item.label.trim() == value) {
            if (item.value != "" && item.value != 'null') {
              return item.value;
            } else {
              return item.attribute;
            }
          }
        }
      } else if (classId == 'type_of_accommodation') {
        for (var item in accommodationTypes) {
          if (item.label.trim() == value) {
            if (item.value != "" && item.value != 'null') {
              return item.value;
            } else {
              return item.attribute;
            }
          }
        }
      } else if (classId == 'reference_relationship_1') {
        for (var item in relationshipTypes) {
          if (item.label.trim() == value) {
            if (item.value != "" && item.value != 'null') {
              return item.value;
            } else {
              return item.attribute;
            }
          }
        }
      } else if (classId == 'reference_relationship_2') {
        for (var item in relationshipTypes) {
          if (item.label.trim() == value) {
            if (item.value != "" && item.value != 'null') {
              return item.value;
            } else {
              return item.attribute;
            }
          }
        }
      } else {
        print("No picker id found for $classId");
        return null;
      }
    } catch (e) {
      print('Exception in getPickerId(): $e');
      return null;
    }
  }

  String? getPickerAttribute(String classId, String value) {
    try {
      if (classId == 'customer_product_type') {
        for (var item in customerProductTypes) {
          if (item.label.trim() == value) {
            if (item.attribute != "" && item.attribute != 'null') {
              return item.attribute;
            } else {
              return null;
            }
          }
        }
      } else {
        print("No picker attribute found for $classId");
        return null;
      }
    } catch (e) {
      print('Exception in getPickerAttribute(): $e');
      return null;
    }
  }

  void populatePickerIds() {
    try {
      for (var key in pickerStates.keys) {
        if (formValues.containsKey(key)) {
          pickerIds[key] = getPickerId(key, formValues[key]) ?? "";
        }
      }
    } catch (e) {
      print('Exception in populatePickerIds(): $e');
    }
  }

  void addPickerIdsIntoFormValues() {
    try {
      for (var key in pickerIds.keys) {
        formValues['${key}_id'] = pickerIds[key];
      }
    } catch (e) {
      print('Exception in addPickerIdsIntoFormValues(): $e');
    }
  }

  Map<String, String>? getCardLimits(String classId, String value) {
    try {
      for (ParametersDataNew item in customerProductTypes) {
        if (item.label == value) {
          Map<String, String> cardLimits = {};
          if (item.minAmount != '' && item.maxAmount != '') {
            cardLimits['min'] = item.minAmount;
            cardLimits['max'] = item.maxAmount;
            return cardLimits;
          }
        }
      }
      print('Card Limits not found!');
      return null;
    } catch (e) {
      print('Exception in getCardLimits(): $e');
      return null;
    }
  }

  Widget generateDocumentPicker(String classId, String placeHolder) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  placeHolder,
                  style: const TextStyle(
                    color: newSecondaryColor,
                    fontSize: 18,
                    fontFamily: "Circular",
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 180,
                  height: 50,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.grey.shade200),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (multiImageSelector[classId] == null ||
                          multiImageSelector[classId]!.length < 3) {
                        _showPickImageDialog(context, classId);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text("You can only upload up to 3 images."),
                          ),
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          "assets/images/ic_document.png",
                          height: 25,
                          width: 25,
                        ),
                        const Text(
                          'Upload Files',
                          style: TextStyle(color: kPrimaryColor, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              multiImageSelector[classId] != null &&
                      multiImageSelector[classId]!.isNotEmpty
                  ? Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: multiImageSelector[classId]?.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Stack(
                                children: [
                                  Image.file(
                                    multiImageSelector[classId]![index],
                                    height: 100.0,
                                    width: 100.0,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: -15,
                                    right: -15,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          multiImageSelector[classId]!
                                              .removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : const Text(
                      'No images selected',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildImage(String assetImage, int index, String text) => Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Image.asset(
              assetImage,
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, bottom: 10),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ],
      );

  Widget buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: assetPaths.length,
        effect: ScrollingDotsEffect(
          dotHeight: 8.h,
          dotWidth: 8.w,
          activeDotColor: activeDotColor, // Color for the active dot
          dotColor: dotColor, // Color for inactive dots
        ),
      );
  void changeCreditCard() {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (formValues['customer_product_type'] != null &&
            pickerStates['customer_product_type'] != null) {
          int index = pickerStates['customer_product_type']!;
          _controller.jumpToPage(index);
        }
      });
    } catch (e) {
      print('Exception in changeCreditCard(): $e');
    }
  }
}
