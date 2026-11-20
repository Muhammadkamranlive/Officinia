// lib/Server/Repo/PaymentRepository.dart

import 'package:client/Server/Model/PaymentStatus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _col => _db.collection('payments');

  // ── Write ──────────────────────────────────────────────────────────────────

  /// Creates a pending payment record. Returns the new docId.
  Future<String> add(PaymentModel payment) async {
    final ref = await _col.add(payment.toMap());
    return ref.id;
  }

  Future<void> update(String docId, PaymentModel payment) async {
    await _col.doc(docId).update(payment.toMap());
  }

  /// Called by your webhook Cloud Function to mark a payment as paid.
  Future<void> markAsPaid(String docId, {String paymentMethod = 'unknown'}) async {
    await _col.doc(docId).update({
      'status':        PaymentStatus.paid.value,
      'paymentMethod': paymentMethod,
      'paidAt':        FieldValue.serverTimestamp(),
    });
  }

  /// Called when Chargily returns to failureUrl.
  Future<void> markAsFailed(String docId) async {
    await _col.doc(docId).update({'status': PaymentStatus.failed.value});
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  /// All payment records for a recruiter, newest first.
  Future<List<PaymentModel>> getForRecruiter(String recruiterId) async {
    final snap = await _col
        .where('recruiterId', isEqualTo: recruiterId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => PaymentModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  /// Returns the most recent PAID and non-expired subscription, or null.
  Future<PaymentModel?> getActiveSubscription(String recruiterId) async {
    final snap = await _col
        .where('recruiterId', isEqualTo: recruiterId)
        .where('status', isEqualTo: PaymentStatus.paid.value)
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('expiresAt', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return PaymentModel.fromMap(
        snap.docs.first.data() as Map<String, dynamic>, snap.docs.first.id);
  }

  /// Quick boolean: does this recruiter have an active subscription?
  Future<bool> hasActiveSubscription(String recruiterId) async {
    final sub = await getActiveSubscription(recruiterId);
    return sub != null;
  }

  /// Real-time stream of subscription status — use in SubscriptionGate.
  Stream<bool> streamSubscriptionStatus(String recruiterId) {
    return _col
        .where('recruiterId', isEqualTo: recruiterId)
        .where('status', isEqualTo: PaymentStatus.paid.value)
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .snapshots()
        .map((snap) => snap.docs.isNotEmpty);
  }

  /// Pending payment for this recruiter (checkout started but not confirmed).
  Future<PaymentModel?> getPendingPayment(String recruiterId) async {
    final snap = await _col
        .where('recruiterId', isEqualTo: recruiterId)
        .where('status', isEqualTo: PaymentStatus.pending.value)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return PaymentModel.fromMap(
        snap.docs.first.data() as Map<String, dynamic>, snap.docs.first.id);
  }

  // ── Admin ──────────────────────────────────────────────────────────────────

  /// All payments across all recruiters — for admin dashboard.
  Future<List<PaymentModel>> getAllPayments() async {
    final snap = await _col.orderBy('createdAt', descending: true).get();
    return snap.docs
        .map((d) => PaymentModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  /// Payments by status — for admin filtering.
  Future<List<PaymentModel>> getByStatus(PaymentStatus status) async {
    final snap = await _col
        .where('status', isEqualTo: status.value)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => PaymentModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Stream<List<PaymentModel>> streamForRecruiter(String recruiterId) {
  return FirebaseFirestore.instance
      .collection('payments')
      .where('recruiterId', isEqualTo: recruiterId)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => PaymentModel.fromMap(d.data(), d.id))
          .toList());
}
}