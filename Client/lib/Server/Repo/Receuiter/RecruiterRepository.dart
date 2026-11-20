
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const int kRecruiterPageSize = 10;

// ── Value object returned by getRecruitersPage ────────────────────────────────
class RecruiterPage {
  final List<Recruiter>   recruiters;
  final DocumentSnapshot? lastDoc; // cursor for next page
  final bool              hasMore;

  const RecruiterPage({
    required this.recruiters,
    required this.lastDoc,
    required this.hasMore,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
class RecruiterRepository extends FirestoreRepository<Recruiter> {
  RecruiterRepository() : super('Recruiters');

  @override
  Recruiter fromMap(Map<String, dynamic> map, String id) =>
      Recruiter.fromMap(map, id);

  @override
  Map<String, dynamic> toMap(Recruiter entity) => entity.toMap();

  // ── Single lookup — unchanged ─────────────────────────────────────────────
  Future<Recruiter?> getByUid(String userId) async {
    final query = await collection
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<RecruiterPage> getRecruitersPage({
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = collection
        .orderBy('pharmacyName') // stable sort for cursor pagination
        .limit(kRecruiterPageSize);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    final docs     = snapshot.docs;

    if (docs.isEmpty) {
      return const RecruiterPage(
          recruiters: [], lastDoc: null, hasMore: false);
    }

    final recruiters = docs
        .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();

    return RecruiterPage(
      recruiters: recruiters,
      lastDoc:    docs.last,
      hasMore:    docs.length == kRecruiterPageSize,
    );
  }

  // ── LEGACY — kept for any screen still calling getAllFromCollection ────────
  Future<List<Recruiter>> getAllFromCollection() async {
    final snapshot = await collection.get();
    return snapshot.docs
        .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }



  Future<bool> tryIncrementPostCount(String recruiterDocId) async {
    final docRef = collection.doc(recruiterDocId);
    final currentMonth = Recruiter.currentMonth;

    // Use a transaction so concurrent taps can't exceed the limit.
    return FirebaseFirestore.instance.runTransaction<bool>((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return false;

      final data  = snap.data() as Map<String, dynamic>;
      final limit = (data['jobPostLimit'] ?? 30) as int;
      final month = (data['jobPostMonth'] ?? '') as String;

      // Month rolled over → treat count as 0 (fresh month).
      final count = (month == currentMonth)
          ? (data['jobPostCount'] ?? 0) as int
          : 0;

      if (count >= limit) return false; // quota exhausted

      tx.update(docRef, {
        'jobPostCount': count + 1,
        'jobPostMonth': currentMonth,
      });
      return true;
    });
  }

  Future<void> decrementPostCount(String recruiterDocId) async {
    final docRef = collection.doc(recruiterDocId);
    final currentMonth = Recruiter.currentMonth;

    await FirebaseFirestore.instance.runTransaction<void>((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;

      final data  = snap.data() as Map<String, dynamic>;
      final month = (data['jobPostMonth'] ?? '') as String;

      // Only decrement if we're still in the same month.
      if (month != currentMonth) return;

      final count = (data['jobPostCount'] ?? 0) as int;
      if (count <= 0) return;

      tx.update(docRef, {'jobPostCount': count - 1});
    });
  }

 
  Future<void> setJobPostLimitForCurrentMonth(
    String recruiterDocId,
    int newLimit,
  ) async 
  {
   
    await collection.doc(recruiterDocId).update({
      'jobPostLimit': newLimit,
      // Reset the month-override marker (optional tracking field).
      'jobPostLimitOverrideMonth': Recruiter.currentMonth,
    });
  }

  /// Sets a permanent limit that survives month rollovers.
  Future<void> setJobPostLimitPermanent(
    String recruiterDocId,
    int newLimit,
  ) async {
    await collection.doc(recruiterDocId).update({'jobPostLimit': newLimit});
  }

  // Add this method to RecruiterRepository — alongside getByUid

/// Real-time stream of a single recruiter document.
/// Emits a new [Recruiter] every time Firestore updates the doc.
Stream<Recruiter?> streamByUid(String userId) {
  return collection
      .where('userId', isEqualTo: userId)
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return fromMap(doc.data() as Map<String, dynamic>, doc.id);
  });
}

}
// ── Search extension — unchanged ──────────────────────────────────────────────
extension RecruiterSearch on RecruiterRepository {
  Future<List<Recruiter>> searchRecruiters(String query) async {
    final snapshot = await collection
        .where('pharmacyName', isGreaterThanOrEqualTo: query)
        .where('pharmacyName', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    return snapshot.docs
        .map((doc) => fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}