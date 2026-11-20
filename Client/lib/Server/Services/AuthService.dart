import 'package:client/Server/Enums/UserRole.dart';
import 'package:client/Server/Model/AppUser.dart';
import 'package:client/Server/Repo/UserRepository.dart';
import 'package:client/widgets/custom_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepo = UserRepository();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<AppUser?> signInWithGoogleAppledevice(BuildContext context) async {
    // ❗ Provide web client ID here for Android
    await _googleSignIn.initialize(
      serverClientId:
          "429018063802-88allo2prk9pc2b8cvu1e3t5aadikcle.apps.googleusercontent.com", // 🧠 Web client ID
    );

    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final firebaseUser = userCredential.user;
    if(firebaseUser==null){
      showCustomToast("No user found with that email. Please sign up first.", context);
      return null;
    }
    final existingUser = await _userRepo.getByUid(firebaseUser.uid);
    if (existingUser == null) {
      showCustomToast("User not registered. Please sign up first.", context);
      return null;
    }
    return existingUser;
  }

  Future<AppUser?> signUpWithGoogleAppledevice(UserRole role,BuildContext context) async {
    // ❗ Provide web client ID here for Android
    await _googleSignIn.initialize(
      serverClientId:
          "429018063802-88allo2prk9pc2b8cvu1e3t5aadikcle.apps.googleusercontent.com", // 🧠 Web client ID
    );

    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final firebaseUser = userCredential.user!;

    final existingUser = await _userRepo.getByUid(firebaseUser.uid);

    if (existingUser != null) {
      showCustomToast("User already exists. Please log in.", context);
      return null;
    }
    // 🆕 First time signup
    final newUser = AppUser(
      userId: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      role: role,
    );

    await _userRepo.add(newUser);
    return newUser;
  }

  Future<AppUser?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    required BuildContext context,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // ✅ Send verification email
    await credential.user!.sendEmailVerification();
    //verify already exists
    final existingUser = await _userRepo.getByUid(credential.user!.uid);
    
    if (existingUser != null) {
      showCustomToast("User already exists. Please log in.", context);
      return null;
    }

    final user = AppUser(
      userId: credential.user!.uid,
      email: email,
      role: role,
    );
    await _userRepo.add(user);
    return user;
  }

  Future<AppUser?> signIn({
  required String email,
  required String password,
  required BuildContext context,
}) async {
  try {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      showCustomToast("No user found with that email. Please sign up first.", context);
      return null;
    }

     // 🔴 EMAIL NOT VERIFIED
     if (!firebaseUser.emailVerified) {
      try {
        await firebaseUser.sendEmailVerification();
      } catch (e) {
        //print("Verification email send error: $e");
      }

      await _auth.signOut(); // ✅ VERY IMPORTANT

      showCustomToast(
        "Email not verified. A verification email has been sent. Please check your inbox. If you don't see it, check your spam folder.",
        context,
      );

      return null;
    }

    // ✅ Verified → continue
    final appUser = await _userRepo.getByEmail(firebaseUser.email!);

    if (appUser == null) {
      showCustomToast("User not registered. Please sign up first.", context);
      await _auth.signOut();
      return null;
    }

    return appUser;

  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'user-not-found':
        showCustomToast("User not found. Please sign up first.", context);
        break;
      case 'wrong-password':
        showCustomToast("Incorrect password.", context);
        break;
      case 'invalid-email':
        showCustomToast("Invalid email address.", context);
        break;
      case 'user-disabled':
        showCustomToast("This account has been disabled.", context);
        break;
      case 'too-many-requests':
        showCustomToast("Too many login attempts. Try again later.", context);
        break;
      case 'invalid-credential':
        showCustomToast(
          "Invalid credentials. Please provide correct login details.",
          context,
        );
        break;
      default:
        showCustomToast("Login failed. ${e.message}", context);
    }

    return null;
  } catch (e) {
    showCustomToast("Something went wrong. Try again.", context);
    return null;
  }
}
  Future<void> signOut() async {
    await _auth.signOut();
  }

  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user != null) {
      // You may fetch full AppUser details from Firestore if needed
    }
    return null;
  }

  //

  Future<void> sendOtp({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {


    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),

      verificationCompleted: (PhoneAuthCredential credential) async {

        await _auth.signInWithCredential(credential);
      },

      verificationFailed: (FirebaseAuthException e) {


        if (e.code == 'too-many-requests') {

          onError("TOO MANY REQUESTS - Wait 2 hours and try again");
        } else {
          onError(e.message ?? "OTP verification failed");
        }
      },

      codeSent: (String verificationId, int? resendToken) {

        onCodeSent(verificationId);
      },

      codeAutoRetrievalTimeout: (String verificationId) {

      },
    );
  }

  Future<AppUser?> verifyOtp({
    required String verificationId,
    required String smsCode,
    required BuildContext context,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final firebaseUser = userCredential.user!;
      final uid = firebaseUser.uid;
      final phone = firebaseUser.phoneNumber ?? '';

      // 🔍 Check if user already exists
      final existingUser = await _userRepo.getByUid(uid);
      return existingUser;
    } catch (e) {
      showCustomToast("Invalid OTP", context);
      return null;
    }
  }

  Future<AppUser?> verifyOtpForRegister({
    required String verificationId,
    required String smsCode,
    required UserRole role,
    required BuildContext context,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final firebaseUser = userCredential.user!;
      final uid = firebaseUser.uid;
      final phone = firebaseUser.phoneNumber ?? '';

      // 🔍 Check if user already exists
      final existingUser = await _userRepo.getByUid(uid);
      if (existingUser != null) {
        return existingUser; // LOGIN
      }

      // 🆕 First time signup
      final newUser = AppUser(userId: uid, email: '', phone: phone, role: role);

      await _userRepo.add(newUser);
      return newUser;
    } catch (e) {
      showCustomToast("Invalid OTP", context);
      return null;
    }
  }
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
  Future<void> deleteCurrentAccount(String uid) async {
    final userRepo = UserRepository();
    final appUser = await userRepo.getByUid(uid);

    if (appUser == null) return;

    // 🔹 Soft delete
    final deletedUser = appUser.copyWith(
      isDeleted: true,
      deletedAt: DateTime.now(),
    );

    await userRepo.updateByUserId(uid, deletedUser);

    // 🔑 Sign out
    await _auth.signOut();
  }
  
  Future<AppUser?> signInWithApple(UserRole role, BuildContext context) async {
  try {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email],
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential = await _auth.signInWithCredential(oauthCredential);
    final firebaseUser   = userCredential.user!;
    final existingUser   = await _userRepo.getByUid(firebaseUser.uid);

    if (existingUser != null) {
      showCustomToast("User already exists. Please log in.", context);
      return null;
    }

    final email = firebaseUser.email ?? appleCredential.email ?? '';

    final newUser = AppUser(
      userId: firebaseUser.uid,
      email: email,
      role: role,
    );

    await _userRepo.add(newUser);

    return newUser;
  } catch (e) {
    showCustomToast("Apple login failed", context);
    return null;
  }
}
  
  Future<AppUser?> signInWithApples(BuildContext context) async {
  try {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email],
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential = await _auth.signInWithCredential(oauthCredential);
    final firebaseUser   = userCredential.user;
    //verify user exists
    if(firebaseUser==null){
      showCustomToast("No user found with that email. Please sign up first.", context);
      return null;
    }

    final existingUser   = await _userRepo.getByUid(firebaseUser.uid);
    return existingUser;
   
  } catch (e) {
    showCustomToast("Apple login failed", context);
    return null;
  }
}

}
