/**
 * XP Configuration — simulates Remote Config values.
 * All XP is awarded server-side only.
 */
export const XP_CONFIG = {
  // Lesson completion
  lessonPerfect: 20,       // 100% score
  lessonComplete: 10,      // < 100% score
  lessonBonusStreak: 5,    // streak >= 7 days

  // Transactions
  transactionAdd: 2,       // adding a transaction
  transactionMax: 10,      // max XP per day from transactions

  // Fixed expenses
  fixedPaid: 5,            // marking a fixed expense as paid

  // Referrals
  referralInviter: 50,     // when a referral completes onboarding
  referralInvitee: 25,     // when invitee completes onboarding

  // Quests
  questDailyComplete: 15,
  questWeeklyComplete: 50,

  // Level thresholds (cumulative XP needed)
  levelThresholds: [0, 100, 250, 500, 900, 1400, 2100, 3000, 4200, 5700],
} as const;

export type XpEvent = keyof Omit<typeof XP_CONFIG, "levelThresholds">;

/**
 * Calculate level from cumulative XP.
 */
export function xpToLevel(cumulativeXp: number): number {
  const { levelThresholds } = XP_CONFIG;
  let level = 0;
  for (let i = 0; i < levelThresholds.length; i++) {
    if (cumulativeXp >= levelThresholds[i]) level = i;
    else break;
  }
  return level;
}

/**
 * XP needed for next level.
 */
export function xpToNextLevel(cumulativeXp: number): number {
  const { levelThresholds } = XP_CONFIG;
  const level = xpToLevel(cumulativeXp);
  if (level >= levelThresholds.length - 1) return 0;
  return levelThresholds[level + 1] - cumulativeXp;
}
