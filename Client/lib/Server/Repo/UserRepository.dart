import 'package:client/Server/Model/AppUser.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';

class UserRepository extends FirestoreRepository<AppUser> {
  UserRepository() : super('users');

  @override
  AppUser fromMap(Map<String, dynamic> map, String id) {
    return AppUser.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(AppUser user) {
    return user.toMap();
  }

  Future<AppUser?> getByUid(String uid) async {
    final snapshot = await collection
        .where('userId', isEqualTo: uid)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<AppUser?> getByEmail(String email) async {
    final snapshot = await collection
        .where('email', isEqualTo: email.toLowerCase())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
  
  /// 🔐 SAFE update by userId
  Future<void> updateByUserId(String userId, AppUser user) async {
    final snapshot = await collection
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return;

    await collection.doc(snapshot.docs.first.id).update(user.toMap());
  }

  Future<List<AppUser>> getPendingAppeals() async {
  final snapshot = await collection
      .where('appealStatus', isEqualTo: 'pending')
      .where('isBlocked', isEqualTo: true)
      .get();

  return snapshot.docs
      .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
      .toList();
}


Future<void> deleteByUserId(String userId) async {
  final snapshot = await collection
      .where('userId', isEqualTo: userId)
      .limit(1)
      .get();

  if (snapshot.docs.isEmpty) return;

  await collection.doc(snapshot.docs.first.id).delete();
}

}
