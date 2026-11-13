import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/money/money.dart';
import 'package:sipho/core/money/money_formatter.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/auth/data/auth_repository.dart';
import 'package:sipho/features/finance/domain/user_finance.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/finance/presentation/income_sheet.dart';
import 'package:sipho/features/onboarding/presentation/onboarding_country_step.dart';

Future<void> showProfileEditSheet(BuildContext context, WidgetRef ref) async {
  final finance =
      ref.read(userFinanceProvider).valueOrNull ?? UserFinance.empty;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _ProfileEditSheet(initial: finance),
  );
}

class _ProfileEditSheet extends ConsumerStatefulWidget {
  const _ProfileEditSheet({required this.initial});

  final UserFinance initial;

  @override
  ConsumerState<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends ConsumerState<_ProfileEditSheet> {
  late final TextEditingController _name;
  late String _country;
  late String _currency;
  late String _region;
  late String _goal;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial.displayName);
    _name.addListener(() {
      if (mounted) setState(() {});
    });

    final matched = OnboardingCountryStep.countries
        .where((c) => c.$1 == initial.countryCode)
        .firstOrNull;
    if (matched != null) {
      _country = matched.$1;
      _currency = initial.currency.isNotEmpty ? initial.currency : matched.$4;
      _region = initial.region.isNotEmpty ? initial.region : matched.$5;
    } else {
      final fallback = OnboardingCountryStep.countries.first;
      _country =
          initial.countryCode.isNotEmpty ? initial.countryCode : fallback.$1;
      _currency = initial.currency.isNotEmpty ? initial.currency : fallback.$4;
      _region = initial.region.isNotEmpty ? initial.region : fallback.$5;
    }
    _goal = initial.goal.isNotEmpty ? initial.goal : 'save_for_project';
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n) async {
    final trimmed = _name.text.trim();
    if (trimmed.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(authRepositoryProvider).updateProfile(
            displayName: trimmed,
            countryCode: _country,
            currency: _currency,
            region: _region,
            goal: _goal,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.editProfileSaved)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.onboardingSaveError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final liveFinance = ref.watch(userFinanceProvider).valueOrNull;
    final incomeCents =
        liveFinance?.monthlyIncomeCents ?? widget.initial.monthlyIncomeCents;
    final incomeLabel = incomeCents > 0
        ? MoneyFormatter.format(
            Money(cents: incomeCents, currency: _currency),
            locale: Localizations.localeOf(context).toString(),
          )
        : l10n.homeSetIncome;

    final goals = [
      ('stop_overdraft', '🛟', l10n.onboardingGoalOverdraft),
      ('save_for_project', '🌱', l10n.onboardingGoalProject),
      ('understand_money', '💡', l10n.onboardingGoalUnderstand),
      ('prepare_future', '☀️', l10n.onboardingGoalRetire),
    ];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.editProfileTitle,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.onboardingNameLabel,
                style: _sectionStyle,
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _name,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
                decoration: InputDecoration(
                  hintText: l10n.onboardingNameHint,
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.editProfileCountry, style: _sectionStyle),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in OnboardingCountryStep.countries)
                    ChoiceChip(
                      label: Text('${c.$3} ${c.$2} (${c.$4})'),
                      selected: _country == c.$1,
                      onSelected: (_) => setState(() {
                        _country = c.$1;
                        _currency = c.$4;
                        _region = c.$5;
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.editProfileGoal, style: _sectionStyle),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final g in goals)
                    ChoiceChip(
                      label: Text('${g.$2} ${g.$3}'),
                      selected: _goal == g.$1,
                      onSelected: (_) => setState(() => _goal = g.$1),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.editProfileIncome, style: _sectionStyle),
              const SizedBox(height: 6),
              InkWell(
                onTap: () => showMonthlyIncomeSheet(context, ref),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          incomeLabel,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SiphoButton3D(
                label: l10n.incomeSheetCta,
                enabled: _name.text.trim().isNotEmpty,
                isLoading: _saving,
                color: AppColors.primary,
                shadowColor: AppColors.primaryDark,
                height: 52,
                borderRadius: figmaButtonRadius,
                onPressed: () => _save(l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _sectionStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 12,
  fontWeight: FontWeight.w800,
  color: AppColors.textSecondary,
);
