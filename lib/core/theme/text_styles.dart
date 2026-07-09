import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// Text styles for CitApps design system using the "Plus Jakarta Sans" font.
abstract class AppTextStyles {
  // ── Base Font Family ──
  static String get _fontFamily => GoogleFonts.plusJakartaSans().fontFamily!;

  // ── Headings ──
  
  /// Título Principal (28 px Bold)
  static TextStyle get h1 => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  /// Título de Pantalla (24 px SemiBold)
  static TextStyle get h2 => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  /// Encabezado de Sección (20 px SemiBold)
  static TextStyle get h3 => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  /// Subtítulo (18 px Medium)
  static TextStyle get h4 => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  // ── Body ──
  
  /// Texto Principal (16 px Regular)
  static TextStyle get bodyLg => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  /// Texto Secundario (14 px Regular)
  static TextStyle get bodyMd => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  /// Etiquetas y Ayuda / Texto Pequeño (12 px Regular)
  static TextStyle get bodySm => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  // ── Labels ──
  
  /// Etiquetas destacadas grandes (14 px SemiBold)
  static TextStyle get labelLg => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  /// Etiquetas destacadas medianas (12 px SemiBold)
  static TextStyle get labelMd => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  /// Etiquetas pequeñas destacadas (10 px SemiBold)
  static TextStyle get labelSm => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      );

  // ── Button ──
  static TextStyle get button => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  // ── Caption ──
  static TextStyle get caption => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );
}
