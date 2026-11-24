import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../../core/widgets/sipho_page_header.dart';
import '../../auth/data/user_profile_provider.dart';
import '../../profile/data/goals_provider.dart';

/// Frames 49–53 · Hub simulateurs + écrans dédiés (seed depuis le profil).
enum SimulatorKind { hub, retirement, debt, compound }

class SimulatorsScreen extends StatelessWidget {
  final SimulatorKind kind;

  const SimulatorsScreen({super.key, this.kind = SimulatorKind.hub});

  @override
  Widget build(BuildContext context) {
    return switch (kind) {
      SimulatorKind.hub => const _SimHub(),
      SimulatorKind.retirement => const _RetirementSim(),
      SimulatorKind.debt => const _DebtSim(),
      SimulatorKind.compound => const _CompoundSim(),
    };
  }
}

class _SimHub extends StatelessWidget {
  const _SimHub();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            SiphoPageHeader(
              title: l10n.simHubHeading,
              lead: l10n.simHubLead,
            ),
            const SizedBox(height: 20),
            SiphoListRow(
              title: l10n.simRetirementTitle,
              subtitle: l10n.simRetirementSub,
              showChevron: true,
              onTap: () => context.push('/simulators/retirement'),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: l10n.simDebtTitle,
              subtitle: l10n.simDebtSub,
              showChevron: true,
              onTap: () => context.push('/simulators/debt'),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: l10n.simCompoundTitle,
              subtitle: l10n.simCompoundSub,
              showChevron: true,
              onTap: () => context.push('/simulators/compound'),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: l10n.familySupportHeading,
              subtitle: l10n.familySupportLead,
              showChevron: true,
              onTap: () => context.push('/family-support'),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: l10n.travelModeHeading,
              subtitle: l10n.travelModeLead,
              showChevron: true,
              onTap: () => context.push('/travel-mode'),
            ),
          ],
        ),
      ),
    );
  }
}

double _seedMonthlyFromIncome(int monthlyIncomeCents) {
  if (monthlyIncomeCents <= 0) return 200;
  final suggested = (monthlyIncomeCents / 100) * 0.1;
  return suggested.clamp(50, 800).toDouble();
}

double _seedBalanceFromGoals(List<Goal> goals) {
  if (goals.isEmpty) return 5000;
  final first = goals.first;
  final remaining = ((first.targetCents - first.savedCents) / 100).toDouble();
  if (remaining <= 0) return 5000;
  return remaining.clamp(500, 20000).toDouble();
}

class _RetirementSim extends ConsumerStatefulWidget {
  const _RetirementSim();

  @override
  ConsumerState<_RetirementSim> createState() => _RetirementSimState();
}

class _RetirementSimState extends ConsumerState<_RetirementSim> {
  late double _monthly;
  double _years = 25;
  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    final income = ref.read(userProfileProvider).monthlyIncomeCents;
    _monthly = _seedMonthlyFromIncome(income);
  }

  int get _estimateCents {
    final years = _years.round();
    const factor = 1.04;
    var pot = 0.0;
    for (var i = 0; i < years; i++) {
      pot = (pot + _monthly * 12) * factor;
    }
    return (pot * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final major = (_estimateCents / 100).round();
    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    SiphoPageHeader(
                      title: l10n.simRetirementTitle,
                      lead: l10n.simEduDisclaimer,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '$major \$',
                      style: SiphoTypography.amountHero.copyWith(
                        fontSize: 48,
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                    Text(
                      l10n.simRetirementResult,
                      style: SiphoTypography.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.simMonthlyLabel(_monthly.round().toString())),
                    Slider(
                      value: _monthly,
                      min: 50,
                      max: 800,
                      divisions: 30,
                      activeColor: SiphoColors.primary,
                      onChanged: (v) => setState(() => _monthly = v),
                    ),
                    Text(l10n.simYearsLabel(_years.round().toString())),
                    Slider(
                      value: _years,
                      min: 5,
                      max: 40,
                      divisions: 35,
                      activeColor: SiphoColors.primary,
                      onChanged: (v) => setState(() => _years = v),
                    ),
                  ],
                ),
              ),
              SiphoButton3D(
                label: l10n.doneBtn,
                variant: SiphoButtonVariant.dark,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DebtSim extends ConsumerStatefulWidget {
  const _DebtSim();

  @override
  ConsumerState<_DebtSim> createState() => _DebtSimState();
}

class _DebtSimState extends ConsumerState<_DebtSim> {
  late double _balance;
  double _extra = 50;
  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    _balance = _seedBalanceFromGoals(ref.read(goalsProvider));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final monthsBase = (_balance / 200).ceil().clamp(1, 999);
    final monthsExtra = (_balance / (200 + _extra)).ceil().clamp(1, 999);
    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    SiphoPageHeader(
                      title: l10n.simDebtTitle,
                      lead: l10n.simEduDisclaimer,
                    ),
                    const SizedBox(height: 20),
                    SiphoListRow(
                      title: l10n.simDebtBase,
                      trailing: l10n.simMonths(monthsBase),
                    ),
                    const SiphoSeparator(),
                    SiphoListRow(
                      title: l10n.simDebtFaster,
                      trailing: l10n.simMonths(monthsExtra),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.simDebtBalance(_balance.round().toString())),
                    Slider(
                      value: _balance,
                      min: 500,
                      max: 20000,
                      divisions: 39,
                      activeColor: SiphoColors.primary,
                      onChanged: (v) => setState(() => _balance = v),
                    ),
                    Text(l10n.simDebtExtra(_extra.round().toString())),
                    Slider(
                      value: _extra,
                      min: 0,
                      max: 300,
                      divisions: 30,
                      activeColor: SiphoColors.primary,
                      onChanged: (v) => setState(() => _extra = v),
                    ),
                  ],
                ),
              ),
              SiphoButton3D(
                label: l10n.doneBtn,
                variant: SiphoButtonVariant.dark,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompoundSim extends ConsumerStatefulWidget {
  const _CompoundSim();

  @override
  ConsumerState<_CompoundSim> createState() => _CompoundSimState();
}

class _CompoundSimState extends ConsumerState<_CompoundSim> {
  late double _seed;
  double _years = 10;
  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    final income = ref.read(userProfileProvider).monthlyIncomeCents;
    // ~1 mois de revenu comme graine éducative
    final major = income > 0 ? income / 100.0 : 1000.0;
    _seed = major.clamp(100, 10000).toDouble();
  }

  int get _result {
    var v = _seed;
    for (var i = 0; i < _years.round(); i++) {
      v *= 1.05;
    }
    return v.round();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    SiphoPageHeader(
                      title: l10n.simCompoundTitle,
                      lead: l10n.simEduDisclaimer,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '$_result \$',
                      style: SiphoTypography.amountHero.copyWith(
                        fontSize: 48,
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                    Text(
                      l10n.simCompoundResult,
                      style: SiphoTypography.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.simCompoundSeed(_seed.round().toString())),
                    Slider(
                      value: _seed,
                      min: 100,
                      max: 10000,
                      divisions: 99,
                      activeColor: SiphoColors.primary,
                      onChanged: (v) => setState(() => _seed = v),
                    ),
                    Text(l10n.simYearsLabel(_years.round().toString())),
                    Slider(
                      value: _years,
                      min: 1,
                      max: 30,
                      divisions: 29,
                      activeColor: SiphoColors.primary,
                      onChanged: (v) => setState(() => _years = v),
                    ),
                  ],
                ),
              ),
              SiphoButton3D(
                label: l10n.doneBtn,
                variant: SiphoButtonVariant.dark,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
