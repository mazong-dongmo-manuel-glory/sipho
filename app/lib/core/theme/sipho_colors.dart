import 'package:flutter/material.dart';

/// Tokens Sipho — style « Épuré » (Figma) + identité de marque (README).
abstract final class SiphoColors {
  // Primaires
  static const Color primary = Color(0xFF1F9D55); // Vert Sipho
  static const Color primaryDark = Color(0xFF14342B); // Vert profond / titres / ombre 3D
  static const Color primaryLight = Color(0xFFE4F2E7); // Pastille onglet actif / jauge piste

  // Accents
  static const Color accentGold = Color(0xFFF2B705); // Jaune tisserin / XP / leçons terminées
  static const Color accentGoldEdge = Color(0xFFB98A00);
  static const Color accentTerra = Color(0xFFC8553D); // Terre cuite

  // Surfaces épurées
  static const Color background = Color(0xFFFCFCF9); // Fond clair épuré
  static const Color softSurface = Color(0xFFF0F4EF); // Cartes / bulles douces
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFEDE6D8);
  static const Color separator = Color(0xFFE4E9E3);

  // Textes
  static const Color textPrimary = Color(0xFF1E2A2F);
  static const Color textSecondary = Color(0xFF5B6770);
  static const Color textMuted = Color(0xFF8E9BA4);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Alertes & Statuts
  static const Color warning = Color(0xFFF2B705); // 70-90% du budget
  static const Color danger = Color(0xFFE5484D); // > 90% du budget
  static const Color success = Color(0xFF1F9D55);

  // Dégradé Flamme de Série
  static const Color flameStart = Color(0xFFFF9F1C);
  static const Color flameEnd = Color(0xFFFF5A1F);

  // Leçons
  static const Color lessonLockedFace = Color(0xFFEDE6D8);
  static const Color lessonLockedEdge = Color(0xFFC7C4BC);
  static const Color lessonLockedIcon = Color(0xFF92988D);
  static const Color lessonStarIcon = Color(0xFF765500);

  // Mode Sombre
  static const Color darkBackground = Color(0xFF121B18);
  static const Color darkSurface = Color(0xFF1A2622);
  static const Color darkBorder = Color(0xFF263833);
  static const Color darkTextPrimary = Color(0xFFF0F4F2);
  static const Color darkTextSecondary = Color(0xFFA2B4AC);
}
