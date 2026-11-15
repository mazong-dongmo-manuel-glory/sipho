import {
  DAILY_QUEST_TEMPLATES,
  MAX_DAILY_QUESTS,
  dailyQuestId,
} from "../shared/dailyQuests";
import {
  QUEST_REWARD_BOUNDS,
  classifyClaim,
  questRewardGems,
  questRewardXp,
} from "../shared/questClaim";

/** Quest types that a server trigger actually advances (onTransactionWrite / completeLesson). */
const ADVANCED_TYPES = ["ADD_TRANSACTION", "COMPLETE_LESSON"];

describe("daily quest templates", () => {
  test("stay within the README cap of three daily quests", () => {
    expect(DAILY_QUEST_TEMPLATES.length).toBeGreaterThan(0);
    expect(DAILY_QUEST_TEMPLATES.length).toBeLessThanOrEqual(MAX_DAILY_QUESTS);
  });

  test("have unique ids and valid ids once combined with a day (claimQuest regex)", () => {
    const ids = DAILY_QUEST_TEMPLATES.map((t) => t.templateId);
    expect(new Set(ids).size).toBe(ids.length);
    for (const id of ids) {
      expect(dailyQuestId(id, "2026-11-14")).toMatch(/^[a-zA-Z0-9_-]+$/);
    }
  });

  test("only use quest types that the server advances", () => {
    for (const tpl of DAILY_QUEST_TEMPLATES) {
      expect(ADVANCED_TYPES).toContain(tpl.type);
    }
  });

  test("have rewards that survive the claim clamps unchanged", () => {
    for (const tpl of DAILY_QUEST_TEMPLATES) {
      expect(questRewardXp(tpl.rewardXp)).toBe(tpl.rewardXp);
      expect(questRewardGems(tpl.rewardGems)).toBe(tpl.rewardGems);
      // README 5.2: daily quest rewards are 20-50 XP in the full catalogue; never above that here.
      expect(tpl.rewardXp).toBeLessThanOrEqual(50);
    }
  });

  test("always pay less than the whole day of lessons, so quests never dominate XP", () => {
    const total = DAILY_QUEST_TEMPLATES.reduce((sum, t) => sum + t.rewardXp, 0);
    expect(total).toBeLessThanOrEqual(100);
  });

  test("have French and English copy, and a positive integer target", () => {
    for (const tpl of DAILY_QUEST_TEMPLATES) {
      for (const lang of ["fr", "en"] as const) {
        expect(tpl.name[lang].trim().length).toBeGreaterThan(0);
        expect(tpl.description[lang].trim().length).toBeGreaterThan(0);
      }
      expect(Number.isInteger(tpl.target)).toBe(true);
      expect(tpl.target).toBeGreaterThan(0);
    }
  });

  test("include a lesson quest", () => {
    const lesson = DAILY_QUEST_TEMPLATES.find((t) => t.type === "COMPLETE_LESSON");
    expect(lesson?.templateId).toBe("daily_lesson");
    expect(lesson?.target).toBe(1);
  });
});

describe("classifyClaim", () => {
  test("claims a completed quest", () => {
    expect(classifyClaim({ status: "completed", progress: 3, target: 3 })).toBe("claimable");
  });

  test("claims when progress reached the target even if status lags", () => {
    expect(classifyClaim({ status: "active", progress: 3, target: 3 })).toBe("claimable");
  });

  test("refuses an unfinished quest", () => {
    expect(classifyClaim({ status: "active", progress: 2, target: 3 })).toBe("not-completed");
    expect(classifyClaim({ status: "active" })).toBe("not-completed");
  });

  test("is idempotent for an already claimed quest", () => {
    expect(classifyClaim({ status: "claimed", progress: 3, target: 3 })).toBe("already-claimed");
  });

  test("refuses an expired quest even when its progress reached the target", () => {
    expect(classifyClaim({ status: "expired", progress: 3, target: 3 })).toBe("expired");
  });

  test("never trusts a malformed document", () => {
    expect(classifyClaim({ status: "active", progress: "9", target: "1" })).toBe("not-completed");
    expect(classifyClaim({ status: "active", progress: 0, target: 0 })).toBe("not-completed");
  });
});

describe("quest reward clamps", () => {
  test("clamp xp and gems to their bounds", () => {
    expect(questRewardXp(10_000)).toBe(QUEST_REWARD_BOUNDS.xp.max);
    expect(questRewardXp(-3)).toBe(QUEST_REWARD_BOUNDS.xp.min);
    expect(questRewardGems(999)).toBe(QUEST_REWARD_BOUNDS.gems.max);
    expect(questRewardGems(0)).toBe(QUEST_REWARD_BOUNDS.gems.min);
  });

  test("fall back to defaults for missing or non-finite values", () => {
    expect(questRewardXp(undefined)).toBe(QUEST_REWARD_BOUNDS.xp.fallback);
    expect(questRewardXp(Number.NaN)).toBe(QUEST_REWARD_BOUNDS.xp.fallback);
    expect(questRewardGems("5")).toBe(QUEST_REWARD_BOUNDS.gems.fallback);
    expect(questRewardGems(Number.POSITIVE_INFINITY)).toBe(QUEST_REWARD_BOUNDS.gems.fallback);
  });
});
