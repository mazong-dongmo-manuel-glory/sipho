import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sound/sound_service.dart';
import 'feedback_cue.dart';
import 'feedback_settings.dart';

typedef HapticPerformer = Future<void> Function(HapticKind kind);

Future<void> performSystemHaptic(HapticKind kind) {
  switch (kind) {
    case HapticKind.selection:
      return HapticFeedback.selectionClick();
    case HapticKind.light:
      return HapticFeedback.lightImpact();
    case HapticKind.medium:
      return HapticFeedback.mediumImpact();
    case HapticKind.heavy:
      return HapticFeedback.heavyImpact();
  }
}

/// Screens call `ref.read(feedbackServiceProvider).play(cue)`.
///
/// Settings are applied at call time. A missing file or a device without a
/// vibration motor cannot break the action.
class FeedbackService {
  FeedbackService({
    required SoundService sound,
    required FeedbackSettings Function() settings,
    HapticPerformer haptic = performSystemHaptic,
  })  : _sound = sound,
        _settings = settings,
        _haptic = haptic;

  final SoundService _sound;
  final FeedbackSettings Function() _settings;
  final HapticPerformer _haptic;

  Future<void> play(SiphoCue cue) async {
    final settings = _settings();
    final effect = cueEffect(cue);

    final haptic = effect.haptic;
    if (settings.haptics && haptic != null) {
      try {
        await _haptic(haptic);
      } catch (error) {
        debugPrint('[Feedback] haptic skipped: $error');
      }
    }

    final sound = effect.sound;
    if (settings.sounds && sound != null) {
      await _sound.play(sound);
    }
    final voice = effect.voice;
    if (settings.sounds && settings.voice && voice != null) {
      await _sound.play(voice);
    }
  }

  Future<void> preload() => _sound.preload();
}

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return FeedbackService(
    sound: ref.watch(soundServiceProvider),
    settings: () => ref.read(feedbackSettingsProvider),
  );
});
