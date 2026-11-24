import 'package:flutter/material.dart';
import 'sipho_colors.dart';

/// Couleurs adaptatives clair / sombre (frames Accueil/Dépenses Sombre).
abstract final class SiphoPalette {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      isDark(context) ? SiphoColors.darkBackground : SiphoColors.background;

  static Color softSurface(BuildContext context) =>
      isDark(context) ? SiphoColors.darkSurface : SiphoColors.softSurface;

  static Color surface(BuildContext context) =>
      isDark(context) ? SiphoColors.darkSurface : SiphoColors.surface;

  static Color separator(BuildContext context) =>
      isDark(context) ? SiphoColors.darkBorder : SiphoColors.separator;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? SiphoColors.darkTextPrimary : SiphoColors.primaryDark;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? SiphoColors.darkTextSecondary : SiphoColors.textSecondary;

  static Color border(BuildContext context) =>
      isDark(context) ? SiphoColors.darkBorder : SiphoColors.border;

  static Color chipSurface(BuildContext context) =>
      isDark(context) ? SiphoColors.darkBorder : SiphoColors.primaryLight;

  static Color selectedChip(BuildContext context) =>
      isDark(context)
          ? SiphoColors.primary.withValues(alpha: 0.22)
          : SiphoColors.primaryLight;
}
