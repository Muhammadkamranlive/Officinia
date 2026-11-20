class ReportIssueModel {
  /// Firebase Auth UID of the reporter
  final String userId;

  /// Issue details
  final String title;
  final String description;
  final String category; // UI, Crash, Payment, Performance, Other

  /// Status & priority
  final String status;   // IssueStatus
  final String priority; // IssuePriority

  /// Optional metadata
  final String? appVersion;
  final String? deviceInfo;
  final List<String> screenshots; // image URLs

  /// Admin handling
  final String  assignedTo; // admin UID/email
  final String? adminComment;

  /// Meta
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Firestore document ID
  String? docId;

  ReportIssueModel({
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    this.status = IssueStatus.open,
    this.priority = IssuePriority.medium,
    this.appVersion,
    this.deviceInfo,
    this.screenshots = const [],
    required this.assignedTo,
    this.adminComment,
    required this.createdAt,
    this.updatedAt,
    this.docId,
  });

  /// 🔥 Firestore → Model
  factory ReportIssueModel.fromMap(Map<String, dynamic> map, String id) {
    return ReportIssueModel(
      userId: map['userId'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Other',
      status: map['status'] ?? IssueStatus.open,
      priority: map['priority'] ?? IssuePriority.medium,
      appVersion: map['appVersion'],
      deviceInfo: map['deviceInfo'],
      screenshots: List<String>.from(map['screenshots'] ?? []),
      assignedTo: map['assignedTo'],
      adminComment: map['adminComment'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
      docId: id,
    );
  }

  /// 🔥 Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'priority': priority,
      'appVersion': appVersion,
      'deviceInfo': deviceInfo,
      'screenshots': screenshots,
      'assignedTo': assignedTo,
      'adminComment': adminComment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// 🔥 Helpers (Admin Dashboard)

  bool get isOpen => status     == IssueStatus.open;
  bool get isResolved => status == IssueStatus.resolved;

  ReportIssueModel copyWith({
    String? userId,
    String? title,
    String? description,
    String? category,
    String? status,
    String? priority,
    String? appVersion,
    String? deviceInfo,
    List<String>? screenshots,
    String? assignedTo,
    String? adminComment,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? docId,
  }) {
    return ReportIssueModel(
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      appVersion: appVersion ?? this.appVersion,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      screenshots: screenshots ?? this.screenshots,
      assignedTo: assignedTo ?? this.assignedTo,
      adminComment: adminComment ?? this.adminComment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      docId: docId ?? this.docId,
    );
  }
}


class IssuePriority {
  static const String low = 'Low';
  static const String medium = 'Medium';
  static const String high = 'High';
  static const String critical = 'Critical';
}

class IssueStatus {
  static const String open = 'Open';
  static const String inProgress = 'InProgress';
  static const String resolved = 'Resolved';
  static const String rejected = 'Rejected';
}

class IssueCategory {
  static const String crash = 'Crash';
  static const String ui = 'UI Issue';
  static const String performance = 'Performance';
  static const String payment = 'Payment';
  static const String loginAuth = 'Login / Auth';
  static const String other = 'Other';
}

