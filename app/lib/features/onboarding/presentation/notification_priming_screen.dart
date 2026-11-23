import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/auth/data/auth_repository.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/notifications/data/notification_service.dart';
import 'package:sipho/features/notifications/domain/notif_prefs.dart';

/// Frame Figma 07 · Autorisation rappels · Épuré (`2:28927`).
class NotificationPrimingScreen extends ConsumerStatefulWidget {
  const NotificationPrimingScreen({super.key});

  @override
  ConsumerState<NotificationPrimingScreen> createState() =>
      _NotificationPrimingScreenState();
}

class _NotificationPrimingScreenState
    extends ConsumerState<NotificationPrimingScreen> {
  bool _saving = false;

  Future<void> _enableThenFinish() async {
    if (_saving) return;
    setState(() => _saving = true);
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    final l10n = AppLocalizations.of(context);
    if (uid != null) {
      try {
        final granted = await ref.read(notificationServiceProvider).enable(
              uid: uid,
              prefs: NotifPrefs.optedIn,
              dailyTitle: l10n.notifDailyTitle,
              dailyBody: l10n.notifDailyBody,
            );
        if (!granted && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.notifDenied)),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.notifDenied)),
          );
        }
      }
    }
    await _complete();
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);
    await _complete();
  }

  Future<void> _complete() async {
    try {
      await ref.read(authRepositoryProvider).finishOnboarding();
      if (!mounted) return;
      context.go('/home');
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.notifFlameTitle,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.notifFlameLead,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              const SiphoArt.happy(frame: 100),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.soft,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.notifFlameCardTitle,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.notifFlameCardBody,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.notifFlameBody,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              SiphoButton3D(
                label: l10n.notifLater,
                onPressed: _saving ? null : _finish,
                color: AppColors.surface,
                shadowColor: AppColors.border,
                textColor: AppColors.primaryDark,
                height: 52,
                borderRadius: figmaButtonRadius,
              ),
              const Spacer(),
              SiphoButton3D(
                label: l10n.notifFlameYes,
                onPressed: _enableThenFinish,
                isLoading: _saving,
                color: AppColors.primaryDark,
                shadowColor: AppColors.primaryDark,
                height: 52,
                borderRadius: figmaButtonRadius,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
