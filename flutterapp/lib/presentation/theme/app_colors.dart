import 'package:flutter/material.dart';

/// App color constants
/// Design system: Orange primary, White/Off-white background, Dark gray text
class AppColors {
  // Primary Colors - Orange palette
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color primaryOrangeDark = Color(0xFFE85A2B);
  static const Color primaryOrangeLight = Color(0xFFFF8C61);

  // Background Colors - White/Off-white
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Text Colors - Dark gray
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textHint = Color(0xFF9E9E9E);

  // Functional Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);

  // UI Element Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFDDDDDD);
  static const Color disabled = Color(0xFFBDBDBD);

  // Chip Colors (for genre selection)
  static const Color chipSelected = primaryOrange;
  static const Color chipUnselected = Color(0xFFE0E0E0);
  static const Color chipTextSelected = Colors.white;
  static const Color chipTextUnselected = textSecondary;
}
