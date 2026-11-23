import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand ───────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1F9D55); // Vert Sipho
  static const Color primaryDark = Color(0xFF14342B); // Vert profond
  static const Color ink = Color(0xFF17221D); // Face du bouton Apple
  static const Color accent = Color(0xFFF2B705); // Jaune tisserin
  static const Color terracotta = Color(0xFFC8553D); // Terre cuite

  // ── Surfaces ────────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFCFCF9); // Fond clair des maquettes
  static const Color cream = Color(0xFFFFF8EC); // Alias crème
  static const Color soft = Color(0xFFF0F4EF); // Surface douce
  static const Color line = Color(0xFFE4E9E3); // Séparateur épuré
  static const Color surface = Color(0xFFFFFFFF); // Blanc cartes
  static const Color border = Color(0xFFEDE6D8);
  static const Color mint = Color(0xFFE4F2E7); // Sélection / pastille niveau
  static const Color weave = Color(0xFF23473B); // Traits du splash
  static const Color mist = Color(0xFFBDCEC3); // Texte discret sur vert
  static const Color flamePill = Color(0xFFFFF0DD);
  static const Color flameText = Color(0xFFA24413);
  static const Color seedPill = Color(0xFFFFF1C7);
  static const Color seedText = Color(0xFF765500);
  static const Color gift = Color(0xFFA57900);
  static const Color economyCard = Color(0xFFFFF6D9);
  static const Color grain = Color(0xFFB48600);
  static const Color warnBrown = Color(0xFF9A6B00);
  static const Color categoryGold = Color(0xFFA07100);
  static const Color spentMuted = Color(0xFFC2DACA);
  static const Color scanWell = Color(0xFF263A31);
  static const Color ticketPaper = Color(0xFFFFFDF4);
  static const Color quizBlue = Color(0xFF3284C5);
  static const Color quizBlueBg = Color(0xFFEDF6FF);
  static const Color pathLink = Color(0xFFD5D9BF);
  static const Color starLip = Color(0xFFB98A00);
  static const Color lockLip = Color(0xFFC7C4BC);
  static const Color lockIcon = Color(0xFF92988D);
  static const Color dayOff = Color(0xFFF1F0EB);
  static const Color flameCheck = Color(0xFFE87215);
  static const Color badgeGold = Color(0xFFAD7B00);
  static const Color badgeLock = Color(0xFF8A918B);
  static const Color switchOff = Color(0xFFD6D9D1);
  static const Color hairline = Color(0xFFF2EEE4);
  static const Color recapTrack = Color(0xFF476B53);
  static const Color recapGoldTrack = Color(0xFFD2A020);
  static const Color weaveGreen = Color(0xFF396F4E);
  static const Color weaveGold = Color(0xFFC99706);
  static const Color relegationZone = Color(0xFFFDE7E6);

  // ── Text ────────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF14342B);
  static const Color textSecondary = Color(0xFF5B6770);

  // ── Semantic ────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF1F9D55);
  static const Color warning = Color(0xFFF2B705);
  static const Color danger = Color(0xFFE5484D);
  static const Color info = Color(0xFF3B9FE8);

  // ── Budget gauges ────────────────────────────────────────────────────────────
  static const Color budgetOk = Color(0xFF1F9D55); // < 70%
  static const Color budgetWarn = Color(0xFFF2B705); // 70–90%
  static const Color budgetOver = Color(0xFFE5484D); // > 90%

  // ── Streak flame ─────────────────────────────────────────────────────────────
  static const Color flameStart = Color(0xFFFF9F1C);
  static const Color flameEnd = Color(0xFFFF5A1F);

  // ── Dark mode overrides ──────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF10261F);
  static const Color surfaceDark = Color(0xFF1B362B);
  static const Color textPrimaryDark = Color(0xFFF7F6E9);
  static const Color textSecondaryDark = Color(0xFFB8C8BC);
  static const Color nightKicker = Color(0xFF9CD9AF);
  static const Color nightPaid = Color(0xFF315444);
  static const Color nightMint = Color(0xFFA4E0B4);
  static const Color nightEconomy = Color(0xFF323B24);
  static const Color nightNav = Color(0xFF1B3028);
  static const Color nightNavActive = Color(0xFF284B3B);
  static const Color nightNavIcon = Color(0xFFE7EDE4);
}
