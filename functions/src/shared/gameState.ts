import { FieldValue } from "firebase-admin/firestore";

export interface StreakInfoDoc {
  current: number;
  best: number;
  lastActiveDay: string | null;
  freezes: number;
  /** ISO timestamp when the streak was last broken (repair window). */
  brokenAt: string | null;
  /** Streak length just before the break (restored by `repairStreak`). */
  brokenCurrent: number;
}

export interface GameStateDoc {
  xp: number;
  level: number;
  gems: number;
  streak: StreakInfoDoc;
  leagueId: string;
  weeklyXp: number;
  badges: string[];
}

export function normalizeStreak(
  raw: unknown,
  legacyLastLessonDate?: string,
  legacyFreezes?: number
): StreakInfoDoc {
  if (raw && typeof raw === "object") {
    const obj = raw as Record<string, unknown>;
    const current = typeof obj.current === "number" ? Math.max(0, Math.trunc(obj.current)) : 0;
    const best =
      typeof obj.best === "number"
        ? Math.max(current, Math.trunc(obj.best))
        : current;
    const lastActiveDay =
      typeof obj.lastActiveDay === "string"
        ? obj.lastActiveDay
        : legacyLastLessonDate ?? null;
    const freezes =
      typeof obj.freezes === "number"
        ? Math.max(0, Math.trunc(obj.freezes))
        : typeof legacyFreezes === "number"
          ? Math.max(0, Math.trunc(legacyFreezes))
          : 2;
    const brokenAt = typeof obj.brokenAt === "string" ? obj.brokenAt : null;
    const brokenCurrent =
      typeof obj.brokenCurrent === "number" ? Math.max(0, Math.trunc(obj.brokenCurrent)) : 0;
    return { current, best, lastActiveDay, freezes, brokenAt, brokenCurrent };
  }

  const current = typeof raw === "number" ? Math.max(0, Math.trunc(raw)) : 0;
  return {
    current,
    best: current,
    lastActiveDay: legacyLastLessonDate ?? null,
    freezes: typeof legacyFreezes === "number" ? Math.max(0, Math.trunc(legacyFreezes)) : 2,
    brokenAt: null,
    brokenCurrent: 0,
  };
}

export function normalizeGameState(raw?: Record<string, unknown>): GameStateDoc {
  const xp = typeof raw?.xp === "number" ? Math.max(0, Math.trunc(raw.xp)) : 0;
  const level = typeof raw?.level === "number" ? Math.max(1, Math.trunc(raw.level)) : 1;
  const gems =
    typeof raw?.gems === "number"
      ? Math.max(0, Math.trunc(raw.gems))
      : typeof raw?.seeds === "number"
        ? Math.max(0, Math.trunc(raw.seeds))
        : 0;
  const legacyLast =
    typeof raw?.lastLessonDate === "string" ? raw.lastLessonDate : undefined;
  const legacyFreezes =
    typeof raw?.freezesAvailable === "number" ? raw.freezesAvailable : undefined;
  const streak = normalizeStreak(raw?.streak, legacyLast, legacyFreezes);
  const leagueId = typeof raw?.leagueId === "string" ? raw.leagueId : "bronze";
  const weeklyXp =
    typeof raw?.weeklyXp === "number" ? Math.max(0, Math.trunc(raw.weeklyXp)) : 0;
  const badges = Array.isArray(raw?.badges)
    ? raw.badges.filter((b): b is string => typeof b === "string")
    : [];

  return { xp, level, gems, streak, leagueId, weeklyXp, badges };
}

export function initialGameStatePayload(): Record<string, unknown> {
  return {
    xp: 0,
    level: 1,
    gems: 0,
    streak: {
      current: 0,
      best: 0,
      lastActiveDay: null,
      freezes: 2,
      brokenAt: null,
      brokenCurrent: 0,
    },
    leagueId: "bronze",
    weeklyXp: 0,
    badges: [],
    updatedAt: FieldValue.serverTimestamp(),
  };
}

/** True while a broken streak is still inside the 24h repair window (freeze not required). */
export function isWithinStreakRepairWindow(
  streak: StreakInfoDoc,
  nowMs: number = Date.now()
): boolean {
  if (!streak.brokenAt || streak.brokenCurrent <= 0) return false;
  const brokenMs = Date.parse(streak.brokenAt);
  if (!Number.isFinite(brokenMs)) return false;
  return nowMs - brokenMs <= 24 * 60 * 60 * 1000;
}

export function computeNextStreak(
  current: StreakInfoDoc,
  todayIso: string,
  nowMs: number = Date.now()
): { nextStreak: StreakInfoDoc; streakBonus: boolean } {
  // After a break, do not start a new streak that would wipe brokenCurrent during the
  // 24h repair window (user may still buy/use a freeze via repairStreak).
  if (isWithinStreakRepairWindow(current, nowMs)) {
    return { nextStreak: current, streakBonus: false };
  }

  if (!current.lastActiveDay) {
    return {
      nextStreak: {
        current: 1,
        best: Math.max(1, current.best),
        lastActiveDay: todayIso,
        freezes: current.freezes,
        brokenAt: null,
        brokenCurrent: 0,
      },
      streakBonus: false,
    };
  }

  const lastMs = Date.parse(`${current.lastActiveDay}T00:00:00Z`);
  const todayMs = Date.parse(`${todayIso}T00:00:00Z`);
  const diffDays = Math.floor((todayMs - lastMs) / 86_400_000);

  if (diffDays <= 0) {
    return { nextStreak: current, streakBonus: false };
  }

  if (diffDays === 1) {
    // current may be 0 after an expired unrepaired break — treat as a fresh start day.
    const nextCurrent = Math.max(0, current.current) + 1;
    return {
      nextStreak: {
        current: nextCurrent,
        best: Math.max(nextCurrent, current.best),
        lastActiveDay: todayIso,
        freezes: current.freezes,
        brokenAt: null,
        brokenCurrent: 0,
      },
      streakBonus: nextCurrent >= 7,
    };
  }

  return {
    nextStreak: {
      current: 1,
      best: Math.max(1, current.best),
      lastActiveDay: todayIso,
      freezes: current.freezes,
      brokenAt: new Date(nowMs).toISOString(),
      brokenCurrent: Math.max(0, current.current),
    },
    streakBonus: false,
  };
}

/** Streak milestones celebrated in the app (README §5.3). */
export const STREAK_MILESTONES = [3, 7, 14, 30, 50, 100, 200, 365] as const;

/** True when a repair is still possible (broken within the last 24 hours, freeze available). */
export function canRepairStreak(
  streak: StreakInfoDoc,
  nowMs: number = Date.now()
): boolean {
  if (streak.freezes < 1) return false;
  return isWithinStreakRepairWindow(streak, nowMs);
}

export function repairStreakState(
  streak: StreakInfoDoc,
  todayIso: string
): StreakInfoDoc | null {
  if (!canRepairStreak(streak)) return null;
  const restored = Math.max(1, streak.brokenCurrent);
  return {
    current: restored,
    best: Math.max(restored, streak.best),
    lastActiveDay: todayIso,
    freezes: streak.freezes - 1,
    brokenAt: null,
    brokenCurrent: 0,
  };
}
