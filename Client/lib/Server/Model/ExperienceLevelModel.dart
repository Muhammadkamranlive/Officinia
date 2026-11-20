// lib/Server/Model/ExperienceLevelModel.dart
//
// Firestore collection: `experience_levels`
//
// experience_levels/{docId}
//   en        : String
//   fr        : String
//   ar        : String
//   order     : int
//   isActive  : bool
//   createdAt : Timestamp

class ExperienceLevelModel {
  final String? docId;
  final String en;
  final String fr;
  final String ar;
  final int order;
  final bool isActive;
  final DateTime createdAt;

  const ExperienceLevelModel({
    this.docId,
    required this.en,
    required this.fr,
    required this.ar,
    required this.order,
    this.isActive = true,
    required this.createdAt,
  });

  /// Returns translated label. Falls back to [en].
  String label(String languageCode) {
    switch (languageCode) {
      case 'fr': return fr;
      case 'ar': return ar;
      default:   return en;
    }
  }

  factory ExperienceLevelModel.fromMap(Map<String, dynamic> map, String id) {
    return ExperienceLevelModel(
      docId:     id,
      en:        map['en']    as String? ?? '',
      fr:        map['fr']    as String? ?? '',
      ar:        map['ar']    as String? ?? '',
      order:     (map['order'] as num?)?.toInt() ?? 0,
      isActive:  map['isActive'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'en':        en,
    'fr':        fr,
    'ar':        ar,
    'order':     order,
    'isActive':  isActive,
    'createdAt': createdAt,
  };

  ExperienceLevelModel copyWith({
    String? docId, String? en, String? fr, String? ar,
    int? order, bool? isActive, DateTime? createdAt,
  }) => ExperienceLevelModel(
    docId:     docId     ?? this.docId,
    en:        en        ?? this.en,
    fr:        fr        ?? this.fr,
    ar:        ar        ?? this.ar,
    order:     order     ?? this.order,
    isActive:  isActive  ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
}