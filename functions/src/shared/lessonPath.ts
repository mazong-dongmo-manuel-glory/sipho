import { XP_CONFIG } from "./xpConfig";

/**
 * The lesson path: ordered units of ordered lessons. The server is the single authority on it.
 *
 * - A lesson is unlocked once the lesson right before it (across units) is completed.
 * - Finishing the last missing lesson of a unit pays a one-time bonus (XP + seeds).
 *
 * Keep in sync with `kCatalogUnits` in the Flutter app
 * (app/lib/features/lessons/domain/lesson_catalog.dart). An unknown id must never earn XP.
 */
export const LESSON_UNITS = [
  {
    id: "unit_1",
    lessons: ["emergency_fund", "needs_wants", "track_spending"],
  },
  {
    id: "unit_2",
    lessons: ["savings_goal", "pay_yourself_first", "small_amounts"],
  },
  {
    id: "unit_3",
    lessons: ["debt_basics", "inflation_101", "spotting_scams"],
  },
] as const;

export type LessonUnitId = (typeof LESSON_UNITS)[number]["id"];
export type LessonId = (typeof LESSON_UNITS)[number]["lessons"][number];

/** All lessons in path order, typed as a non-empty tuple so zod can build an enum from it. */
export const ALL_LESSON_IDS = LESSON_UNITS.flatMap((unit) => [
  ...unit.lessons,
]) as unknown as [LessonId, ...LessonId[]];

export interface UnitBonus {
  unitId: LessonUnitId;
  xp: number;
  seeds: number;
}

/** Unit a lesson belongs to, or null for an unknown lesson. */
export function unitOfLesson(lessonId: string): (typeof LESSON_UNITS)[number] | null {
  return LESSON_UNITS.find((unit) => (unit.lessons as readonly string[]).includes(lessonId)) ?? null;
}

/** The lesson that must be completed before `lessonId`, or null for the first lesson of the path. */
export function prerequisiteOf(lessonId: string): LessonId | null {
  const index = (ALL_LESSON_IDS as readonly string[]).indexOf(lessonId);
  return index > 0 ? ALL_LESSON_IDS[index - 1] : null;
}

export function isLessonUnlocked(lessonId: string, completed: ReadonlySet<string>): boolean {
  if (!(ALL_LESSON_IDS as readonly string[]).includes(lessonId)) return false;
  const prerequisite = prerequisiteOf(lessonId);
  return prerequisite === null || completed.has(prerequisite);
}

/**
 * Lessons whose completion state matters when finishing `lessonId`: the prerequisite and the
 * other lessons of the same unit. The caller reads these before writing anything.
 */
export function lessonsToCheck(lessonId: string): string[] {
  const ids = new Set<string>();
  const prerequisite = prerequisiteOf(lessonId);
  if (prerequisite) ids.add(prerequisite);
  for (const mate of unitOfLesson(lessonId)?.lessons ?? []) {
    if (mate !== lessonId) ids.add(mate);
  }
  return [...ids];
}

/**
 * Bonus earned by completing `lessonId` for the first time, or null when this completion does not
 * finish its unit. `completed` is what was done *before* this completion.
 *
 * Paid at most once per unit: it is only possible on the first completion of the unit's last
 * missing lesson, and replays never qualify.
 */
export function unitBonusFor(lessonId: string, completed: ReadonlySet<string>): UnitBonus | null {
  if (completed.has(lessonId)) return null;
  const unit = unitOfLesson(lessonId);
  if (!unit) return null;
  const othersDone = unit.lessons.every((id) => id === lessonId || completed.has(id));
  if (!othersDone) return null;
  return {
    unitId: unit.id,
    xp: XP_CONFIG.unitComplete,
    seeds: XP_CONFIG.unitCompleteSeeds,
  };
}
