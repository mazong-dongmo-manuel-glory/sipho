import {
  ALL_LESSON_IDS,
  LESSON_UNITS,
  isLessonUnlocked,
  lessonsToCheck,
  prerequisiteOf,
  unitBonusFor,
  unitOfLesson,
} from "../shared/lessonPath";
import { XP_CONFIG } from "../shared/xpConfig";

describe("lesson path", () => {
  test("every lesson belongs to exactly one unit and ids are unique", () => {
    expect(new Set(ALL_LESSON_IDS).size).toBe(ALL_LESSON_IDS.length);
    for (const id of ALL_LESSON_IDS) {
      const owners = LESSON_UNITS.filter((u) => (u.lessons as readonly string[]).includes(id));
      expect(owners).toHaveLength(1);
    }
    expect(unitOfLesson("fake")).toBeNull();
  });

  test("the prerequisite is the previous lesson, across units", () => {
    expect(prerequisiteOf("emergency_fund")).toBeNull();
    expect(prerequisiteOf("needs_wants")).toBe("emergency_fund");
    // first lesson of unit 2 requires the last lesson of unit 1
    expect(prerequisiteOf("savings_goal")).toBe("track_spending");
    expect(prerequisiteOf("fake")).toBeNull();
  });

  test("lessons unlock in order and unit 2 needs unit 1 finished", () => {
    expect(isLessonUnlocked("emergency_fund", new Set())).toBe(true);
    expect(isLessonUnlocked("needs_wants", new Set())).toBe(false);
    expect(isLessonUnlocked("needs_wants", new Set(["emergency_fund"]))).toBe(true);
    expect(isLessonUnlocked("savings_goal", new Set(["emergency_fund", "needs_wants"]))).toBe(
      false
    );
    expect(isLessonUnlocked("savings_goal", new Set(["track_spending"]))).toBe(true);
    expect(isLessonUnlocked("fake", new Set(ALL_LESSON_IDS))).toBe(false);
  });

  test("lessonsToCheck covers the prerequisite and the unit mates, never the lesson itself", () => {
    expect(lessonsToCheck("savings_goal").sort()).toEqual(
      ["track_spending", "pay_yourself_first", "small_amounts"].sort()
    );
    expect(lessonsToCheck("emergency_fund")).not.toContain("emergency_fund");
    expect(lessonsToCheck("fake")).toEqual([]);
  });

  test("the unit bonus is paid only when the last missing lesson is completed for the first time", () => {
    expect(unitBonusFor("needs_wants", new Set(["emergency_fund"]))).toBeNull();
    expect(unitBonusFor("track_spending", new Set(["emergency_fund"]))).toBeNull();

    const bonus = unitBonusFor("track_spending", new Set(["emergency_fund", "needs_wants"]));
    expect(bonus).toEqual({
      unitId: "unit_1",
      xp: XP_CONFIG.unitComplete,
      seeds: XP_CONFIG.unitCompleteSeeds,
    });

    // order inside the unit does not matter: whichever lesson comes last pays
    expect(unitBonusFor("emergency_fund", new Set(["needs_wants", "track_spending"]))).not.toBeNull();
  });

  test("replaying a lesson never pays the unit bonus again", () => {
    const all = new Set<string>(ALL_LESSON_IDS);
    for (const id of ALL_LESSON_IDS) expect(unitBonusFor(id, all)).toBeNull();
    expect(unitBonusFor("fake", new Set())).toBeNull();
  });
});
