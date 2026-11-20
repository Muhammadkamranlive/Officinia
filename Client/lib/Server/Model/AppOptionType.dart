// lib/Server/Model/AppOption.dart

/// Type of option stored in the `app_options` collection.
/// Currently: province, jobType
enum AppOptionType { province, jobType }

extension AppOptionTypeX on AppOptionType {
  String get value {
    switch (this) {
      case AppOptionType.province:
        return 'province';
      case AppOptionType.jobType:
        return 'jobType';
    }
  }

  String get displayName {
    switch (this) {
      case AppOptionType.province:
        return 'Province';
      case AppOptionType.jobType:
        return 'Job Type';
    }
  }

  static AppOptionType fromString(String v) {
    switch (v) {
      case 'province':
        return AppOptionType.province;
      case 'jobType':
        return AppOptionType.jobType;
      default:
        return AppOptionType.province;
    }
  }
}

/// Represents one item in the `app_options` Firestore collection.
///
/// Firestore structure:
/// ```
/// app_options/{docId}
///   type      : "province" | "jobType"
///   order     : int           (display sort order)
///   en        : String        (English label)
///   fr        : String        (French label)
///   ar        : String        (Arabic label)
///   isActive  : bool
///   createdAt : Timestamp
/// ```
///
/// Storage rule: always persist [en] as the key in job offers / profiles.
/// Display rule: call [label(languageCode)] to get the translated label.
class AppOption {
  final String? docId;
  final AppOptionType type;
  final int order;
  final String en;
  final String fr;
  final String ar;
  final bool isActive;
  final DateTime createdAt;

  const AppOption({
    this.docId,
    required this.type,
    required this.order,
    required this.en,
    required this.fr,
    required this.ar,
    this.isActive = true,
    required this.createdAt,
  });

  /// Returns the translated label for [languageCode]. Falls back to [en].
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

  factory AppOption.fromMap(Map<String, dynamic> map, String id) {
    return AppOption(
      docId: id,
      type: AppOptionTypeX.fromString(map['type'] as String? ?? 'province'),
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

  AppOption copyWith({
    String? docId,
    AppOptionType? type,
    int? order,
    String? en,
    String? fr,
    String? ar,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AppOption(
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