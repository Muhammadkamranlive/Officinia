import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/utilities/dialog_boxes/dialog_class.dart';
import 'package:mobile_onboarding/utilities/securedData/secureDataHandler.dart';
import 'package:mobile_onboarding/widgets/newDocumentsUpload/DocumentsModel.dart';
import 'package:mobile_onboarding/widgets/newDocumentsUpload/apiService.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

/// Global map for selected files: docId -> [File, File, ...]
Map<int, List<File>> globalDocSelectedFilesMap = {};

/// Global map for uploaded doc IDs: docId -> [uploadId, uploadId, ...]
Map<int, List<int>> globalUploadedDocIdsMap = {};
final ImagePicker _imagePicker = ImagePicker();

class DocumentUploadWidget extends StatefulWidget {
  final List<DocumentInfo> documents;

  const DocumentUploadWidget({Key? key, required this.documents})
      : super(key: key);

  @override
  DocumentUploadWidgetState createState() => DocumentUploadWidgetState();
}

class DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  Map<int, bool> _uploadingMap = {};

  bool areAllMandatoryDocsSelectedAndUploaded() {
    final mandatoryDocs =
        widget.documents.where((doc) => doc.mandetoryFlag == 'Y');

    for (var doc in mandatoryDocs) {
      final selectedFiles = globalDocSelectedFilesMap[doc.documentId];
      if (selectedFiles == null || selectedFiles.isEmpty) {
        return false; // Not selected
      }

      final uploadIds = globalUploadedDocIdsMap[doc.documentId];
      if (uploadIds == null || uploadIds.isEmpty) {
        return false; // Not uploaded
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final mandatoryDocs =
        widget.documents.where((doc) => doc.mandetoryFlag == 'Y').toList();

    if (mandatoryDocs.isEmpty) {
      return const Center(child: Text('No mandatory documents to upload.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var doc in mandatoryDocs) _buildDocumentCard(context, doc),
      ],
    );
  }

  Widget _buildDocumentCard(BuildContext context, DocumentInfo doc) {
    final filesForDoc = globalDocSelectedFilesMap[doc.documentId] ?? [];
    final maxDocs = int.tryParse(doc.noOfDocuments) ?? 0;
    final uploadedIds = globalUploadedDocIdsMap[doc.documentId];

    final bool quotaMet = maxDocs > 0 && filesForDoc.length >= maxDocs;
    final bool alreadyUploaded = (uploadedIds?.isNotEmpty ?? false) && quotaMet;
    final bool hasFiles = filesForDoc.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 250.h,
      child: Card(
        elevation: 0,
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      doc.documentName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: hasFiles ? Colors.grey : newSecondaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline,
                        color: newSecondaryColor),
                    tooltip: 'Document Info',
                    onPressed: () => _showDocInfo(context, doc),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              _buildFilePreviewSection(doc),

              const Spacer(),

              // ── Upload / Uploaded button ──────────────────────────────────
              _uploadingMap[doc.documentId] == true
                  ? const CircularProgressIndicator()
                  : Container(
                      decoration: BoxDecoration(
                        color: ScaffoldBackground,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      width: 140.w,
                      height: 45.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: ScaffoldBackground,
                        ),
                        onPressed: (alreadyUploaded || !hasFiles)
                            ? null
                            : () => _uploadAllFiles(context, doc),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/images/ic_document.png',
                              height: 25,
                              width: 25,
                            ),
                            Text(
                              alreadyUploaded ? 'Uploaded' : 'Upload',
                              style: TextStyle(
                                color: (alreadyUploaded || !hasFiles)
                                    ? Colors.grey
                                    : kPrimaryColor,
                              ),
                            ),
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

  Widget _buildFilePreviewSection(DocumentInfo doc) {
    final files = globalDocSelectedFilesMap[doc.documentId] ?? [];
    final maxDocs = int.tryParse(doc.noOfDocuments) ?? 0;
    final isMaxReached = files.length >= maxDocs;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (files.isEmpty)
          SizedBox(
            height: 50,
            child: Center(
              child: Text(
                'No documents selected yet.',
                style: TextStyle(color: newSecondaryColor),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: files.map((file) {
              final fileExtension = file.path.split('.').last.toLowerCase();
              final isImage =
                  ['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension);

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isImage)
                    Image.file(
                      file,
                      width: 35.w,
                      height: 35.h,
                      fit: BoxFit.cover,
                    )
                  else
                    const Icon(
                      Icons.insert_drive_file,
                      size: 35,
                      color: Colors.grey,
                    ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: descriptionText,
                      size: 25,
                    ),
                    tooltip: 'Delete Document',
                    onPressed: () {
                      setState(() {
                        // 1. Remove the file from the selected files
                        globalDocSelectedFilesMap[doc.documentId]?.remove(file);

                        // 2. If we want to consider "upload" invalid as soon as any file is deleted:
                        //    clear the upload IDs for that doc.
                        //    (So user must re-upload if they still want that doc.)
                        globalUploadedDocIdsMap.remove(doc.documentId);

                        // Alternatively:
                        // globalUploadedDocIdsMap[doc.documentId]?.clear();
                        // but .remove(...) removes the entire key,
                        // ensuring no "uploaded" status remains for that doc.
                      });
                    },
                  ),
                ],
              );
            }).toList(),
          ),

        const SizedBox(width: 10),

        // "Add" icon button
        if (!isMaxReached)
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add another file',
            onPressed: isMaxReached
                ? null // Disable if we've reached noOfDocuments limit
                : () => _pickFile(doc),
          ),
      ],
    );
  }

