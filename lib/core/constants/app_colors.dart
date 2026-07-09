/// Application color palette for CitApps.
///
/// Uses a professional dark theme with amber/gold accents
/// that evoke a premium barbershop aesthetic.
library;

import 'package:flutter/material.dart';

abstract class AppColors {
  // ── Primary (Amber/Gold) ──
  static const Color primary = Color(0xFFD4A853);
  static const Color primaryLight = Color(0xFFE8C97A);
  static const Color primaryDark = Color(0xFFB8892E);

  // ── Background ──
  static const Color backgroundDark = Color(0xFF0F0F0F);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF242424);
  static const Color cardLight = Color(0xFFF8F8F8);

  // ── Text ──
  static const Color textPrimaryDark = Color(0xFFE8E8E8);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF757575);

  // ── Status ──
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);

  // ── Appointment Status ──
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusConfirmed = Color(0xFF42A5F5);
  static const Color statusInProgress = Color(0xFF7E57C2);
  static const Color statusCompleted = Color(0xFF4CAF50);
  static const Color statusCancelled = Color(0xFFEF5350);
  static const Color statusNoShow = Color(0xFF78909C);

  // ── Dividers & Borders ──
  static const Color dividerDark = Color(0xFF2E2E2E);
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF3A3A3A);
  static const Color borderLight = Color(0xFFBDBDBD);

  // ── Shimmer ──
  static const Color shimmerBaseDark = Color(0xFF2A2A2A);
  static const Color shimmerHighlightDark = Color(0xFF3A3A3A);
  static const Color shimmerBaseLight = Color(0xFFE0E0E0);
  static const Color shimmerHighlightLight = Color(0xFFF5F5F5);
}
