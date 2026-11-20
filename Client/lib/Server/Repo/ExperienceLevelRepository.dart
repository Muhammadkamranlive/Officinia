// lib/Server/Repo/ExperienceLevelRepository.dart

import 'package:client/Server/Model/ExperienceLevelModel.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';

class ExperienceLevelRepository
    extends FirestoreRepository<ExperienceLevelModel> {
  ExperienceLevelRepository() : super('experience_levels');

  @override
  ExperienceLevelModel fromMap(Map<String, dynamic> map, String id) =>
      ExperienceLevelModel.fromMap(map, id);

  @override
  Map<String, dynamic> toMap(ExperienceLevelModel entity) => entity.toMap();

  /// Active only, sorted by order — use in dropdowns.
  Future<List<ExperienceLevelModel>> getExperienceLevels() async {
    final snap = await collection
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();
    return snap.docs
        .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  /// All including inactive — for admin screen.
  Future<List<ExperienceLevelModel>> getAllExperienceLevels() async {
    final snap = await collection.orderBy('order').get();
    return snap.docs
        .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Stream<List<ExperienceLevelModel>> streamExperienceLevels() {
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