import 'dart:io' show Platform;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// Every sound the app can play. Files live in `assets/sounds/<fileName>.ogg`.
///
/// The first ten are the MVP sound effects from the README (section 7.3); the
/// `sipho*` entries are slots for Sipho's voice (onomatopoeia) and are only
/// played when the user enabled "Voice" in the settings.
enum SiphoSound {
  ding('ding'),
  softError('soft_error'),
  coins('coins'),
  flame('flame'),
  scanDone('scan_done'),
  giftOpen('gift_open'),
  levelUp('level_up'),
  leagueUp('league_up'),
  lessonDone('lesson_done'),

  /// Budget alert (`SiphoCue.budgetAlert`) when remaining goes negative.
  uhOh('uh_oh'),
  siphoHappy('sipho_happy', isVoice: true),
  siphoProud('sipho_proud', isVoice: true),
  siphoWorried('sipho_worried', isVoice: true);

  const SiphoSound(this.fileName, {this.isVoice = false});

  final String fileName;
  final bool isVoice;

  String get assetPath => 'assets/sounds/$fileName.ogg';
}

/// Low-level player. Kept behind an interface so the service can be tested
/// without the native audio engine.
abstract class SoundBackend {
  /// Prepares the engine. May throw when audio is unavailable on this device.
  Future<void> init();

  /// Loads [assetPath] (if needed) and plays it. Throws when the asset is
  /// missing or cannot be decoded.
  Future<void> play(String assetPath);

  /// Loads [assetPath] into memory without playing it.
  Future<void> preload(String assetPath);

  Future<void> dispose();
}

/// Plays sound effects. Never throws: a device without audio, or a sound whose
/// file has not been added yet, is silently skipped (and logged once).
class SoundService {
  SoundService(this._backend);

  final SoundBackend _backend;

  Future<bool>? _init;
  final Set<SiphoSound> _unavailable = {};

  Future<bool> _ensureInit() =>
      _init ??= _backend.init().then((_) => true).catchError(
        (Object error) {
          debugPrint('[Sound] audio engine unavailable: $error');
          return false;
        },
      );

  /// Loads every sound ahead of time so the first play has no latency.
  Future<void> preload() async {
    if (!await _ensureInit()) return;
    for (final sound in SiphoSound.values) {
      try {
        await _backend.preload(sound.assetPath);
      } catch (error) {
        _markUnavailable(sound, error);
      }
    }
  }

  Future<void> play(SiphoSound sound) async {
    if (_unavailable.contains(sound)) return;
    if (!await _ensureInit()) return;
    try {
      await _backend.play(sound.assetPath);
    } catch (error) {
      _markUnavailable(sound, error);
    }
  }

  void _markUnavailable(SiphoSound sound, Object error) {
    if (_unavailable.add(sound)) {
      debugPrint('[Sound] "${sound.fileName}" skipped: $error');
    }
  }

  Future<void> dispose() => _backend.dispose();
}

/// SoLoud-backed implementation.
///
/// `flutter_soloud` deliberately leaves the iOS audio session alone, so it is
/// configured here: the *ambient* category follows the silent switch and mixes
/// with the user's music instead of stopping it. On Android no audio focus is
/// requested, so background music is never paused or ducked by our short effects.
class SoLoudSoundBackend implements SoundBackend {
  final Map<String, AudioSource> _cache = {};

  @override
  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.ambient,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          usage: AndroidAudioUsage.game,
        ),
      ),
    );
    if (Platform.isIOS) await session.setActive(true);
    if (!SoLoud.instance.isInitialized) await SoLoud.instance.init();
  }

  Future<AudioSource> _load(String assetPath) async {
    final cached = _cache[assetPath];
    if (cached != null) return cached;
    final source = await SoLoud.instance.loadAsset(assetPath);
    _cache[assetPath] = source;
    return source;
  }

  @override
  Future<void> preload(String assetPath) => _load(assetPath);

  @override
  Future<void> play(String assetPath) async {
    final source = await _load(assetPath);
    await SoLoud.instance.play(source);
  }

  @override
  Future<void> dispose() async {
    // Cleanup must never crash the app, e.g. when the native engine never loaded.
    try {
      if (!SoLoud.instance.isInitialized) return;
      for (final source in _cache.values) {
        await SoLoud.instance.disposeSource(source);
      }
      _cache.clear();
      SoLoud.instance.deinit();
    } catch (error) {
      debugPrint('[Sound] dispose skipped: $error');
    }
  }
}

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService(SoLoudSoundBackend());
  ref.onDispose(service.dispose);
  return service;
});
