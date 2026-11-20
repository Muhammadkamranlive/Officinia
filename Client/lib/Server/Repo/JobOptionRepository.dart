// lib/Server/Repo/JobOptionRepository.dart

import 'package:client/Server/Model/JobOption.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';

class JobOptionRepository extends FirestoreRepository<JobOption> {
  JobOptionRepository() : super('job_options');

  @override
  JobOption fromMap(Map<String, dynamic> map, String id) {
    return JobOption.fromMap(map, id);
  }

  @override
  Map<String, dynamic> toMap(JobOption entity) {
    return entity.toMap();
  }

  // ─── Fetch by type (active only, sorted by order) ───────────────────────────

  Future<List<JobOption>> getJobTitles() =>
      _getByType(JobOptionType.jobTitle);

  Future<List<JobOption>> getSkills() =>
      _getByType(JobOptionType.skill);

  Future<List<JobOption>> _getByType(JobOptionType type) async {
    final snapshot = await collection
        .where('type', isEqualTo: type.value)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  // ─── Streams ─────────────────────────────────────────────────────────────────

  Stream<List<JobOption>> streamJobTitles() =>
      _streamByType(JobOptionType.jobTitle);

  Stream<List<JobOption>> streamSkills() =>
      _streamByType(JobOptionType.skill);

  Stream<List<JobOption>> _streamByType(JobOptionType type) {
    return collection
        .where('type', isEqualTo: type.value)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  // ─── Admin helpers ────────────────────────────────────────────────────────────

  /// Fetches ALL options (including inactive) — for admin screens.
  Future<List<JobOption>> getAllOptions() async {
    final snapshot =
        await collection.orderBy('type').orderBy('order').get();
    return snapshot.docs
        .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  /// Soft-deletes by setting isActive = false.
  Future<void> deactivate(String docId) async {
    await collection.doc(docId).update({'isActive': false});
  }

  /// Re-activates a previously deactivated option.
  Future<void> activate(String docId) async {
    await collection.doc(docId).update({'isActive': true});
  }
}