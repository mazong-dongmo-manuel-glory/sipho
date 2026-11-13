import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/analytics/analytics_service.dart';
import 'package:sipho/core/money/amount_input.dart';
import 'package:sipho/core/money/money_formatter.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/expenses/presentation/expense_category_label.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/fixed_expenses/data/fixed_expense_repository.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_expense.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_expense_draft.dart';

class FixedAmountScreen extends ConsumerStatefulWidget {
  const FixedAmountScreen({super.key, this.draft});

  final FixedExpenseDraft? draft;

  @override
  ConsumerState<FixedAmountScreen> createState() => _FixedAmountScreenState();
}

class _FixedAmountScreenState extends ConsumerState<FixedAmountScreen> {
  String _digits = '';
  bool _automatic = true;
  int _dueDay = 1;
  bool _saving = false;

  FixedExpenseDraft get _draft => widget.draft ?? kSocleTemplates.first;

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

  Future<void> _save(AppLocalizations l10n) async {
    final cents = AmountInput.parseCents(_digits);
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (cents <= 0 || uid == null || _saving) return;

    setState(() => _saving = true);
    try {
      await ref.read(fixedExpenseRepositoryProvider).addFixedExpense(
            uid,
            FixedExpense(
              id: '',
              name: expenseCategoryLabel(l10n, _draft.categoryId),
              category: _draft.categoryId,
              icon: _draft.emoji,
              amountCents: cents,
              dueDay: _dueDay,
              payMode: _automatic ? 'auto' : 'manual',
              type: _draft.type,
              createdAt: DateTime.now(),
            ),
          );
      try {
        await ref.read(analyticsServiceProvider).logFixedExpenseAdded(
              category: _draft.categoryId,
              amountCents: cents,
            );
      } catch (error) {
        debugPrint('Analytics fixed_expense_added skipped: $error');
      }
      if (!mounted) return;
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go('/onboarding/ready');
      }
    } catch (error) {
      debugPrint('Add fixed expense failed: $error');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.socleSaveError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shown = _digits.isEmpty ? '0' : _digits;
    final currency =
        ref.watch(userFinanceProvider).valueOrNull?.currency ?? 'CAD';
    final symbol = MoneyFormatter.currencySymbol(currency);
    final cents = AmountInput.parseCents(_digits);
    final title = expenseCategoryLabel(l10n, _draft.categoryId);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Column(
            children: [
              SizedBox(
                height: 36,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: const Text(
                          '‹',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      l10n.fixedSocle,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_draft.emoji}  $title',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$shown $symbol',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                l10n.fixedEachMonth,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  height: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              _Keypad(onTap: _tap),
              const SizedBox(height: 16),
              Container(
                height: 62,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.fixedDueValue(_dueDay),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    _DayStep(
                      icon: Icons.remove,
                      onTap: () {
                        if (_dueDay > 1) setState(() => _dueDay -= 1);
                      },
                    ),
                    const SizedBox(width: 8),
                    _DayStep(
                      icon: Icons.add,
                      onTap: () {
                        if (_dueDay < 31) setState(() => _dueDay += 1);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.fixedAuto,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  Switch(
                    value: _automatic,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primary,
                    onChanged: (value) => setState(() => _automatic = value),
                  ),
                ],
              ),
              const Spacer(),
              SiphoButton3D(
                label: l10n.fixedAdd,
                enabled: cents > 0 && !_saving,
                isLoading: _saving,
                onPressed: () => _save(l10n),
                color: AppColors.primary,
                shadowColor: AppColors.primaryDark,
                height: 52,
                borderRadius: figmaButtonRadius,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayStep extends StatelessWidget {
  const _DayStep({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.seedPill,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: AppColors.primaryDark, size: 18),
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
        for (final row in _keys) ...[
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
      ],
    );
  }
}
