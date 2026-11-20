// lib/Server/Model/PaymentModel.dart
//
// Firestore collection: `payments`
//
// payments/{docId}
//   recruiterId   : String    (recruiter's userId — links to users collection)
//   checkoutId    : String    (Chargily checkout ID — for webhook verification)
//   amount        : double    (amount in DZD)
//   year          : int       (subscription year e.g. 2025)
//   status        : String    ('pending' | 'paid' | 'failed' | 'cancelled')
//   paymentMethod : String    ('edahabia' | 'cib' | 'unknown')
//   createdAt     : Timestamp
//   paidAt        : Timestamp? (set when webhook confirms payment)
//   expiresAt     : Timestamp  (createdAt + 1 year — used for access checks)

import 'package:client/Server/Model/Recruiter.dart';

enum PaymentStatus { pending, paid, failed, cancelled }

extension PaymentStatusX on PaymentStatus {
  String get value {
    switch (this) {
      case PaymentStatus.pending:   return 'pending';
      case PaymentStatus.paid:      return 'paid';
      case PaymentStatus.failed:    return 'failed';
      case PaymentStatus.cancelled: return 'cancelled';
    }
  }

  static PaymentStatus fromString(String v) {
    switch (v) {
      case 'paid':      return PaymentStatus.paid;
      case 'failed':    return PaymentStatus.failed;
      case 'cancelled': return PaymentStatus.cancelled;
      default:          return PaymentStatus.pending;
    }
  }

  String get label {
    switch (this) {
      case PaymentStatus.pending:   return 'Pending';
      case PaymentStatus.paid:      return 'Active';
      case PaymentStatus.failed:    return 'Failed';
      case PaymentStatus.cancelled: return 'Cancelled';
    }
  }
}

class PaymentModel {
  final String? docId;
  final String recruiterId;
  final String checkoutId;       // Chargily checkout.id
  final double amount;           // in DZD
  final int year;                // subscription year
  final PaymentStatus status;
  final String paymentMethod;    // 'edahabia' | 'cib' | 'unknown'
  final DateTime createdAt;
  final DateTime? paidAt;
  final DateTime expiresAt;      // createdAt + 365 days

  const PaymentModel({
    this.docId,
    required this.recruiterId,
    required this.checkoutId,
    required this.amount,
    required this.year,
    required this.status,
    this.paymentMethod = 'unknown',
    required this.createdAt,
    this.paidAt,
    required this.expiresAt,
  });

  /// True when subscription is active and not expired.
  bool get isActive =>
      status == PaymentStatus.paid && expiresAt.isAfter(DateTime.now());

  factory PaymentModel.fromMap(Map<String, dynamic> map, String id) {
    return PaymentModel(
      docId:         id,
      recruiterId:   map['recruiterId']   as String? ?? '',
      checkoutId:    map['checkoutId']    as String? ?? '',
      amount:        (map['amount'] as num?)?.toDouble() ?? 0,
      year:          (map['year'] as num?)?.toInt() ?? DateTime.now().year,
      status:        PaymentStatusX.fromString(map['status'] as String? ?? ''),
      paymentMethod: map['paymentMethod'] as String? ?? 'unknown',
      createdAt:     map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      paidAt:        map['paidAt'] != null
          ? (map['paidAt'] as dynamic).toDate()
          : null,
      expiresAt:     map['expiresAt'] != null
          ? (map['expiresAt'] as dynamic).toDate()
          : DateTime.now().add(const Duration(days: 365)),
    );
  }

  Map<String, dynamic> toMap() => {
    'recruiterId':   recruiterId,
    'checkoutId':    checkoutId,
    'amount':        amount,
    'year':          year,
    'status':        status.value,
    'paymentMethod': paymentMethod,
    'createdAt':     createdAt,
    'paidAt':        paidAt,
    'expiresAt':     expiresAt,
  };

  PaymentModel copyWith({
    String? docId,
    String? recruiterId,
    String? checkoutId,
    double? amount,
    int? year,
    PaymentStatus? status,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? paidAt,
    DateTime? expiresAt,
  }) =>
      PaymentModel(
        docId:         docId         ?? this.docId,
        recruiterId:   recruiterId   ?? this.recruiterId,
        checkoutId:    checkoutId    ?? this.checkoutId,
        amount:        amount        ?? this.amount,
        year:          year          ?? this.year,
        status:        status        ?? this.status,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        createdAt:     createdAt     ?? this.createdAt,
        paidAt:        paidAt        ?? this.paidAt,
        expiresAt:     expiresAt     ?? this.expiresAt,
      );
}



// ── Data holder ───────────────────────────────────────────────────────────────

class PaymentEntry {
  final PaymentModel payment;
  final Recruiter? recruiter;
  const PaymentEntry({required this.payment, this.recruiter});
}