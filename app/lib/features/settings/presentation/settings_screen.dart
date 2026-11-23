import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/core/feedback/feedback_service.dart';
import 'package:sipho/core/feedback/feedback_settings.dart';
import 'package:sipho/core/legal/sipho_legal.dart';
import 'package:sipho/core/sound/sound_service.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/auth/data/auth_repository.dart';
import 'package:sipho/features/profile/presentation/profile_edit_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _prefsKey = kSettingsTogglesKey;
  final _on = <bool>[true, true, false, true, false, true, true, true, false];

  @override
  void initState() {
    super.initState();
    _loadToggles();
  }

  Future<void> _loadToggles() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_prefsKey);
    if (stored == null || !mounted) return;
    setState(() {
      for (var i = 0; i < _on.length && i < stored.length; i++) {
        _on[i] = stored[i] == '1';
      }
    });
  }

  Future<void> _setToggle(int index, bool value) async {
    setState(() => _on[index] = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      _on.map((on) => on ? '1' : '0').toList(),
    );
    // Let the sound / vibration service pick the new preference up right away,
    // and let the user feel / hear what they just switched on.
    await ref.read(feedbackSettingsProvider.notifier).reload();
    if (!value) return;
    if (index == kSoundsToggleIndex) {
      unawaited(ref.read(soundServiceProvider).play(SiphoSound.ding));
    } else if (index == kHapticsToggleIndex) {
      unawaited(performSystemHaptic(HapticKind.medium));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = <({String label, VoidCallback? onLabel})>[
      (label: l10n.settingsStreak, onLabel: null),
      (label: l10n.settingsBudget, onLabel: null),
      (label: l10n.settingsFriends, onLabel: null),
      (label: l10n.settingsTips, onLabel: null),
      (label: l10n.settingsEconomy, onLabel: null),
      (label: l10n.settingsRecap, onLabel: () => context.push('/recap')),
      (label: l10n.settingsSounds, onLabel: null),
      (label: l10n.settingsHaptics, onLabel: null),
      (label: l10n.settingsVoice, onLabel: null),
    ];
    String statusFor(int index, bool on) {
      final feminine = index == 1 || index == 7 || index == 8; // budget, haptics, voice
      if (on) {
        return feminine ? l10n.settingsEnabledF : l10n.settingsEnabled;
      }
      return feminine ? l10n.settingsDisabledF : l10n.settingsDisabled;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            16,
            AppSpacing.pagePadding,
            24,
          ),
          children: [
            // Frame 25 · Réglages · Épuré
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.primaryDark,
                    size: 28,
                  ),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    l10n.settingsTitle,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.settingsSubtitle,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.3,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < rows.length; i++) ...[
              _PrefRow(
                label: rows[i].label,
                status: statusFor(i, _on[i]),
                on: _on[i],
                onChanged: (value) => _setToggle(i, value),
                onLabel: rows[i].onLabel,
              ),
              if (i != rows.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, thickness: 1, color: AppColors.line),
                ),
            ],
            const SizedBox(height: 16),
            _PrefRow(
              label: l10n.settingsReminder,
              status: l10n.settingsReminderTime,
              on: true,
              onChanged: (_) {},
              onLabel: () => context.push('/notification-settings'),
              statusOnly: true,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.settingsSleep,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            const _EditProfileSettingsCard(),
            const SizedBox(height: 12),
            const _PrivacyPolicyRow(),
            const SizedBox(height: 16),
            const _SignOutButton(),
          ],
        ),
      ),
    );
  }
}

class _PrivacyPolicyRow extends StatelessWidget {
  const _PrivacyPolicyRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {
          launchUrl(
            Uri.parse(kSiphoPrivacyPolicyUrl),
            mode: LaunchMode.externalApplication,
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 58,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                const Icon(
                  Icons.privacy_tip_outlined,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.settingsPrivacyPolicy,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                const Icon(
                  Icons.open_in_new,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditProfileSettingsCard extends ConsumerWidget {
  const _EditProfileSettingsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => showProfileEditSheet(context, ref),
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 58,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.editProfileTitle,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignOutButton extends ConsumerWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SiphoButton3D(
      label: l10n.profileSignOut,
      height: 48,
      color: AppColors.primaryDark,
      shadowColor: AppColors.ink,
      onPressed: () async {
        await ref.read(authRepositoryProvider).signOut();
        if (context.mounted) context.go('/login');
      },
    );
  }
}

class _PrefRow extends StatelessWidget {
  const _PrefRow({
    required this.label,
    required this.status,
    required this.on,
    required this.onChanged,
    this.onLabel,
    this.statusOnly = false,
  });

  final String label;
  final String status;
  final bool on;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onLabel;
  final bool statusOnly;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: statusOnly ? null : on,
      label: '$label, $status',
      child: GestureDetector(
        onTap: () {
          if (onLabel != null) {
            onLabel!();
            return;
          }
          if (!statusOnly) onChanged(!on);
        },
        behavior: HitTestBehavior.opaque,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              status,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
