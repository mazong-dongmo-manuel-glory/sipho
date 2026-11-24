import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../auth/data/user_profile_provider.dart';
import '../../expenses/data/expenses_provider.dart';
import '../../expenses/domain/expense.dart';

class _DetectedSub {
  final String merchant;
  final int amountCents;
  final int occurrences;

  const _DetectedSub({
    required this.merchant,
    required this.amountCents,
    required this.occurrences,
  });
}

/// Frames 31–32 · Revue d’abonnements — détection depuis transactions.
class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  static const _keywords = [
    'netflix',
    'spotify',
    'disney',
    'apple',
    'google',
    'icloud',
    'youtube',
    'amazon',
    'prime',
    'crave',
    'canal',
    'deezer',
    'xbox',
    'playstation',
    'gym',
    'fitness',
    'club',
    'abo',
    'sub',
    'streaming',
    'cloud',
  ];

  List<_DetectedSub> _detect(List<Expense> expenses) {
    final byMerchant = <String, List<Expense>>{};
    for (final e in expenses) {
      final key = e.title.trim().toLowerCase();
      if (key.isEmpty) continue;
      final cat = e.category.toLowerCase();
      final looksLikeSub = _keywords.any((k) => key.contains(k)) ||
          cat == 'shopping' ||
          cat == 'phone' ||
          cat.contains('loisir') ||
          cat.contains('abonnement');
      if (!looksLikeSub) continue;
      byMerchant.putIfAbsent(key, () => []).add(e);
    }

    final out = <_DetectedSub>[];
    byMerchant.forEach((key, list) {
      if (list.isEmpty) return;
      list.sort((a, b) => b.date.compareTo(a.date));
      final latest = list.first;
      final cents = latest.amountMainCents ?? latest.amount.cents;
      out.add(_DetectedSub(
        merchant: latest.title.isEmpty ? key : latest.title,
        amountCents: cents,
        occurrences: list.length,
      ));
    });
    out.sort((a, b) => b.amountCents.compareTo(a.amountCents));
    return out.take(12).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fr = Localizations.localeOf(context).languageCode == 'fr';
    final locale = Localizations.localeOf(context).toString();
    final currency = ref.watch(userProfileProvider).currency;
    final subs = _detect(ref.watch(expensesProvider));
    final total = subs.fold<int>(0, (a, s) => a + s.amountCents);

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      fr ? 'Chasseur d’abonnements' : 'Subscription hunter',
                      style: SiphoTypography.title.copyWith(
                        fontSize: 28,
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fr
                          ? 'Revue trimestrielle · garde ce qui compte.'
                          : 'Quarterly review · keep what matters.',
                      style: SiphoTypography.body.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                    if (subs.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        Money(cents: total, currency: currency).format(locale),
                        style: SiphoTypography.amountHero.copyWith(
                          fontSize: 40,
                          color: SiphoPalette.textPrimary(context),
                        ),
                      ),
                      Text(
                        fr
                            ? 'Estimé mensuel détecté'
                            : 'Estimated monthly detected',
                        style: SiphoTypography.label.copyWith(
                          fontWeight: FontWeight.w700,
                          color: SiphoPalette.textSecondary(context),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (subs.isEmpty)
                      SiphoSoftCard(
                        child: Text(
                          fr
                              ? 'Aucun abonnement détecté pour l’instant. Note des dépenses (streaming, cloud, sport…) et reviens ici.'
                              : 'No subscriptions detected yet. Log spending (streaming, cloud, gym…) and come back.',
                          style: SiphoTypography.bodyBold.copyWith(
                            fontSize: 16,
                            color: SiphoPalette.textPrimary(context),
                          ),
                        ),
                      )
                    else
                      for (final s in subs) ...[
                        SiphoListRow(
                          title: s.merchant,
                          subtitle: fr
                              ? '${s.occurrences} occurrence(s)'
                              : '${s.occurrences} occurrence(s)',
                          trailing: Money(
                            cents: s.amountCents,
                            currency: currency,
                          ).format(locale),
                          onTap: () => context.push(
                            '/subscriptions/trimmed',
                            extra: {
                              'merchant': s.merchant,
                              'amountCents': s.amountCents,
                              'currency': currency,
                            },
                          ),
                        ),
                        const SiphoSeparator(),
                      ],
                    const SizedBox(height: 16),
                    SiphoSoftCard(
                      child: Text(
                        fr
                            ? 'Un abonnement allégé = un brin de plus pour ton nid.'
                            : 'A trimmed subscription frees a bit more for your nest.',
                        style: SiphoTypography.bodyBold.copyWith(
                          fontSize: 16,
                          color: SiphoPalette.textPrimary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SiphoButton3D(
                label: fr ? 'Marquer la revue faite' : 'Mark review done',
                variant: SiphoButtonVariant.dark,
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString(
                    'sipho_subs_review_at',
                    DateTime.now().toIso8601String(),
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        fr ? 'Revue notée. Bravo !' : 'Review noted. Nice!',
                      ),
                    ),
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
