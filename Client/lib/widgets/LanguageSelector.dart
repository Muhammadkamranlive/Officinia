import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/LocaleProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  final bool isDashboard;
  const LanguageSelector({super.key, this.isDashboard = false});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    final bgColor = isDashboard ? Colors.white : Colors.white.withOpacity(0.15);
    final borderColor = isDashboard ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.3);
    final textColor = isDashboard ? AppColors.darkGreen : Colors.white;
    final iconColor = isDashboard ? AppColors.darkGreen : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: isDashboard ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.locale.languageCode,
          icon: Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: Icon(Icons.language, color: iconColor, size: 18),
          ),
          dropdownColor: Colors.white,
          style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600),
          onChanged: (String? newValue) {
            if (newValue != null) {
              provider.setLocale(Locale(newValue));
            }
          },
          
          items: [
            DropdownMenuItem(
              value: 'en',
              child: Text('EN', style: const TextStyle(color: Color(0xFF1A3C28))),
            ),
            DropdownMenuItem(
              value: 'fr',
              child: Text('FR', style: const TextStyle(color: Color(0xFF1A3C28))),
            ),
            DropdownMenuItem(
              value: 'ar',
              child: Text('AR', style: const TextStyle(color: Color(0xFF1A3C28))),
            ),
          ],
        ),
      ),
    );
  }
}

