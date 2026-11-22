import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/router.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/core/feedback/feedback_service.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/coach/data/coach_repository.dart';
import 'package:sipho/features/coach/domain/coach_tip.dart';
import 'package:sipho/features/notifications/data/notification_service.dart';

const _prefsLastShownTipKey = 'sipho_coach_last_shown_tip';

/// Listens to the server hourly tip and shows an in-app popup (never twice for
/// the same tipId). Also surfaces a local notification when a new tip arrives
/// while the app is in the foreground stack.
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
    // Wait a beat so Home finishes building (avoids showing over splash/login).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _dialogOpen) return;
      if (tip.tipId == _lastShownTipId) return;
      // CoachPopupHost sits in MaterialApp.router's builder (above the navigator),
      // so GoRouterState.of(context) would throw. Use the Riverpod router instead.
      final route = ref.read(routerProvider).state.uri.path;
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

    try {
      await ref.read(feedbackServiceProvider).play(SiphoCue.fixedPaid);
    } catch (_) {}

    // Local heads-up so the tip is also a “notification” while in-app.
    try {
      await ref.read(notificationServiceProvider).showLocal(
            id: tip.tipId.hashCode & 0x7fffffff,
            title: '${tip.emoji} ${tip.title}',
            body: tip.body,
            payload: '/home',
          );
    } catch (_) {}

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
      backgroundColor: AppColors.surface,
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
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: SiphoArt.happy(frame: 72),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tip.title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              tip.body,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.coachEducationLevel(
                  _stageLabel(l10n, tip.stageId),
                  tip.educationScore,
                ),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
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
