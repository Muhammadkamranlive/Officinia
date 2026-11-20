import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = lightTheme;

  ThemeData get currentTheme => _currentTheme;

  // Define the light and dark themes here
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    hintColor: Colors.green,
    // Customize other theme properties as needed
    appBarTheme: const AppBarTheme(
      color: Colors.blue, // Customize app bar color for light theme
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Colors.green, // Customize text color for light theme
      ),
      displayLarge: TextStyle(
          color: Colors.black, fontSize: 16, fontWeight: FontWeight.w800),
      // Customize other text styles as needed
    ),
    // Customize other theme properties as needed
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.orange,
    hintColor: Colors.orange,
    // Customize other theme properties as needed
    appBarTheme: const AppBarTheme(
      color: Colors.black, // Customize app bar color for dark theme
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Colors.white, // Customize text color for dark theme
      ),
      displayLarge: TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
      // Customize other text styles as needed
    ), // Customize other theme properties as needed
  );

  ThemeProvider() {
    _loadThemePreference();
  }

  void toggleTheme() async {
    _currentTheme = _currentTheme == lightTheme ? darkTheme : lightTheme;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkModeEnabled', _currentTheme == darkTheme);

    notifyListeners();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkModeEnabled = prefs.getBool('isDarkModeEnabled') ?? false;
    _currentTheme = isDarkModeEnabled ? darkTheme : lightTheme;
    notifyListeners();
  }
}
