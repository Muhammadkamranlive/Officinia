import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:io' if (dart.library.html) 'fake_io.dart'; // Web placeholder

import 'handler.dart'; // your updated SSL pinning handler

class NetworkClient {
  /// Returns a Web-safe HTTP client
  static Future<http.Client> getHttpClient() async {
    if (kIsWeb) {
      // Web → default client, SSL pinning skipped
      return http.Client();
    }
    return await createHttpClientWithPinnedSha256();
  }

  /// Returns a Web-safe Dio client
  static Future<Dio> getDioClient() async {
    if (kIsWeb) {
      final dio = Dio();
      dio.options
        ..connectTimeout = const Duration(seconds: 20)
        ..receiveTimeout = const Duration(seconds: 20);
      return dio; // default browser-enforced HTTPS
    }

    return await createPinnedDioSha256();
  }
}
