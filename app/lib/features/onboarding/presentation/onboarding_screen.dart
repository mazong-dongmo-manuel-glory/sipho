import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/onboarding/presentation/onboarding_country_step.dart';
import 'package:sipho/features/onboarding/presentation/onboarding_goal_step.dart';
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
  String _goal = 'understand_money';

  final int _totalSteps = 3;

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      context.go(
        '/onboarding/celebration',
        extra: {
          'name': _name,
          'country': _country,
          'currency': _currency,
          'goal': _goal,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: LinearProgressIndicator(
          value: (_currentStep + 1) / _totalSteps,
          backgroundColor: AppColors.border,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    OnboardingNameStep(
                      onNameChanged: (val) => _name = val,
                    ),
                    OnboardingCountryStep(
                      selectedCountry: _country,
                      onCountrySelected: (c, curr) {
                        _country = c;
                        _currency = curr;
                      },
                    ),
                    OnboardingGoalStep(
                      selectedGoal: _goal,
                      onGoalSelected: (g) => _goal = g,
                    ),
                  ],
                ),
              ),
              SiphoButton3D(
                text: 'CONTINUER',
                onPressed: _nextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

