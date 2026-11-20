import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  /// Firebase UID of the user this notification belongs to
  final String userId;

  /// Notification type: login, logout, payment, job_post, job_apply, etc.
  final String type;

  /// Notification title and description
  final String title;
  final String description;

  /// Status
  final bool isRead;
  final bool isSent;
  /// Meta
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? targetId;   // jobId / chatId / applicationId
  final String? targetType; // job, chat, application
  final String? route;      // navigation route
  final Map<String, dynamic>? payload; // dynamic data for localization
  /// Firestore document ID (NOT stored)
  String? docId;

  NotificationModel({
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.targetId,
    required this.targetType,
    required this.route,
    this.payload,
    this.updatedAt,
    this.isRead = false,
    this.isSent = false,
    this.docId,
  });

   /// 🔥 ADD THIS
  NotificationModel copyWith({
    String? docId,
    String? userId,
    String? type,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? payload,
  }) {
    return NotificationModel(
      docId: docId ?? this.docId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      route: route ?? this.route,
      isSent: isSent ?? this.isSent,
      payload: payload ?? this.payload,
    );
  }

  /// Convert Firestore document to NotificationModel
  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      userId: map['userId'],
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      targetId: map['targetId'],
      targetType: map['targetType'],
      route: map['route'],
      payload: map['payload'] != null ? Map<String, dynamic>.from(map['payload']) : null,
      isSent: map['isSent'] ?? false,
      docId: id,
    );
  }

  /// Convert NotificationModel to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'title': title,
      'description': description,
      'isRead': isRead,
      'isSent': isSent,
      'targetId': targetId,
      'targetType': targetType,
      'route': route,
      'payload': payload,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
