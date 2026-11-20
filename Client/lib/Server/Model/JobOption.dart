// lib/Server/Model/JobOption.dart

/// Type of option stored in the `job_options` collection
enum JobOptionType { jobTitle, skill }

extension JobOptionTypeX on JobOptionType {
  String get value {
    switch (this) {
      case JobOptionType.jobTitle:
        return 'jobTitle';
      case JobOptionType.skill:
        return 'skill';
    }
  }

  static JobOptionType fromString(String v) {
    switch (v) {
      case 'jobTitle':
        return JobOptionType.jobTitle;
      case 'skill':
        return JobOptionType.skill;
      default:
        return JobOptionType.skill;
    }
  }
}

/// Represents one item in the `job_options` Firestore collection.
///
/// Firestore structure:
/// ```
/// job_options/{docId}
///   type        : "jobTitle" | "skill"
///   order       : int          (display sort order)
///   en          : String       (English label)
///   fr          : String       (French label)
///   ar          : String       (Arabic label)
///   isActive    : bool
///   createdAt   : Timestamp
/// ```
class JobOption {
  final String? docId;
  final JobOptionType type;
  final int order;
  final String en;
  final String fr;
  final String ar;
  final bool isActive;
  final DateTime createdAt;

  const JobOption({
    this.docId,
    required this.type,
    required this.order,
    required this.en,
    required this.fr,
    required this.ar,
    this.isActive = true,
    required this.createdAt,
  });

  /// Returns the label for the current app locale.
  /// Falls back to [en] if the locale is not supported.
  String label(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return fr;
      case 'ar':
        return ar;
      default:
        return en;
    }
  }

  factory JobOption.fromMap(Map<String, dynamic> map, String id) {
    return JobOption(
      docId: id,
      type: JobOptionTypeX.fromString(map['type'] as String? ?? 'skill'),
      order: (map['order'] as num?)?.toInt() ?? 0,
      en: map['en'] as String? ?? '',
      fr: map['fr'] as String? ?? '',
      ar: map['ar'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.value,
      'order': order,
      'en': en,
      'fr': fr,
      'ar': ar,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }

  JobOption copyWith({
    String? docId,
    JobOptionType? type,
    int? order,
    String? en,
    String? fr,
    String? ar,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return JobOption(
      docId: docId ?? this.docId,
      type: type ?? this.type,
      order: order ?? this.order,
      en: en ?? this.en,
      fr: fr ?? this.fr,
      ar: ar ?? this.ar,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}