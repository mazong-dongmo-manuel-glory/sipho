import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/auth/data/auth_repository.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/notifications/data/notification_service.dart';
import 'package:sipho/features/notifications/domain/notif_prefs.dart';

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
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Column(
            children: [
              const SizedBox(height: 48),
              const Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  SiphoArt.waving(frame: 230),
                  Positioned(
                    right: 8,
                    top: 70,
                    child: Text('🔔', style: TextStyle(fontSize: 46)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                l10n.notifFlameTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 23),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.notifFlameBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const Spacer(),
              SiphoButton3D(
                label: l10n.notifFlameYes,
                onPressed: _enableThenFinish,
                isLoading: _saving,
                color: AppColors.primary,
                shadowColor: AppColors.primaryDark,
                height: 52,
                borderRadius: figmaButtonRadius,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _saving ? null : _finish,
                child: Text(
                  l10n.notifLater,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
