import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../auth/data/user_profile_provider.dart';
import '../data/budgets_provider.dart';

/// Frame 14 · Budgets · limites Firestore + dépenses du mois.
class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  Color _colorFor(BuildContext context, double progress) {
    if (progress >= 0.95) return SiphoColors.accentTerra;
    if (progress >= 0.75) return SiphoColors.accentGold;
    return SiphoPalette.textPrimary(context);
  }

  String _status(double progress) {
    final pct = (progress * 100).round().clamp(0, 999);
    if (progress >= 0.95) return '$pct % · On ralentit ?';
    if (progress >= 0.75) return '$pct % · À surveiller';
    return '$pct % · À l’aise';
  }

  Future<void> _editLimit(BuildContext context, WidgetRef ref, BudgetCategory? existing) async {
    final controller = TextEditingController(
      text: existing != null && existing.limitCents > 0
          ? (existing.limitCents / 100).toStringAsFixed(0)
          : '',
    );
    String selectedId = existing?.id ?? 'restaurants';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(
                existing == null ? 'Nouveau budget' : 'Modifier le plafond',
                style: SiphoTypography.bodyBold,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (existing == null)
                    DropdownButtonFormField<String>(
                      initialValue: selectedId,
                      items: kBudgetLabels.entries
                          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setLocal(() => selectedId = v);
                      },
                    ),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Plafond (\$)',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Annuler')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Enregistrer')),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;
    final dollars = double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
    final cents = (dollars * 100).round();
    if (cents <= 0) return;
    await ref.read(budgetsProvider.notifier).setLimit(
          categoryId: existing?.id ?? selectedId,
          limitCents: cents,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsProvider);
    final currency = ref.watch(userProfileProvider).currency;
    final now = DateTime.now();
    final monthLabel = DateFormat.yMMMM(Localizations.localeOf(context).toString()).format(now);
    final tight = budgets.where((b) => b.limitCents > 0 && b.progress >= 0.85).toList();

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Text(
              'Ton argent, en clair',
              style: SiphoTypography.title.copyWith(
                fontSize: 28,
                color: SiphoPalette.textPrimary(context),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              monthLabel,
              style: SiphoTypography.body.copyWith(
                fontSize: 16,
                color: SiphoPalette.textSecondary(context),
              ),
            ),
            const SizedBox(height: 20),
            if (budgets.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Pose un premier plafond par catégorie pour suivre ton rythme.',
                  style: SiphoTypography.body.copyWith(color: SiphoPalette.textSecondary(context)),
                ),
              )
            else
              ...budgets.map((b) {
                final progress = b.limitCents <= 0
                    ? 0.0
                    : b.progress.clamp(0.0, 1.0);
                final color = _colorFor(context, b.progress);
                final spent = Money(cents: b.spentCents, currency: currency).formatWhole();
                final limit = b.limitCents <= 0
                    ? 'sans plafond'
                    : Money(cents: b.limitCents, currency: currency).formatWhole();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () => _editLimit(context, ref, b),
                    child: Column(
                      children: [
                        SiphoListRow(
                          title: b.label,
                          subtitle: '$spent / $limit',
                          trailing: b.limitCents <= 0
                              ? 'Définir'
                              : _status(b.progress),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            backgroundColor: SiphoColors.separator,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            if (tight.isNotEmpty)
              SiphoSoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oh-oh. On ralentit ?',
                      style: SiphoTypography.bodyBold.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${tight.first.label} approche du plafond. On peut rattraper ça cette semaine.',
                      style: SiphoTypography.body.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SiphoButton3D(
              label: 'Ajouter un budget',
              variant: SiphoButtonVariant.dark,
              onPressed: () => _editLimit(context, ref, null),
            ),
            const SizedBox(height: 16),
            SiphoListRow(
              title: 'Tes graphiques',
              subtitle: '4 vues simples, sans jargon',
              showChevron: true,
              onTap: () => context.push('/charts'),
            ),
          ],
        ),
      ),
    );
  }
}
