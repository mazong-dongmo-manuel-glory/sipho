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
        onSurface: SiphoColors.primaryDark,
        error: SiphoColors.danger,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: SiphoTypography.fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: SiphoColors.primaryDark,
          height: 1.3,
        ),
        iconTheme: IconThemeData(color: SiphoColors.primaryDark),
      ),
      dividerColor: SiphoColors.separator,
      cardTheme: CardThemeData(
        color: SiphoColors.softSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
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
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: SiphoTypography.fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: SiphoColors.darkTextPrimary,
          height: 1.3,
        ),
        iconTheme: IconThemeData(color: SiphoColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: SiphoColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: SiphoColors.darkBorder, width: 1),
        ),
      ),
    );
  }
}
