import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_radius.dart';
import 'package:sipho/app/theme/app_spacing.dart';
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
    } catch (_) {
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
    final lead = switch (_currentStep) {
      0 => l10n.onboardingNameLead,
      1 => l10n.onboardingCountryLead,
      2 => l10n.onboardingLifeLead,
      3 => l10n.onboardingGoalLead,
      _ => l10n.onboardingIncomeLead,
    };
    final onIncome = _currentStep == 4;
    final button = onIncome
        ? l10n.onboardingBuildNest
        : l10n.continueBtn.toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _OnboardingBar(
                step: _currentStep,
                total: _totalSteps,
                onBack: _back,
              ),
              const SizedBox(height: 18),
              Text(heading, style: _heading),
              const SizedBox(height: 8),
              Text(lead, style: _lead),
              const SizedBox(height: 16),
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
                color: AppColors.primary,
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
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
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
  fontWeight: FontWeight.w900,
  height: 1.2,
  color: AppColors.primaryDark,
);

const _lead = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 16,
  fontWeight: FontWeight.w400,
  height: 1.2,
  color: AppColors.textSecondary,
);

class _OnboardingBar extends StatelessWidget {
  const _OnboardingBar({
    required this.step,
    required this.total,
    required this.onBack,
  });

  final int step;
  final int total;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: const SizedBox(
            width: 30,
            height: 36,
            child: Text(
              '‹',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 30,
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: SizedBox(
              height: 10,
              child: Stack(
                children: [
                  const ColoredBox(color: AppColors.border),
                  FractionallySizedBox(
                    widthFactor: (step + 1) / total,
                    child: const ColoredBox(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
