import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand ───────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1F9D55);        // Vert Sipho
  static const Color primaryDark = Color(0xFF14342B);    // Vert profond
  static const Color accent = Color(0xFFF2B705);         // Jaune tisserin
  static const Color terracotta = Color(0xFFC8553D);     // Terre cuite

  // ── Surfaces ────────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFFF8EC);     // Crème
  static const Color surface = Color(0xFFFFFFFF);        // Blanc cartes
  static const Color border = Color(0xFFEDE6D8);

  // ── Text ────────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1E2A2F);
  static const Color textSecondary = Color(0xFF5B6770);

  // ── Semantic ────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF1F9D55);
  static const Color warning = Color(0xFFF2B705);
  static const Color danger = Color(0xFFE5484D);
  static const Color info = Color(0xFF3B9FE8);

  // ── Budget gauges ────────────────────────────────────────────────────────────
  static const Color budgetOk = Color(0xFF1F9D55);    // < 70%
  static const Color budgetWarn = Color(0xFFF2B705);  // 70–90%
  static const Color budgetOver = Color(0xFFE5484D);  // > 90%

  // ── Streak flame ─────────────────────────────────────────────────────────────
  static const Color flameStart = Color(0xFFFF9F1C);
  static const Color flameEnd = Color(0xFFFF5A1F);

  // ── Dark mode overrides ──────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0D1F18);
  static const Color surfaceDark = Color(0xFF1A2E22);
  static const Color textPrimaryDark = Color(0xFFF0EAD6);
  static const Color textSecondaryDark = Color(0xFFA8B4A0);
}
