import { FieldValue } from "firebase-admin/firestore";

export interface StreakInfoDoc {
  current: number;
  best: number;
  lastActiveDay: string | null;
  freezes: number;
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
    return { current, best, lastActiveDay, freezes };
  }

  const current = typeof raw === "number" ? Math.max(0, Math.trunc(raw)) : 0;
  return {
    current,
    best: current,
    lastActiveDay: legacyLastLessonDate ?? null,
    freezes: typeof legacyFreezes === "number" ? Math.max(0, Math.trunc(legacyFreezes)) : 2,
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
    },
    leagueId: "bronze",
    weeklyXp: 0,
    badges: [],
    updatedAt: FieldValue.serverTimestamp(),
  };
}

export function computeNextStreak(
  current: StreakInfoDoc,
  todayIso: string
): { nextStreak: StreakInfoDoc; streakBonus: boolean } {
  if (!current.lastActiveDay) {
    return {
      nextStreak: {
        current: 1,
        best: Math.max(1, current.best),
        lastActiveDay: todayIso,
        freezes: current.freezes,
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
    const nextCurrent = current.current + 1;
    return {
      nextStreak: {
        current: nextCurrent,
        best: Math.max(nextCurrent, current.best),
        lastActiveDay: todayIso,
        freezes: current.freezes,
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
    },
    streakBonus: false,
  };
}
