// lib/Server/Model/LocationModel/CityModel.dart
//
// Firestore path: `provinces/{provinceId}/cities/{cityId}`
//
// provinces/{provinceId}/cities/{docId}
//   en         : String
//   fr         : String
//   ar         : String
//   provinceId : String   (parent province docId — denormalized for easy querying)
//   order      : int
//   isActive   : bool
//   createdAt  : Timestamp
//
// Storage rule : persist [en] as the key; [provinceId] links back to province.
// Display rule : call [label(languageCode)].

class CityModel {
  final String? docId;
  final String provinceId; // parent province's docId
  final String en;
  final String fr;
  final String ar;
  final int order;
  final bool isActive;
  final DateTime createdAt;

  const CityModel({
    this.docId,
    required this.provinceId,
    required this.en,
    required this.fr,
    required this.ar,
    required this.order,
    this.isActive = true,
    required this.createdAt,
  });

  String label(String languageCode) {
    switch (languageCode) {
      case 'fr': return fr;
      case 'ar': return ar;
      default:   return en;
    }
  }

  factory CityModel.fromMap(Map<String, dynamic> map, String id) {
    return CityModel(
      docId:      id,
      provinceId: map['provinceId'] as String? ?? '',
      en:         map['en']    as String? ?? '',
      fr:         map['fr']    as String? ?? '',
      ar:         map['ar']    as String? ?? '',
      order:      (map['order'] as num?)?.toInt() ?? 0,
      isActive:   map['isActive'] as bool? ?? true,
      createdAt:  map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'provinceId': provinceId,
    'en':         en,
    'fr':         fr,
    'ar':         ar,
    'order':      order,
    'isActive':   isActive,
    'createdAt':  createdAt,
  };

  CityModel copyWith({
    String? docId, String? provinceId,
    String? en, String? fr, String? ar,
    int? order, bool? isActive, DateTime? createdAt,
  }) => CityModel(
    docId:      docId      ?? this.docId,
    provinceId: provinceId ?? this.provinceId,
    en:         en         ?? this.en,
    fr:         fr         ?? this.fr,
    ar:         ar         ?? this.ar,
    order:      order      ?? this.order,
    isActive:   isActive   ?? this.isActive,
    createdAt:  createdAt  ?? this.createdAt,
  );
}