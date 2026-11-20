import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads profile image and OVERWRITES existing one
  /// Path: profile_images/{uid}.jpg
  Future<String> uploadProfileImage({
    required String uid,
    required File imageFile,
  }) async {
    final ref = _storage.ref().child('profile_images/$uid.jpg');

    await ref.putFile(imageFile);

    return await ref.getDownloadURL();
  }
}
