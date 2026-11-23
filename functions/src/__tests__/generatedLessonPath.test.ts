import { corePathCompleted, isGeneratedLessonUnlocked, isLessonUnlocked } from "../shared/lessonPath";

const core = [
  "emergency_fund",
  "needs_wants",
  "track_spending",
  "savings_goal",
  "pay_yourself_first",
  "small_amounts",
  "debt_basics",
  "inflation_101",
  "spotting_scams",
  "investing_basics",
  "compound_interest",
  "smart_budget_503020",
];

describe("generated lesson path", () => {
  test("gen_001 stays locked until the 12 static lessons are done", () => {
    expect(isLessonUnlocked("gen_001", new Set())).toBe(false);
    expect(isGeneratedLessonUnlocked("gen_001", new Set(core.slice(0, 11)))).toBe(false);
    expect(corePathCompleted(new Set(core))).toBe(true);
    expect(isLessonUnlocked("gen_001", new Set(core))).toBe(true);
  });

  test("gen_002 waits for gen_001", () => {
    const done = new Set([...core, "gen_001"]);
    expect(isLessonUnlocked("gen_002", new Set(core))).toBe(false);
    expect(isLessonUnlocked("gen_002", done)).toBe(true);
  });
});
