import 'dart:async';
// ignore: depend_on_referenced_packages
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ConnectivityBannerState createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print("Couldn't check connectivity status: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_connectivityResult == ConnectivityResult.none) {
      return Container(
        color: Colors.red,
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, color: Colors.white),
            SizedBox(width: 8),
            Text('No internet connection',
                style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
