// document_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;

import 'package:http/http.dart' as http;

import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/utilities/api_services/getgenericHeader.dart';
import 'package:mobile_onboarding/utilities/sslPinning/handler.dart';
import 'package:mobile_onboarding/widgets/newDocumentsUpload/DocumentsModel.dart';

/// Fetch documents using http
Future<List<DocumentInfo>> fetchDocuments({
  required int productCodeId,
  required String? employmentTypeId,
}) async {
  final client = await createHttpClientWithPinnedCert();
  final headers = await getGenericHeaders();
  final url = Uri.parse(
    '${getApiBaseUrl()}/LOS/getDocuments?productCodeId=$productCodeId&employmentTypeId=$employmentTypeId',
  );

  final response = await client.get(url, headers: headers);
  print(response.body.toString());
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    if (jsonResponse['code'] == '200') {
      List data = jsonResponse['data'];
      return data.map((e) => DocumentInfo.fromJson(e)).toList();
    } else {
      throw Exception("Error fetching documents: ${jsonResponse['message']}");
    }
  } else {
    throw Exception("Failed to call API. Status code: ${response.statusCode}");
  }
}

/// Upload documents using Dio (multipart/form-data)
Future<List<int>> uploadDocuments({
  required int documentTypeId,
  required String cnic,
  required String mobileNo,
  required List<File> files,
}) async {
  try {
    final dioClient = dio.Dio();
    final url = '${getApiBaseUrl()}/LOS/uploadDocument';
    final headers = await getGenericHeaders();

    // Prepare multipart files
    final multipartFiles = <dio.MultipartFile>[];
    for (final file in files) {
      multipartFiles.add(
        await dio.MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      );
    }

    // Build form-data
    final formData = dio.FormData.fromMap({
      'cnic': cnic,
      'mob': mobileNo,
      'docTypeId': documentTypeId,
      'file': multipartFiles,
    });

    final response = await dioClient.post(
      url,
      data: formData,
      options: dio.Options(headers: headers),
    );

    if (response.statusCode == 200) {
      final rawData = response.data;
      Map<String, dynamic>? jsonResponse;

      if (rawData is Map<String, dynamic>) {
        jsonResponse = rawData;
      } else if (rawData is String) {
        try {
          jsonResponse = jsonDecode(rawData);
        } catch (_) {
          return [];
        }
      }

      if (jsonResponse != null && jsonResponse['code'] == '200') {
        final data = jsonResponse['data'];
        if (data is List) {
          // Convert dynamic list to List<int>
          return data.map<int>((e) => e as int).toList();
        } else if (data is int) {
          // Single value fallback
          return [data];
        }
      }
    }

    // On any failure, return empty list
    return [];
  } catch (e) {
    print('Upload error: $e');
    return [];
  }
}
