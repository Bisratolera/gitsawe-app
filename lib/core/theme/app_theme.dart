import 'package:flutter/material.dart';

class AppColors {
  static const maroon = Color(0xFF2B1620);   // app bar / background
  static const maroonDark = Color(0xFF1F0F17);
  static const gold = Color(0xFFF2C744);     // "ግዕዝ" chip
  static const green = Color(0xFF2E9E5B);    // "English" chip
  static const cream = Color(0xFFF7F3EE);    // body text background
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.maroon,
        primary: AppColors.maroon,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.maroon,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      fontFamily: 'NotoSansEthiopic', // add this font for proper Ge'ez glyphs
    );
  }
}