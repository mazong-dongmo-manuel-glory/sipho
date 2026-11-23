import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/money/amount_input.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/auth/data/auth_repository.dart';
import 'package:sipho/features/onboarding/presentation/onboarding_country_step.dart';
import 'package:sipho/features/onboarding/presentation/onboarding_goal_step.dart';
import 'package:sipho/features/onboarding/presentation/onboarding_income_step.dart';
import 'package:sipho/features/onboarding/presentation/onboarding_life_stage_step.dart';
import 'package:sipho/features/onboarding/presentation/onboarding_name_step.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentStep = 0;
  String _name = '';
  String _country = 'CA';
  String _currency = 'CAD';
  String _region = 'Québec';
  String _goal = 'save_for_project';
  String _lifeStage = 'first_job';
  String _incomeDigits = '';
  bool _saving = false;

  /// name → country → life stage → goal → income (README §3.1).
  static const _totalSteps = 5;

  Future<void> _finish({required bool skipIncome}) async {
    if (_saving) return;
    setState(() => _saving = true);
    final incomeCents =
        skipIncome ? 0 : AmountInput.parseCents(_incomeDigits);
    try {
      await ref.read(authRepositoryProvider).saveOnboardingProfile(
            displayName: _name.trim(),
            countryCode: _country,
            currency: _currency,
            region: _region,
            goal: _goal,
            lifeStage: _lifeStage,
            monthlyIncomeCents: incomeCents,
          );
      if (!mounted) return;
      context.go('/onboarding/nest', extra: _name.trim());
    } catch (error, stack) {
      debugPrint('onboarding saveOnboardingProfile failed: $error\n$stack');
      // Profile may already be saved (retry / race). Continue if so.
      try {
        final uid = ref.read(authRepositoryProvider).currentUser?.uid;
        if (uid != null) {
          final existing = await ref.read(authRepositoryProvider).getUser(uid);
          if (existing != null && existing.displayName.trim().isNotEmpty) {
            if (!mounted) return;
            context.go('/onboarding/nest', extra: _name.trim());
            return;
          }
        }
      } catch (recoverError) {
        debugPrint('onboarding recover-after-save failed: $recoverError');
      }
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).onboardingSaveError),
        ),
      );
    }
  }

  Future<void> _nextStep() async {
    if (_currentStep == 0 && _name.trim().isEmpty) return;
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      return;
    }
    await _finish(skipIncome: false);
  }

  void _back() {
    if (_currentStep == 0) return;
    setState(() => _currentStep--);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final heading = switch (_currentStep) {
      0 => l10n.onboardingNameHeading,
      1 => l10n.onboardingCountryHeading,
      2 => l10n.onboardingLifeHeading,
      3 => l10n.onboardingGoalHeading,
      _ => l10n.onboardingIncomeHeading,
    };
    final stepLabel = (_currentStep + 1).toString().padLeft(2, '0');
    final totalLabel = _totalSteps.toString().padLeft(2, '0');
    final lead = l10n.onboardingStepLead(stepLabel, totalLabel);
    final onIncome = _currentStep == 4;
    final button =
        onIncome ? l10n.onboardingBuildNest : l10n.continueBtn;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_currentStep > 0)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: _back,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      size: 32,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  ),
                ),
              if (_currentStep > 0) const SizedBox(height: 4),
              Text(heading, style: _heading),
              const SizedBox(height: 20),
              Text(lead, style: _lead),
              const SizedBox(height: 20),
              Expanded(
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    OnboardingNameStep(
                      initialName: _name,
                      onNameChanged: (value) => setState(() => _name = value),
                    ),
                    OnboardingCountryStep(
                      selectedCountry: _country,
                      region: _region,
                      currency: _currency,
                      onCountrySelected: (code, currency, region) {
                        setState(() {
                          _country = code;
                          _currency = currency;
                          _region = region;
                        });
                      },
                    ),
                    OnboardingLifeStageStep(
                      selected: _lifeStage,
                      onSelected: (stage) =>
                          setState(() => _lifeStage = stage),
                    ),
                    OnboardingGoalStep(
                      selectedGoal: _goal,
                      onGoalSelected: (goal) => setState(() => _goal = goal),
                    ),
                    OnboardingIncomeStep(
                      currency: _currency,
                      digits: _incomeDigits,
                      onDigitsChanged: (value) =>
                          setState(() => _incomeDigits = value),
                    ),
                  ],
                ),
              ),
              SiphoButton3D(
                label: button,
                onPressed: _nextStep,
                enabled: _currentStep > 0 || _name.trim().isNotEmpty,
                isLoading: _saving,
                color: AppColors.primaryDark,
                shadowColor: AppColors.primaryDark,
                height: 52,
                borderRadius: figmaButtonRadius,
              ),
              if (onIncome) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _saving
                      ? null
                      : () => _finish(skipIncome: true),
                  child: Text(
                    l10n.onboardingIncomeSkip,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

const _heading = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 28,
  fontWeight: FontWeight.w800,
  height: 1.3,
  color: AppColors.primaryDark,
);

const _lead = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 16,
  fontWeight: FontWeight.w400,
  height: 1.3,
  color: AppColors.textSecondary,
);
