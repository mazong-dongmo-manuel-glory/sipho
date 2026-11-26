import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/user_profile_provider.dart';
import '../../features/budget/data/remaining_budget_provider.dart';
import '../../features/gamification/data/game_state_provider.dart';
import '../../features/gamification/domain/game_cues.dart';
import 'feedback_cue.dart';
import 'feedback_service.dart';
import 'feedback_settings.dart';

/// Mounted once at the app root. Preloads sounds and plays celebrations the
/// server writes (level, league, badge, streak) plus a single budget alert.
class FeedbackBinder extends ConsumerStatefulWidget {
  const FeedbackBinder({super.key});

  @override
  ConsumerState<FeedbackBinder> createState() => _FeedbackBinderState();
}

class _FeedbackBinderState extends ConsumerState<FeedbackBinder> {
  String? _uid;
  bool _budgetAlerted = false;

  @override
  void initState() {
    super.initState();
    ref.read(feedbackSettingsProvider);
    Future.microtask(() => ref.read(feedbackServiceProvider).preload());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(gameStateProvider, (previous, next) {
      final uid = ref.read(authUidProvider);
      if (uid != _uid) {
        _uid = uid;
        return;
      }
      final cue = cueForGameChange(previous, next);
      if (cue != null) {
        ref.read(feedbackServiceProvider).play(cue);
      }
    });

    ref.listen<int>(remainingBudgetCentsProvider, (previous, next) {
      if (_budgetAlerted) return;
      final profile = ref.read(userProfileProvider);
      if (!profile.onboardingDone) return;
      if (next < 0 && (previous == null || previous >= 0)) {
        _budgetAlerted = true;
        ref.read(feedbackServiceProvider).play(SiphoCue.budgetAlert);
      }
    });

    return const SizedBox.shrink();
  }
}

/// Plays [cue] once when inserted. Used by celebration screens.
class PlayCueOnce extends ConsumerStatefulWidget {
  final SiphoCue cue;

  const PlayCueOnce({super.key, required this.cue});

  @override
  ConsumerState<PlayCueOnce> createState() => _PlayCueOnceState();
}

class _PlayCueOnceState extends ConsumerState<PlayCueOnce> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(feedbackServiceProvider).play(widget.cue);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
