import 'package:flutter/material.dart';

/// Centralized color palette for the application.
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A43CC);

  // Accent
  static const Color accent = Color(0xFFFF6584);
  static const Color accentLight = Color(0xFFFF91A8);

  // Background
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F1FA);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFA0AEC0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Income / Expense
  static const Color income = Color(0xFF22C55E);
  static const Color expense = Color(0xFFEF4444);

  // Borders & Dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Shadows
  static const Color shadow = Color(0x1A6C63FF);
  static const Color shadowDark = Color(0x0D000000);

  // Category Colors
  static const List<Color> categoryColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6584),
    Color(0xFF43A9A2),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
    Color(0xFF10B981),
    Color(0xFFF97316),
    Color(0xFF64748B),
  ];
}
