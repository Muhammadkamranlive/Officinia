import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/screens/newSingUpScreen/components/funtions/message_extractor.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomersRegistration {
  final String phoneNumber;
  final String deviceId;
  final String email;
  final String smsOtp;
  final String emailOtp;
  final String startDate;
  final String endDate;
  final String createdBy;
  final Map<String, dynamic> profilePic;
  final bool isActive;
  final String message;

  CustomersRegistration(
    this.phoneNumber,
    this.deviceId,
    this.email,
    this.smsOtp,
    this.emailOtp,
    this.startDate,
    this.endDate,
    this.createdBy,
    this.profilePic,
    this.isActive,
    this.message,
  );

  Map<String, dynamic> toJson() {
    return {
      "mobilenumber": phoneNumber,
      "deviceid": deviceId,
      "emailid": email,
      "smsotp": smsOtp,
      "emailotp": emailOtp,
      "startdate": startDate,
      "enddate": endDate,
      "createdby": createdBy,
      "profilepic": profilePic,
      "isactive": isActive,
      "message": message,
    };
  }
}

Future<String> registerCustomer({
  required String phoneNumber,
  required String deviceId,
  required String createdBy,
  required String email,
  required String apiBaseUrl,
}) async {
  try {
    final customersRegistration = CustomersRegistration(
      phoneNumber,
      deviceId,
      email,
      "",
      "",
      "2024-02-07T11:07:40.075Z",
      "2024-02-07T11:07:40.075Z",
      createdBy,
      {},
      true,
      "",
    );
    final client = await createHttpClientWithPinnedCert();
    final requestBody = jsonEncode(customersRegistration.toJson());
    print("Request Body: $requestBody");
    final headers = await getGenericHeaders();
    final url = Uri.parse("$apiBaseUrl/Registration/CustomersRegistration");
    final request = http.Request('POST', url)
      ..headers.addAll(headers) // ✅ Apply dynamic headers
      ..body = requestBody;

    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    String responseMessage = extractMessage(response.body.toString());
    print("Response Received: ${response.body.toString()}");
    return responseMessage;
  } catch (e) {
    print("Exception in registerCustomer(): $e");
    return 'exceoption'; // Return 0 for exception cases
  }
}

Future<void> generateOTP(String mobileNumber) async {
  try {
    final client = await createHttpClientWithPinnedCert();
    // Encode the mobile number to handle special characters like '+'
    final encodedMobileNumber = Uri.encodeComponent(mobileNumber);

    final uri = Uri.parse(
        "${getApiBaseUrl()}/Registration/GenerateOTP?mobileNumber=$encodedMobileNumber&reSend=true");

    final response = await client.get(uri);

    print("Complete API URL: $uri");
    print("Response received in generateOTP(): ${response.body}");

    if (response.statusCode == 200) {
      print("OTP generated successfully.");
    } else {
      print("Failed to generate OTP. Status Code: ${response.statusCode}");
    }
  } catch (e) {
    print("Exception in generateOTP(): $e");
  }
}

String deviceId = "";
Future<void> _getDeviceId() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    deviceId = prefs.getString("device_id")!;
    print("Device ID: $deviceId");
  } catch (e) {
    print("Exception in getDeviceId(): $e");
  }
}
