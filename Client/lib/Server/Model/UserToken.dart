// lib/Server/Model/UserToken.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserToken {
  final String userId;
  final String token;
  final String platform;
  final DateTime updatedAt;
  String? docId;

  UserToken({
    required this.userId,
    required this.token,
    required this.platform,
    required this.updatedAt,
    this.docId,
  });

  factory UserToken.fromMap(Map<String, dynamic> map, String id) {
    return UserToken(
      userId: map['userId'],
      token: map['token'],
      platform: map['platform'],
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      docId: id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'token': token,
      'platform': platform,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
