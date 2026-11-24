import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/sipho_colors.dart';
import '../core/theme/sipho_palette.dart';
import '../core/theme/sipho_typography.dart';
import '../core/widgets/sipho_list_row.dart';
import 'l10n/app_localizations.dart';

/// Choix FAB « + » : saisie manuelle ou scan caméra + IA.
Future<void> showFabAddSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: SiphoPalette.surface(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.fabAddTitle,
                style: SiphoTypography.title.copyWith(
                  fontSize: 22,
                  color: SiphoPalette.textPrimary(ctx),
                ),
              ),
              const SizedBox(height: 16),
              SiphoListRow(
                title: l10n.fabAddScan,
                trailing: '📷',
                showChevron: true,
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.push('/expenses/scan');
                },
              ),
              const SiphoSeparator(),
              SiphoListRow(
                title: l10n.fabAddManual,
                trailing: '＋',
                showChevron: true,
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.push('/expenses/add');
                },
              ),
              const SizedBox(height: 8),
              Text(
                l10n.scanPrivacy,
                style: SiphoTypography.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: SiphoPalette.textSecondary(ctx),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    l10n.cancelBtn,
                    style: SiphoTypography.bodyBold.copyWith(
                      color: SiphoColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
