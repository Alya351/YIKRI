import 'package:flutter/material.dart';

class AppColors {
  static const Color green = Color(0xFF1B7A4E);
  static const Color greenLight = Color(0xFFE8F5EE);
  static const Color greenMid = Color(0xFF2EA366);
  static const Color gold = Color(0xFFD4920A);
  static const Color goldLight = Color(0xFFFEF7E6);
  static const Color goldMid = Color(0xFFF0AC2B);
  static const Color background = Color(0xFFF7F9F8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color dark = Color(0xFF0F1F17);
  static const Color dark2 = Color(0xFF1E3828);
  static const Color text = Color(0xFF1A2E22);
  static const Color text2 = Color(0xFF4A6357);
  static const Color text3 = Color(0xFF8FA99A);
  static const Color border = Color(0xFFE2EDE8);
  static const Color red = Color(0xFFE03E2D);
  static const Color redLight = Color(0xFFFEF0EE);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,
        brightness: Brightness.light,
        surface: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      // Utiliser la police locale PlusJakartaSans — pas de téléchargement réseau
      fontFamily: 'PlusJakartaSans',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}