import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';
import 'package:path_provider/path_provider.dart';

class ProductFAQWidget extends StatefulWidget {
  final String productCode;

  const ProductFAQWidget({required this.productCode});

  @override
  State<ProductFAQWidget> createState() => _ProductFAQWidgetState();
}

class _ProductFAQWidgetState extends State<ProductFAQWidget> {
  bool _loading = false;
  Future<void> _fetchAndOpenPDF(String attribute) async {
    setState(() => _loading = true);

    try {
      final header = await getGenericHeaders();
      final client = await createHttpClientWithPinnedCert();
      final response = await client.get(
          Uri.parse(
              '${getApiBaseUrl()}/DynamicUIUX/GetFAQsDocument?attribute=$attribute'),
          headers: header);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final base64PDF = json['data'];
        final bytes = base64Decode(base64PDF);

        final output = await getTemporaryDirectory();
        final filePath = "${output.path}/${json['fileName']}";
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewerScreen(pdfPath: filePath),
          ),
        );
      } else {
        _showError("Failed to load PDF");
      }
    } catch (e) {
      _showError("Error loading PDF: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _loading
          ? const CircularProgressIndicator()
          : TextButton(
              onPressed: () => _fetchAndOpenPDF('NC'),
              child: const Text(
                "View FAQs",
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Color(0xFF0097A7)), // Use newSecondaryColor here
              ),
            ),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final String pdfPath;

  const PDFViewerScreen({required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // let the PDF go behind the app bar if you want full bleed
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('FAQs PDF'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: PDFView(
          filePath: pdfPath,

          // scale each page to fill both width & height
          fitEachPage: true,
          fitPolicy: FitPolicy.BOTH,

          // optional: swipe settings
          swipeHorizontal: false,
          pageFling: true,
          pageSnap: true,

          // turn off auto spacing so pages butt together
          autoSpacing: false,
        ),
      ),
    );
  }
}
