import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/core/feedback/feedback_settings.dart';
import 'package:sipho/core/sound/sound_service.dart';

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

/// Single entry point used by the screens: `ref.read(feedbackServiceProvider).play(cue)`.
///
/// It applies the user's settings (sounds / vibrations / voice) at the moment of
/// the call and never throws, so a missing sound file or a device without a
/// vibration motor cannot break a user action.
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

  /// Fire-and-forget: callers do not need to await it.
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
