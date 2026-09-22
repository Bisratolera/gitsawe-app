import 'package:flutter/material.dart';

class AppColors {
  static const maroon = Color(0xFF422129); // Deeper, more modern maroon
  static const maroonDark = Color(0xFF2B1015);
  static const gold = Color(0xFFD4AF37); // Metallic gold
  static const green = Color(0xFF1B5E20); // Forest green
  static const cream = Color(0xFFF9F7F2); // Softer cream background
  static const ink = Color(0xFF2C2C2C); // Dark grey for text
  static const secondary = Color(0xFFE9E4DE);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.maroon,
        primary: AppColors.maroon,
        secondary: AppColors.gold,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.maroon,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.maroon,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'NotoSansEthiopic',
        ),
        iconTheme: IconThemeData(color: AppColors.maroon),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black12),
        ),
        color: AppColors.cream,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.ink, fontFamily: 'NotoSansEthiopic'),
        bodyMedium: TextStyle(color: AppColors.ink, fontFamily: 'NotoSansEthiopic'),
        titleLarge: TextStyle(
            color: AppColors.maroon,
            fontWeight: FontWeight.bold,
            fontFamily: 'NotoSansEthiopic'),
      ),
      dividerTheme: const DividerThemeData(
        thickness: 1,
        color: Colors.black12,
      ),
      fontFamily: 'NotoSansEthiopic',
    );
  }

static ThemeData get darkTheme {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.gold,
    brightness: Brightness.dark,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF171114),
    colorScheme: scheme,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontFamily: 'NotoSansEthiopic'),
      bodyMedium: TextStyle(color: Colors.white, fontFamily: 'NotoSansEthiopic'),
      bodySmall: TextStyle(color: Color(0xFFCEC4C7), fontFamily: 'NotoSansEthiopic'),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'NotoSansEthiopic'),
    ),
    dividerTheme: DividerThemeData(thickness: 1, color: scheme.outlineVariant),
    fontFamily: 'NotoSansEthiopic',
  );
}
}