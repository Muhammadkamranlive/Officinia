import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_onboarding/widgets/newDocumentsUpload/DocumentUpload.dart';
import 'package:mobile_onboarding/widgets/newDocumentsUpload/DocumentsModel.dart';

const String kAndroidPackageName = 'com.AutoSoft.FBLCdob';
const String? kIosAppStoreUrl = null;
const int kExpectedBuildNo = 1;
const String kExpectedVersion = '1.0';
String formatWithCommas(String value) {
  if (value.isEmpty) return '';
  final number = int.tryParse(value.replaceAll(',', ''));
  if (number == null) return value;
  return number.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
}

late Future<List<DocumentInfo>> _futureDocuments1;
bool docIsLoading = false;
const kPrimaryColor = Color(0xFF27316E);
// ignore: constant_identifier_names
const ScaffoldBackground = Color(0xffF5F5F5);
const disclaimerBG = Color(0xffDDE4E4);
const newSecondaryColor = Color(0xFF29ACAD);
List<int> globalUploadedDocIds = [];
const kPrimaryLightColor = Color(0xFF007078);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF007078), Color(0xFF2C296F)],
);
const RadialGradient radialGradient = RadialGradient(
  center: Alignment(0.0, -0.1), // Adjusted based on "Top: -32.48px"
  radius: 0.5, // Matches the desired gradient size
  colors: <Color>[
    Color(0xFF1EBCBE),
    Color(0xFF14838C), // First color
    // Second color
  ],
  stops: <double>[0.0, 1.0], // Start and end of the gradient (normalized)
);

const kDividerColor = Color(0xFFD3D3D3);
const kSecondaryColor = Color(0xFF979797);
const kTextColor = Color(0xFF757575);
const kBackgroundColor = Color(0xFFF1EFF1);
const newConsentBoxBackground = Color(0xFFe1ebec);
const kHeadingWhiteColor = Color(0xFFFFFFFF);
const kHeadingColor = Color(0xFF27316E);
const kLabelColor = Color(0xFF007078);
const kErrorColor = Color(0xFFFF0000);

const activeDotColor = Color(0xFF1a8e9d);
const dotColor = Color(0xFFa4cdd2);
const kTileColorOne = Color(0xFF007078);
const kTileColorTwo = Color(0xFF076477);
const kTileColorThree = Color(0xFF0F5875);
const kTileColorFour = Color(0xFF164D74);
const kTileColorFive = Color(0xFF1D4172);
const kTileColorSix = Color(0xFF253571);
const descriptionText = Color(0xFF3E4246);

const kDisclaimerBG = Color(0xFFFCF8CD);
const kDisclaimerText = Color(0xFFD48E24);

final List colors = [
  const Color(0xffB85252),
  const Color(0xffB4C6A6),
  const Color(0xffF4ABC4),
  const Color(0xff346751),
  const Color(0xffFFC947),
  const Color(0xff3282B8),
];
void clearAllDocs() {
  globalDocSelectedFilesMap.clear();
  globalUploadedDocIdsMap.clear();
}

class CNICInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove any non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Apply the CNIC pattern: #####-#######-#
    StringBuffer formatted = StringBuffer();

    for (int i = 0; i < digitsOnly.length; i++) {
      // Insert dash after the 5th digit and after the 12th digit
      if (i == 5 || i == 12) {
        formatted.write('-');
      }
      formatted.write(digitsOnly[i]);
    }

    // Limit total length to 15 characters: 13 digits + 2 dashes
    String finalText = formatted.toString();
    if (finalText.length > 15) {
      finalText = finalText.substring(0, 15);
    }

    return TextEditingValue(
      text: finalText,
      selection: TextSelection.collapsed(offset: finalText.length),
    );
  }
}

int cnicToRequestId(String rawCnic) {
  // strips every non-digit character, then converts to int
  final digits = rawCnic.replaceAll(RegExp(r'\D'), '');
  return int.parse(digits);
}

