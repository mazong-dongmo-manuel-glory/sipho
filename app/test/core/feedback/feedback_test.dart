import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/core/feedback/feedback_service.dart';
import 'package:sipho/core/feedback/feedback_settings.dart';
import 'package:sipho/core/sound/sound_service.dart';

class _FakeBackend implements SoundBackend {
  _FakeBackend({this.failInit = false, this.missing = const {}});

  final bool failInit;
  final Set<String> missing;
  int initCalls = 0;
  final played = <String>[];
  final preloaded = <String>[];

  @override
  Future<void> init() async {
    initCalls++;
    if (failInit) throw StateError('no audio device');
  }

  @override
  Future<void> play(String assetPath) async {
    if (missing.contains(assetPath)) throw StateError('missing $assetPath');
    played.add(assetPath);
  }

  @override
  Future<void> preload(String assetPath) async {
    if (missing.contains(assetPath)) throw StateError('missing $assetPath');
    preloaded.add(assetPath);
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  group('SiphoSound', () {
    test('asset paths are unique snake_case .ogg files', () {
      final paths = SiphoSound.values.map((s) => s.assetPath).toList();
      expect(paths.toSet(), hasLength(paths.length));
      for (final sound in SiphoSound.values) {
        expect(
            sound.assetPath, matches(RegExp(r'^assets/sounds/[a-z_]+\.ogg$')));
      }
    });

    test('the 10 MVP sound effects match the README names', () {
      final effects = SiphoSound.values
          .where((s) => !s.isVoice)
          .map((s) => s.fileName)
          .toSet();
      expect(effects, {
        'ding',
        'soft_error',
        'coins',
        'flame',
        'scan_done',
        'gift_open',
        'level_up',
        'league_up',
        'lesson_done',
        'uh_oh',
      });
    });

    test('voice slots are all prefixed sipho_', () {
      for (final sound in SiphoSound.values.where((s) => s.isVoice)) {
        expect(sound.fileName, startsWith('sipho_'));
      }
    });
  });

  group('cueEffect', () {
    test('every cue produces a sound or a vibration', () {
      for (final cue in SiphoCue.values) {
        final effect = cueEffect(cue);
        expect(effect.sound != null || effect.haptic != null, isTrue,
            reason: '$cue');
      }
    });

    test('voice is only ever a voice sound, effects never are', () {
      for (final cue in SiphoCue.values) {
        final effect = cueEffect(cue);
        if (effect.voice != null) expect(effect.voice!.isVoice, isTrue);
        if (effect.sound != null) expect(effect.sound!.isVoice, isFalse);
      }
    });

    test('a wrong answer stays soft: sound only, no vibration', () {
      final effect = cueEffect(SiphoCue.lessonWrong);
      expect(effect.sound, SiphoSound.softError);
      expect(effect.haptic, isNull);
    });

    test('big moments vibrate harder than everyday actions', () {
      expect(cueEffect(SiphoCue.levelUp).haptic, HapticKind.heavy);
      expect(cueEffect(SiphoCue.giftOpened).haptic, HapticKind.heavy);
      expect(cueEffect(SiphoCue.expenseAdded).haptic, HapticKind.medium);
    });
  });

  group('FeedbackSettings.fromToggles', () {
    test('nothing stored means the defaults: sounds + vibration on, voice off',
        () {
      final s = FeedbackSettings.fromToggles(null);
      expect(s, FeedbackSettings.defaults);
      expect(s.sounds, isTrue);
      expect(s.haptics, isTrue);
      expect(s.voice, isFalse);
    });

    test('reads the sound / vibration / voice positions of the settings list',
        () {
      // positions 6, 7, 8 = sounds, vibrations, voice
      final s = FeedbackSettings.fromToggles(
          ['1', '1', '0', '1', '0', '1', '0', '1', '1']);
      expect(s.sounds, isFalse);
      expect(s.haptics, isTrue);
      expect(s.voice, isTrue);
    });

    test('a list saved by an older version (too short) keeps the defaults', () {
      expect(FeedbackSettings.fromToggles(['1', '0', '0']),
          FeedbackSettings.defaults);
    });
  });

  group('SoundService', () {
    test('plays the asset of the requested sound', () async {
      final backend = _FakeBackend();
      await SoundService(backend).play(SiphoSound.coins);
      expect(backend.played, ['assets/sounds/coins.ogg']);
    });

    test('a missing file never throws and is not retried', () async {
      final backend = _FakeBackend(missing: {SiphoSound.ding.assetPath});
      final service = SoundService(backend);
      await service.play(SiphoSound.ding);
      await service.play(SiphoSound.ding);
      await service.play(SiphoSound.coins);
      expect(backend.played, ['assets/sounds/coins.ogg']);
    });

    test('an unavailable audio engine never throws and is initialised once',
        () async {
      final backend = _FakeBackend(failInit: true);
      final service = SoundService(backend);
      await service.play(SiphoSound.ding);
      await service.play(SiphoSound.coins);
      await service.preload();
      expect(backend.initCalls, 1);
      expect(backend.played, isEmpty);
    });

    test('preload loads every sound that exists and skips the missing ones',
        () async {
      final backend = _FakeBackend(missing: {SiphoSound.levelUp.assetPath});
      final service = SoundService(backend);
      await service.preload();
      expect(backend.preloaded, hasLength(SiphoSound.values.length - 1));
      expect(backend.preloaded, isNot(contains(SiphoSound.levelUp.assetPath)));
      await service.play(SiphoSound.levelUp);
      expect(backend.played, isEmpty);
    });
  });

  group('FeedbackService', () {
    late _FakeBackend backend;
    late List<HapticKind> haptics;

    FeedbackService build(FeedbackSettings settings) {
      backend = _FakeBackend();
      haptics = [];
      return FeedbackService(
        sound: SoundService(backend),
        settings: () => settings,
        haptic: (kind) async => haptics.add(kind),
      );
    }

    test('plays the sound and the vibration of a cue', () async {
      final service = build(FeedbackSettings.defaults);
      await service.play(SiphoCue.expenseAdded);
      expect(backend.played, ['assets/sounds/ding.ogg']);
      expect(haptics, [HapticKind.medium]);
    });

    test('sounds off: vibration only', () async {
      final service = build(const FeedbackSettings(sounds: false));
      await service.play(SiphoCue.expenseAdded);
      expect(backend.played, isEmpty);
      expect(haptics, [HapticKind.medium]);
    });

    test('vibrations off: sound only', () async {
      final service = build(const FeedbackSettings(haptics: false));
      await service.play(SiphoCue.expenseAdded);
      expect(backend.played, ['assets/sounds/ding.ogg']);
      expect(haptics, isEmpty);
    });

    test('voice stays silent unless enabled, and needs sounds on', () async {
      var service = build(FeedbackSettings.defaults);
      await service.play(SiphoCue.levelUp);
      expect(backend.played, ['assets/sounds/level_up.ogg']);

      service = build(const FeedbackSettings(voice: true));
      await service.play(SiphoCue.levelUp);
      expect(backend.played,
          ['assets/sounds/level_up.ogg', 'assets/sounds/sipho_proud.ogg']);

      service = build(const FeedbackSettings(voice: true, sounds: false));
      await service.play(SiphoCue.levelUp);
      expect(backend.played, isEmpty);
    });

    test('a failing vibration motor never breaks the action', () async {
      final service = FeedbackService(
        sound: SoundService(_FakeBackend()),
        settings: () => FeedbackSettings.defaults,
        haptic: (_) async => throw StateError('no motor'),
      );
      await service.play(SiphoCue.levelUp);
    });

    test('settings are read at the moment of the call', () async {
      var settings = FeedbackSettings.defaults;
      final b = _FakeBackend();
      final service = FeedbackService(
        sound: SoundService(b),
        settings: () => settings,
        haptic: (_) async {},
      );
      await service.play(SiphoCue.expenseAdded);
      settings = const FeedbackSettings(sounds: false);
      await service.play(SiphoCue.expenseAdded);
      expect(b.played, hasLength(1));
    });
  });
}
