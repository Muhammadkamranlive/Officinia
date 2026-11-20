import 'package:client/Server/Model/NotificationModel.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationRepository extends FirestoreRepository<NotificationModel> {
  NotificationRepository() : super('Notifications');

  @override
  NotificationModel fromMap(Map<String, dynamic> map, String id) =>
      NotificationModel.fromMap(map, id);

  @override
  Map<String, dynamic> toMap(NotificationModel entity) => entity.toMap();

  /// Get all job offers created by a recruiter (via userId)
  Future<List<NotificationModel>> getByUserId(String userId) async {
    final query = await collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs
        .map((doc) => fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// Get stream of notifications for a specific user
  Stream<List<NotificationModel>> streamByUserId(String userId) {
    return collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Get single job offer by document ID (optional helper)
  Future<NotificationModel?> getByDocId(String docId) async {
    final doc = await collection.doc(docId).get();
    if (doc.exists) {
      return fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // lib/Server/Repo/Notifications/NotificationsRepository.dart

  // ── Mark a single notification as read ───────────────────────────
  // Call this the moment the user opens the notification screen
  // or taps a notification item — do NOT wait for screen dispose.
  Future<void> markAsRead(String docId) async {
    await collection.doc(docId).update({'isRead': true});
  }

  // ── Mark ALL unread as read for the current user in one batch ────
  // Call this when NotificationScreen becomes visible (in initState
  // or didChangeDependencies), not on dispose or pop.
  Future<void> markAllAsRead(String userId) async {
    final snap = await collection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    if (snap.docs.isEmpty) return;

    // Batch write — single round trip regardless of count
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
