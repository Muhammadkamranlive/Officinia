import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_onboarding/constants.dart';

class AppVersionInfo {
  final int buildNo;
  final String versionNo;
  final bool versionOnOff;
  AppVersionInfo({
    required this.buildNo,
    required this.versionNo,
    required this.versionOnOff,
  });
  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      buildNo: json['BuildNo'] is int
          ? json['BuildNo'] as int
          : int.tryParse('${json['BuildNo']}') ?? 0,
      versionNo: '${json['VersionNo'] ?? ''}',
      versionOnOff: json['VersionOnOff'] == true,
    );
  }
}

class VersionService {
  static Future<void> ensureVersionIsValid() async {
    try {
      final info = await _fetchVersionInfo();

      // 👇 Print what came from server
      debugPrint(
          '[Version] SERVER => build=${info.buildNo}, version=${info.versionNo}, switch=${info.versionOnOff}');

      // 👇 Print what the app is using (your current constants)
      debugPrint(
          '[Version]  APP   => build=$kExpectedBuildNo, version=$kExpectedVersion (from constants.dart)');

      // 👇 Print exactly what is being compared
      debugPrint(
          '[Version] CHECK => build: server(${info.buildNo}) == app($kExpectedBuildNo)');
      debugPrint(
          '[Version] CHECK => version: compare(server="${info.versionNo}", app="$kExpectedVersion") == 0 (equal)');
      if (info.versionOnOff != true) {
        debugPrint(
            '[Version] Server switch OFF => skipping checks, starting app.');
        return;
      }
      final buildOk = info.buildNo == kExpectedBuildNo;
      final verCmp = _compareVersionStrings(info.versionNo, kExpectedVersion);
      final versionOk = verCmp == 0;

      debugPrint(
          '[Version] RESULT => buildOk=$buildOk, versionOk=$versionOk (cmp=$verCmp),');

      if (buildOk && versionOk) {
        return;
      }

      // Optional: print why it failed
      if (!buildOk) debugPrint('[Version] BLOCK: build mismatch.');
      if (!versionOk) debugPrint('[Version] BLOCK: version mismatch.');

      await _launchStore();
      exit(0);
    } catch (e, st) {
      debugPrint('[Version] ERROR while checking version: $e');
      // If you want to see the stack:
      // debugPrint('$st');
      return;
    }
  }

  static Future<AppVersionInfo> _fetchVersionInfo({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final uri = Uri.parse('${getApiBaseUrl()}/Auth/GetVersion');
    final resp = await http.get(
      uri,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ).timeout(timeout);

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = resp.body.isEmpty ? '{}' : resp.body;
      final map = jsonDecode(body) as Map<String, dynamic>;
      return AppVersionInfo.fromJson(map);
    }
    throw HttpException('Version API failed: ${resp.statusCode}', uri: uri);
  }

  static int _compareVersionStrings(String a, String b) {
    final as = a.split('.');
    final bs = b.split('.');
    final len = as.length > bs.length ? as.length : bs.length;

    for (int i = 0; i < len; i++) {
      final ai = i < as.length ? int.tryParse(as[i]) ?? 0 : 0;
      final bi = i < bs.length ? int.tryParse(bs[i]) ?? 0 : 0;
      if (ai != bi) {
        final res = ai < bi ? -1 : 1;
        debugPrint('[Version] SEGMENT cmp: a[$i]=$ai vs b[$i]=$bi -> $res');
        return res;
      }
    }
    debugPrint('[Version] SEGMENT cmp: all equal -> 0');
    return 0;
  }

  static Future<void> _launchStore() async {
    if (Platform.isAndroid) {
      final marketUri = Uri.parse('market://details?id=$kAndroidPackageName');
      final webUri = Uri.parse(
          'https://play.google.com/store/apps/details?id=$kAndroidPackageName');
      if (!await launchUrl(marketUri, mode: LaunchMode.externalApplication)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } else if (Platform.isIOS) {
      if (kIosAppStoreUrl == null) return;
      await launchUrl(Uri.parse(kIosAppStoreUrl!),
          mode: LaunchMode.externalApplication);
    }
  }
}