List<TextInputFormatter> getTextInputFormatters(
  String keyboardType,
  String classId,
) {
  if (classId == 'reference_mobile_1' || classId == 'reference_mobile_2') {
    return [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(11),
      TextInputFormatter.withFunction((oldValue, newValue) {
        final text = newValue.text;
        // Allow:
        //  • empty string (so user can clear)
        //  • "0" (first keystroke)
        //  • any string starting "03" plus up to 9 more digits (max 11 total)
        if (text.isEmpty ||
            text == '0' ||
            RegExp(r'^03\d{0,9}$').hasMatch(text)) {
          return newValue;
        }
        return oldValue;
      }),
    ];
  } else if (classId == 'telephone_number' || classId == 'office_number') {
    return [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(11),
    ];
  } else if (classId == 'reference_cnic_1' || classId == 'reference_cnic_2') {
    return [CNICInputFormatter()];
  } else if (classId == "full_name" ||
      classId == "father_name" ||
      classId == "mother_name" ||
      classId == "reference_name_2" ||
      classId == "reference_name_1") {
    return [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))];
  } else if (classId == 'card_name') {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
      FilteringTextInputFormatter.deny(RegExp(r'^\s+')),
      LengthLimitingTextInputFormatter(18),
    ];
  } else if (keyboardType == "number") {
    return [FilteringTextInputFormatter.digitsOnly];
  } else {
    return [LengthLimitingTextInputFormatter(265)];
  }
}

//Non mandatory fields
const List<String> noValidationClassIds = [
  'number_of_dependents',
  'own_car',
  'Country of Birth',
  'Auto Debit Account',
  'Telephone Number (Residence)',
  'Other Source of Income',
  'Other Income',
];
const kAnimationDuration = Duration(milliseconds: 200);

const double headingSize = 26;
String journeyType = "";
const double subHeadingSize = 18;
const double pagesubHeadingSize = 22;
const double titleHeadingSize = 18;
const double labelSize = 14;
const double labelSize12 = 10;
const double smallLabelSize = 13;
const double textInputSize = 16;
const double buttonSize = 16;
Map<String, dynamic>? C360data;
String? employmentTypeId = '';
const kDefaultPadding = 10.0;
const companyType = 1;
int productType = 0;

String product_attributes = "";
// icons_list.dart
String productInstructionsJsonString = '';
final List<IconData> noorCardJourneyIconsList = [
  // Icons.work,
  // Icons.credit_card,
  // Icons.person,
  // Icons.camera_alt,
  // Icons.home,
  // Icons.description,
  // Icons.check_circle,
  // Icons.help_outline,
  // Add more icons as needed
];

final List<IconData> accountOpeningJourneyIconsList = [
  Icons.person_2_outlined,
  Icons.living_outlined,
  Icons.work_outline_outlined,
  Icons.person_add_alt_rounded,
  Icons.document_scanner,
  Icons.verified_user_outlined,

  // Add more icons as needed
];
const headingHomeStyle = TextStyle(
  color: kHeadingWhiteColor,
  fontSize: headingSize,
  fontWeight: FontWeight.normal,
  height: 1.5,
);
const journeyStepsStyle = TextStyle(
  color: Colors.white,
  fontSize: 15,
  fontWeight: FontWeight.normal,
);

late int otptimer = 0;
const TextStyle circularbookParagraph18 = TextStyle(
  fontFamily: 'Circular',
  fontSize: 18,
  fontWeight: FontWeight.w500,
  color: newSecondaryColor,
);
const TextStyle circularboldHeadingFAQs23 = TextStyle(
  fontFamily: 'Circular',
  fontSize: 23,
  fontWeight: FontWeight.w700,
  color: newSecondaryColor,
);
const TextStyle circularFAQsQuestions18 = TextStyle(
  fontFamily: 'Circular',
  fontSize: 18,
  fontWeight: FontWeight.w400,
  color: newSecondaryColor,
);
TextStyle circularboldHeading23 = TextStyle(
  fontFamily: 'Circular',
  fontSize: 30.sp,
  fontWeight: FontWeight.w700,
  color: kPrimaryColor,
);
const TextStyle circularboldHeading24 = TextStyle(
  fontFamily: 'Circular',
  fontSize: 30,
  fontWeight: FontWeight.w700,
  color: Colors.white,
);

