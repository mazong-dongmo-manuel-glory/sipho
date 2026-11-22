import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/analytics/analytics_service.dart';
import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/core/feedback/feedback_service.dart';
import 'package:sipho/core/money/amount_input.dart';
import 'package:sipho/core/money/money.dart';
import 'package:sipho/core/money/money_formatter.dart';
import 'package:sipho/core/time/local_day.dart';
import 'package:sipho/core/widgets/category_chip.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/expenses/data/transaction_repository.dart';
import 'package:sipho/features/expenses/domain/expense_category.dart';
import 'package:sipho/features/expenses/domain/transaction.dart';
import 'package:sipho/features/expenses/presentation/expense_category_label.dart';
import 'package:sipho/features/finance/data/fx_rates_repository.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/gamification/data/game_state_repository.dart';

class AddExpenseSheet extends ConsumerStatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  String _digits = '';
  int _selected = 6;
  bool _saving = false;
  String? _txCurrency;

  static const _currencies = ['CAD', 'USD', 'EUR', 'XAF', 'XOF', 'GBP'];

  void _tap(String key) {
    setState(() {
      if (key == '⌫') {
        if (_digits.isNotEmpty) {
          _digits = _digits.substring(0, _digits.length - 1);
        }
        return;
      }
      if (!AmountInput.canAppend(_digits, key)) return;
      _digits += key;
    });
  }

  String _greetingName(WidgetRef ref, AppLocalizations l10n) {
    final name = ref.watch(userFinanceProvider).valueOrNull?.firstName ?? '';
    return name.isEmpty ? l10n.homeGuestName : name;
  }

  Future<void> _save(AppLocalizations l10n) async {
    final cents = AmountInput.parseCents(_digits);
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (cents <= 0 || uid == null || _saving) return;

    final mainCurrency =
        ref.read(userFinanceProvider).valueOrNull?.currency ?? 'CAD';
    final currency = _txCurrency ?? mainCurrency;
    final fx = ref.read(fxRatesProvider).valueOrNull;
    final rate = fx?.rateTo(from: currency, to: mainCurrency);
    final mainCents = fx?.convertCents(
          amountCents: cents,
          from: currency,
          to: mainCurrency,
        ) ??
        (currency == mainCurrency ? cents : null);
    if (mainCents == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.expenseFxUnavailable)),
      );
      return;
    }
    final category = kQuickExpenseCategories[_selected];
    setState(() => _saving = true);
    try {
      await ref.read(transactionRepositoryProvider).addTransaction(
            uid,
            SiphoTransaction(
              id: '',
              amountCents: cents,
              currency: currency,
              amountMainCents: mainCents,
              fxRate: rate,
              category: category.id,
              date: LocalDay.now().isoDate,
              source: 'manual',
              createdAt: DateTime.now(),
            ),
          );
      try {
        await ref.read(analyticsServiceProvider).logExpenseAdded(
              category: category.id,
              amountCents: cents,
              currency: currency,
              source: 'manual',
            );
      } catch (error) {
        debugPrint('Analytics expense_added skipped: $error');
      }
      if (!mounted) return;
      unawaited(ref.read(feedbackServiceProvider).play(SiphoCue.expenseAdded));
      final formatted = MoneyFormatter.format(
        Money(cents: cents, currency: currency),
        locale: Localizations.localeOf(context).toString(),
      );
      context.pop((
        amount: formatted,
        category: expenseCategoryLabel(l10n, category.id),
      ));
    } catch (error) {
      debugPrint('Add expense failed: $error');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.expenseSaveError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const categories = kQuickExpenseCategories;
    final mainCurrency =
        ref.watch(userFinanceProvider).valueOrNull?.currency ?? 'CAD';
    final game = ref.watch(gameStateStreamProvider).valueOrNull;
    final currency = _txCurrency ?? mainCurrency;
    final shown = _digits.isEmpty ? '0' : _digits;
    final symbol = MoneyFormatter.currencySymbol(currency);
    final cents = AmountInput.parseCents(_digits);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                8,
                AppSpacing.pagePadding,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _MiniPill(
                        AppColors.flamePill,
                        AppColors.flameText,
                        '🔥  ${game?.streak.current ?? '—'}',
                      ),
                      const SizedBox(width: 16),
                      _MiniPill(
                        AppColors.seedPill,
                        AppColors.seedText,
                        '🌾  ${game?.gems ?? '—'}',
                      ),
                      const SizedBox(width: 16),
                      _MiniPill(
                        AppColors.mint,
                        AppColors.primaryDark,
                        l10n.homeLevelPill(game?.level ?? 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.homeHello(_greetingName(ref, l10n)),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Center(child: SiphoArt.happy(frame: 120)),
                ],
              ),
            ),
            const Positioned.fill(
              child: ColoredBox(color: Color(0x2614342B)),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 168,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 49,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D6CB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.addExpenseTitle,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: const Icon(Icons.close,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          l10n.expenseCurrencyLabel,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: currency,
                          underline: const SizedBox.shrink(),
                          items: [
                            for (final code in {
                              mainCurrency,
                              ..._currencies,
                            })
                              DropdownMenuItem(
                                value: code,
                                child: Text(
                                  code,
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _txCurrency = value);
                          },
                        ),
                      ],
                    ),
                    Text(
                      '$shown $symbol',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisExtent: 72,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          return CategoryChip(
                            emoji: cat.emoji,
                            label: expenseCategoryLabel(l10n, cat.id),
                            isSelected: index == _selected,
                            onTap: () => setState(() => _selected = index),
                          );
                        },
                      ),
                    ),
                    _Keypad(onTap: _tap),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SiphoButton3D(
                            label: l10n.addExpenseCta,
                            height: 39,
                            shadowOffset: 3,
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.primary,
                            shadowColor: AppColors.primaryDark,
                            isLoading: _saving,
                            enabled: cents > 0 && !_saving,
                            onPressed: () => _save(l10n),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => context.push('/expenses/scan'),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.photo_camera_outlined,
                                color: AppColors.primary,
                                size: 24,
                              ),
                              Text(
                                l10n.addExpenseScan,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class _MiniPill extends StatelessWidget {
  const _MiniPill(this.background, this.foreground, this.label);

  final Color background;
  final Color foreground;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: foreground,
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onTap});

  final ValueChanged<String> onTap;

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    [',', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in _keys)
          Row(
            children: [
              for (var i = 0; i < row.length; i++) ...[
                if (i > 0) const SizedBox(width: 7),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Material(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () => onTap(row[i]),
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          height: 47,
                          child: Center(
                            child: row[i] == '⌫'
                                ? const Icon(
                                    Icons.backspace_outlined,
                                    color: AppColors.primaryDark,
                                  )
                                : Text(
                                    row[i],
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }
}
