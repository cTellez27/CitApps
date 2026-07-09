import 'package:flutter/material.dart';

/// Application color palette for CitApps.
///
/// Implements a premium, modern, and minimal design system with
/// carbon black, warm white, and soft gold accents.
abstract class AppColors {
  // ── Core Design System Colors ──
  
  /// Color Primario: Negro Carbón (#1F1F1F)
  static const Color primary = Color(0xFF1F1F1F);
  
  /// Color Secundario: Blanco Cálido (#F8F8F6)
  static const Color secondary = Color(0xFFF8F8F6);
  
  /// Fondo General: Gris Muy Claro (#F2F3F5)
  static const Color background = Color(0xFFF2F3F5);
  
  /// Superficies: Blanco (#FFFFFF)
  static const Color surface = Color(0xFFFFFFFF);
  
  /// Color de Acento: Dorado Suave (#B78D3F)
  static const Color accent = Color(0xFFB78D3F);

  // ── Text Colors ──
  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF6B7280);

  // ── States ──
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFFB78D3F); // Gold accent as info/accent indicator

  // ── Backward Compatibility Mappings (forces light premium style in both configurations) ──
  static const Color primaryLight = Color(0xFFB78D3F); // Gold
  static const Color primaryDark = Color(0xFF1F1F1F); // Carbon

  static const Color backgroundDark = Color(0xFFF2F3F5); // General grey background
  static const Color backgroundLight = Color(0xFFF2F3F5);
  static const Color surfaceDark = Color(0xFFFFFFFF); // White surface
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFFFFFFFF); // White cards
  static const Color cardLight = Color(0xFFFFFFFF);

  static const Color textPrimaryDark = Color(0xFF222222);
  static const Color textSecondaryDark = Color(0xFF6B7280);
  static const Color textPrimaryLight = Color(0xFF222222);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  static const Color dividerDark = Color(0xFFE5E7EB);
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFFD1D5DB);
  static const Color borderLight = Color(0xFFD1D5DB);

  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusConfirmed = Color(0xFFB78D3F);
  static const Color statusInProgress = Color(0xFFB78D3F);
  static const Color statusCompleted = Color(0xFF22C55E);
  static const Color statusCancelled = Color(0xFFDC2626);
  static const Color statusNoShow = Color(0xFF6B7280);

  static const Color shimmerBaseDark = Color(0xFFE5E7EB);
  static const Color shimmerHighlightDark = Color(0xFFF3F4F6);
  static const Color shimmerBaseLight = Color(0xFFE5E7EB);
  static const Color shimmerHighlightLight = Color(0xFFF3F4F6);
}