const TextStyle circularboldButtonTitle20 = TextStyle(
  fontFamily: 'Circular',
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: Colors.white,
);
TextStyle circularAppBarheading18 = TextStyle(
  fontFamily: 'Circular',
  fontSize: 20,
  fontWeight: FontWeight.w500,
  color: Colors.grey.shade600,
);
TextStyle circularProductDetailheading22 = TextStyle(
  fontFamily: 'Circular',
  fontSize: 22,
  fontWeight: FontWeight.w700,
  color: Colors.grey.shade600,
);
TextStyle circularProductDetailSubheading22 = TextStyle(
  fontFamily: 'Circular',
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: Colors.grey.shade600,
);

TextStyle circularboldButtonapplyTitle18 = TextStyle(
  fontFamily: 'Circular',
  fontSize: 18.sp,
  fontWeight: FontWeight.w500,
  color: Colors.white,
);
const TextStyle circularMedium23 = TextStyle(
  fontFamily: 'Circular',
  fontSize: 23,
  fontWeight: FontWeight.w500,
  color: kPrimaryColor,
);
TextStyle circularbook14 = TextStyle(
  fontFamily: 'Circular',
  fontSize: 14.sp,
  fontWeight: FontWeight.w300,
  color: Colors.grey.shade600,
);
TextStyle circularbookOtpWhite14 = TextStyle(
  fontFamily: 'Circular',
  fontSize: 16.sp,
  fontWeight: FontWeight.w500,
  color: Colors.white,
);
TextStyle circularbookOtpPhEmail = const TextStyle(
  fontFamily: 'Circular',
  fontSize: 16,
  fontWeight: FontWeight.w300,
  color: Color(0xFF67F3FF),
);
// ignore: constant_identifier_names
const TextStyle PoppinRegular16 = TextStyle(
  fontFamily: 'poppins',
  fontSize: 18,
  fontWeight: FontWeight.w500,
  color: newSecondaryColor,
);
TextStyle PoppinRegular14 = TextStyle(
  fontFamily: 'poppins',
  fontSize: 14.sp,
  fontWeight: FontWeight.w300,
  color: Colors.grey.shade600,
);
const TextStyle PoppinRegular12 = TextStyle(
  fontFamily: 'poppins',
  fontSize: 12,
  fontWeight: FontWeight.w300,
);
const headingStyle = TextStyle(
  // color: Color(0xFF67F3FF),
  color: Colors.white,
  fontSize: headingSize,
  fontWeight: FontWeight.bold,
  height: 1.5,
  fontFamily: 'Circular',
);
const DynamicsFormHeadingStyle = TextStyle(
  color: kPrimaryColor,
  fontSize: headingSize,
  fontWeight: FontWeight.bold,
  height: 1.5,
);
const subHeading = TextStyle(
  color: kPrimaryColor,
  fontSize: pagesubHeadingSize,
  fontWeight: FontWeight.bold,
  height: 1.5,
);

const headingStyleNew = TextStyle(
  color: kHeadingColor,
  fontSize: 20,
  fontWeight: FontWeight.bold,
  height: 1.2,
);

const smallLabelStyle = TextStyle(color: kLabelColor, fontSize: smallLabelSize);

const requestLabelLeftStyle = TextStyle(
  color: kSecondaryColor,
  fontSize: 16,
  fontFamily: 'Circular',
);

const requestLabelRightStyle = TextStyle(
  color: newSecondaryColor,
  fontSize: 16,
  fontFamily: 'Circular',
);

const labelStyle = TextStyle(color: descriptionText, fontSize: labelSize);
const labelStyleforauthentication = TextStyle(
  color: Colors.white,
  fontSize: labelSize,
);

const learnMoreStyle = TextStyle(
  color: kPrimaryColor,
  fontWeight: FontWeight.bold,
  decoration: TextDecoration.underline,
  fontSize: labelSize,
);

const labelWhiteStyle = TextStyle(color: Colors.white, fontSize: labelSize12);

const headingWhiteStyle = TextStyle(
  color: kHeadingColor,
  fontSize: subHeadingSize,
  fontWeight: FontWeight.bold,
  height: 1,
);

const appBarTitleStyle = TextStyle(
  color: kHeadingColor,
  fontSize: titleHeadingSize,
  fontWeight: FontWeight.w600,
  height: 1,
);

