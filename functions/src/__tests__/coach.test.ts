import {
  COACH_TIPS,
  coachRoll,
  computeEducationProgress,
  pickCoachTip,
  stageFromScore,
  stageIdFor,
} from "../shared/coach";

describe("education progress", () => {
  test("maps scores to progressive stages", () => {
    expect(stageFromScore(0)).toBe(0);
    expect(stageFromScore(19)).toBe(0);
    expect(stageFromScore(20)).toBe(1);
    expect(stageFromScore(45)).toBe(2);
    expect(stageFromScore(70)).toBe(3);
    expect(stageFromScore(90)).toBe(4);
    expect(stageIdFor(2)).toBe("saving");
  });

  test("rewards lessons and habits without inventing financial advice", () => {
    const beginner = computeEducationProgress({
      lessonsCompleted: 0,
      streakBest: 0,
      level: 1,
      hasIncome: false,
      hasGoal: false,
      underBudgetDayCount: 0,
    });
    expect(beginner.stage).toBe(0);
    expect(beginner.stageId).toBe("foundation");

    const advanced = computeEducationProgress({
      lessonsCompleted: 10,
      streakBest: 30,
      level: 8,
      hasIncome: true,
      hasGoal: true,
      underBudgetDayCount: 5,
    });
    expect(advanced.educationScore).toBeGreaterThanOrEqual(80);
    expect(advanced.stage).toBe(4);
  });
});

describe("pickCoachTip", () => {
  test("never repeats the previous tip when another exists", () => {
    const last = COACH_TIPS[0]!.id;
    for (let i = 0; i < 20; i++) {
      const picked = pickCoachTip({
        stage: 4,
        lastTipId: last,
        recentTipIds: [],
        locale: "fr",
        roll: i / 20,
      });
      expect(picked).not.toBeNull();
      expect(picked!.tip.id).not.toBe(last);
    }
  });

  test("respects minStage (progressivity)", () => {
    const picked = pickCoachTip({
      stage: 0,
      lastTipId: null,
      recentTipIds: [],
      locale: "en",
      roll: 0.1,
    });
    expect(picked!.tip.minStage).toBeLessThanOrEqual(0);
  });

  test("prefers tips outside the recent window", () => {
    const stageTips = COACH_TIPS.filter((t) => t.minStage <= 1);
    const recent = stageTips.slice(0, Math.max(1, stageTips.length - 1)).map((t) => t.id);
    const picked = pickCoachTip({
      stage: 1,
      lastTipId: null,
      recentTipIds: recent,
      locale: "fr",
      roll: 0.2,
    });
    expect(recent.includes(picked!.tip.id)).toBe(false);
  });

  test("coachRoll is stable", () => {
    expect(coachRoll("u1", "2026-11-19T10")).toBe(coachRoll("u1", "2026-11-19T10"));
    expect(coachRoll("u1", "2026-11-19T10")).not.toBe(coachRoll("u2", "2026-11-19T10"));
  });

  test("every tip has both locales and a unique id", () => {
    const ids = new Set<string>();
    for (const tip of COACH_TIPS) {
      expect(tip.title.fr.length).toBeGreaterThan(3);
      expect(tip.title.en.length).toBeGreaterThan(3);
      expect(tip.body.fr.length).toBeGreaterThan(10);
      expect(tip.body.en.length).toBeGreaterThan(10);
      expect(ids.has(tip.id)).toBe(false);
      ids.add(tip.id);
    }
  });
});
