import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `SharedPreferences` key written by the settings screen (a list of '1' / '0').
const String kSettingsTogglesKey = 'settings_toggles';

/// Positions of the feedback toggles inside [kSettingsTogglesKey].
const int kSoundsToggleIndex = 6;
const int kHapticsToggleIndex = 7;
const int kVoiceToggleIndex = 8;

/// The user's sound / vibration / voice preferences.
class FeedbackSettings {
  const FeedbackSettings({
    this.sounds = true,
    this.haptics = true,
    this.voice = false,
  });

  /// Same defaults as the settings screen: sounds and vibrations on, voice off.
  static const FeedbackSettings defaults = FeedbackSettings();

  final bool sounds;
  final bool haptics;
  final bool voice;

  /// Reads the stored toggles. Missing or short lists fall back to the defaults
  /// so a preference saved by an older app version is never misread.
  factory FeedbackSettings.fromToggles(List<String>? stored) {
    bool read(int index, bool fallback) {
      if (stored == null || index >= stored.length) return fallback;
      return stored[index] == '1';
    }

    return FeedbackSettings(
      sounds: read(kSoundsToggleIndex, defaults.sounds),
      haptics: read(kHapticsToggleIndex, defaults.haptics),
      voice: read(kVoiceToggleIndex, defaults.voice),
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

  /// Re-reads the preferences; call it after the settings screen saved a change.
  Future<void> reload() async {
    final prefs = await SharedPreferences.getInstance();
    state =
        FeedbackSettings.fromToggles(prefs.getStringList(kSettingsTogglesKey));
  }
}

final feedbackSettingsProvider =
    NotifierProvider<FeedbackSettingsNotifier, FeedbackSettings>(
  FeedbackSettingsNotifier.new,
);
