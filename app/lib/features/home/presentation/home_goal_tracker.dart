import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../auth/data/user_profile_provider.dart';
import '../../profile/data/goals_provider.dart';

/// Tracker d’objectif d’épargne sur l’accueil (Firestore `goals`).
class HomeGoalTrackerSection extends ConsumerWidget {
  const HomeGoalTrackerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currency = ref.watch(userProfileProvider).currency;
    final goals = ref.watch(goalsProvider);

    if (goals.isEmpty) {
      return SiphoSoftCard(
        child: Row(
          children: [
            const Text('🎯', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.goalEmptyTitle,
                    style: SiphoTypography.bodyBold.copyWith(
                      fontSize: 14,
                      color: SiphoPalette.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.goalEmptySubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: SiphoTypography.label.copyWith(
                      fontSize: 12,
                      color: SiphoPalette.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push('/goals');
              },
              child: Text(
                l10n.addGoalBtn,
                style: SiphoTypography.label.copyWith(
                  fontWeight: FontWeight.w900,
                  color: SiphoColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final active = goals.where((g) => g.savedCents < g.targetCents).toList();
    final goal = active.isNotEmpty ? active.first : goals.first;
    final locale = Localizations.localeOf(context).toString();
    final saved = Money(cents: goal.savedCents, currency: currency).format(locale);
    final target = Money(cents: goal.targetCents, currency: currency).format(locale);
    final percent = (goal.progress * 100).round();

    return SiphoSoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  goal.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SiphoTypography.bodyBold.copyWith(
                    fontSize: 15,
                    color: SiphoPalette.textPrimary(context),
                  ),
                ),
              ),
              Text(
                '$percent %',
                style: SiphoTypography.label.copyWith(
                  fontWeight: FontWeight.w800,
                  color: SiphoColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: goal.progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: SiphoPalette.separator(context),
              valueColor: const AlwaysStoppedAnimation(SiphoColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$saved / $target',
            style: SiphoTypography.label.copyWith(
              fontWeight: FontWeight.w700,
              color: SiphoPalette.textSecondary(context),
            ),
          ),
          const SizedBox(height: 12),
          SiphoButton3D(
            label: l10n.goalDepositBtn,
            variant: SiphoButtonVariant.secondary,
            height: 48,
            onPressed: () => _quickDeposit(context, ref, goal.id),
          ),
        ],
      ),
    );
  }

  Future<void> _quickDeposit(
    BuildContext context,
    WidgetRef ref,
    String goalId,
  ) async {
    final currency = ref.read(userProfileProvider).currency;
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
                final raw = controller.text.replaceAll(' ', '').replaceAll(',', '.');
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
