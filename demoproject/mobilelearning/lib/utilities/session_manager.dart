// import 'package:shared_preferences/shared_preferences.dart';

// class SessionManager {
//   static const String _sessionKey = 'session_token';
//   static const String _expiryKey = 'session_expiry';

//   Future<void> createSession(String token, DateTime expiry) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_sessionKey, token);
//     await prefs.setString(_expiryKey, expiry.toIso8601String());
//   }

//   Future<bool> isSessionValid() async {
//     final prefs = await SharedPreferences.getInstance();
//     final expiryString = prefs.getString(_expiryKey);
//     if (expiryString == null) {
//       return false;
//     }
//     final expiry = DateTime.parse(expiryString);
//     return DateTime.now().isBefore(expiry);
//   }

//   Future<void> clearSession() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_sessionKey);
//     await prefs.remove(_expiryKey);
//   }

//   Future<String?> getSessionToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_sessionKey);
//   }
// }
