import 'package:client/Server/Repo/FirestoreRepository.dart';
import 'package:client/Server/Model/ReportIssueModel.dart';

class ReportIssueRepository extends FirestoreRepository<ReportIssueModel> {
  ReportIssueRepository() : super('ReportedIssues');

  @override
  ReportIssueModel fromMap(Map<String, dynamic> map, String id) =>
      ReportIssueModel.fromMap(map, id);

  @override
  Map<String, dynamic> toMap(ReportIssueModel entity) =>
      entity.toMap();

  /// 🔹 Get all issues reported by a user
  Future<List<ReportIssueModel>> getByUserId(String userId) async {
    final query = await collection
        .where('userId', isEqualTo: userId)
        //.orderBy('createdAt', descending: true)
        .get();

    return query.docs
        .map((doc) =>
            fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// 🔹 Admin: get all issues
  Future<List<ReportIssueModel>> getAll() async {
    final query = await collection
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs
        .map((doc) =>
            fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// 🔹 Admin: filter by status
  Future<List<ReportIssueModel>> getByStatus(String status) async {
    final query = await collection
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs
        .map((doc) =>
            fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// 🔹 Update issue status
  Future<void> updateStatus({
    required String docId,
    required String status,
    String? adminComment,
  }) async {
    await collection.doc(docId).update({
      'status': status,
      'adminComment': adminComment,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
