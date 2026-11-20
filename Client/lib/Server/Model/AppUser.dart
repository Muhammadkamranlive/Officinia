import 'package:client/Server/Enums/UserRole.dart';

enum AppealStatus {
  none,
  pending,
  approved,
  rejected,
}

class AppUser {
  final String userId;
  final String email;
  final UserRole role;
  final String? phone;

  // 🔐 Block
  final bool isBlocked;
  final String? blockReason;
  final String? blockedBy;
  final DateTime? blockedAt;

  // 🙏 Appeal
  final String? appealMessage;
  final AppealStatus appealStatus;
  final DateTime? appealAt;

  // ✅ Reactivation
  final String? unblockReason;
  final DateTime? unblockedAt;

  // 🗑 Soft delete
  final bool isDeleted;
  final DateTime? deletedAt;

  AppUser({
    required this.userId,
    required this.email,
    required this.role,
    this.phone,

    this.isBlocked = false,
    this.blockReason,
    this.blockedBy,
    this.blockedAt,

    this.appealMessage,
    this.appealStatus = AppealStatus.none,
    this.appealAt,

    this.unblockReason,
    this.unblockedAt,

    this.isDeleted = false,
    this.deletedAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      userId: map['userId'],
      email: map['email'] ?? '',
      role: _roleFromString(map['role'] ?? 'jobSeeker'),
      phone: map['phone'],

      isBlocked: map['isBlocked'] ?? false,
      blockReason: map['blockReason'],
      blockedBy: map['blockedBy'],
      blockedAt: map['blockedAt'] != null
          ? DateTime.parse(map['blockedAt'])
          : null,

      appealMessage: map['appealMessage'],
      appealStatus: _appealStatusFromString(map['appealStatus']),
      appealAt: map['appealAt'] != null
          ? DateTime.parse(map['appealAt'])
          : null,

      unblockReason: map['unblockReason'],
      unblockedAt: map['unblockedAt'] != null
          ? DateTime.parse(map['unblockedAt'])
          : null,

      isDeleted: map['isDeleted'] ?? false,
      deletedAt: map['deletedAt'] != null
          ? DateTime.parse(map['deletedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'role': role.name,
      'phone': phone,

      'isBlocked': isBlocked,
      'blockReason': blockReason,
      'blockedBy': blockedBy,
      'blockedAt': blockedAt?.toIso8601String(),

      'appealMessage': appealMessage,
      'appealStatus': appealStatus.name,
      'appealAt': appealAt?.toIso8601String(),

      'unblockReason': unblockReason,
      'unblockedAt': unblockedAt?.toIso8601String(),

      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  AppUser copyWith({
    bool? isBlocked,
    String? blockReason,
    String? blockedBy,
    DateTime? blockedAt,
    String? appealMessage,
    AppealStatus? appealStatus,
    DateTime? appealAt,
    String? unblockReason,
    DateTime? unblockedAt,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return AppUser(
      userId: userId,
      email: email,
      role: role,
      phone: phone,

      isBlocked: isBlocked ?? this.isBlocked,
      blockReason: blockReason ?? this.blockReason,
      blockedBy: blockedBy ?? this.blockedBy,
      blockedAt: blockedAt ?? this.blockedAt,

      appealMessage: appealMessage ?? this.appealMessage,
      appealStatus: appealStatus ?? this.appealStatus,
      appealAt: appealAt ?? this.appealAt,

      unblockReason: unblockReason ?? this.unblockReason,
      unblockedAt: unblockedAt ?? this.unblockedAt,

      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  static AppealStatus _appealStatusFromString(String? status) {
    switch (status) {
      case 'pending':
        return AppealStatus.pending;
      case 'approved':
        return AppealStatus.approved;
      case 'rejected':
        return AppealStatus.rejected;
      default:
        return AppealStatus.none;
    }
  }

  static UserRole _roleFromString(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'recruiter':
        return UserRole.recruiter;
      default:
        return UserRole.jobSeeker;
    }
  }
}
