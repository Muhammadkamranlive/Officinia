import 'dart:convert'; // for base64 decoding
import 'dart:io'; // for writing temporary files
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/screens/pdfViewerScreen/pdfViewerScreen.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';
import 'package:path_provider/path_provider.dart'; // for temporary directory
// No pdfx import needed, as we are using flutter_pdfview

class UnderlinedPdfButton extends StatefulWidget {
  /// The attribute that you want to pass to the API
  final String attribute;
  final String buttonText;

  const UnderlinedPdfButton({
    Key? key,
    required this.attribute,
    this.buttonText = 'View PDF',
  }) : super(key: key);

  @override
  _UnderlinedPdfButtonState createState() => _UnderlinedPdfButtonState();
}

class _UnderlinedPdfButtonState extends State<UnderlinedPdfButton> {
  bool isLoading = false;

  Future<void> _fetchAndShowPdf() async {
    setState(() => isLoading = true);
    try {
      final header = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      // Construct the URL with the attribute
      final url =
          '${getApiBaseUrl()}/DynamicUIUX/GetAgreementDocument?attribute=${widget.attribute}';

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
    if (isLoading) {
      // Show a loading indicator if we are fetching the PDF
      return const Center(child: CircularProgressIndicator());
    }

    // Otherwise, show the underlined text button
    return TextButton(
      onPressed: _fetchAndShowPdf,
      child: Text(
        widget.buttonText,
        style: const TextStyle(
            decoration: TextDecoration.underline, color: newSecondaryColor),
      ),
    );
  }
}
