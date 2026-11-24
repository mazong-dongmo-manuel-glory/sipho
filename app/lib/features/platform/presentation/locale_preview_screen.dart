import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../expenses/presentation/expenses_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../lessons/presentation/learn_screen.dart';

/// Frames 80–82 · English Home / Expenses / Learn.
enum LocalePreviewTab { home, expenses, learn }

class LocalePreviewScreen extends StatelessWidget {
  final LocalePreviewTab tab;
  final Locale locale;

  const LocalePreviewScreen({
    super.key,
    required this.tab,
    this.locale = const Locale('en'),
  });

  @override
  Widget build(BuildContext context) {
    final child = switch (tab) {
      LocalePreviewTab.home => const HomeScreen(),
      LocalePreviewTab.expenses => const ExpensesScreen(),
      LocalePreviewTab.learn => const LearnScreen(),
    };

    return Localizations(
      locale: locale,
      delegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: SiphoPalette.background(context),
            body: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                    child: Row(
                      children: [
                        Text(
                          'EN preview',
                          style: SiphoTypography.label.copyWith(
                            fontWeight: FontWeight.w700,
                            color: SiphoPalette.textSecondary(context),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(
                            'Close',
                            style: SiphoTypography.bodyBold.copyWith(
                              color: SiphoPalette.textPrimary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          );
        },
      ),
    );
  }
}
