class SkillVerificationMeta {
  final String jobSeekerId;
  final String skill;
  
  /// List of recruiter IDs who verified this skill
  final List<String> verifiedBy;
  
  /// List of recruiter IDs who rejected this skill
  final List<String> rejectedBy;
  
  final DateTime createdAt;
  final DateTime updatedAt;
  
  String? docId;

  SkillVerificationMeta({
    required this.jobSeekerId,
    required this.skill,
    this.verifiedBy = const [],
    this.rejectedBy = const [],
    required this.createdAt,
    required this.updatedAt,
    this.docId,
  });

  /// How many recruiters verified this skill
  int get verifiedCount => verifiedBy.length;
  
  /// How many recruiters rejected this skill
  int get rejectedCount => rejectedBy.length;
  
  /// Overall status based on verification count
  String get status {
    if (verifiedCount >= 1) return 'Verified'; // 3+ verifications = trusted
    if (rejectedCount > verifiedCount) return 'Rejected';
    return 'Pending';
  }
  
  /// Check if a specific recruiter already verified/rejected this skill
  bool hasRecruiterVerified(String recruiterId) => verifiedBy.contains(recruiterId);
  bool hasRecruiterRejected(String recruiterId) => rejectedBy.contains(recruiterId);
  bool hasRecruiterReviewed(String recruiterId) => 
      hasRecruiterVerified(recruiterId) || hasRecruiterRejected(recruiterId);

  factory SkillVerificationMeta.fromMap(Map<String, dynamic> map, String id) {
    return SkillVerificationMeta(
      jobSeekerId: map['jobSeekerId'],
      skill: map['skill'],
      verifiedBy: List<String>.from(map['verifiedBy'] ?? []),
      rejectedBy: List<String>.from(map['rejectedBy'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      docId: id,
    );
  }

  // ✅ FIXED: Now includes computed values for Firestore queries
  Map<String, dynamic> toMap() {
    return {
      'jobSeekerId': jobSeekerId,
      'skill': skill,
      'verifiedBy': verifiedBy,
      'rejectedBy': rejectedBy,
      'verifiedCount': verifiedCount,  // ✅ ADDED: Store computed value
      'rejectedCount': rejectedCount,  // ✅ ADDED: Store computed value
      'status': status,                // ✅ ADDED: Store computed value
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated verification
  SkillVerificationMeta copyWith({
    List<String>? verifiedBy,
    List<String>? rejectedBy,
    DateTime? updatedAt,
  }) {
    return SkillVerificationMeta(
      jobSeekerId: jobSeekerId,
      skill: skill,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      docId: docId,
    );
  }
}