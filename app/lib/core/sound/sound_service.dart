import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sound_service.g.dart';

enum SiphoSound {
  coinDrop,
  levelUp,
  questComplete,
  streakExtend,
  error,
  chestOpen,
  xpGain,
  buttonTap,
}

extension SiphSoundPath on SiphoSound {
  String get path {
    const paths = {
      SiphoSound.coinDrop: 'assets/sounds/coin_drop.mp3',
      SiphoSound.levelUp: 'assets/sounds/level_up.mp3',
      SiphoSound.questComplete: 'assets/sounds/quest_complete.mp3',
      SiphoSound.streakExtend: 'assets/sounds/streak_extend.mp3',
      SiphoSound.error: 'assets/sounds/error.mp3',
      SiphoSound.chestOpen: 'assets/sounds/chest_open.mp3',
      SiphoSound.xpGain: 'assets/sounds/xp_gain.mp3',
      SiphoSound.buttonTap: 'assets/sounds/button_tap.mp3',
    };
    return paths[this]!;
  }
}

@riverpod
SoundService soundService(SoundServiceRef ref) {
  final service = SoundService();
  ref.onDispose(service.dispose);
  return service;
}

class SoundService {
  final _soloud = SoLoud.instance;
  final Map<SiphoSound, AudioSource> _cache = {};
  bool _muted = false;

  Future<void> init() async {
    await _soloud.init();
  }

  void setMuted(bool muted) => _muted = muted;

  Future<void> play(SiphoSound sound) async {
    if (_muted) return;
    final source = _cache[sound] ?? await _loadSource(sound);
    await _soloud.play(source);
  }

  Future<AudioSource> _loadSource(SiphoSound sound) async {
    final source = await _soloud.loadAsset(sound.path);
    _cache[sound] = source;
    return source;
  }

  void dispose() {
    for (final source in _cache.values) {
      _soloud.disposeSource(source);
    }
    _soloud.deinit();
  }
}
