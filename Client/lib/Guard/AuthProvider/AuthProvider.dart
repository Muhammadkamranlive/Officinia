// import 'package:client/Server/Model/AppUser.dart';
// import 'package:client/Server/Repo/UserRepository.dart';
// import 'package:client/Server/Services/FcmTokenService.dart';
// import 'package:client/Server/Services/NotificationService.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class AuthProvider extends ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final UserRepository _userRepo = UserRepository();
//   bool isDeletingAccount = false;

//   AppUser? _appUser;
//   bool _isLoading = true;

//   AppUser? get user => _appUser;
//   bool get isAuthenticated => _appUser != null;
//   bool get isLoading => _isLoading;

//   AuthProvider() {
//     _listenAuthChanges();
//   }

//   void _listenAuthChanges() {
//     _auth.authStateChanges().listen((firebaseUser) async {
//        // ⛔ Ignore auth changes while deleting account
//       if (isDeletingAccount) return;

//       _isLoading = true;
//       notifyListeners();

//       if (firebaseUser == null) {
//         _appUser = null;
//       } else {
//         _appUser = await _userRepo.getByUid(firebaseUser.uid);
//           // 🔔 SAVE FCM TOKEN (once user is confirmed)
         
//       }

//       _isLoading = false;
//       notifyListeners();
//     });
//   }

//   /// 🔥 Explicit cleanup after delete
//   void clearUser() {
//     _appUser = null;
//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<void> logout() async {
    
//     NotificationService.reset();
//     await FirebaseAuth.instance.signOut();
//     await _auth.signOut();
//     // In your logout logic (AuthProvider or wherever signOut is called):
//   }

//   void setUser(AppUser user) { _appUser = user; notifyListeners(); } 
// }


import 'package:client/Server/Model/AppUser.dart';
import 'package:client/Server/Repo/UserRepository.dart';
import 'package:client/Server/Services/FcmTokenService.dart';
import 'package:client/Server/Services/NotificationService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth   _auth     = FirebaseAuth.instance;
  final UserRepository _userRepo = UserRepository();
  bool isDeletingAccount = false;

  AppUser? _appUser;
  bool _isLoading = true;

  AppUser? get user          => _appUser;
  bool get isAuthenticated   => _appUser != null;
  bool get isLoading         => _isLoading;

  AuthProvider() {
    _listenAuthChanges();
  }

  void _listenAuthChanges() {
    _auth.authStateChanges().listen((firebaseUser) async {
      if (isDeletingAccount) return;

      _isLoading = true;
      notifyListeners();

      if (firebaseUser == null) {
        _appUser = null;
      } else {
        _appUser = await _userRepo.getByUid(firebaseUser.uid);

        if (_appUser != null) {
          // ── Save FCM token every login / app restart ────────
          // This was commented out — this is why token was stale
          // after restart and notifications stopped arriving.
          await FcmTokenService.init(_appUser!.userId);

          // ── Start Firestore notification listener ────────────
          // Only start AFTER token is saved so the backend can
          // always reach this device.
          NotificationService.listenToUserNotifications(_appUser!.userId);
        }
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  void clearUser() {
    _appUser = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    // ── Reset notification listener so it restarts on next login ─
    NotificationService.reset();
    await _auth.signOut();
  }

  void setUser(AppUser user) {
    _appUser = user;
    notifyListeners();
  }
}