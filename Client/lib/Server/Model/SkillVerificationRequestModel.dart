class SkillVerificationRequest {
  final String jobSeekerId;
  final String recruiterId;
  final String? jobId; // nullable for outside employment
  final DateTime createdAt;
  final String status;
  final String? note; // optional note for outside job
  final List<String>? skills; // skills for outside verification
  String? docId;

  SkillVerificationRequest({
    required this.jobSeekerId,
    required this.recruiterId,
    this.jobId,
    required this.createdAt,
    this.status = 'Pending',
    this.note,
    this.skills,
    this.docId,
  });

  factory SkillVerificationRequest.fromMap(Map<String, dynamic> map, String id) {
    return SkillVerificationRequest(
      jobSeekerId: map['jobSeekerId'],
      recruiterId: map['recruiterId'],
      jobId: map['jobId'],
      createdAt: DateTime.parse(map['createdAt']),
      status: map['status'] ?? 'Pending',
      note: map['note'],
      skills: map['skills'] != null ? List<String>.from(map['skills']) : null,
      docId: id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobSeekerId': jobSeekerId,
      'recruiterId': recruiterId,
      'jobId': jobId,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'note': note,
      'skills': skills,
    };
  }
}

