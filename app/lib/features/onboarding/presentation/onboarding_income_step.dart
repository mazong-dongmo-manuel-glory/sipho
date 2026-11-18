import 'package:flutter/material.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/money/amount_input.dart';
import 'package:sipho/core/money/money_formatter.dart';
import 'package:sipho/core/widgets/sipho_art.dart';

/// Optional monthly income (README §3.1). Empty digits = skip for later.
class OnboardingIncomeStep extends StatelessWidget {
  const OnboardingIncomeStep({
    super.key,
    required this.currency,
    required this.digits,
    required this.onDigitsChanged,
  });

  final String currency;
  final String digits;
  final ValueChanged<String> onDigitsChanged;

  void _tap(String key) {
    if (key == '⌫') {
      if (digits.isNotEmpty) {
        onDigitsChanged(digits.substring(0, digits.length - 1));
      }
      return;
    }
    if (!AmountInput.canAppend(digits, key)) return;
    onDigitsChanged(digits + key);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shown = digits.isEmpty ? '0' : digits;
    final symbol = MoneyFormatter.currencySymbol(currency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SiphoArt.happy(),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.onboardingIncomeBubble,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          '$shown $symbol',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.onboardingIncomeHint,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _IncomeKeypad(onTap: _tap),
        ),
      ],
    );
  }
}

class _IncomeKeypad extends StatelessWidget {
  const _IncomeKeypad({required this.onTap});

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
          Expanded(
            child: Row(
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
                ],
              ],
            ),
          ),
      ],
    );
  }
}
