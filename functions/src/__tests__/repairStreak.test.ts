import {
  canRepairStreak,
  computeNextStreak,
  isWithinStreakRepairWindow,
  normalizeStreak,
  repairStreakState,
  STREAK_MILESTONES,
} from "../shared/gameState";

describe("streak repair & milestones", () => {
  test("milestones match the README list", () => {
    expect([...STREAK_MILESTONES]).toEqual([3, 7, 14, 30, 50, 100, 200, 365]);
  });

  test("canRepairStreak requires freeze, brokenCurrent and a 24h window", () => {
    const now = Date.parse("2026-11-17T12:00:00Z");
    const streak = normalizeStreak({
      current: 0,
      best: 5,
      lastActiveDay: "2026-11-15",
      freezes: 1,
      brokenAt: "2026-11-17T10:00:00Z",
      brokenCurrent: 5,
    });
    expect(canRepairStreak(streak, now)).toBe(true);
    expect(canRepairStreak({ ...streak, freezes: 0 }, now)).toBe(false);
    expect(
      canRepairStreak(
        { ...streak, brokenAt: "2026-11-16T10:00:00Z" },
        now
      )
    ).toBe(false);
  });

  test("computeNextStreak preserves brokenCurrent during the repair window", () => {
    const now = Date.parse("2026-11-17T12:00:00Z");
    const broken = normalizeStreak({
      current: 0,
      best: 8,
      lastActiveDay: "2026-11-14",
      freezes: 1,
      brokenAt: "2026-11-17T10:00:00Z",
      brokenCurrent: 8,
    });
    expect(isWithinStreakRepairWindow(broken, now)).toBe(true);
    const next = computeNextStreak(broken, "2026-11-17", now);
    expect(next.nextStreak.brokenCurrent).toBe(8);
    expect(next.nextStreak.current).toBe(0);
    expect(next.nextStreak.brokenAt).toBe("2026-11-17T10:00:00Z");
  });

  test("repairStreakState restores the streak and spends one freeze", () => {
    const streak = normalizeStreak({
      current: 0,
      best: 5,
      lastActiveDay: "2026-11-15",
      freezes: 2,
      brokenAt: new Date().toISOString(),
      brokenCurrent: 5,
    });
    const repaired = repairStreakState(streak, "2026-11-17");
    expect(repaired).toMatchObject({
      current: 5,
      best: 5,
      freezes: 1,
      brokenAt: null,
      brokenCurrent: 0,
      lastActiveDay: "2026-11-17",
    });
  });
});
