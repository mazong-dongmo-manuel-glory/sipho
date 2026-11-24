import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_page_header.dart';
import '../../gamification/domain/badges.dart';

/// Frame 41 · Badge gagné.
class BadgeEarnedScreen extends StatelessWidget {
  const BadgeEarnedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final extra = GoRouterState.of(context).extra;
    String? title;
    String? id;
    if (extra is Map) {
      title = extra['title']?.toString();
      id = extra['id']?.toString();
    }
    BadgeDef? def;
    if (id != null) {
      for (final b in kBadges) {
        if (b.id == id) {
          def = b;
          break;
        }
      }
    }
    final name = title ?? def?.titleFr ?? l10n.badgeEarnedName;
    final emoji = def?.emoji ?? '🏆';

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
                      title: l10n.badgeEarnedHeading,
                      lead: l10n.badgeEarnedLead,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: SiphoColors.accentGold,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(emoji, style: const TextStyle(fontSize: 56)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: SiphoTypography.title.copyWith(
                        fontSize: 24,
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.badgeEarnedBody,
                      textAlign: TextAlign.center,
                      style: SiphoTypography.body.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 88,
                        height: 88,
                        child: SvgPicture.asset(
                          'assets/images/sipho_happy.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SiphoButton3D(
                label: l10n.badgeEarnedCta,
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
