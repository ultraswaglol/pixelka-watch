import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primaryColor = Color(0xFF7C4DFF);
  static const lightBg = Color.fromARGB(255, 248, 248, 248);
  static const lightSurface = Color.fromARGB(255, 238, 237, 237);
  static const lightBotBubble = Color.fromARGB(255, 255, 255, 255);
  static const lightText = Color(0xFF1E1E1E);
  static const darkBg = Color.fromARGB(255, 0, 0, 0);
  static const darkSurface = Color.fromARGB(255, 17, 17, 17);
  static const darkBotBubble = Color.fromARGB(255, 0, 0, 0);
  static const darkText = Color(0xFFE0E0E0);
}

class AppTheme {
  static final _baseInputDecoration = InputDecorationTheme(
    filled: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide.none,
    ),
    hintStyle: const TextStyle(
      fontWeight: FontWeight.w500,
    ),
  );

  static final _baseTextTheme = GoogleFonts.nunitoTextTheme(
    const TextTheme(
      bodyLarge:
          TextStyle(fontSize: 16.5, height: 1.5, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontSize: 16, height: 1.5),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );

  static const _snackBarTheme = SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    width: 400,
    showCloseIcon: true,
    insetPadding: kIsWeb
        ? EdgeInsets.only(bottom: 150, left: 16, right: 16)
        : EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      textTheme: _baseTextTheme.apply(
          bodyColor: AppColors.lightText, displayColor: AppColors.lightText),
      snackBarTheme: _snackBarTheme.copyWith(
        backgroundColor: const Color(0xFF333333),
        contentTextStyle: const TextStyle(color: Colors.white),
        closeIconColor: Colors.white70,
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryColor,
        onPrimary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightText,
        error: Color(0xFFD32F2F),
        onError: Colors.white,
        surfaceContainerHighest: AppColors.lightBotBubble,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightText,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      inputDecorationTheme: _baseInputDecoration.copyWith(
        fillColor: const Color(0xFFEFEFF0),
        hintStyle: TextStyle(
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      textTheme: _baseTextTheme.apply(
          bodyColor: AppColors.darkText, displayColor: AppColors.darkText),
      snackBarTheme: _snackBarTheme.copyWith(
        backgroundColor: const Color(0xFF333333),
        contentTextStyle: const TextStyle(color: Colors.white),
        closeIconColor: Colors.white70,
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryColor,
        onPrimary: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkText,
        error: Color(0xFFEF9A9A),
        onError: Color(0xFF1E1E1E),
        surfaceContainerHighest: AppColors.darkBotBubble,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      inputDecorationTheme: _baseInputDecoration.copyWith(
        fillColor: const Color.fromARGB(255, 0, 0, 0),
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}
