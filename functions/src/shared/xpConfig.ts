/**
 * XP Configuration — server-only constants (mirrors Remote Config defaults).
 * All XP, levels, gems/seeds, and streaks are computed exclusively on the server.
 */
export const XP_CONFIG = {
  lessonPerfect: 20,
  lessonComplete: 10,
  lessonBonusStreak: 5,
  // Practice XP for replaying an already-mastered lesson, capped per local day.
  lessonReplay: 2,
  lessonReplayMax: 10,

  transactionAdd: 2,
  transactionMax: 10,

  fixedPaid: 5,
  // Max XP from marking fixed expenses as paid per local day.
  fixedPaidMax: 15,

  referralInviter: 50,
  referralInvitee: 25,

  questDailyComplete: 15,
  questWeeklyComplete: 50,

  // Level 1 starts at 0 XP (matches Flutter GameState default level = 1).
  levelThresholds: [0, 100, 250, 500, 900, 1400, 2100, 3000, 4200, 5700],
} as const;

export type XpEvent = keyof Omit<typeof XP_CONFIG, "levelThresholds">;

/**
 * Calculates 1-based level from cumulative XP (0 XP => level 1).
 */
export function xpToLevel(cumulativeXp: number): number {
  const safeXp = Math.max(0, Math.trunc(cumulativeXp));
  const { levelThresholds } = XP_CONFIG;
  let index = 0;
  for (let i = 0; i < levelThresholds.length; i++) {
    if (safeXp >= levelThresholds[i]) index = i;
    else break;
  }
  return index + 1;
}

/**
 * XP needed to reach the next level (0 when at max threshold).
 */
export function xpToNextLevel(cumulativeXp: number): number {
  const safeXp = Math.max(0, Math.trunc(cumulativeXp));
  const { levelThresholds } = XP_CONFIG;
  const index = xpToLevel(safeXp) - 1;
  if (index >= levelThresholds.length - 1) return 0;
  return levelThresholds[index + 1] - safeXp;
}
