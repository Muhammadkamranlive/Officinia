import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/Guard/AuthProvider/ThemeProvider.dart';
import 'package:client/AppColors/AppColors.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark 
                ? Colors.white.withOpacity(0.1) 
                : AppColors.green.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: isDark ? Colors.amberAccent : AppColors.darkGreen,
          size: 22,
        ),
      ),
    );
  }
}
