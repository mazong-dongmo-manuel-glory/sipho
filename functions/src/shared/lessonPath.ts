import { XP_CONFIG } from "./xpConfig";
import {
  COUNTRY_LESSON_MODULES,
  type CountryLessonId,
} from "./countryLessonTopics";

export { COUNTRY_LESSON_MODULES, type CountryLessonId };
export {
  COUNTRY_SLOTS,
  TOPIC_BANK,
  isAwardableSlot,
  pickRandomTopic,
  slotsForCountry,
  topicsForCountry,
  topicById,
  slotById,
} from "./countryLessonTopics";

/**
 * The lesson path: ordered units of ordered lessons. The server is the single authority on it.
 *
 * - A lesson is unlocked once the lesson right before it (across units) is completed.
 * - Finishing the last missing lesson of a unit pays a one-time bonus (XP + seeds).
 *
 * Keep in sync with `kCatalogUnits` in the Flutter app
 * (app/lib/features/lessons/domain/lesson_catalog.dart). An unknown id must never earn XP.
 *
 * Country modules: awardable **slots** from `countryLessonTopics.ts` (`ca_slot_01`…).
 * AI content is generated into those slots; topic seeds are not awardable.
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
  {
    id: "unit_4",
    lessons: ["investing_basics", "compound_interest", "smart_budget_503020"],
  },
] as const;

export type LessonUnitId = (typeof LESSON_UNITS)[number]["id"];
export type LessonId = (typeof LESSON_UNITS)[number]["lessons"][number];

/** All lessons in path order, typed as a non-empty tuple so zod can build an enum from it. */
export const ALL_LESSON_IDS = LESSON_UNITS.flatMap((unit) => [
  ...unit.lessons,
]) as unknown as [LessonId, ...LessonId[]];

/** Path + country modules — anything that may earn XP via `completeLesson`. */
export const ALL_AWARDABLE_LESSON_IDS = [
  ...ALL_LESSON_IDS,
  ...COUNTRY_LESSON_MODULES.map((m) => m.id),
] as unknown as [string, ...string[]];

export function countryLessonCountries(lessonId: string): readonly string[] | null {
  const mod = COUNTRY_LESSON_MODULES.find((m) => m.id === lessonId);
  return mod ? mod.countries : null;
}

export function isCountryLesson(lessonId: string): boolean {
  return countryLessonCountries(lessonId) != null;
}

/** True when a country module is available for this user's countryCode. */
export function isCountryLessonAllowed(
  lessonId: string,
  countryCode: string | null | undefined
): boolean {
  const countries = countryLessonCountries(lessonId);
  if (!countries) return false;
  if (countries.includes("*")) return true;
  const code = (countryCode ?? "").toUpperCase();
  return code.length === 2 && (countries as readonly string[]).includes(code);
}

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

/** Server-generated lessons: `gen_001`, `gen_002`, … stored in `users/{uid}/aiLessons`. */
export const GENERATED_LESSON_ID = /^gen_(\d{3})$/;

export function generatedLessonIndex(lessonId: string): number | null {
  const match = GENERATED_LESSON_ID.exec(lessonId);
  if (!match) return null;
  const index = Number(match[1]);
  if (!Number.isInteger(index) || index < 1 || index > 999) return null;
  return index;
}

export function isGeneratedLessonId(lessonId: string): boolean {
  return generatedLessonIndex(lessonId) != null;
}

export function generatedLessonIdFor(index: number): string {
  return `gen_${String(index).padStart(3, "0")}`;
}

export function previousGeneratedLessonId(lessonId: string): string | null {
  const index = generatedLessonIndex(lessonId);
  if (index == null || index <= 1) return null;
  return generatedLessonIdFor(index - 1);
}

/** The 12 static lessons are finished, so the open-ended tail may start. */
export function corePathCompleted(completed: ReadonlySet<string>): boolean {
  return (ALL_LESSON_IDS as readonly string[]).every((id) => completed.has(id));
}

/**
 * A generated lesson unlocks only after the static path, then one by one.
 * The document must also exist; `completeLesson` checks that separately.
 */
export function isGeneratedLessonUnlocked(
  lessonId: string,
  completed: ReadonlySet<string>
): boolean {
  const index = generatedLessonIndex(lessonId);
  if (index == null) return false;
  if (!corePathCompleted(completed)) return false;
  if (index === 1) return true;
  const previous = previousGeneratedLessonId(lessonId);
  return previous != null && completed.has(previous);
}

export function isLessonUnlocked(lessonId: string, completed: ReadonlySet<string>): boolean {
  if (isGeneratedLessonId(lessonId)) {
    return isGeneratedLessonUnlocked(lessonId, completed);
  }
  // Country modules have no path prerequisite (gated by country in completeLesson).
  if (isCountryLesson(lessonId)) return true;
  if (!(ALL_LESSON_IDS as readonly string[]).includes(lessonId)) return false;
  const prerequisite = prerequisiteOf(lessonId);
  return prerequisite === null || completed.has(prerequisite);
}

/**
 * Lessons whose completion state matters when finishing `lessonId`: the prerequisite and the
 * other lessons of the same unit. The caller reads these before writing anything.
 */
export function lessonsToCheck(lessonId: string): string[] {
  if (isGeneratedLessonId(lessonId)) {
    const previous = previousGeneratedLessonId(lessonId);
    if (previous) return [previous];
    return [...ALL_LESSON_IDS];
  }
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