// keep your other imports…

  Future<void> _pickFile(DocumentInfo doc) async {
    final allowedTypes = doc.parseAllowedTypes(); // e.g. ['jpg','png','pdf']
    final maxSizeInMB = doc.maxSizeAllowed();
    final maxDocs = int.tryParse(doc.noOfDocuments) ?? 0;

    final currentCount = globalDocSelectedFilesMap[doc.documentId]?.length ?? 0;
    if (currentCount >= maxDocs) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Capture from Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _imagePicker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    _handlePickedFile(doc, File(image.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Select from Gallery'),
                onTap: () async {
                  print('pressed');
                  Navigator.pop(context);
                  // 👉 Use FilePicker here to allow images & PDFs (or anything in allowedTypes)
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: allowedTypes,
                    withData: false,
                  );
                  if (result == null) return; // user cancelled
                  final path = result.files.single.path!;
                  final file = File(path);
                  _handlePickedFile(doc, file);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handlePickedFile(DocumentInfo doc, File file) async {
    final allowedTypes = doc.parseAllowedTypes();
    final maxSizeInMB = doc.maxSizeAllowed();
    final fileExtension = file.path.split('.').last.toLowerCase();
    // final fileName = file.path.split('/').last;
    String fileName = p.basename(file.path);
    File fileToUse = file;
    if (fileName.length > 40) {
      final ext = p.extension(file.path); // e.g. .jpg
      final newName = 'doc_${DateTime.now().millisecondsSinceEpoch}$ext';
      final appDir = await getApplicationDocumentsDirectory();
      final newPath = p.join(appDir.path, newName);
      fileToUse = await file.copy(newPath);
      fileName = newName;
      print(fileName.toString());
    }
    if (!allowedTypes.contains(fileExtension)) {
      _showErrorDialog(
        context,
        'Invalid file type. Allowed: ${allowedTypes.join(", ")}',
      );
      return;
    }

    final fileSizeInMB = file.lengthSync() / (1024 * 1024);
    if (fileSizeInMB > maxSizeInMB) {
      _showErrorDialog(
        context,
        'File too large. Max size: $maxSizeInMB MB',
      );
      return;
    }

    setState(() {
      globalDocSelectedFilesMap.putIfAbsent(doc.documentId, () => []);
      globalDocSelectedFilesMap[doc.documentId]!.add(file);
      globalUploadedDocIdsMap.remove(doc.documentId);
    });
  }

  Future<void> _uploadAllFiles(BuildContext context, DocumentInfo doc) async {
    setState(() {
      _uploadingMap[doc.documentId] = true;
    });

    final files = globalDocSelectedFilesMap[doc.documentId] ?? [];
    if (files.isEmpty) {
      setState(() {
        _uploadingMap[doc.documentId] = false;
      });
      return;
    }
    final secureStorage = FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();
    final cnic = await UserSecretStore.getCnic();
    final mobNo = await UserSecretStore.getSignNumber();
    final List<int> uploadIds = await uploadDocuments(
      documentTypeId: doc.documentId,
      cnic: cnic!,
      mobileNo: mobNo!,
      files: files,
    );

    if (uploadIds.isNotEmpty) {
      doc.uploadId = uploadIds;

      ReusableDialogs.showSuccessDialog(context);

      // Replace any old IDs for this doc with the new list
      globalUploadedDocIdsMap[doc.documentId] = List.from(uploadIds);

      debugPrint(
        'Uploaded docId=${doc.documentId}, uploadIds=$uploadIds\n'
        'globalUploadedDocIdsMap=$globalUploadedDocIdsMap',
      );
    } else {
      ReusableDialogs.showErrorDialogDocuments(
        context,
        message: "Failed to Upload Document",
        title: "Failed",
      );
      debugPrint("Upload failed for docId=${doc.documentId}");
    }
    setState(() {
      _uploadingMap[doc.documentId] = false;
    });
  }

  void _showDocInfo(BuildContext context, DocumentInfo doc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Document Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Allowed types: ${doc.documentTypes}'),
            Text('Max size: ${doc.documentSize} MB'),
            Text('Max documents: ${doc.noOfDocuments}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
}
