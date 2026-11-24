import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_theme.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../expenses/presentation/expenses_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../lessons/presentation/learn_screen.dart';

/// Frames 76–78 · Chrome Android (barre statut Material + contenu).
enum AndroidChromeTab { home, expenses, learn }

class AndroidChromeScreen extends StatelessWidget {
  final AndroidChromeTab tab;

  const AndroidChromeScreen({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    final child = switch (tab) {
      AndroidChromeTab.home => const HomeScreen(),
      AndroidChromeTab.expenses => const ExpensesScreen(),
      AndroidChromeTab.learn => const LearnScreen(),
    };

    return Theme(
      data: SiphoTheme.lightTheme,
      child: Scaffold(
        backgroundColor: SiphoPalette.background(context),
        body: Column(
          children: [
            Container(
              height: 28,
              color: SiphoPalette.background(context),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '9:41',
                    style: SiphoTypography.label.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: SiphoPalette.textPrimary(context),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.signal_cellular_alt,
                      size: 14, color: SiphoPalette.textPrimary(context)),
                  const SizedBox(width: 6),
                  Icon(Icons.wifi, size: 14, color: SiphoPalette.textPrimary(context)),
                  const SizedBox(width: 6),
                  Icon(Icons.battery_full,
                      size: 14, color: SiphoPalette.textPrimary(context)),
                ],
              ),
            ),
            Expanded(child: child),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'Fermer chrome Android',
                        style: SiphoTypography.label.copyWith(
                          fontWeight: FontWeight.w700,
                          color: SiphoPalette.textSecondary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
