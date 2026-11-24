import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../notifications/data/device_registration.dart';

/// Frame 07 · Autorisation rappels · Épuré — FCM + `users/{uid}/devices`.
class NotificationsPermissionScreen extends ConsumerWidget {
  const NotificationsPermissionScreen({super.key});

  Future<void> _allow(BuildContext context, WidgetRef ref) async {
    await ref.read(deviceRegistrationProvider).requestAndRegister();
    if (!context.mounted) return;
    context.go('/home');
  }

  void _later(BuildContext context) => context.go('/home');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      l10n.notifFlameTitle,
                      style: SiphoTypography.title.copyWith(
                        fontSize: 28,
                        color: SiphoPalette.textPrimary(context),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.notifFlameLead,
                      style: SiphoTypography.body.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: SvgPicture.asset(
                        'assets/images/sipho_happy.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SiphoSoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.notifFlameCardTitle,
                            style: SiphoTypography.bodyBold.copyWith(
                              fontSize: 16,
                              color: SiphoPalette.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.notifFlameCardBody,
                            style: SiphoTypography.body.copyWith(
                              fontSize: 16,
                              color: SiphoPalette.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.notifFlameBody,
                      style: SiphoTypography.body.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textSecondary(context),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SiphoButton3D(
                      label: l10n.notifLater,
                      variant: SiphoButtonVariant.outline,
                      onPressed: () => _later(context),
                    ),
                  ],
                ),
              ),
              SiphoButton3D(
                label: l10n.notifFlameYes,
                variant: SiphoButtonVariant.dark,
                onPressed: () => _allow(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
