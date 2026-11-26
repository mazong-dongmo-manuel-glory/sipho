import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kFeedbackPrefsKey = 'sipho_feedback_prefs';

/// Sound, vibration and voice preferences. Defaults: sounds and haptics on.
class FeedbackSettings {
  const FeedbackSettings({
    this.sounds = true,
    this.haptics = true,
    this.voice = false,
  });

  static const FeedbackSettings defaults = FeedbackSettings();

  final bool sounds;
  final bool haptics;
  final bool voice;

  factory FeedbackSettings.fromStored(String? stored) {
    if (stored == null || stored.isEmpty) return defaults;
    final parts = stored.split(',');
    bool read(int index, bool fallback) {
      if (index >= parts.length) return fallback;
      return parts[index] == '1';
    }

    return FeedbackSettings(
      sounds: read(0, defaults.sounds),
      haptics: read(1, defaults.haptics),
      voice: read(2, defaults.voice),
    );
  }

  String get stored =>
      '${sounds ? '1' : '0'},${haptics ? '1' : '0'},${voice ? '1' : '0'}';

  FeedbackSettings copyWith({bool? sounds, bool? haptics, bool? voice}) {
    return FeedbackSettings(
      sounds: sounds ?? this.sounds,
      haptics: haptics ?? this.haptics,
      voice: voice ?? this.voice,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FeedbackSettings &&
      other.sounds == sounds &&
      other.haptics == haptics &&
      other.voice == voice;

  @override
  int get hashCode => Object.hash(sounds, haptics, voice);
}

class FeedbackSettingsNotifier extends Notifier<FeedbackSettings> {
  @override
  FeedbackSettings build() {
    Future.microtask(reload);
    return FeedbackSettings.defaults;
  }

  Future<void> reload() async {
    final prefs = await SharedPreferences.getInstance();
    state = FeedbackSettings.fromStored(prefs.getString(kFeedbackPrefsKey));
  }

  Future<void> setSounds(bool value) => _save(state.copyWith(sounds: value));

  Future<void> setHaptics(bool value) => _save(state.copyWith(haptics: value));

  Future<void> setVoice(bool value) => _save(state.copyWith(voice: value));

  Future<void> _save(FeedbackSettings next) async {
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kFeedbackPrefsKey, next.stored);
  }
}

final feedbackSettingsProvider =
    NotifierProvider<FeedbackSettingsNotifier, FeedbackSettings>(
  FeedbackSettingsNotifier.new,
);
