/// How the home progression card should speak.
enum OnTrackTone { onTrack, catchUp, start }

class OnTrackFeedback {
  const OnTrackFeedback(this.tone);

  final OnTrackTone tone;
}

/// A streak, a month that still has money left, or steady logging means
/// the person is on track. A negative remainder asks for a recovery, not blame.
OnTrackFeedback buildOnTrack({
  required int streak,
  required bool hasIncome,
  required int remainingCents,
  required int expensesThisMonth,
}) {
  if (hasIncome && remainingCents < 0) {
    return const OnTrackFeedback(OnTrackTone.catchUp);
  }
  if (streak >= 3 || expensesThisMonth >= 3) {
    return const OnTrackFeedback(OnTrackTone.onTrack);
  }
  return const OnTrackFeedback(OnTrackTone.start);
}
