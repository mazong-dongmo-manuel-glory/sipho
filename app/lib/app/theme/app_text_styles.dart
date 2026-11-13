import 'package:flutter/material.dart';
import 'package:sipho/app/theme/app_colors.dart';

/// Typographie Sipho — Police Nunito
/// Titres ExtraBold, montants Black, corps Regular/SemiBold
abstract final class AppTextStyles {
  static const String _fontFamily = 'Nunito';

  // ── Display (montants géants) ─────────────────────────────────────────────
  static const TextStyle displayXl = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 56,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    height: 1.0,
  );

  static const TextStyle displayLg = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  // ── Headings ──────────────────────────────────────────────────────────────
  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ── Body ─────────────────────────────────────────────────────────────────
  static const TextStyle bodyLg = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySemiBold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // ── Labels ────────────────────────────────────────────────────────────────
  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // ── Button ───────────────────────────────────────────────────────────────
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
    height: 1.0,
  );

  // ── Material 3 / Semantic Aliases ─────────────────────────────────────────
  static const TextStyle displayLarge = displayLg;
  static const TextStyle headlineMedium = h2;
  static const TextStyle bodyLarge = bodyLg;
  static const TextStyle bodyMedium = body;
  static const TextStyle labelLarge = label;
  static const TextStyle labelMedium = labelSm;
  static const TextStyle amountDisplay = displayXl;
}
