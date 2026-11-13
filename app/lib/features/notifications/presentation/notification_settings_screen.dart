import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_radius.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/notifications/data/notification_service.dart';
import 'package:sipho/features/notifications/domain/notif_prefs.dart';
import 'package:sipho/features/notifications/presentation/notification_binder.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prefs =
        ref.watch(notifPrefsProvider).valueOrNull ?? NotifPrefs.defaults;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.notifSettingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.cardRadius,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _Switch(
                    title: l10n.notifStreakTitle,
                    subtitle: l10n.notifStreakBody,
                    value: prefs.streakReminder,
                    onChanged: (value) => _save(
                      context,
                      ref,
                      prefs.copyWith(streakReminder: value),
                    ),
                  ),
                  const Divider(),
                  _Switch(
                    title: l10n.notifBudgetTitle,
                    subtitle: l10n.notifBudgetBody,
                    value: prefs.budgetAlert,
                    onChanged: (value) => _save(
                      context,
                      ref,
                      prefs.copyWith(budgetAlert: value),
                    ),
                  ),
                  const Divider(),
                  _Switch(
                    title: l10n.notifFixedTitle,
                    subtitle: l10n.notifFixedBody,
                    value: prefs.fixedDue,
                    onChanged: (value) => _save(
                      context,
                      ref,
                      prefs.copyWith(fixedDue: value),
                    ),
                  ),
                  const Divider(),
                  _Switch(
                    title: l10n.notifTipsTitle,
                    subtitle: l10n.notifTipsBody,
                    value: prefs.tips,
                    onChanged: (value) => _save(
                      context,
                      ref,
                      prefs.copyWith(tips: value),
                    ),
                  ),
                  const Divider(),
                  _Switch(
                    title: l10n.notifEconomyTitle,
                    subtitle: l10n.notifEconomyBody,
                    value: prefs.economy,
                    onChanged: (value) => _save(
                      context,
                      ref,
                      prefs.copyWith(economy: value),
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

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    NotifPrefs next,
  ) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    final l10n = AppLocalizations.of(context);
    final service = ref.read(notificationServiceProvider);
    final wantsAny = next.streakReminder ||
        next.budgetAlert ||
        next.fixedDue ||
        next.tips ||
        next.economy;
    try {
      if (wantsAny) {
        final granted = await service.enable(
          uid: uid,
          prefs: next,
          dailyTitle: l10n.notifDailyTitle,
          dailyBody: l10n.notifDailyBody,
        );
        if (!granted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.notifDenied)),
          );
        }
        return;
      }
      await service.savePrefs(
        uid: uid,
        prefs: next,
        dailyTitle: l10n.notifDailyTitle,
        dailyBody: l10n.notifDailyBody,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.onboardingSaveError)),
      );
    }
  }
}

class _Switch extends StatelessWidget {
  const _Switch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}
