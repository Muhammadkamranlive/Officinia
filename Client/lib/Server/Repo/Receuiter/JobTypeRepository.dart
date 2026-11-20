// lib/Server/Repo/JobTypeRepository.dart

import 'package:client/Server/Model/JobTypeModel.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';

class JobTypeRepository extends FirestoreRepository<JobTypeModel> {
  JobTypeRepository() : super('job_types');

  @override
  JobTypeModel fromMap(Map<String, dynamic> map, String id) =>
      JobTypeModel.fromMap(map, id);

  @override
  Map<String, dynamic> toMap(JobTypeModel entity) => entity.toMap();

  /// Active only, sorted by order. Use in dropdowns.
  Future<List<JobTypeModel>> getJobTypes() async {
    final snap = await collection
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();
    return snap.docs
        .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  /// All including inactive. For admin screen.
  Future<List<JobTypeModel>> getAllJobTypes() async {
    final snap = await collection.orderBy('order').get();
    return snap.docs
        .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Stream<List<JobTypeModel>> streamJobTypes() {
    return collection
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Future<void> activate(String docId) =>
      collection.doc(docId).update({'isActive': true});

  Future<void> deactivate(String docId) =>
      collection.doc(docId).update({'isActive': false});
}