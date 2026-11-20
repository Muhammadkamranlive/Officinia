// lib/Server/Repo/AppOptionRepository.dart

import 'package:client/Server/Model/AppOptionType.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';

class AppOptionRepository extends FirestoreRepository<AppOption> {
  AppOptionRepository() : super('app_options');

  @override
  AppOption fromMap(Map<String, dynamic> map, String id) =>
      AppOption.fromMap(map, id);

  @override
  Map<String, dynamic> toMap(AppOption entity) => entity.toMap();

  // ─── Fetch active only, sorted by order ──────────────────────────────────

  Future<List<AppOption>> getProvinces() =>
      _getByType(AppOptionType.province);

  Future<List<AppOption>> getJobTypes() =>
      _getByType(AppOptionType.jobType);

  Future<List<AppOption>> _getByType(AppOptionType type) async {
    final snapshot = await collection
        .where('type', isEqualTo: type.value)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();
    return snapshot.docs
        .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  // ─── Streams ──────────────────────────────────────────────────────────────

  Stream<List<AppOption>> streamProvinces() =>
      _streamByType(AppOptionType.province);

  Stream<List<AppOption>> streamJobTypes() =>
      _streamByType(AppOptionType.jobType);

  Stream<List<AppOption>> _streamByType(AppOptionType type) {
    return collection
        .where('type', isEqualTo: type.value)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  // ─── Admin helpers ────────────────────────────────────────────────────────

  /// Returns ALL options (including inactive) for admin screen.
  Future<List<AppOption>> getAllOptions() async {
    final snapshot =
        await collection.orderBy('type').orderBy('order').get();
    return snapshot.docs
        .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Future<void> deactivate(String docId) =>
      collection.doc(docId).update({'isActive': false});

  Future<void> activate(String docId) =>
      collection.doc(docId).update({'isActive': true});
}