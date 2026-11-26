import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'soloud_sound_backend.dart';
import 'sound_catalog.dart';

/// Low-level player. Kept behind an interface so tests skip the native engine.
abstract class SoundBackend {
  Future<void> init();

  Future<void> play(String assetPath);

  Future<void> preload(String assetPath);

  Future<void> dispose();
}

/// Plays sound effects. Never throws: a device without audio, or a sound whose
/// file has not been added yet, is silently skipped.
class SoundService {
  SoundService(this._backend);

  final SoundBackend _backend;

  Future<bool>? _init;
  final Set<SiphoSound> _unavailable = {};

  Future<bool> _ensureInit() => _init ??= _backend.init().then((_) => true).catchError(
        (Object error) {
          debugPrint('[Sound] audio engine unavailable: $error');
          return false;
        },
      );

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

final soundBackendProvider = Provider<SoundBackend>((ref) {
  return SoLoudSoundBackend();
});

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService(ref.watch(soundBackendProvider));
  ref.onDispose(service.dispose);
  return service;
});
