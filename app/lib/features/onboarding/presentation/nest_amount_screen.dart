import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/amount_keypad.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../auth/data/user_profile_provider.dart';
import '../../fixed_expenses/data/fixed_expenses_provider.dart';
import '../../fixed_expenses/domain/fixed_expense.dart';

/// Frame 05 · Montant du socle — pas de presets pays en dur.
class NestAmountScreen extends ConsumerStatefulWidget {
  final String id;
  final String name;
  final String emoji;

  const NestAmountScreen({
    super.key,
    required this.id,
    required this.name,
    required this.emoji,
  });

  @override
  ConsumerState<NestAmountScreen> createState() => _NestAmountScreenState();
}

class _NestAmountScreenState extends ConsumerState<NestAmountScreen>
    with AmountInputMixin {
  bool _autoPay = false;

  @override
  void initState() {
    super.initState();
    amountString = '0';
  }

  void _save() {
    if (amountCents <= 0) return;
    final currency = ref.read(userProfileProvider).currency;
    final envelopeIds = {
      'groceries',
      'groceries_market',
      'transport',
      'transport_gbaka',
      'family',
      'family_support',
    };
    ref.read(fixedExpensesProvider.notifier).addFixedExpense(
          FixedExpense(
            id: widget.id,
            name: widget.name,
            category: widget.name,
            emoji: widget.emoji,
            amount: Money(cents: amountCents, currency: currency),
            dueDay: 1,
            type: envelopeIds.contains(widget.id) ? 'envelope' : 'bill',
            isPaid: false,
            payMode: _autoPay ? 'auto' : 'manual',
          ),
        );
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fr = Localizations.localeOf(context).languageCode == 'fr';
    final currency = ref.watch(userProfileProvider).currency;
    final money = Money(cents: amountCents, currency: currency);

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  Text(
                    fr
                        ? 'Ton ${widget.name.toLowerCase()}'
                        : 'Your ${widget.name.toLowerCase()}',
                    style: SiphoTypography.title.copyWith(
                      fontSize: 28,
                      color: SiphoPalette.textPrimary(context),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    fr
                        ? 'Un montant, un jour. Et un brin de plus.'
                        : 'One amount, one day. And one more strand.',
                    style: SiphoTypography.body.copyWith(
                      fontSize: 16,
                      color: SiphoPalette.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    money.formatWhole(),
                    style: SiphoTypography.amountHero.copyWith(
                      fontSize: 56,
                      color: SiphoPalette.textPrimary(context),
                    ),
                  ),
                  Text(
                    l10n.fixedPerMonth,
                    style: SiphoTypography.label.copyWith(
                      fontWeight: FontWeight.w700,
                      color: SiphoPalette.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SiphoListRow(
                    title: fr ? 'Prélèvement' : 'Due day',
                    trailing: fr ? '1er du mois' : '1st of month',
                  ),
                  const SiphoSeparator(
                    margin: EdgeInsets.symmetric(vertical: 14),
                  ),
                  SiphoListRow(
                    title: l10n.fixedAuto,
                    trailing: _autoPay
                        ? (fr ? 'Activé' : 'On')
                        : (fr ? 'Manuel' : 'Manual'),
                    onTap: () => setState(() => _autoPay = !_autoPay),
                  ),
                  const SizedBox(height: 16),
                  AmountKeypad(onKeyTap: onAmountKey),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SiphoButton3D(
                label: fr ? 'Ajouter au nid' : 'Add to nest',
                variant: SiphoButtonVariant.dark,
                onPressed: amountCents > 0 ? _save : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
