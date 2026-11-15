/**
 * Weekly leagues: pure rules (no Firestore access).
 *
 * - 10 tiers, groups of up to 30 players, ranking on the XP earned during the week ONLY.
 * - The week is global (the same for everyone): it runs from Sunday 20:00 UTC to the next
 *   Sunday 20:00 UTC, so a group has a single, shared end time.
 * - Top 7 are promoted (if they earned XP), the last 5 are relegated (only in groups of at least
 *   15 players, so tiny groups do not churn).
 */

export const LEAGUE_TIERS = [
  "bronze",
  "silver",
  "gold",
  "sapphire",
  "ruby",
  "emerald",
  "amethyst",
  "pearl",
  "obsidian",
  "diamond",
] as const;

export type LeagueTier = (typeof LEAGUE_TIERS)[number];

export const LEAGUE_GROUP_SIZE = 30;
export const LEAGUE_PROMOTE_COUNT = 7;
export const LEAGUE_RELEGATE_COUNT = 5;
export const LEAGUE_MIN_GROUP_FOR_RELEGATION = 15;

const WEEK_START_DAY_UTC = 0; // Sunday
const WEEK_START_HOUR_UTC = 20;
const DAY_MS = 24 * 60 * 60 * 1000;

/** Most recent Sunday 20:00 UTC at or before `now`. */
export function leagueWeekStart(now: Date): Date {
  const candidate = Date.UTC(
    now.getUTCFullYear(),
    now.getUTCMonth(),
    now.getUTCDate() - ((now.getUTCDay() - WEEK_START_DAY_UTC + 7) % 7),
    WEEK_START_HOUR_UTC
  );
  return new Date(candidate > now.getTime() ? candidate - 7 * DAY_MS : candidate);
}

/** `yyyy-MM-dd` (UTC) of the week's start: identifies the week. */
export function leagueWeekKey(now: Date): string {
  return leagueWeekStart(now).toISOString().slice(0, 10);
}

export function leagueWeekEnd(now: Date): Date {
  return new Date(leagueWeekStart(now).getTime() + 7 * DAY_MS);
}

/** Index of a tier id; unknown / missing values fall back to the lowest tier. */
export function leagueTierIndex(id: unknown): number {
  const idx = LEAGUE_TIERS.indexOf(id as LeagueTier);
  return idx < 0 ? 0 : idx;
}

export function leagueTierId(index: number): LeagueTier {
  return LEAGUE_TIERS[Math.min(LEAGUE_TIERS.length - 1, Math.max(0, index))];
}

export type LeagueResult = "promoted" | "relegated" | "stayed";

export interface LeagueMemberScore {
  uid: string;
  weeklyXp: number;
}

export interface LeagueOutcome {
  uid: string;
  rank: number;
  weeklyXp: number;
  result: LeagueResult;
  fromTier: LeagueTier;
  toTier: LeagueTier;
}

/** Ranks a finished group and decides who moves up or down. */
export function planLeagueOutcomes(
  members: LeagueMemberScore[],
  tierIndex: number
): LeagueOutcome[] {
  const sorted = [...members].sort(
    (a, b) => b.weeklyXp - a.weeklyXp || a.uid.localeCompare(b.uid)
  );
  const size = sorted.length;
  const top = LEAGUE_TIERS.length - 1;
  const canRelegate = size >= LEAGUE_MIN_GROUP_FOR_RELEGATION;

  return sorted.map((member, idx) => {
    const rank = idx + 1;
    let result: LeagueResult = "stayed";
    if (rank <= LEAGUE_PROMOTE_COUNT && member.weeklyXp > 0 && tierIndex < top) {
      result = "promoted";
    } else if (
      canRelegate &&
      rank > LEAGUE_PROMOTE_COUNT &&
      rank > size - LEAGUE_RELEGATE_COUNT &&
      tierIndex > 0
    ) {
      result = "relegated";
    }
    const target =
      result === "promoted" ? tierIndex + 1 : result === "relegated" ? tierIndex - 1 : tierIndex;
    return {
      uid: member.uid,
      rank,
      weeklyXp: member.weeklyXp,
      result,
      fromTier: leagueTierId(tierIndex),
      toTier: leagueTierId(target),
    };
  });
}
