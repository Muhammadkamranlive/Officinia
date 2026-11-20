import 'package:cloud_firestore/cloud_firestore.dart';

class JobOffer {
  /// Recruiter Firebase UID (same field name as Recruiter.userId)
  final String userId;

  // Job details
  final String jobTitle;        // gerant, pharmacist, physician, etc.
  final String jobType;         // part-time / full-time / replacement
  final List<String> skills;    // selected skills
  final String salary;
  // Status
  final bool isDraft;           // true = draft, false = posted
  final bool isActive;
  
  // Meta
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Firestore document ID (NOT stored)
  String? docId;

  JobOffer({
    required this.userId,
    required this.jobTitle,
    required this.jobType,
    required this.skills,
    required this.salary,
    required this.createdAt,
    this.updatedAt,
    this.isDraft = true,
    this.isActive = true,
    this.docId,
  });

  factory JobOffer.fromMap(Map<String, dynamic> map, String id) {
  return JobOffer(
    userId: map['userId'] as String? ?? '',          // ✅ was: map['userId'] (no fallback)
    jobTitle: map['jobTitle'] as String? ?? '',
    jobType: map['jobType'] as String? ?? '',
    skills: List<String>.from(map['skills'] ?? []),
    salary: map['salary'] as String? ?? '',          // ✅ was: map['salary'] (no fallback)
    isDraft: map['isDraft'] as bool? ?? true,
    isActive: map['isActive'] as bool? ?? true,
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(), // ✅ was: ...! (hard crash)
    updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    docId: id,
  );
}

 Map<String, dynamic> toMap({required bool isCreate}) {
  return {
    'userId': userId,
    'jobTitle': jobTitle,
    'jobType': jobType,
    'skills': skills,
    'salary':salary,
    'isDraft': isDraft,
    'isActive': isActive,
     
    // 🔥 Only set once
    if (isCreate) 'createdAt': FieldValue.serverTimestamp(),

    // 🔥 Always update
    'updatedAt': FieldValue.serverTimestamp(),
  };
}



 JobOffer copyWith({
    String? userId,
    String? jobTitle,
    String? jobType,
    List<String>? skills,
    String? salary,
    bool? isDraft,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? docId,
  }) {
    return JobOffer(
      userId: userId ?? this.userId,
      jobTitle: jobTitle ?? this.jobTitle,
      jobType: jobType ?? this.jobType,
      skills: skills ?? this.skills,
      salary: salary ?? this.salary,
      isDraft: isDraft ?? this.isDraft,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      docId: docId ?? this.docId,
    );
  }


}
