import 'dart:convert';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/screens/pdfViewerScreen/pdfViewerScreen.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';
import 'package:path_provider/path_provider.dart';

class HyperlinkedCheckbox extends StatefulWidget {
  final ValueChanged<bool> onChanged;
  final bool initialValue;

  const HyperlinkedCheckbox({
    Key? key,
    required this.onChanged,
    this.initialValue = false,
  }) : super(key: key);

  @override
  _HyperlinkedCheckboxState createState() => _HyperlinkedCheckboxState();
}

class _HyperlinkedCheckboxState extends State<HyperlinkedCheckbox> {
  late bool _isChecked;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialValue;

    // Disable next button by default when widget first draws
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged(false);
    });
  }

  void _handleCheckboxChanged(bool? value) {
    setState(() {
      _isChecked = value ?? false;
    });
    // If user checks the box, we pass `true` – enabling next
    // If user unchecks, we pass `false` – disabling next
    widget.onChanged(_isChecked);
  }

  Future<void> _fetchAndShowPdf(String atrribute) async {
    setState(() => isLoading = true);
    try {
      final header = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      // Construct the URL with the attribute
      final url =
          '${getApiBaseUrl()}/DynamicUIUX/GetAgreementDocument?attribute=$atrribute';

      final response = await client.get(Uri.parse(url), headers: header);

      // Check status code
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        // Basic validation: must have a "data" key
        if (decodedResponse == null ||
            !decodedResponse.containsKey('data') ||
            decodedResponse['data'] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No PDF data found in response.')),
          );
          return;
        }

        // Extract optional fileName
        final fileName = decodedResponse['fileName'] ?? 'Unknown.pdf';

        // Decode base64 PDF data
        final base64Data = decodedResponse['data'] as String;
        final pdfBytes = base64.decode(base64Data);

        // Write bytes to a temp file so flutter_pdfview can read it
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(pdfBytes);

        // Navigate to a new screen to display the PDF
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfViewerScreen(pdfPath: filePath),
          ),
        );
      } else {
        // Non-200 status code
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('HTTP error: ${response.statusCode}')),
        );
      }
    } catch (error) {
      debugPrint('Error fetching PDF: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while fetching the PDF.'),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: newConsentBoxBackground,
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              isLoading
                  ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Checkbox(
                      activeColor: newSecondaryColor,
                      value: _isChecked,
                      onChanged: _handleCheckboxChanged,
                    ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Musawamah Agreement, ',
                        style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: newSecondaryColor),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _fetchAndShowPdf("MA");
                            debugPrint('Terms & Conditions tapped');
                            // Show T&C or navigate
                          },
                      ),
                      TextSpan(
                        text: 'Key fact sheet, ',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: newSecondaryColor,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _fetchAndShowPdf("KF");

                            // Show T&C or navigate
                          },
                      ),
                      TextSpan(
                        text: 'Zakat Declaration',
                        style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: newSecondaryColor),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _fetchAndShowPdf("ZD");

                            // Show T&C or navigate
                          },
                      ),
                      const TextSpan(text: ' & '),
                      TextSpan(
                        text: 'Terms and conditions',
                        style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: newSecondaryColor),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _fetchAndShowPdf("NC");
                            debugPrint('Privacy Policy tapped');
                            // Show Privacy Policy or navigate
                          },
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
