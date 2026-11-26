import 'dart:io' show Platform;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import 'sound_service.dart';

/// SoLoud player.
///
/// The iOS session is ambient so the silent switch is respected and music is
/// not stopped. Android requests no exclusive focus for these short effects.
class SoLoudSoundBackend implements SoundBackend {
  final Map<String, AudioSource> _cache = {};

  @override
  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.ambient,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          usage: AndroidAudioUsage.game,
        ),
      ),
    );
    if (!kIsWeb && Platform.isIOS) await session.setActive(true);
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
