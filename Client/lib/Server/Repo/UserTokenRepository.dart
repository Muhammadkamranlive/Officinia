// lib/Server/Repo/UserToken/UserTokenRepository.dart
import 'package:client/Server/Model/UserToken.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserTokenRepository extends FirestoreRepository<UserToken> {
  UserTokenRepository() : super('userTokens');

  @override
  UserToken fromMap(Map<String, dynamic> map, String id) {
    return UserToken.fromMap(map, id);
  }

  @override
  Map<String, dynamic> toMap(UserToken token) {
    return token.toMap();
  }

  /// ✅ Save or update token for user
 /// ✅ Save or update token for user (ONE user = ONE token)
Future<void> saveToken({
  required String userId,
  required String token,
  required String platform,
}) async {
  final snapshot = await collection
      .where('userId', isEqualTo: userId)
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    // 🔄 User exists → UPDATE token
    await collection.doc(snapshot.docs.first.id).update({
      'token': token,
      'platform': platform,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return;
  }

  // ➕ First time login → create token
  await collection.add({
    'userId': userId,
    'token': token,
    'platform': platform,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

  /// ❌ Remove token on logout
  Future<void> deleteToken(String token) async {
    final snapshot =
        await collection.where('token', isEqualTo: token).get();

    for (final doc in snapshot.docs) {
      await collection.doc(doc.id).delete();
    }
  }
}