// Form Error
final RegExp emailValidatorRegExp = RegExp(
  r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
);
const String kEmailNullError = "Please enter your email";
const String kInvalidEmailError = "Please enter Valid Email";
const String kPassNullError = "Please Enter your password";
const String kShortPassError = "Password is too short";
const String kMatchPassError = "Passwords don't match";
const String kNameNullError = "Please enter your name";
const String kPhoneNumberNullError = "Please enter your phone number";
const String kPhoneLengthError = "Please enter 11 digit phone number";
const String kAddressNullError = "Please enter your address";
const String kPhoneOTPNullError = "Please enter valid Mobile OTP code";
const String kEmailOTPNullError = "Please enter valid Email OTP code";

const String biometricLogin = "bio_metric_login";

TextStyle cardHeading = TextStyle(
  color: kHeadingColor,
  fontSize: 15.sp,
  fontWeight: FontWeight.bold,
);

const disableCardHeading = TextStyle(
  color: Colors.grey,
  fontSize: 15,
  fontWeight: FontWeight.w400,
);

TextStyle cardSubHeadingStyle = TextStyle(
  color: Colors.grey,
  fontSize: 14.sp,
  fontWeight: FontWeight.w400,
);

final otpInputDecoration = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(vertical: 15),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: kPrimaryColor),
  );
}

