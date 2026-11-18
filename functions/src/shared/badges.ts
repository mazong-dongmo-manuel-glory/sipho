import { LESSON_UNITS } from "./lessonPath";
import { leagueTierIndex } from "./leagues";

/**
 * Badges: pure rules (no Firestore access).
 *
 * Every badge is earned from state that only ever grows (lessons done, best streak, level,
 * league tier). A badge is therefore never lost, and evaluating again is always safe.
 * Badges are cosmetic: they give no XP, so they can never feed the XP / league economy.
 *
 * Keep the ids in sync with `kBadges` in the Flutter app
 * (app/lib/features/gamification/domain/badges.dart).
 */
export interface BadgeInput {
  level: number;
  bestStreak: number;
  leagueId: string;
  completedLessonIds: ReadonlySet<string>;
  /** Nest finished (onboarding). Awards the "builder" badge. */
  onboardingDone?: boolean;
}

interface BadgeRule {
  id: string;
  earned: (input: BadgeInput) => boolean;
}

const UNIT_BADGES: BadgeRule[] = LESSON_UNITS.map((unit) => ({
  id: unit.id,
  earned: (input) => unit.lessons.every((lessonId) => input.completedLessonIds.has(lessonId)),
}));

/** In display order. */
export const BADGE_RULES: readonly BadgeRule[] = [
  { id: "builder", earned: (i) => i.onboardingDone === true },
  { id: "first_lesson", earned: (i) => i.completedLessonIds.size >= 1 },
  ...UNIT_BADGES,
  { id: "streak_7", earned: (i) => i.bestStreak >= 7 },
  { id: "streak_30", earned: (i) => i.bestStreak >= 30 },
  { id: "level_5", earned: (i) => i.level >= 5 },
  { id: "level_10", earned: (i) => i.level >= 10 },
  { id: "league_silver", earned: (i) => leagueTierIndex(i.leagueId) >= 1 },
];

export const BADGE_IDS: readonly string[] = BADGE_RULES.map((rule) => rule.id);

/** Ids of every badge the input qualifies for. */
export function earnedBadges(input: BadgeInput): string[] {
  return BADGE_RULES.filter((rule) => rule.earned(input)).map((rule) => rule.id);
}

/** Badges earned but not yet owned, in display order. */
export function missingBadges(input: BadgeInput, owned: readonly string[]): string[] {
  const have = new Set(owned);
  return earnedBadges(input).filter((id) => !have.has(id));
}
