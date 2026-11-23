import 'package:flutter/material.dart';
import 'sipho_colors.dart';
import 'sipho_typography.dart';

abstract final class SiphoTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: SiphoTypography.fontFamily,
      scaffoldBackgroundColor: SiphoColors.background,
      colorScheme: const ColorScheme.light(
        primary: SiphoColors.primary,
        onPrimary: Colors.white,
        secondary: SiphoColors.accentGold,
        surface: SiphoColors.surface,
        onSurface: SiphoColors.textPrimary,
        error: SiphoColors.danger,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: SiphoTypography.title,
        iconTheme: IconThemeData(color: SiphoColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: SiphoColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: SiphoColors.border, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: SiphoTypography.fontFamily,
      scaffoldBackgroundColor: SiphoColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: SiphoColors.primary,
        onPrimary: Colors.white,
        secondary: SiphoColors.accentGold,
        surface: SiphoColors.darkSurface,
        onSurface: SiphoColors.darkTextPrimary,
        error: SiphoColors.danger,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: SiphoTypography.fontFamily,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: SiphoColors.darkTextPrimary,
        ),
        iconTheme: IconThemeData(color: SiphoColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: SiphoColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: SiphoColors.darkBorder, width: 1.5),
        ),
      ),
    );
  }
}
