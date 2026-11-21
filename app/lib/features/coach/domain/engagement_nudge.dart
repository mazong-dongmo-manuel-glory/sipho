import 'package:sipho/features/coach/domain/engagement_popup.dart';
import 'package:sipho/features/economy/domain/economy_tips.dart';

/// Max in-app engagement popups per local calendar day (coach + advice + soft).
const kMaxEngagementPopupsPerDay = 3;

/// Minimum gap between two in-app engagement popups.
const kMinEngagementGap = Duration(minutes: 90);

/// Quiet hours (local): no soft/advice popups outside this window.
/// Coach hourly already respects 08–21 server-side; we mirror for soft tips.
const kEngagementQuietStartHour = 8;
const kEngagementQuietEndHour = 21;

class EngagementFrequencyState {
  const EngagementFrequencyState({
    required this.dayKey,
    required this.countToday,
    required this.lastShownAt,
    required this.shownIds,
  });

  final String dayKey;
  final int countToday;
  final DateTime? lastShownAt;
  final Set<String> shownIds;

  static const empty = EngagementFrequencyState(
    dayKey: '',
    countToday: 0,
    lastShownAt: null,
    shownIds: {},
  );
}

/// Pure rules for soft contextual nudges (ADR-016).
///
/// Priority (first match wins): budget over → no spend today → claimable quest
/// → tip of the day (economy catalog).
EngagementPopup? pickSoftEngagementNudge({
  required DateTime now,
  required String locale,
  required bool onHomeRoute,
  required bool tipsOptIn,
  required EngagementFrequencyState frequency,
  required bool hasIncome,
  required int? remainingCents,
  required bool loggedExpenseToday,
  required bool hasClaimableQuest,
  required bool hasActiveGoal,
  EconomyTip? tipOfDay,
}) {
  if (!onHomeRoute) return null;
  if (!tipsOptIn) return null;
  if (!_inQuietWindow(now)) return null;
  if (!_canShowMore(now, frequency)) return null;

  // 1) Budget pressure — highest retention signal.
  if (hasIncome &&
      remainingCents != null &&
      remainingCents < 0 &&
      !frequency.shownIds.contains('soft:budget_over')) {
    return EngagementPopup(
      id: 'soft:budget_over',
      emoji: '🛟',
      title: locale.startsWith('fr')
          ? 'Reste à vivre sous zéro'
          : 'Living money is negative',
      body: locale.startsWith('fr')
          ? 'Pas de panique : regarde tes variables du jour et coche une charge fixe si elle est payée. Une petite action suffit.'
          : 'No panic — check today’s variables and tick a fixed bill if it’s paid. One small action is enough.',
      source: 'soft',
      ctaRoute: '/expenses',
      ctaLabelKey: 'log',
    );
  }

  // 2) Soft log reminder (after late morning).
  if (now.hour >= 11 &&
      !loggedExpenseToday &&
      !frequency.shownIds.contains('soft:log_today')) {
    return EngagementPopup(
      id: 'soft:log_today',
      emoji: '✍️',
      title: locale.startsWith('fr')
          ? '30 secondes pour ta série'
          : '30 seconds for your streak',
      body: locale.startsWith('fr')
          ? 'Note une dépense — ou confirme « Aucune dépense aujourd’hui ». C’est ce qui garde ta flamme allumée.'
          : 'Log one expense — or confirm “No spend today”. That’s what keeps your streak alive.',
      source: 'soft',
      ctaRoute: '/expenses/add',
      ctaLabelKey: 'log',
    );
  }

  // 3) Claimable quest waiting.
  if (hasClaimableQuest &&
      !frequency.shownIds.contains('soft:claim_quest')) {
    return EngagementPopup(
      id: 'soft:claim_quest',
      emoji: '🎁',
      title: locale.startsWith('fr')
          ? 'Une récompense t’attend'
          : 'A reward is waiting',
      body: locale.startsWith('fr')
          ? 'Tu as terminé une quête : ouvre l’accueil et réclame ton cadeau Sipho.'
          : 'You finished a quest — open Home and claim your Sipho gift.',
      source: 'soft',
      ctaRoute: '/home',
      ctaLabelKey: 'quests',
    );
  }

  // 4) Nudge to set a goal if none.
  if (!hasActiveGoal &&
      now.hour >= 12 &&
      !frequency.shownIds.contains('soft:set_goal')) {
    return EngagementPopup(
      id: 'soft:set_goal',
      emoji: '🎯',
      title: locale.startsWith('fr')
          ? 'Un objectif rend l’épargne visible'
          : 'A goal makes saving visible',
      body: locale.startsWith('fr')
          ? 'Fixe un petit objectif (voyage, fonds d’urgence…). Sipho te montrera la jauge sur l’accueil.'
          : 'Set a small goal (trip, emergency fund…). Sipho will show a progress bar on Home.',
      source: 'soft',
      ctaRoute: '/profile',
      ctaLabelKey: 'goals',
    );
  }

  // 5) Tip of the day from the static catalog (lowest priority).
  final tip = tipOfDay ?? dailyEconomyTip(now);
  final tipId = 'soft:tip:${tip.id}:${_dayKey(now)}';
  if (frequency.shownIds.contains(tipId)) return null;
  return EngagementPopup(
    id: tipId,
    emoji: tip.emoji,
    title: tip.title.of(locale),
    body: tip.body.of(locale),
    source: 'soft',
    ctaRoute: '/economy',
    ctaLabelKey: 'insights',
  );
}

bool canShowEngagementPopup({
  required DateTime now,
  required EngagementFrequencyState frequency,
  required String popupId,
}) {
  if (frequency.shownIds.contains(popupId)) return false;
  return _canShowMore(now, frequency);
}

bool _canShowMore(DateTime now, EngagementFrequencyState frequency) {
  final day = _dayKey(now);
  final count = frequency.dayKey == day ? frequency.countToday : 0;
  if (count >= kMaxEngagementPopupsPerDay) return false;
  final last = frequency.lastShownAt;
  if (last != null && now.difference(last) < kMinEngagementGap) return false;
  return true;
}

bool _inQuietWindow(DateTime now) =>
    now.hour >= kEngagementQuietStartHour &&
    now.hour < kEngagementQuietEndHour;

String _dayKey(DateTime now) =>
    '${now.year.toString().padLeft(4, '0')}-'
    '${now.month.toString().padLeft(2, '0')}-'
    '${now.day.toString().padLeft(2, '0')}';

String engagementDayKey(DateTime now) => _dayKey(now);
