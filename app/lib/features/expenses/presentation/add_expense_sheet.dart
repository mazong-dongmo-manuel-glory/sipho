import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../../core/widgets/sipho_page_header.dart';
import '../../auth/data/user_profile_provider.dart';
import '../../economy/data/economy_provider.dart';
import '../../expenses/data/expenses_provider.dart';

/// Frames 09 + 26 + 27 · Saisie express (montant → catégorie → validation).
class AddExpenseSheet extends ConsumerStatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  int _step = 0; // 0 montant · 1 catégorie · 2 validation
  String _amountString = '0';
  String _selectedCategory = 'restaurants';
  String _merchant = '';
  String? _entryCurrency;
  bool _travelPrefApplied = false;

  static const _currencies = ['CAD', 'EUR', 'USD', 'XOF', 'GBP'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_travelPrefApplied) return;
    _travelPrefApplied = true;
    final user = ref.read(userProfileProvider);
    if (user.travelModeEnabled && user.travelCurrency.isNotEmpty) {
      _entryCurrency = user.travelCurrency;
    }
  }

  /// ids alignés sur `ALLOWED_EXPENSE_CATEGORIES` (serveur).
  static const _categories = <(String id, String label)>[
    ('groceries', 'Épicerie'),
    ('restaurants', 'Restos'),
    ('transport', 'Transport'),
    ('shopping', 'Shopping'),
    ('family', 'Soutien à la famille'),
    ('phone', 'Téléphone'),
  ];

  int get _cents {
    final clean = _amountString.replaceAll(' ', '').replaceAll(',', '.');
    final value = double.tryParse(clean) ?? 0;
    return (value * 100).round();
  }

  void _onKeyTap(String key) {
    setState(() {
      if (key == '⌫') {
        if (_amountString.length > 1) {
          _amountString = _amountString.substring(0, _amountString.length - 1);
        } else {
          _amountString = '0';
        }
      } else if (key == ',') {
        if (!_amountString.contains(',')) _amountString += ',';
      } else {
        if (_amountString == '0') {
          _amountString = key;
        } else {
          _amountString += key;
        }
      }
    });
  }

  int _toMainCents({
    required int amountCents,
    required String from,
    required String to,
    required String fxBase,
    required Map<String, double> rates,
  }) {
    if (from == to || amountCents <= 0) return amountCents;
    double toBase(String ccy, double amount) {
      if (ccy == fxBase) return amount;
      final r = rates[ccy];
      if (r == null || r == 0) return amount;
      return amount / r;
    }

    double fromBase(String ccy, double amountInBase) {
      if (ccy == fxBase) return amountInBase;
      final r = rates[ccy];
      if (r == null) return amountInBase;
      return amountInBase * r;
    }

    final inBase = toBase(from, amountCents / 100.0);
    return (fromBase(to, inBase) * 100).round();
  }

  void _next() {
    if (_step == 0) {
      if (_cents <= 0) return;
      setState(() => _step = 1);
      return;
    }
    if (_step == 1) {
      setState(() => _step = 2);
      return;
    }

    final user = ref.read(userProfileProvider);
    final eco = ref.read(economyProvider);
    final entry = _entryCurrency ?? user.currency;
    final main = user.currency;
    final mainCents = _toMainCents(
      amountCents: _cents,
      from: entry,
      to: main,
      fxBase: eco.fxBase,
      rates: eco.fxRates,
    );
    final fxRate = _cents <= 0 ? 1.0 : mainCents / _cents;
    final label = _categories
        .firstWhere(
          (c) => c.$1 == _selectedCategory,
          orElse: () => (_selectedCategory, _selectedCategory),
        )
        .$2;
    final merchant = _merchant.trim().isEmpty ? label : _merchant.trim();
    ref.read(expensesProvider.notifier).addExpense(
          title: merchant,
          category: _selectedCategory,
          emoji: _emojiFor(_selectedCategory),
          amount: Money(cents: _cents, currency: entry),
          amountMainCents: mainCents,
          fxRate: fxRate,
          entryCurrency: entry,
        );
    final mainMoney = Money(cents: mainCents, currency: main);
    context.pushReplacement('/expenses/reward', extra: {
      'amount': mainMoney.format(),
      'category': label,
      'merchant': merchant,
      'xp': 2, // mirrors XP_CONFIG.transactionAdd (server awards)
    });
  }

  String _emojiFor(String cat) => switch (cat) {
        'groceries' => '🛒',
        'restaurants' => '🍔',
        'transport' => '🚌',
        'shopping' => '🛍️',
        'family' => '💌',
        'phone' => '📱',
        _ => '✨',
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat.yMMMd(locale).format(DateTime.now());
    final mainCurrency = ref.watch(userProfileProvider).currency;
    final entry = _entryCurrency ?? mainCurrency;
    final eco = ref.watch(economyProvider);
    final mainCents = _toMainCents(
      amountCents: _cents,
      from: entry,
      to: mainCurrency,
      fxBase: eco.fxBase,
      rates: eco.fxRates,
    );

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  if (_step == 0) ...[
                    SiphoPageHeader(
                      title: l10n.expenseAmountHeading,
                      lead: l10n.expenseStepLead('1', '3'),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final ccy in {
                          mainCurrency,
                          ..._currencies,
                        })
                          ChoiceChip(
                            label: Text(ccy),
                            selected: entry == ccy,
                            onSelected: (_) =>
                                setState(() => _entryCurrency = ccy),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        '$_amountString $entry',
                        style: SiphoTypography.amountHero.copyWith(
                          fontSize: 48,
                          color: SiphoPalette.textPrimary(context),
                        ),
                      ),
                    ),
                    if (entry != mainCurrency && _cents > 0) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          '≈ ${Money(cents: mainCents, currency: mainCurrency).format()}',
                          style: SiphoTypography.label.copyWith(
                            fontWeight: FontWeight.w700,
                            color: SiphoPalette.textSecondary(context),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SiphoButton3D(
                      label: l10n.expenseScanCta,
                      variant: SiphoButtonVariant.outline,
                      icon: const Icon(Icons.photo_camera_outlined, size: 22),
                      onPressed: () => context.push('/expenses/scan'),
                    ),
                    const SizedBox(height: 16),
                    _Keypad(onKeyTap: _onKeyTap),
                  ] else if (_step == 1) ...[
                    SiphoPageHeader(
                      title: l10n.expenseCategoryHeading,
                      lead: l10n.expenseCategoryLead(
                        Money(cents: _cents, currency: entry).format(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (final cat in _categories) ...[
                      SiphoListRow(
                        title: cat.$2,
                        trailing: _selectedCategory == cat.$1 ? '✓' : '○',
                        onTap: () =>
                            setState(() => _selectedCategory = cat.$1),
                      ),
                      const SiphoSeparator(),
                    ],
                  ] else ...[
                    SiphoPageHeader(
                      title: l10n.expenseConfirmHeading,
                      lead: l10n.expenseConfirmLead,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      Money(cents: _cents, currency: entry).format(),
                      style: SiphoTypography.amountHero.copyWith(
                        fontSize: 48,
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                    if (entry != mainCurrency) ...[
                      const SizedBox(height: 4),
                      Text(
                        '≈ ${Money(cents: mainCents, currency: mainCurrency).format()}',
                        style: SiphoTypography.label.copyWith(
                          fontWeight: FontWeight.w700,
                          color: SiphoPalette.textSecondary(context),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SiphoListRow(
                      title: l10n.expenseConfirmCategory,
                      trailing: _categories
                          .firstWhere(
                            (c) => c.$1 == _selectedCategory,
                            orElse: () =>
                                (_selectedCategory, _selectedCategory),
                          )
                          .$2,
                    ),
                    const SiphoSeparator(),
                    SiphoListRow(
                      title: l10n.expenseConfirmDate,
                      trailing: dateLabel,
                    ),
                    const SiphoSeparator(),
                    SiphoListRow(
                      title: l10n.expenseConfirmMerchant,
                      trailing: _merchant.trim().isEmpty
                          ? '—'
                          : _merchant.trim(),
                      onTap: () async {
                        final controller =
                            TextEditingController(text: _merchant);
                        final value = await showDialog<String>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l10n.expenseConfirmMerchant),
                            content: TextField(
                              controller: controller,
                              autofocus: true,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(l10n.adviceLater),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, controller.text),
                                child: Text(l10n.saveBtn),
                              ),
                            ],
                          ),
                        );
                        if (value != null) {
                          setState(() => _merchant = value.trim());
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() => _step = 0),
                      child: Text(
                        l10n.expenseConfirmEdit,
                        style: SiphoTypography.bodyBold.copyWith(
                          color: SiphoPalette.textPrimary(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: SiphoPalette.softSurface(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.expenseConfirmPrivacyTitle,
                            style: SiphoTypography.bodyBold.copyWith(
                              fontSize: 16,
                              color: SiphoPalette.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.expenseConfirmPrivacyBody,
                            style: SiphoTypography.body.copyWith(
                              fontSize: 16,
                              color: SiphoPalette.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  if (_step > 0)
                    IconButton(
                      onPressed: () => setState(() => _step--),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: SiphoPalette.textPrimary(context),
                    ),
                  if (_step == 0)
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: SiphoPalette.textPrimary(context),
                    ),
                  Expanded(
                    child: SiphoButton3D(
                      label: _step == 2 ? l10n.saveBtn : l10n.continueBtn,
                      variant: SiphoButtonVariant.dark,
                      onPressed: _next,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  final ValueChanged<String> onKeyTap;

  const _Keypad({required this.onKeyTap});

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      [',', '0', '⌫'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((k) {
              return SizedBox(
                width: 80,
                height: 56,
                child: TextButton(
                  onPressed: () => onKeyTap(k),
                  style: TextButton.styleFrom(
                    backgroundColor: SiphoPalette.softSurface(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    k,
                    style: SiphoTypography.amountHero.copyWith(
                      fontSize: 24,
                      color: SiphoPalette.textPrimary(context),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
