import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../app/routes.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../data/coach_repository.dart';
import '../domain/coach_tip.dart';

const _prefsLastShownTipKey = 'sipho_coach_last_shown_tip';

/// Listens to `users/{uid}/coach/current` and shows an in-app popup once per tip.
class CoachPopupHost extends ConsumerStatefulWidget {
  const CoachPopupHost({super.key});

  @override
  ConsumerState<CoachPopupHost> createState() => _CoachPopupHostState();
}

class _CoachPopupHostState extends ConsumerState<CoachPopupHost>
    with WidgetsBindingObserver {
  bool _dialogOpen = false;
  String? _lastShownTipId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLastShown();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadLastShown() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _lastShownTipId = prefs.getString(_prefsLastShownTipKey));
  }

  Future<void> _markShown(String tipId) async {
    _lastShownTipId = tipId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsLastShownTipKey, tipId);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final tip = ref.read(coachCurrentTipProvider).valueOrNull;
      if (tip != null) _maybeShow(tip);
    }
  }

  void _maybeShow(CoachTip tip) {
    if (!tip.isValid) return;
    if (_dialogOpen) return;
    if (tip.tipId == _lastShownTipId) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _dialogOpen) return;
      if (tip.tipId == _lastShownTipId) return;
      // Host lives in MaterialApp.builder (outside RouteBase) — use the router.
      final route = siphoRouter.state.uri.path;
      if (route.startsWith('/splash') ||
          route.startsWith('/login') ||
          route.startsWith('/onboarding')) {
        return;
      }
      _showDialog(tip);
    });
  }

  Future<void> _showDialog(CoachTip tip) async {
    _dialogOpen = true;
    final l10n = AppLocalizations.of(context);
    await _markShown(tip.tipId);
    if (!mounted) {
      _dialogOpen = false;
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _CoachTipDialog(tip: tip, l10n: l10n),
    );
    _dialogOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<CoachTip?>>(coachCurrentTipProvider, (prev, next) {
      final tip = next.valueOrNull;
      if (tip != null) _maybeShow(tip);
    });
    return const SizedBox.shrink();
  }
}

class _CoachTipDialog extends StatelessWidget {
  const _CoachTipDialog({required this.tip, required this.l10n});

  final CoachTip tip;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: SiphoPalette.surface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(tip.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.coachHourlyTitle,
                    style: SiphoTypography.label.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: SiphoPalette.textSecondary(context),
                    ),
                  ),
                ),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: SvgPicture.asset(
                    'assets/images/sipho_happy.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tip.title,
                style: SiphoTypography.title.copyWith(
                  fontSize: 20,
                  color: SiphoPalette.textPrimary(context),
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              tip.body,
              style: SiphoTypography.body.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: SiphoPalette.textPrimary(context),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: SiphoColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.coachEducationLevel(
                  _stageLabel(l10n, tip.stageId),
                  tip.educationScore,
                ),
                style: SiphoTypography.label.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: SiphoColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SiphoButton3D(
              label: l10n.coachHourlyDismiss,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  String _stageLabel(AppLocalizations l10n, String stageId) {
    switch (stageId) {
      case 'habits':
        return l10n.coachStageHabits;
      case 'saving':
        return l10n.coachStageSaving;
      case 'protect':
        return l10n.coachStageProtect;
      case 'grow':
        return l10n.coachStageGrow;
      case 'foundation':
      default:
        return l10n.coachStageFoundation;
    }
  }
}
