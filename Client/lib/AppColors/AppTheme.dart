import 'package:flutter/material.dart';
import 'package:client/AppColors/AppColors.dart';

class AppTheme {
  static const Color darkBackground = Colors.black;
  static const Color darkSurface    = Colors.black;
  static const Color darkCard       = Colors.black;
  
  static ThemeData lightTheme(Locale locale) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      // Allow system to find a better matching font for Arabic
      fontFamilyFallback: locale.languageCode == 'ar' ? ['system-ui', 'Roboto', 'Arial'] : null,
      brightness: Brightness.light,
      primaryColor: AppColors.green,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.card,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.greenCeladon,
        brightness: Brightness.light,
        surface: AppColors.card,
      ),
      textTheme: locale.languageCode == 'ar'
          ? const TextTheme(
              bodyLarge: TextStyle(fontWeight: FontWeight.w400, height: 1.3),
              bodyMedium: TextStyle(fontWeight: FontWeight.w400, height: 1.3),
              titleLarge: TextStyle(fontWeight: FontWeight.w600, height: 1.3),
            )
          : null,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static ThemeData darkTheme(Locale locale) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      fontFamilyFallback: locale.languageCode == 'ar' ? ['system-ui', 'Roboto', 'Arial'] : null,
      brightness: Brightness.dark,
      primaryColor: AppColors.green,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkCard,
      canvasColor: darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.greenCeladon,
        brightness: Brightness.dark,
        surface: darkSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      textTheme: locale.languageCode == 'ar'
          ? const TextTheme(
              bodyLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, height: 1.3),
              bodyMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, height: 1.3),
              titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, height: 1.3),
              displayLarge: TextStyle(color: Colors.white),
              displayMedium: TextStyle(color: Colors.white),
              displaySmall: TextStyle(color: Colors.white),
              headlineLarge: TextStyle(color: Colors.white),
              headlineMedium: TextStyle(color: Colors.white),
              headlineSmall: TextStyle(color: Colors.white),
              titleMedium: TextStyle(color: Colors.white),
              titleSmall: TextStyle(color: Colors.white),
            )
          : const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
              displayLarge: TextStyle(color: Colors.white),
              displayMedium: TextStyle(color: Colors.white),
              displaySmall: TextStyle(color: Colors.white),
              headlineLarge: TextStyle(color: Colors.white),
              headlineMedium: TextStyle(color: Colors.white),
              headlineSmall: TextStyle(color: Colors.white),
              titleLarge: TextStyle(color: Colors.white),
              titleMedium: TextStyle(color: Colors.white),
              titleSmall: TextStyle(color: Colors.white),
            ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.12),
      ),
    );
  }
}
