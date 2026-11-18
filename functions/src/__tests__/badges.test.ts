import { BADGE_IDS, BadgeInput, earnedBadges, missingBadges } from "../shared/badges";

const none: BadgeInput = {
  level: 1,
  bestStreak: 0,
  leagueId: "bronze",
  completedLessonIds: new Set(),
};

describe("badges", () => {
  test("a new user has none, and ids are unique", () => {
    expect(earnedBadges(none)).toEqual([]);
    expect(new Set(BADGE_IDS).size).toBe(BADGE_IDS.length);
  });

  test("builder badge requires onboardingDone", () => {
    expect(earnedBadges({ ...none, onboardingDone: false })).toEqual([]);
    expect(earnedBadges({ ...none, onboardingDone: true })).toEqual(["builder"]);
  });

  test("lesson badges: first lesson, then each unit once all its lessons are done", () => {
    const one = { ...none, completedLessonIds: new Set(["emergency_fund"]) };
    expect(earnedBadges(one)).toEqual(["first_lesson"]);

    const partial = { ...none, completedLessonIds: new Set(["emergency_fund", "needs_wants"]) };
    expect(earnedBadges(partial)).toEqual(["first_lesson"]);

    const unit1 = {
      ...none,
      completedLessonIds: new Set(["emergency_fund", "needs_wants", "track_spending"]),
    };
    expect(earnedBadges(unit1)).toEqual(["first_lesson", "unit_1"]);
  });

  test("streak badges use the best streak, so a broken streak does not take them away", () => {
    expect(earnedBadges({ ...none, bestStreak: 6 })).toEqual([]);
    expect(earnedBadges({ ...none, bestStreak: 7 })).toEqual(["streak_7"]);
    expect(earnedBadges({ ...none, bestStreak: 30 })).toEqual(["streak_7", "streak_30"]);
  });

  test("level and league badges", () => {
    expect(earnedBadges({ ...none, level: 4 })).toEqual([]);
    expect(earnedBadges({ ...none, level: 5 })).toEqual(["level_5"]);
    expect(earnedBadges({ ...none, level: 10 })).toEqual(["level_5", "level_10"]);
    expect(earnedBadges({ ...none, leagueId: "silver" })).toEqual(["league_silver"]);
    expect(earnedBadges({ ...none, leagueId: "diamond" })).toEqual(["league_silver"]);
    // an unknown league falls back to the lowest tier
    expect(earnedBadges({ ...none, leagueId: "???" })).toEqual([]);
  });

  test("missingBadges skips what is already owned and keeps display order", () => {
    const input = { ...none, level: 5, bestStreak: 7 };
    expect(missingBadges(input, [])).toEqual(["streak_7", "level_5"]);
    expect(missingBadges(input, ["streak_7"])).toEqual(["level_5"]);
    expect(missingBadges(input, ["streak_7", "level_5"])).toEqual([]);
    // an owned badge the user no longer qualifies for is not "missing"
    expect(missingBadges(none, ["level_5"])).toEqual([]);
  });
});
