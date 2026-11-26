/// Every sound the app can play. Files live in `assets/sounds/<fileName>.ogg`.
///
/// Voice slots are played only when the user enables Sipho's voice. Their files
/// are optional: a missing asset is skipped.
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
  uhOh('uh_oh'),
  siphoHappy('sipho_happy', isVoice: true),
  siphoProud('sipho_proud', isVoice: true),
  siphoWorried('sipho_worried', isVoice: true);

  const SiphoSound(this.fileName, {this.isVoice = false});

  final String fileName;
  final bool isVoice;

  String get assetPath => 'assets/sounds/$fileName.ogg';
}
