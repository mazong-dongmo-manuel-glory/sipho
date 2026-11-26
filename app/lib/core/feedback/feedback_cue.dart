import '../sound/sound_catalog.dart';

/// Strength of a vibration.
enum HapticKind { selection, light, medium, heavy }

/// A moment that deserves a sound and/or a vibration.
///
/// Cues celebrate tracking, learning and consistency. They never reward spending.
/// Errors stay soft (no vibration).
enum SiphoCue {
  expenseAdded,
  fixedPaid,
  lessonCorrect,
  lessonWrong,
  softError,
  scanDone,
  questClaimed,
  giftOpened,
  levelUp,
  leagueUp,
  streakExtended,
  badgeUnlocked,
  budgetDay,
  budgetAlert,
  lessonDone,
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
    case SiphoCue.fixedPaid:
      return const CueEffect(sound: SiphoSound.ding, haptic: HapticKind.medium);
    case SiphoCue.lessonCorrect:
      return const CueEffect(
        sound: SiphoSound.ding,
        haptic: HapticKind.medium,
        voice: SiphoSound.siphoProud,
      );
    case SiphoCue.lessonWrong:
    case SiphoCue.softError:
      return const CueEffect(sound: SiphoSound.softError);
    case SiphoCue.scanDone:
      return const CueEffect(sound: SiphoSound.scanDone, haptic: HapticKind.light);
    case SiphoCue.questClaimed:
    case SiphoCue.budgetDay:
      return const CueEffect(sound: SiphoSound.coins, haptic: HapticKind.light);
    case SiphoCue.giftOpened:
    case SiphoCue.badgeUnlocked:
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
    case SiphoCue.budgetAlert:
      return const CueEffect(
        sound: SiphoSound.uhOh,
        haptic: HapticKind.medium,
        voice: SiphoSound.siphoWorried,
      );
    case SiphoCue.lessonDone:
      return const CueEffect(
        sound: SiphoSound.lessonDone,
        haptic: HapticKind.medium,
        voice: SiphoSound.siphoProud,
      );
  }
}
