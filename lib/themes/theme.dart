import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color lightPrimaryColor = Color(0xFF0A73BB);
  static const Color lightSecondaryColor = Color(0xFF53A6F3);
  static const Color lightAccentColor = Color(0xFFFDCA40);
  static const Color lightBackgroundColor = Color(0xFFF7F7F7);
  static const Color lightTextColor = Color(0xFF333333);
  static const Color lightGrey = Color(0xFF9E9E9E);

  // Dark Theme Colors
  static const Color darkPrimaryColor = Color(0xFF1A1A1A);
  static const Color darkSecondaryColor = Color(0xFF444444);
  static const Color darkAccentColor = Color(0xFFFDCA40);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkTextColor = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF666666);
}

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimaryColor,
    hintColor: AppColors.lightAccentColor,
    scaffoldBackgroundColor: AppColors.lightBackgroundColor,
    primaryColorDark: Colors.black,
    appBarTheme: const AppBarTheme(
      color: AppColors.lightPrimaryColor,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    iconTheme: const IconThemeData(
      color: AppColors.lightSecondaryColor,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.lightTextColor,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(fontSize: 16, color: Colors.black),
    ),
  );
}

ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimaryColor,
    hintColor: AppColors.darkAccentColor,
    scaffoldBackgroundColor: AppColors.darkBackgroundColor,
    primaryColorDark: Colors.white,
    appBarTheme: const AppBarTheme(
      color: AppColors.darkPrimaryColor,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    iconTheme: const IconThemeData(
      color: AppColors.darkSecondaryColor,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(fontSize: 16, color: Colors.white70),
      displayLarge: TextStyle(
        color: Colors.black,
      ),
    ),
  );
}
