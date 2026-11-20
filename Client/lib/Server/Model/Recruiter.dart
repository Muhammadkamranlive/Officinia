import 'package:cloud_firestore/cloud_firestore.dart';

class Recruiter {
  /// Same as Firebase Auth UID (Primary Key like SQL)
  final String userId;

  // Pharmacy information
  final String pharmacyName;
  final String pharmacistFirstName;
  final String pharmacistLastName;

  // Location (Algeria)
  final String province;        // was: wilaya
  final String city;            // was: commune
  final String streetAddress;   // was: address
  final double latitude;
  final double longitude;

  // Meta
  final DateTime createdAt;
  final bool isActive;
  String? logoUrl;
  String profileStatus;
  // License information
  String? licenseStatus; // "Inactive", "Active", "Expired"
  DateTime? licenseExpiresAt;

  final int jobPostLimit;
  final int jobPostCount;
  final String jobPostMonth;
  String? docId;

  Recruiter({
    required this.userId,
    required this.pharmacyName,
    required this.pharmacistFirstName,
    required this.pharmacistLastName,
    required this.province,
    required this.city,
    required this.streetAddress,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    
    this.licenseStatus = "Inactive",
    this.isActive = true,
    this.profileStatus="Normal",
    this.licenseExpiresAt,
    this.docId,
    this.logoUrl,
    this.jobPostLimit = 30,
    this.jobPostCount = 0,
    this.jobPostMonth = '',
  });

  
factory Recruiter.fromMap(Map<String, dynamic> map, String id) {
  return Recruiter(
    userId: map['userId'],
    pharmacyName: map['pharmacyName'] ?? '',
    pharmacistFirstName: map['pharmacistFirstName'] ?? '',
    pharmacistLastName: map['pharmacistLastName'] ?? '',
    province: map['province'] ?? '',
    city: map['city'] ?? '',
    streetAddress: map['streetAddress'] ?? '',
    latitude: (map['latitude'] ?? 0).toDouble(),
    longitude: (map['longitude'] ?? 0).toDouble(),
    createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
    isActive: map['isActive'] ?? true,
    profileStatus: map['profileStatus'] ?? 'Normal',
    licenseStatus: map['licenseStatus'] ?? 'Inactive',
    licenseExpiresAt: _parseDateTime(map['licenseExpiresAt']),
    // ── new ──
      jobPostLimit: (map['jobPostLimit'] ?? 30) as int,
      jobPostCount: (map['jobPostCount'] ?? 0) as int,
      jobPostMonth: map['jobPostMonth'] ?? '',
    logoUrl: map['logoUrl'],
    docId: id,
  );
}

/// Safely parses a DateTime from either a Firestore Timestamp or an ISO String.
static DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value);
  return null;
}

  Map<String, dynamic> toMap() {
    return {
      'userId': userId, // 🔥 REQUIRED // 🔥 from FIELD
      'pharmacyName': pharmacyName,
      'pharmacistFirstName': pharmacistFirstName,
      'pharmacistLastName': pharmacistLastName,
      'province': province,
      'city': city,
      'streetAddress': streetAddress,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'profileStatus':profileStatus,
      'licenseStatus': licenseStatus,
      'licenseExpiresAt': licenseExpiresAt?.toIso8601String(),
      'logoUrl':logoUrl,
      // ── new ──
      'jobPostLimit': jobPostLimit,
      'jobPostCount': jobPostCount,
      'jobPostMonth': jobPostMonth,
    };
  }

  bool get hasActiveLicense {
    if (!isActive) return false;

    if (licenseStatus != "Active") return false;

    if (licenseExpiresAt == null) return false;

    return licenseExpiresAt!.isAfter(DateTime.now());
  }

  bool get isLicenseExpired {
    if (licenseExpiresAt == null) return true;
    return licenseExpiresAt!.isBefore(DateTime.now());
  }

  // ── new quota helpers ─────────────────────────────────────────
  /// "YYYY-MM" for the current calendar month.
  static String get currentMonth {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

    /// True if the recruiter is in the same calendar month as now.
  bool get isCurrentMonth => jobPostMonth == currentMonth;

  /// Effective count this month (resets to 0 if month rolled over).
  int get effectivePostCount => isCurrentMonth ? jobPostCount : 0;

  /// How many more jobs this recruiter can post this month.
  int get remainingPostsThisMonth => (jobPostLimit - effectivePostCount).clamp(0, jobPostLimit);

  /// True when the recruiter has NOT exceeded their monthly limit.
  bool get canPostJob => remainingPostsThisMonth > 0;
}
