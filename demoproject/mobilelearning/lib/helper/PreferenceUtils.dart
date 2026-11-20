import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async' show Future;

class PreferenceUtils {
  static late SharedPreferences _prefs;

  // call this method from iniState() function of mainApp().
  static Future<SharedPreferences> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs;
  }

  //sets
  static Future<bool> setBool(String key, bool value) async =>
      await _prefs.setBool(key, value);

  static Future<bool> setDouble(String key, double value) async =>
      await _prefs.setDouble(key, value);

  static Future<bool> setInt(String key, int value) async =>
      await _prefs.setInt(key, value);

  static Future<bool> setString(String key, String value) async =>
      await _prefs.setString(key, value);

  static Future<bool> setStringList(String key, List<String> value) async =>
      await _prefs.setStringList(key, value);

  //gets
  static bool getBool(String key, [bool? defValue]) => _prefs.getBool(key) ?? defValue ?? false;

  static double getDouble(String key, [double? defValue]) => _prefs.getDouble(key)?? defValue ?? 0;

  static int getInt(String key, [int? defValue]) => _prefs.getInt(key)?? defValue ?? 0;

  static String getString(String key, [String? defValue]) => _prefs.getString(key) ?? defValue ?? "";

  static List<String>? getStringList(String key) => _prefs.getStringList(key);

  //deletes..
  static Future<bool> remove(String key) async => await _prefs.remove(key);

  static Future<bool> clear() async => await _prefs.clear();

// static Future<String> getString(String key, [String? defValue]) async {
//   SharedPreferences prefsInstance = await SharedPreferences.getInstance();
//   return prefsInstance.getString(key) ?? defValue ?? "";
// }
//
// static Future<bool> setString(String key, String value) async {
//   SharedPreferences prefsInstance = await SharedPreferences.getInstance();
//   return prefsInstance?.setString(key, value) ?? Future.value(false);
// }
//
// static Future<int> getInt(String key, [int? defValue]) async {
//   SharedPreferences prefsInstance = await SharedPreferences.getInstance();
//   return prefsInstance.getInt(key) ?? defValue ?? 0;
// }
//
// static Future<bool> setInt(String key, int value) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   return prefs?.setInt(key, value) ?? Future.value(false);
// }
//
// static Future<double> getDouble(String key, [double? defValue]) async {
//   SharedPreferences prefsInstance = await SharedPreferences.getInstance();
//   return prefsInstance.getDouble(key) ?? defValue ?? 0;
// }
//
// static Future<bool> setDouble(String key, double value) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   return prefs?.setDouble(key, value) ?? Future.value(false);
// }
//
// static Future<bool> getBool(String key, [bool? defValue]) async {
//   SharedPreferences prefsInstance = await SharedPreferences.getInstance();
//   return prefsInstance.getBool(key) ?? defValue ?? false;
// }
//
// static Future<bool> setBool(String key, bool value) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   return prefs?.setBool(key, value) ?? Future.value(false);
// }
}
