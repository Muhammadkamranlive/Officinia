import 'dart:io' show HttpClient, SecurityContext, X509Certificate;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter/foundation.dart'; // <-- Added for kIsWeb

const String kPinnedSha256 =
    'cb3ccbb76031e5e0138f8dd39a23f9de47ffc35e43c1144cea27d46a5ab1cb5f';
const String kExpectedHost = 'fbldigilending.faysalbank.com';
const bool kEnablePinningLogs = true;

const Duration kMinRemainingValidity = Duration(days: 0);

String _sha256OfCert(X509Certificate cert) {
  final base64Body = cert.pem
      .replaceAll('-----BEGIN CERTIFICATE-----', '')
      .replaceAll('-----END CERTIFICATE-----', '')
      .replaceAll(RegExp(r'\s+'), '');
  final derBytes = base64.decode(base64Body);
  final digest = sha256.convert(derBytes);
  return digest.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

bool _isCertTimeValid(X509Certificate cert) {
  final now = DateTime.now().toUtc();
  final notBefore = cert.startValidity.toUtc();
  final notAfter = cert.endValidity.toUtc();
  final remaining = notAfter.difference(now);

  final isInWindow = now.isAfter(notBefore) && now.isBefore(notAfter);
  final hasMinRemaining = remaining >= kMinRemainingValidity;

  if (kEnablePinningLogs) {
    print(
      '[Pinning] Validity: notBefore=$notBefore, notAfter=$notAfter, now=$now, remaining=${remaining.inDays}d',
    );
    if (!isInWindow) {
      print('[Pinning] ❌ Cert is not currently valid');
    } else if (!hasMinRemaining) {
      print('[Pinning] ❌ Cert too close to expiry');
    }
  }

  return isInWindow && hasMinRemaining;
}

bool _verifyPinHostAndExpiry(X509Certificate cert, String host) {
  final fp = _sha256OfCert(cert);
  final isFingerprintValid = (fp == kPinnedSha256);
  final isHostValid = (host == kExpectedHost);
  final isTimeValid = _isCertTimeValid(cert);

  if (kEnablePinningLogs) {
    print('[Pinning] Host: $host');
    print('[Pinning] FP: $fp');
    print('[Pinning] Expected: $kPinnedSha256');

    if (!isFingerprintValid || !isHostValid || !isTimeValid) {
      print('[Pinning] ❌ Reject');
    }
  }

  return isFingerprintValid && isHostValid && isTimeValid;
}

/// ======================================================
///     WEB BYPASS (DO NOT DELETE ANY EXISTING CODE)
/// ======================================================
Future<http.Client> createHttpClientWithPinnedSha256() async {
  if (kIsWeb) {
    print('[Pinning] Web platform → Certificate pinning disabled');
    return http.Client(); // ✔ Safe fallback for web
  }

  final context = SecurityContext(withTrustedRoots: false);
  final httpClient = HttpClient(context: context);

  httpClient.badCertificateCallback =
      (X509Certificate cert, String host, int port) {
        return _verifyPinHostAndExpiry(cert, host);
      };

  return IOClient(httpClient);
}

Future<http.Client> createHttpClientWithPinnedCert() =>
    createHttpClientWithPinnedSha256();

/// ======================================================
///     DIO WEB BYPASS
/// ======================================================
Future<Dio> createPinnedDioSha256() async {
  if (kIsWeb) {
    print('[Pinning] Web detected → Using default Dio client');
    return Dio(); // ✔ Web-safe fallback (no pinning)
  }

  final dio = Dio();
  final ioAdapter = IOHttpClientAdapter();

  ioAdapter.onHttpClientCreate = (HttpClient _) {
    final context = SecurityContext(withTrustedRoots: false);
    final client = HttpClient(context: context);

    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
          return _verifyPinHostAndExpiry(cert, host);
        };

    return client;
  };

  dio.httpClientAdapter = ioAdapter;

  dio.options
    ..connectTimeout = const Duration(seconds: 20)
    ..receiveTimeout = const Duration(seconds: 20);

  return dio;
}

Future<Dio> createPinnedDio() => createPinnedDioSha256();
