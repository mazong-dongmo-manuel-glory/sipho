import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/feedback/feedback_settings.dart';
import '../../../core/firebase/cloud_functions_service.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../auth/data/auth_repository.dart';
import '../data/notif_prefs_provider.dart';

/// Frame 25 · Réglages · prefs Firestore + déconnexion / suppression.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;

  String _label(bool on) => on ? 'Activés' : 'Désactivés';
  String _labelF(bool on) => on ? 'Activées' : 'Désactivées';

  Future<void> _signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    if (!mounted) return;
    context.go('/login');
  }

  Future<void> _deleteAccount() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Supprimer mon compte'),
        content: Text(
          'Cette action est définitive (RGPD / Loi 25). '
          'Tu devras écrire DELETE MY ACCOUNT pour confirmer.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Continuer')),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmation'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'DELETE MY ACCOUNT'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Annuler')),
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, controller.text.trim() == 'DELETE MY ACCOUNT'),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final result = await ref.read(cloudFunctionsServiceProvider).deleteAccount();
    if (!mounted) return;
    setState(() => _busy = false);
    if (result['status'] == 'error') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Suppression impossible'),
          backgroundColor: SiphoColors.primaryDark,
        ),
      );
      return;
    }
    await ref.read(authRepositoryProvider).signOut();
    if (!mounted) return;
    context.go('/login');
  }

  Future<void> _pickHour(NotifPrefs prefs) async {
    final hour = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Heure du rappel'),
        children: [
          for (final h in [8, 12, 18, 19, 20, 21])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, h),
              child: Text(h == prefs.preferredHour ? '$h h  ✓' : '$h h'),
            ),
        ],
      ),
    );
    if (hour == null) return;
    await ref.read(notifPrefsProvider.notifier).setHour(hour);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(notifPrefsProvider);
    final notifier = ref.read(notifPrefsProvider.notifier);
    final feedback = ref.watch(feedbackSettingsProvider);
    final feedbackNotifier = ref.read(feedbackSettingsProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Text(
              'À ton rythme',
              style: SiphoTypography.title.copyWith(
                fontSize: 28,
                color: SiphoPalette.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu gardes le contrôle.',
              style: SiphoTypography.body.copyWith(
                fontSize: 16,
                color: SiphoPalette.textSecondary(context),
              ),
            ),
            const SizedBox(height: 20),
            SiphoListRow(
              title: 'Rappels de série',
              trailing: _label(prefs.streak),
              onTap: () => notifier.setFlag('streak', !prefs.streak),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: 'Alertes budget',
              trailing: _labelF(prefs.budget),
              onTap: () => notifier.setFlag('budget', !prefs.budget),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: 'Conseils',
              trailing: _label(prefs.tips),
              onTap: () => notifier.setFlag('tips', !prefs.tips),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: 'Échéances fixes',
              trailing: _labelF(prefs.fixedDue),
              onTap: () => notifier.setFlag('fixedDue', !prefs.fixedDue),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: 'Actualité et taux',
              trailing: _label(prefs.economy),
              onTap: () => notifier.setFlag('economy', !prefs.economy),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: 'Amis et ligue',
              trailing: _label(prefs.social),
              onTap: () => notifier.setFlag('social', !prefs.social),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: 'Heure du rappel',
              trailing: '${prefs.preferredHour} h',
              onTap: () => _pickHour(prefs),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: l10n.settingsSounds,
              trailing: feedback.sounds ? l10n.settingsEnabled : l10n.settingsDisabled,
              onTap: () => feedbackNotifier.setSounds(!feedback.sounds),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: l10n.settingsHaptics,
              trailing:
                  feedback.haptics ? l10n.settingsEnabledF : l10n.settingsDisabledF,
              onTap: () => feedbackNotifier.setHaptics(!feedback.haptics),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: l10n.settingsVoice,
              trailing: feedback.voice ? l10n.settingsEnabledF : l10n.settingsDisabledF,
              onTap: () => feedbackNotifier.setVoice(!feedback.voice),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: 'Exemples de notifications',
              showChevron: true,
              onTap: () => context.push('/notifications/examples'),
            ),
            const SizedBox(height: 24),
            SiphoButton3D(
              label: 'Se déconnecter',
              variant: SiphoButtonVariant.outline,
              onPressed: _busy ? null : _signOut,
            ),
            const SizedBox(height: 12),
            SiphoButton3D(
              label: _busy ? '…' : 'Supprimer mon compte',
              variant: SiphoButtonVariant.outline,
              onPressed: _busy ? null : _deleteAccount,
            ),
            const SizedBox(height: 16),
            Text(
              'Chaque catégorie peut être coupée.\nPromis, je respecte ton sommeil.',
              style: SiphoTypography.label.copyWith(
                fontWeight: FontWeight.w700,
                color: SiphoPalette.textSecondary(context),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
