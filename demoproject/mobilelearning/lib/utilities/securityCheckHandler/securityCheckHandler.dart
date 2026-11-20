import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:root_checker_plus/root_checker_plus.dart';

/// Channel to ask the native side if a debugger is connected
const _debugChannel = MethodChannel('com.example.app/debugger');

/// Channel to verify APK signature
const _sigChannel = MethodChannel('com.example.app/signature');

Future<void> secureScreen() async {
  if (Platform.isAndroid) {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }
}

Future<bool> isRootedDevice() async {
  try {
    if (Platform.isAndroid) {
      final res = await RootCheckerPlus.isRootChecker;
      return res == true;
    }
    if (Platform.isIOS) {
      final res = await RootCheckerPlus.isJailbreak;
      return res == true;
    }
  } catch (_) {}
  return false;
}

Future<bool> isEmulatorDevice() async {
  try {
    final info = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final a = await info.androidInfo;
      final isEmu = !a.isPhysicalDevice;
      print('Device check (Android): emulator=$isEmu');
      return isEmu;
    }

    if (Platform.isIOS) {
      final i = await info.iosInfo;
      final isEmu = !i.isPhysicalDevice;
      print('Device check (iOS): simulator=$isEmu');
      return isEmu;
    }

    print('Device check: unsupported platform -> assuming real device');
    return false;
  } catch (e) {
    print('Device check error: $e -> assuming real device');
    return false;
  }
}

/// NEW: call into Android Debug.isDebuggerConnected()
Future<bool> isDebuggerAttached() async {
  if (Platform.isAndroid) {
    try {
      final bool attached =
          await _debugChannel.invokeMethod('isDebuggerConnected');
      return attached;
    } catch (_) {
      return true; // safest default: assume attached if channel fails
    }
  }
  return false;
}

Future<bool> hasValidSignature() async {
  try {
    final sig = await _sigChannel.invokeMethod<String>('getSignature');
    const knownGoodSig =
        '55:91:F0:A5:63:41:59:59:9C:01:12:D9:E2:85:1B:63:09:BA:8B:CC:AC:A8:93:03:39:2B:23:37:A8:87:19:0A';
    return sig == knownGoodSig;
  } catch (_) {
    return false;
  }
}

Future<bool> shouldBlockDevice() async {
  if (!kReleaseMode) return false;

  if (await isRootedDevice()) return true;
  if (await isEmulatorDevice()) return true;
  // if (await isDebuggerAttached()) return true;
  // if (!await hasValidSignature()) return true;

  return false;
}