const cardCountStyle = TextStyle(
  color: Color.fromARGB(255, 225, 153, 238),
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

String getCompanyLogo() {
  String companyLogo = "";
  if (companyType == 1) {
    companyLogo = "assets/images/faisal_bank_banner.png";
  } else {}

  return companyLogo;
}

AppBar buildAppBar(BuildContext context, String title) {
  return AppBar(
    title: Text(title, style: appBarTitleStyle),
    toolbarHeight: 56,
    centerTitle: false,
    // for back navigation we use this
    automaticallyImplyLeading: true,
    elevation: 4,
    backgroundColor: Colors.white,
    shape: const Border(bottom: BorderSide(color: kPrimaryLightColor)),
  );
}

TextInputType getKeyboardType(String type) {
  if (type.toLowerCase() == 'text') {
    return TextInputType.text;
  } else {
    return TextInputType.number;
  }
}

const kDefaultShadow = BoxShadow(
  offset: Offset(0, 15),
  blurRadius: 5,
  color: Colors.black12, // Black color with 12% opacity
);

String getApiBaseUrl() {
  // return "http://110.36.222.125:100/Services";
  // return "http://110.36.222.125:1000/Services";
  // return "http://202.142.179.170:1000/Services";
  // return "http://10.42.3.149:4000/Services";  QA new Machine local
  // return "http://110.36.222.125:4000/Services"; //QA new Machine public
  //return "https://fbldigilending.faysalbank.com/Services"; //production fbl
  // return "https://cobdd.faysalbank.com/Services"; //New UAT
  // return "https://cboduat.faysalbank.com/Services"; //FBL environment
  // return "http://10.42.2.102:1000/Services";
  return "https://localhost:30545/Services";
  // return "http://10.12.12.113:90/Services";
  // return "http://10.11.11.205:100/Services";
  // return "http://110.36.222.125:90/Services"; /*QA PUBLIC IP*/
}

String getParameterApiBaseUrl() {
  // return "http://10.11.11.205:7215/Services";
  // return "http://110.36.222.125:100/Services";
  return "http://110.36.222.125:90/Services"; /*QA PUBLIC IP*/
}

// final result = {
//   "data": {
//     "rightindex": {
//       "date": "2025-01-21T18:13:28.030 +0500",
//       "captureTimeTaken": 6118,
//       "overallTimeTaken": 7390,
//       "processingTimeTaken": 1853,
//       "hand": "right",
//       "finger": "index",
//       "identy_quality": 77,
//       "fingerprintQuality": 77,
//       "height": 421,
//       "width": 356,
//       "bits_per_pixel": 8,
//       "resolution": "356x421x1",
//       "nfiq_1": 1,
//       "spoof_score": 0.9571171998977661,
//       "templates": {
//         "ISO_19794_2": {
//           "DEFAULT": "Rk1SACAyMAAAAAHmAAABZAGlAMUAxQEAAgBNTIBhAPWrY4BXAROlXkCOAW5rXUCCAMOtXEDHAUdA\nW0BcAXd1W4DbAHrxWkEEAT03WUCIAKamWECJATBGVYCmADmSVIDFAEf7U4D4AOjAUkBnAVF3UoCO\nAVFiUkCZAMuuUoEdAUM5UoEaAG/hUUEVANjHUUDXATU9T0EEAWkmT4C8AHWVToDiAOS9ToDSATtA\nTYC+AUFHTUCKAQy7TEDeAO27S0D+ACp1SkDBAHWUSoDKAFaLSUEdAWkoSYCDAYV9SYDnAU6oSIET\nAR+5R4EZAQ9AR0DSAFd9RoDRAPQ8RUDLAMW1RYDEAVtzRUDtAWkmQ0DxAUc1QkDKAX4HQkDMAJkB\nQYCmAWNrQUDeAMbGQIDSAJ6LPoDhAVsfPoCvAFQJPoCpAYmFPIBKATYkPEDEAKSlO4DgANfFO4Db\nAVsrO4BEAS2fOkC8AEuHOUC3AUdQOIBhASnFOEAvAToGOIBYAUZ9OED5ACJ0N0A2ASCvN4BIATwG\nN0DaAMupNQBVAT0GNQDKAKahMwDHAWcJMgA3ATofMADQANg7MADKAL2vLgDSAMU4LgAwASEgLgDL\nALHoLQBVATosLAFBAVE5LAC/AFQAKwDYAN07KwAA\n"
//         }
//       }
//     },
//     "rightlittle": {
//       "date": "2025-01-21T18:13:28.030 +0500",
//       "captureTimeTaken": 6118,
//       "overallTimeTaken": 7390,
//       "processingTimeTaken": 1853,
//       "hand": "right",
//       "finger": "little",
//       "identy_quality": 93,
//       "fingerprintQuality": 93,
//       "height": 411,
//       "width": 301,
//       "bits_per_pixel": 8,
//       "resolution": "301x411x1",
//       "nfiq_1": 1,
//       "spoof_score": 0.9571171998977661,
//       "templates": {
//         "ISO_19794_2": {
//           "DEFAULT": "Rk1SACAyMAAAAAGAAAABLQGbAMUAxQEABQBdO4CtAMDFZID7AU5gYkBTAHawYEB6AHi1YEA6AGCr\nX4BGAOiyX4CSAVZpX0CPAE6pXYB9AKa5XUBbALCyXYDrAWFnXIC5AFOaXIEBATZVW0CIADkUW0Dd\nAL3JWkBgAPi7WoCvAD8OWYBpAT1OWIDRAWFiV4DaAU5RV4BRAEIhVkBTAJ8yVIAwAPmlVICfAW9p\nVEDbAHaPUkBQAVSAUkA0ATojUICrAUFHUEBRARyrT4B+AUBQT4DFAQzJToDoARrTTYDbALLDTYAp\nAVsDTIBiAUp5S0AwANEuS0COAUNOSoCrAV5gSEEUASxTSIBBAUf3R4DRAIGjRUDrALDLRUC2AV1X\nRUC3AHWqRYCVAHIlRIEPAWJrQYDFAJC5OkDsAJfWOUBLATsJN0DSAJa1N4DNAJO1NgDWAFYBMwDW\nAIr6LgDdAJ7HLQEYAR/ZLQEMANnULADoAJ7VKgDrAKbQKgCvAHURKQAA\n"
//         }
//       }
//     },
//     "leftring": {
//       "date": "2025-01-21T18:13:17.431 +0500",
//       "captureTimeTaken": 5887,
//       "overallTimeTaken": 7016,
//       "processingTimeTaken": 1904,
//       "hand": "left",
//       "finger": "ring",
//       "identy_quality": 78,
//       "fingerprintQuality": 78,
//       "height": 466,
//       "width": 316,
//       "bits_per_pixel": 8,
//       "resolution": "316x466x1",
//       "nfiq_1": 1,
//       "spoof_score": 1,
//       "templates": {
//         "ISO_19794_2": {
//           "DEFAULT": "Rk1SACAyMAAAAAHmAAABPAHSAMUAxQEACQBOTEBWARY3X4BLATZDW4DBAOq7WoDAAQu3WkA8AVhJ\nWoBRAOwxWYA3AX1pWYCCASezWICZASqzWEC5AYUuV0DQAN5DVkBjASo1VoBbATY5U0BxAYUUU4C6\nAZwdU4DNAZgkUoDyAZkkUYEHARm9UICxAJXhT4CjAUi1ToEaAOdATkCeAMm9TYEiAZgWTYDQAKzH\nTEEJAZYqTIEfAU25S0CKANe3S0B6ATUtS4DeAZ4gS4EEAVE9SkAjAX5vSkApAYNuSoClASM3SYBo\nAVcrSYCqAZUfSICwAHWDSEB2AUKrR4CEAKIQR4CMAMuyR4AyAPrAR0BPAYRtR4EVAZgmRUCXAGQD\nRYB9AUiqRUCZAKTpREAyAQK9RECeAYktRIDKAHZuRIBYAVEpQoBPAWlRQkA7AWpYQkBXAYQLQoDX\nAIZsQUCqASk3QUAaAWpeQUCqAL3DQEBcALatP4BjAW0jP0BcAX9uP4DUAH1pPkCMAI8LPkCDAJec\nPoBYAXtpPoCVAZAgPkCdAH8APkCpAEv3PYCwAEH1PEDMAO67PEBhAVgrPIC2AUE7O4C2ATC5O0Cb\nAXkzO0CkAHr3OUB6AJGqOUCYAFaCOUCdAFSCOAAA\n"
//         }
//       }
//     },
//     "rightring": {
//       "date": "2025-01-21T18:13:28.030 +0500",
//       "captureTimeTaken": 6118,
//       "overallTimeTaken": 7390,
//       "processingTimeTaken": 1853,
//       "hand": "right",
//       "finger": "ring",
//       "identy_quality": 91,
//       "fingerprintQuality": 91,
//       "height": 464,
//       "width": 325,
//       "bits_per_pixel": 8,
//       "resolution": "325x464x1",
//       "nfiq_1": 1,
//       "spoof_score": 0.9571171998977661,
//       "templates": {
//         "ISO_19794_2": {
//           "DEFAULT": "Rk1SACAyMAAAAAHmAAABRQHQAMUAxQEABABbTEClAN9AZEBtATXHY4DKAYt1YUDnATrNYID+AYh7\nYIDaAXRVXkBiASCzXoDBAWhLXkBgAUCzXYBgAVDLXUB+AW9QXICVAOfDXEBlAPS7W4B/AX53WoDl\nALLAWUCOAUBHWUA6AMG3WYClAZZ7WYCMAFeuV4AwAXmfVUCDAZx9VYDeAWdNU4DLAXhhUkDLAJO3\nUUETATZNUYCVAX9pUUDbAY9wUECbAXJQUEBbAGi1T0A1AYIhToBuAXiDToCDADWkTEEgAYUCS4DN\nAG6jSoBXAV6oSoByAG8uSkC2AXlYSUDiAZKASUAgAYkgSEBIAMM5R0DtAW1QR0DhAHCFR0EOAOLN\nR4DMAF2dRkD7AQvNRkD4AMPJRUBCAN05RYCgAXhkRYCvAJu7RUEZAQxLREDhAJ61RIDWAGgGQUDF\nAPzHQYDrAGMAPkDSAFqTPYBIAYIDPYBlAW5JPIDtAHV0O0EaAOpOO0DeAIlAO0DtAIHkOAEdAV2H\nNQDdAJdDNAEgAP9FNAEaAQBLNAC/AHuzMwEMAKRjMwDKAH61MgDoAI7mMgEFAMnFMQEuAVMsMQEP\nAMnOMADSAG4DLwENALFfLQEMALfGLQEPAM7NLQAA\n"
//         }
//       }
//     },
//     "leftlittle": {
//       "date": "2025-01-21T18:13:17.431 +0500",
//       "captureTimeTaken": 5887,
//       "overallTimeTaken": 7016,
//       "processingTimeTaken": 1904,
//       "hand": "left",
//       "finger": "little",
//       "identy_quality": 84,
//       "fingerprintQuality": 84,
//       "height": 419,
//       "width": 301,
//       "bits_per_pixel": 8,
//       "resolution": "301x419x1",
//       "nfiq_1": 1,
//       "spoof_score": 1,
//       "templates": {
//         "ISO_19794_2": {
//           "DEFAULT": "Rk1SACAyMAAAAAHmAAABLQGjAMUAxQEACgBUTIDBAQ67XIAqARwuWECTAUoyV4CdAVwkV4DuAIla\nVoCEAJnvVoDiAQ/FVYBWAVwjVYCvARu7VEDEAWMVU4D+AMXNUkEBARPPUoB4AWcfUYA8ATUoUIBo\nAUGgT0A/AUodT4A2ATcmToBhASkxTkBiAG8VTYDWAHvYTYC2AVQhTUBnAUifTIBrAMO3TIBoAWkf\nTICrAHh9SkC+AO+uSYC/AX8NSUCkAX8LSECrAJ/LSICQAMm9SIBYAIUaR0CtARa3R4C3ATwyR0BL\nAJOpRoAyANmyRUEPAJDVRICwAXQLRIC5AP+5Q0DdAYOSQ0CgAKDQQkDhAUo0QkC+ARS8QUDoAX0J\nQUBcAKUiQEDGAOG7QEC2APMwQIDMATuhP4CtAI9wPkBPAX4JPkBuAG8JPkB+AKyaPoCXAYILPoC6\nARtAPYC8ASk1PEBuAFcJPEBVAHWnPIDNARu1PEC3AH3gO0BlARU1O4DHARvDO0DAAUGpO0B3AMC3\nOoB+AMa3OkDEASy7OkEUAUGIOoBjAF4VOkCwAP8oOYCJAYMXOYDNAUY5OYCgAJvRN4CeAH3sN4Cx\nAX+NN4BLAKarNoBIAIaoNUC+ATKrNYCfAYUNNQAA\n"
//         }
//       }
//     },
//     "leftindex": {
//       "date": "2025-01-21T18:13:17.431 +0500",
//       "captureTimeTaken": 5887,
//       "overallTimeTaken": 7016,
//       "processingTimeTaken": 1904,
//       "hand": "left",
//       "finger": "index",
//       "identy_quality": 67,
//       "fingerprintQuality": 67,
//       "height": 449,
//       "width": 334,
//       "bits_per_pixel": 8,
//       "resolution": "334x449x1",
//       "nfiq_1": 2,
//       "spoof_score": 1,
//       "templates": {
//         "ISO_19794_2": {
//           "DEFAULT": "Rk1SACAyMAAAAAHmAAABTgHBAMUAxQEABwBDTIDLAQlDYoCbAO29YUDSAOzAX4BbAWpQX0DLATJA\nXkAvAQm5XYDaAVajV4BxAXRTV0BKAKiyV4ENATrFVUEZAVjdVYAwAXVmVYCwARNDU0BGAW9RU4CZ\nAX9bU4CMAO01UoD7AP/FUkAsAJWpUIAuAJmqUECJAYhmUEBBAP67UICtAOjDT0EBAR/DT0BhAXtk\nTUETAVDATUC5AUhJS0DGAUZHS4BdANu5SYCpASnJSUDrAYUdSIB8AZNySIC6AYJ0SIDHAWEpR0EF\nAXgwR0CYAN21RoAoAWJLRkCCAYJmRoC0AZb5RkCtAMfXRUESARTPRYCrAXvsRICrAW1aQ4DnAZkH\nQ4CYAMu0Q4CpANHTQoAaAPKyQEEoAWpVQIClAXX3QEB4AP45PoA8AQC9PoCEAP7FPUDHAX4XPEEB\nAYIOPIDAAXUZO4DLAKzlOUCeAVzTOYC5AWJXOUCOAWhOOUC+AW8YOYCEAPM5OIEfAXmOOEC+ALTW\nNgCXAXJWNQCZAV5LMwCeANGzMAEaAWrLMACMAPkzLwC+AJv4LgCjANfJLgDEALZ1LQC5AaAALACe\nAH8PLACTAHAbKwEvAVdSKwB9AGSdKgDsAaAMKgAA\n"
//         }
//       }
//     },
//     "leftmiddle": {
//       "date": "2025-01-21T18:13:17.431 +0500",
//       "captureTimeTaken": 5887,
//       "overallTimeTaken": 7016,
//       "processingTimeTaken": 1904,
//       "hand": "left",
//       "finger": "middle",
//       "identy_quality": 73,
//       "fingerprintQuality": 73,
//       "height": 463,
//       "width": 365,
//       "bits_per_pixel": 8,
//       "resolution": "365x463x1",
//       "nfiq_1": 1,
//       "spoof_score": 1,
//       "templates": {
//         "ISO_19794_2": {
//           "DEFAULT": "Rk1SACAyMAAAAAHUAAABbQHPAMUAxQEACABJSUD+AUNDZEDGAOW9ZEClAN27YYCSAPo9XkEfAMbL\nXUE6AQDLXYEvAOTLXUDlAS/AW0CzAQi1WoDRAUKzWkC8AVGjWYByALIxWIDoAYoqWICIATJLVkB8\nAHirVUDzAQbFVIEgAZIdVEEOAPTJU0BuASnLUoEHATvAUoAvAUHLUoDSAZMgUoBbAXJZUYA/AXtT\nT0AvAX1YTkCMAYt1ToEEAZKQTUDMAX4rTICxAXEpS4BiAXJlS0EYAXU9SoDMARu7SYCKAUhQSYAh\nAX5nSUCgAH4cSECPASNJSECbARw3R0DmAJfJR4BiAYltR0D5AZMXR0CgATUtRoCPAWhkRYBjAZb7\nRUD/AYorRICMAH2pRECfALwYQ0B9AW9hQ4C8AZUSQ4DbAZaJQoDSAI9WQYDLANlHQYCTALAkQIFD\nAX07QECJAVZVP0CTAU5FPkBxAVbgPkDLALLLPkCqAMy9PkDaAJ5RPYDLALjHPUBnAYRoPEBrAZh1\nPIBjAazwPEC6AZkHO4DlAZ4gO0C6AaAHO0CgAW4kOoB3AYtrOkC6AIndOYCXAFyfOEClAT0rOICe\nAUswOEByAVzjNwAA\n"
//         }
//       }
//     },
//     "rightmiddle": {
//       "date": "2025-01-21T18:13:28.030 +0500",
//       "captureTimeTaken": 6118,
//       "overallTimeTaken": 7390,
//       "processingTimeTaken": 1853,
//       "hand": "right",
//       "finger": "middle",
//       "identy_quality": 92,
//       "fingerprintQuality": 92,
//       "height": 456,
//       "width": 365,
//       "bits_per_pixel": 8,
//       "resolution": "365x456x1",
//       "nfiq_1": 1,
//       "spoof_score": 0.9571171998977661,
//       "templates": {
//         "ISO_19794_2": {
//           "DEFAULT": "Rk1SACAyMAAAAAHUAAABbQHIAMUAxQEAAwBcSYCdAVhFZEEtAPpHZECJARm5Y0FBARVFYkCGALC1\nYYCbAXRVYIBlARqyYICwAXhQX0EcAI5dXoBBARSsXkBWAUepXYDAARPHXUE1ATdSXYDiAH6SXEC/\nAU3LXEB2AO25XED3AV5TWkCDAXRRWoENAHDiWoB/AZ93WYCKAGokV0DXAWdQV0CwAC2SV4DoAPPJ\nVUCkAQK9VYD7AX5rVYBpAXRRVIBiAYOAU4DRAY5jU0CzAGSlU0CSAZBpU0E6AI7VUkBKAWkqUkCq\nAUdDUIBXAGqwUEC/ARnDUEBbAV2jT4DNAI8MT4AlAUgkT0DWATXLTkDAAZJkToEzAJ/LTkBrALC1\nTkEJANJPToEIANlNSkFKASxDSkFKAUFQSYAuAYsQSUCqAaBwSEElAUZYSIDBAImsR0BNAFynRYDX\nAMC5RUDaAMa7Q4DrAIOMQkDdANLFQoFDAVSDQoEqAUtmQUDxAMXJQYE2AUNkQUE/AKXNPoCqAPI9\nPoDmAZxzPYDMAM0uO4BCAYsDO4E1AIRcO0DdALa5OYFKATZMOUA8AHUoOYDxAL7QOQDmALrLMwDe\nAKSoMgDlALG3MgAA\n"
//         }
//       }
//     }
//   }
// };
// final Map<String, dynamic> fingerMap = jsonDecode(result);
