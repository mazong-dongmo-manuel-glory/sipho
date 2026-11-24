import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../../core/widgets/sipho_page_header.dart';
import '../../../core/widgets/sipho_status_body.dart';
import '../../auth/data/user_profile_provider.dart';
import '../data/goals_provider.dart';

/// Frames 28–29 · Objectifs (Firestore `goals`) + dépôt.
class GoalsScreen extends ConsumerWidget {
  final bool empty;

  const GoalsScreen({super.key, this.empty = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final goals = ref.watch(goalsProvider);
    final currency = ref.watch(userProfileProvider).currency;
    final locale = Localizations.localeOf(context).toString();
    final showEmpty = empty || goals.isEmpty;

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: showEmpty
            ? SiphoStatusBody(
                title: l10n.goalsHeading,
                lead: l10n.goalsEmptyLead,
                cardTitle: l10n.goalsEmptyCardTitle,
                cardBody: l10n.goalsEmptyCardBody,
                ctaLabel: l10n.goalsNewCta,
                onCta: () => _createGoal(context, ref),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          SiphoPageHeader(
                            title: l10n.goalsHeading,
                            lead: l10n.goalsLead,
                          ),
                          const SizedBox(height: 20),
                          for (final g in goals) ...[
                            SiphoListRow(
                              title: g.title,
                              subtitle:
                                  '${Money(cents: g.savedCents, currency: currency).format(locale)} / ${Money(cents: g.targetCents, currency: currency).format(locale)}',
                              trailing: '${(g.progress * 100).round()} %',
                              onTap: () => context.push(
                                    '/goals/milestone',
                                    extra: {'goalId': g.id},
                                  ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: LinearProgressIndicator(
                                value: g.progress,
                                minHeight: 7,
                                backgroundColor: SiphoColors.separator,
                                valueColor: const AlwaysStoppedAnimation(
                                  SiphoColors.primary,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    _deposit(context, ref, g.id, currency),
                                child: Text(
                                  l10n.goalDepositBtn,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: SiphoColors.primaryDark,
                                  ),
                                ),
                              ),
                            ),
                            const SiphoSeparator(),
                          ],
                        ],
                      ),
                    ),
                    SiphoButton3D(
                      label: l10n.goalsNewCta,
                      variant: SiphoButtonVariant.dark,
                      onPressed: () => _createGoal(context, ref),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _deposit(
    BuildContext context,
    WidgetRef ref,
    String goalId,
    String currency,
  ) async {
    final controller = TextEditingController();
    final cents = await showDialog<int>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(l10n.goalDepositTitle),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.goalDepositAmount,
              suffixText: currency,
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.adviceLater),
            ),
            TextButton(
              onPressed: () {
                final raw =
                    controller.text.replaceAll(' ', '').replaceAll(',', '.');
                final value = double.tryParse(raw) ?? 0;
                Navigator.pop(ctx, (value * 100).round());
              },
              child: Text(l10n.goalDepositConfirm),
            ),
          ],
        );
      },
    );
    if (cents == null || cents <= 0) return;
    await ref.read(goalsProvider.notifier).deposit(goalId: goalId, cents: cents);
  }

  Future<void> _createGoal(BuildContext context, WidgetRef ref) async {
    final fr = Localizations.localeOf(context).languageCode == 'fr';
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(fr ? 'Nouvel objectif' : 'New goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: fr ? 'Titre' : 'Title',
              ),
            ),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: fr ? 'Cible' : 'Target',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(fr ? 'Annuler' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(fr ? 'Créer' : 'Create'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final major = double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0;
    if (major <= 0) return;
    await ref.read(goalsProvider.notifier).createGoal(
          title: titleCtrl.text.trim().isEmpty
              ? (fr ? 'Objectif' : 'Goal')
              : titleCtrl.text.trim(),
          targetCents: (major * 100).round(),
        );
  }
}
