// document_info.dart
class DocumentInfo {
  final int documentId;
  late List<int> uploadId;
  final String documentName;
  final String mandetoryFlag;
  final String noOfDocuments;
  final String documentSize;
  final String documentTypes;

  DocumentInfo({
    required this.documentId,
    required this.documentName,
    required this.mandetoryFlag,
    required this.noOfDocuments,
    required this.documentSize,
    required this.documentTypes,
  });

  factory DocumentInfo.fromJson(Map<String, dynamic> json) {
    return DocumentInfo(
      documentId: json['documentId'],
      documentName: json['documentName'],
      mandetoryFlag: json['mandetoryFlag'],
      noOfDocuments: json['noOfDocuments'],
      documentSize: json['documentSize'],
      documentTypes: json['documentTypes'],
    );
  }

  List<String> parseAllowedTypes() {
    final splitted = documentTypes.split(',');
    return splitted
        .map((e) {
          e = e.trim().toLowerCase();
          if (e.contains('.')) {
            e = e.split('.').last;
          }
          return e;
        })
        .toSet()
        .toList();
  }

  double maxSizeAllowed() {
    return double.tryParse(documentSize) ?? 10.0;
  }

  int maxDocsAllowed() {
    return int.tryParse(noOfDocuments) ?? 1;
  }
}
