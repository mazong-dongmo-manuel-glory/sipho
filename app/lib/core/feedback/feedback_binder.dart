import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/core/feedback/feedback_service.dart';
import 'package:sipho/core/feedback/feedback_settings.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/gamification/data/game_state_repository.dart';
import 'package:sipho/features/gamification/domain/game_cues.dart';
import 'package:sipho/features/gamification/domain/game_extras.dart';

/// Invisible widget mounted once at the app root. It preloads the sounds and
/// plays the celebrations the server triggers (level up, league promotion,
/// streak extended) by watching the game state.
class FeedbackBinder extends ConsumerStatefulWidget {
  const FeedbackBinder({super.key});

  @override
  ConsumerState<FeedbackBinder> createState() => _FeedbackBinderState();
}

class _FeedbackBinderState extends ConsumerState<FeedbackBinder> {
  String? _uid;
  String? _extrasUid;

  @override
  void initState() {
    super.initState();
    // Reading the provider loads the saved sound / vibration preferences.
    ref.read(feedbackSettingsProvider);
    Future.microtask(() => ref.read(feedbackServiceProvider).preload());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(gameStateStreamProvider, (previous, next) {
      final uid = ref.read(authStateProvider).valueOrNull?.uid;
      // A different account just signed in: its state is not "progress".
      if (uid != _uid) {
        _uid = uid;
        return;
      }
      final cue = cueForGameChange(previous?.valueOrNull, next.valueOrNull);
      if (cue != null) ref.read(feedbackServiceProvider).play(cue);
    });
    // The budget-day reward is written at the start of the day that follows it.
    ref.listen(gameExtrasStreamProvider, (previous, next) {
      final uid = ref.read(authStateProvider).valueOrNull?.uid;
      if (uid != _extrasUid) {
        _extrasUid = uid;
        return;
      }
      final isNew = isNewBudgetDayAward(
        previousLoaded: previous?.hasValue ?? false,
        previous: previous?.valueOrNull?.budgetDay,
        next: next.valueOrNull?.budgetDay,
      );
      if (isNew) ref.read(feedbackServiceProvider).play(SiphoCue.budgetDay);
    });
    return const SizedBox.shrink();
  }
}
