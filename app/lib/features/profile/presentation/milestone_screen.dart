import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_page_header.dart';
import '../../auth/data/user_profile_provider.dart';
import '../data/goals_provider.dart';

/// Frame 30 · Jalon atteint.
class MilestoneScreen extends ConsumerWidget {
  const MilestoneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final extra = GoRouterState.of(context).extra;
    String? goalId;
    if (extra is Map) {
      goalId = extra['goalId']?.toString();
    } else if (extra is String) {
      goalId = extra;
    }
    final goals = ref.watch(goalsProvider);
    Goal? goal;
    if (goalId != null) {
      for (final g in goals) {
        if (g.id == goalId) {
          goal = g;
          break;
        }
      }
    }
    goal ??= goals.isEmpty ? null : goals.first;
    final currency = ref.watch(userProfileProvider).currency;
    final locale = Localizations.localeOf(context).toString();
    final amount = Money(
      cents: goal?.savedCents ?? 0,
      currency: currency,
    ).format(locale);

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
                      title: l10n.milestoneHeading,
                      lead: goal?.title ?? l10n.milestoneLead,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: SvgPicture.asset(
                          'assets/images/sipho_happy.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      amount,
                      style: SiphoTypography.amountHero.copyWith(
                        fontSize: 56,
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                    Text(
                      l10n.milestoneKicker,
                      style: SiphoTypography.label.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                            l10n.milestoneCardTitle,
                            style: SiphoTypography.bodyBold.copyWith(
                              fontSize: 16,
                              color: SiphoPalette.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            goal == null
                                ? l10n.milestoneCardBody
                                : '${Money(cents: goal.savedCents, currency: currency).format(locale)} / ${Money(cents: goal.targetCents, currency: currency).format(locale)}',
                            style: SiphoTypography.body.copyWith(
                              fontSize: 16,
                              color: SiphoPalette.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (goal != null) ...[
                SiphoButton3D(
                  label: l10n.goalDepositBtn,
                  variant: SiphoButtonVariant.secondary,
                  onPressed: () => _deposit(context, ref, goal!.id, currency),
                ),
                const SizedBox(height: 10),
              ],
              SiphoButton3D(
                label: l10n.continueBtn,
                variant: SiphoButtonVariant.dark,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deposit(
    BuildContext context,
    WidgetRef ref,
    String goalId,
    String currency,
  ) async {
    final controller = TextEditingController();
    final cents = await showDialog<int>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(l10n.goalDepositTitle),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.goalDepositAmount,
              suffixText: currency,
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.adviceLater),
            ),
            TextButton(
              onPressed: () {
                final raw =
                    controller.text.replaceAll(' ', '').replaceAll(',', '.');
                final value = double.tryParse(raw) ?? 0;
                Navigator.pop(ctx, (value * 100).round());
              },
              child: Text(l10n.goalDepositConfirm),
            ),
          ],
        );
      },
    );
    if (cents == null || cents <= 0) return;
    await ref.read(goalsProvider.notifier).deposit(goalId: goalId, cents: cents);
  }
}
