import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationService {
  /// Call this before anything that needs coordinates.
  /// Returns the position, or null if permission denied.
  static Future<Position?> getCurrentLocation(BuildContext context) async {
    // ── 1. Check if device GPS is on ─────────────────────
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        _showDialog(
          context,
          title: 'Location Disabled',
          message: 'Please turn on location services to find nearby pharmacies.',
          onConfirm: () => Geolocator.openLocationSettings(),
        );
      }
      return null;
    }

    // ── 2. Check / request permission ────────────────────
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // First time — show the system prompt
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      // User tapped "Don't Allow" on the system prompt
      if (context.mounted) {
        _showDialog(
          context,
          title: 'Permission Denied',
          message: 'Location permission is needed to show nearby pharmacies.',
          onConfirm: null, // just dismiss
        );
      }
      return null;
    }

    if (permission == LocationPermission.deniedForever) {
      // User tapped "Never Allow" — must go to Settings
      if (context.mounted) {
        _showDialog(
          context,
          title: 'Permission Permanently Denied',
          message:
              'Please enable location access in Settings so we can find nearby pharmacies.',
          onConfirm: () => Geolocator.openAppSettings(), // opens Settings
        );
      }
      return null;
    }

    // ── 3. Permission granted — get position ─────────────
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, // GPS-level on Android, Core Location on iOS
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  static void _showDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (onConfirm != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: const Text('Open Settings'),
            ),
        ],
      ),
    );
  }
}