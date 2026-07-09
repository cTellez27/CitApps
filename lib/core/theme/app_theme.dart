import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Light theme configuration for CitApps.
///
/// Implements a modern, elegant, and minimal layout using
/// Carbon Black as primary, Soft Gold as accent, and warm white surfaces.
ThemeData buildLightTheme() {
  final fontFamily = GoogleFonts.plusJakartaSans().fontFamily;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: fontFamily,

    // ── Colors ──
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary, // Negro Carbón
      onPrimary: Colors.white,
      secondary: AppColors.accent, // Dorado Suave
      onSecondary: Colors.white,
      surface: AppColors.surface, // Blanco
      onSurface: AppColors.textPrimary, // #222222
      error: AppColors.error,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.background, // Gris Muy Claro #F2F3F5

    // ── AppBar ──
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary, // Negro Carbón
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: AppSizes.appBarHeight,
    ),

    // ── Card ──
    cardTheme: CardThemeData(
      color: AppColors.surface, // Blanco
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.dividerLight, width: 0.8),
      ),
      margin: EdgeInsets.zero,
    ),

    // ── ElevatedButton ──
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent, // Dorado Suave
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0), // Rounded 14 px
        ),
        elevation: 0,
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ── OutlinedButton ──
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary, // Negro Carbón
        minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0), // Rounded 14 px
        ),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ── TextButton ──
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent, // Dorado Suave
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ── InputDecoration ──
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface, // Blanco
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5), // Dorado Suave
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
    ),

    // ── BottomNavigationBar ──
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.accent, // Dorado Suave
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // ── Divider ──
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerLight,
      thickness: 0.8,
    ),

    // ── FloatingActionButton ──
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent, // Dorado Suave
      foregroundColor: Colors.white,
      elevation: 3,
    ),

    // ── SnackBar ──
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.primary, // Negro Carbón
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // ── Dialog ──
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
