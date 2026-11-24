import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../auth/data/user_profile_provider.dart';
import '../data/fixed_expenses_provider.dart';

/// Frame 13 · Socle et enveloppes · Épuré.
class SocleScreen extends ConsumerWidget {
  const SocleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(userProfileProvider);
    final fixed = ref.watch(fixedExpensesProvider);
    final total = ref.watch(totalFixedExpensesCentsProvider);

    final bills = fixed.where((e) => e.id != 'groceries' && e.id != 'transport').toList();
    final envelopes = fixed.where((e) => e.id == 'groceries' || e.id == 'transport').toList();

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Text(
              'Ton socle',
              style: SiphoTypography.title.copyWith(
                fontSize: 28,
                color: SiphoPalette.textPrimary(context),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.socleSubtitle,
              style: SiphoTypography.body.copyWith(
                fontSize: 16,
                color: SiphoPalette.textSecondary(context),
              ),
            ),
            const SizedBox(height: 16),
            SiphoListRow(
              title: 'Socle mensuel',
              trailing: Money(cents: total, currency: user.currency).formatWhole(),
            ),
            const SizedBox(height: 16),
            ...bills.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  children: [
                    SiphoListRow(
                      title: f.name,
                      subtitle: f.isPaid ? '✓ ${l10n.homePaid}' : f.dueDayLabel,
                      trailing: f.amount.formatWhole(),
                      onTap: () => ref.read(fixedExpensesProvider.notifier).togglePaid(f.id),
                    ),
                    const SiphoSeparator(margin: EdgeInsets.symmetric(vertical: 12)),
                  ],
                ),
              ),
            ),
            Text(
              'ENVELOPPES VARIABLES',
              style: SiphoTypography.label.copyWith(
                fontWeight: FontWeight.w700,
                color: SiphoPalette.textSecondary(context),
              ),
            ),
            const SizedBox(height: 12),
            ...envelopes.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SiphoListRow(
                  title: f.name.replaceAll(' (enveloppe)', ''),
                  subtitle: 'Budget du mois, pas une facture',
                  trailing: f.amount.formatWhole(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
