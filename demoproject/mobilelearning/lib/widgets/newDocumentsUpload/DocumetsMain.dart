import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/widgets/newDocumentsUpload/DocumentUpload.dart';
import 'package:mobile_onboarding/widgets/newDocumentsUpload/DocumentsModel.dart';
import 'package:mobile_onboarding/widgets/newDocumentsUpload/apiService.dart';
// Assume fetchDocuments(...) exists

class DocumentUploadPage extends StatefulWidget {
  final GlobalKey<DocumentUploadWidgetState> docWidgetKey; // <--
  final int productId;
  final String? employmentTypeId;

  const DocumentUploadPage({
    Key? key,
    required this.docWidgetKey, // <--
    required this.productId,
    required this.employmentTypeId,
  }) : super(key: key);

  @override
  State<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  late Future<List<DocumentInfo>> _futureDocuments;
  bool _dialogShowing = false;
  // 1) Create a GlobalKey with the STATE class name

  @override
  void initState() {
    super.initState();
    print("Document emploment ID:${employmentTypeId}");
    _futureDocuments = fetchDocuments(
      productCodeId: widget.productId,
      employmentTypeId: widget.employmentTypeId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentInfo>>(
      future: _futureDocuments,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (!_dialogShowing) {
            // schedule the dialog to show after this frame
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showPleaseWaitDialog();
            });
          }
          // Return an empty container behind the dialog
          return const SizedBox.shrink();
        }

        // 2) If we were showing a dialog, close it now
        if (_dialogShowing) {
          Navigator.of(context, rootNavigator: true).pop();
          _dialogShowing = false;
        }

        if (snapshot.hasError) {
          return Text('No Documents');
        }

        final documents = snapshot.data ?? [];

        return Column(
          children: [
            // 2) Pass the key into the child widget
            DocumentUploadWidget(
              key: widget.docWidgetKey,
              documents: documents,
            ),

            // 3) Some "Next" or "Submit" button:
            // ElevatedButton(
            //   onPressed: _onNextPressed,
            //   child: const Text("Next"),
            // ),
          ],
        );
      },
    );
  }

  // void _onNextPressed() {
  //   // 4) Check if all mandatory docs are uploaded:
  //   final allUploaded =
  //       _docWidgetKey.currentState?.areAllMandatoryDocsUploaded() ?? false;

  //   if (!allUploaded) {
  //     // Show an error and do NOT navigate forward
  //     showDialog(
  //       context: context,
  //       builder: (_) => AlertDialog(
  //         title: const Text('Upload Required'),
  //         content: const Text('Please upload all mandatory documents first.'),
  //         actions: [
  //           TextButton(
  //             child: const Text('OK'),
  //             onPressed: () => Navigator.pop(context),
  //           )
  //         ],
  //       ),
  //     );
  //   } else {
  //     // All mandatory docs are present, proceed
  //     // Navigator.of(context).push(
  //     //   MaterialPageRoute(
  //     //     builder: (ctx) => const SomeNextScreen(),
  //     //   ),
  //     // );
  //   }
  // }
  void _showPleaseWaitDialog() {
    _dialogShowing = true;
    showDialog(
      context: context,
      // barrierDismissible: false, // user cannot dismiss by tapping outside
      barrierColor: Colors.white,
      builder: (context) {
        return WillPopScope(
          // Prevent back-button dismissal
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: Colors.white,
            content: Row(
              children: const [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Please wait...',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
