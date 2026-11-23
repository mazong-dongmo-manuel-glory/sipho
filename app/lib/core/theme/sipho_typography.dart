import 'package:flutter/material.dart';
import 'sipho_colors.dart';

/// Typographie Nunito officielle d'après les maquettes Figma et la spécification Sipho.
abstract final class SiphoTypography {
  static const String fontFamily = 'Nunito';

  /// Montants géants héroïques (40-56 pt, Black 900)
  static const TextStyle amountHero = TextStyle(
    fontFamily: fontFamily,
    fontSize: 44,
    fontWeight: FontWeight.w900,
    color: SiphoColors.textPrimary,
    letterSpacing: -1.0,
    height: 1.1,
  );

  /// Titres d'écrans (24-28 pt, ExtraBold 800)
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: SiphoColors.textPrimary,
    height: 1.2,
  );

  /// Sous-titres (18-20 pt, Bold 700)
  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: SiphoColors.textPrimary,
    height: 1.25,
  );

  /// Corps de texte (15-16 pt, Regular 400)
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: SiphoColors.textPrimary,
    height: 1.35,
  );

  /// Corps de texte gras (15-16 pt, Bold 700)
  static const TextStyle bodyBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: SiphoColors.textPrimary,
    height: 1.35,
  );

  /// Libellés / Badges (13 pt, SemiBold 600)
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: SiphoColors.textSecondary,
    height: 1.2,
  );

  /// Boutons (15 pt MAJ, ExtraBold 800)
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.8,
    height: 1.0,
  );
}
