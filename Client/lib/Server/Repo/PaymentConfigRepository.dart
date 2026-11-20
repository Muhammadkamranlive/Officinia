// lib/Server/Repo/PaymentConfigRepository.dart

import 'package:client/Server/Model/PaymentConfig.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Reads and writes payment configuration from:
///   `app_config/payment_config`
///
/// This keeps ALL payment credentials, URLs, fees, and UI strings
/// out of the app binary — change them in Firestore without an app update.
class PaymentConfigRepository {
  final _db  = FirebaseFirestore.instance;

  DocumentReference get _doc =>
      _db.collection('app_config').doc('payment_config');

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Returns the live config, or [PaymentConfig.defaults()] if the document
  /// does not exist yet.
  Future<PaymentConfig> get() async {
    final snap = await _doc.get();
    if (!snap.exists) return PaymentConfig.defaults();
    return PaymentConfig.fromMap(snap.data() as Map<String, dynamic>);
  }

  /// Real-time stream — rebuilds UI whenever admin changes config in Firestore.
  Stream<PaymentConfig> stream() {
    return _doc.snapshots().map((snap) {
      if (!snap.exists) return PaymentConfig.defaults();
      return PaymentConfig.fromMap(snap.data() as Map<String, dynamic>);
    });
  }

  // ── Write (admin only) ────────────────────────────────────────────────────

  /// Creates or fully overwrites the config document.
  Future<void> set(PaymentConfig config) async {
    await _doc.set({
      ...config.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Partially updates specific fields without overwriting the whole document.
  Future<void> update(Map<String, dynamic> fields) async {
    await _doc.update({
      ...fields,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Convenience: flip test mode on/off from admin panel.
  Future<void> setTestMode(bool value) =>
      update({'testMode': value});

  /// Convenience: update annual fee.
  Future<void> setAnnualFee(double fee) =>
      update({'annualFee': fee});
}