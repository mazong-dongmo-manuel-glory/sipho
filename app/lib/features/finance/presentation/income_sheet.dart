import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/money/amount_input.dart';
import 'package:sipho/core/money/money_formatter.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/auth/data/auth_repository.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';

Future<void> showMonthlyIncomeSheet(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final finance = ref.read(userFinanceProvider).valueOrNull;
  final currency = finance?.currency ?? 'CAD';
  final currentCents = finance?.monthlyIncomeCents ?? 0;
  final saved = await showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => _IncomeSheet(
      currency: currency,
      initialCents: currentCents,
    ),
  );
  if (saved == null || saved <= 0) return;

  try {
    await ref.read(authRepositoryProvider).updateMonthlyIncome(saved);
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.incomeSaveError)),
    );
  }
}

class _IncomeSheet extends StatefulWidget {
  const _IncomeSheet({required this.currency, this.initialCents = 0});

  final String currency;
  final int initialCents;

  @override
  State<_IncomeSheet> createState() => _IncomeSheetState();
}

class _IncomeSheetState extends State<_IncomeSheet> {
  late String _digits;

  @override
  void initState() {
    super.initState();
    if (widget.initialCents <= 0) {
      _digits = '';
    } else if (widget.initialCents % 100 == 0) {
      _digits = '${widget.initialCents ~/ 100}';
    } else {
      final major = widget.initialCents ~/ 100;
      final minor = (widget.initialCents % 100).toString().padLeft(2, '0');
      _digits = '$major,$minor';
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cents = AmountInput.parseCents(_digits);
    final shown = _digits.isEmpty ? '0' : _digits;
    final symbol = MoneyFormatter.currencySymbol(widget.currency);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Text(
            l10n.incomeSheetTitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$shown $symbol',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          _IncomeKeypad(onTap: _tap),
          const SizedBox(height: 8),
          SiphoButton3D(
            label: l10n.incomeSheetCta,
            enabled: cents > 0,
            onPressed: () => Navigator.of(context).pop(cents),
          ),
        ],
      ),
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
