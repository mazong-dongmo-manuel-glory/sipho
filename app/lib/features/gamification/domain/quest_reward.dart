/// What the server paid when a quest was claimed (`claimQuest` response).
///
/// The gift screen shows exactly these numbers. The server grants XP and seeds only, so the
/// screen never promises anything else.
class QuestReward {
  const QuestReward({
    required this.xpGained,
    required this.gemsGained,
    required this.levelUp,
    required this.alreadyClaimed,
  });

  factory QuestReward.fromCallable(Map<String, dynamic> data) {
    int number(String key) {
      final value = data[key];
      return value is num ? value.toInt() : 0;
    }

    return QuestReward(
      xpGained: number('xpGained'),
      gemsGained: number('gemsGained'),
      levelUp: data['levelUp'] == true,
      alreadyClaimed: data['alreadyClaimed'] == true,
    );
  }

  final int xpGained;
  final int gemsGained;
  final bool levelUp;

  /// The quest had already been claimed: nothing was paid this time.
  final bool alreadyClaimed;

  bool get isEmpty => xpGained <= 0 && gemsGained <= 0;
}
