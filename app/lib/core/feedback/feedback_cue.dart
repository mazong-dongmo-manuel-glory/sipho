import 'package:sipho/core/sound/sound_service.dart';

/// Strength of a vibration.
enum HapticKind { selection, light, medium, heavy }

/// A moment of the app that deserves a sound and/or a vibration.
///
/// README 15.3: important validations get animation + sound + haptics, and
/// nothing here ever rewards *spending*: the cues celebrate tracking, learning
/// and consistency. Errors stay soft (no vibration).
enum SiphoCue {
  expenseAdded,
  fixedPaid,
  lessonCorrect,
  lessonWrong,
  scanDone,
  questClaimed,
  giftOpened,
  levelUp,
  leagueUp,
  streakExtended,

  /// The server awarded a new badge.
  badgeUnlocked,

  /// The server rewarded a day under budget (with at least one expense tracked).
  budgetDay,
}

class CueEffect {
  const CueEffect({this.sound, this.haptic, this.voice});

  final SiphoSound? sound;
  final HapticKind? haptic;

  /// Played in addition to [sound], only when the user enabled Sipho's voice.
  final SiphoSound? voice;
}

CueEffect cueEffect(SiphoCue cue) {
  switch (cue) {
    case SiphoCue.expenseAdded:
      return const CueEffect(sound: SiphoSound.ding, haptic: HapticKind.medium);
    case SiphoCue.fixedPaid:
      return const CueEffect(sound: SiphoSound.ding, haptic: HapticKind.medium);
    case SiphoCue.lessonCorrect:
      return const CueEffect(
        sound: SiphoSound.lessonDone,
        haptic: HapticKind.medium,
        voice: SiphoSound.siphoProud,
      );
    case SiphoCue.lessonWrong:
      return const CueEffect(sound: SiphoSound.softError);
    case SiphoCue.scanDone:
      return const CueEffect(
          sound: SiphoSound.scanDone, haptic: HapticKind.light);
    case SiphoCue.questClaimed:
      return const CueEffect(sound: SiphoSound.coins, haptic: HapticKind.light);
    case SiphoCue.giftOpened:
      return const CueEffect(
        sound: SiphoSound.giftOpen,
        haptic: HapticKind.heavy,
        voice: SiphoSound.siphoHappy,
      );
    case SiphoCue.levelUp:
      return const CueEffect(
        sound: SiphoSound.levelUp,
        haptic: HapticKind.heavy,
        voice: SiphoSound.siphoProud,
      );
    case SiphoCue.leagueUp:
      return const CueEffect(
        sound: SiphoSound.leagueUp,
        haptic: HapticKind.heavy,
        voice: SiphoSound.siphoProud,
      );
    case SiphoCue.streakExtended:
      return const CueEffect(
        sound: SiphoSound.flame,
        haptic: HapticKind.medium,
        voice: SiphoSound.siphoHappy,
      );
    case SiphoCue.badgeUnlocked:
      return const CueEffect(
        sound: SiphoSound.giftOpen,
        haptic: HapticKind.medium,
        voice: SiphoSound.siphoHappy,
      );
    case SiphoCue.budgetDay:
      return const CueEffect(sound: SiphoSound.coins, haptic: HapticKind.light);
  }
}
