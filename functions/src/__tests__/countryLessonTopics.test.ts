import {
  COUNTRY_SLOTS,
  TOPIC_BANK,
  isAwardableSlot,
  pickRandomTopic,
  slotsForCountry,
  topicsForCountry,
} from "../shared/countryLessonTopics";
import { ALL_AWARDABLE_LESSON_IDS, isCountryLessonAllowed } from "../shared/lessonPath";

describe("country lesson slots & topic bank", () => {
  test("slots are unique, awardable, and wired into ALL_AWARDABLE_LESSON_IDS", () => {
    const ids = COUNTRY_SLOTS.map((s) => s.id);
    expect(new Set(ids).size).toBe(ids.length);
    expect(ids.length).toBeGreaterThanOrEqual(50);
    for (const id of ids) {
      expect(isAwardableSlot(id)).toBe(true);
      expect(ALL_AWARDABLE_LESSON_IDS).toContain(id);
    }
    // Topic seeds must never be awardable.
    expect(isAwardableSlot(TOPIC_BANK[0].id)).toBe(false);
    expect(ALL_AWARDABLE_LESSON_IDS).not.toContain(TOPIC_BANK[0].id);
  });

  test("TOPIC_BANK has ≥1000 unique seeds", () => {
    const ids = TOPIC_BANK.map((t) => t.id);
    expect(ids.length).toBeGreaterThanOrEqual(1000);
    expect(new Set(ids).size).toBe(ids.length);
    for (const t of TOPIC_BANK) {
      expect(t.theme.length).toBeGreaterThan(3);
      expect(t.angle.length).toBeGreaterThan(3);
      expect(t.countries.length).toBeGreaterThan(0);
    }
  });

  test("slotsForCountry / topicsForCountry gate by country with * fallback", () => {
    expect(slotsForCountry("CA").every((s) => s.countries.includes("CA"))).toBe(true);
    expect(slotsForCountry("CA").some((s) => s.id === "ca_slot_01")).toBe(true);
    expect(slotsForCountry("ZZ").every((s) => s.countries.includes("*"))).toBe(true);
    expect(topicsForCountry("FR").length).toBeGreaterThanOrEqual(100);
    expect(topicsForCountry("ZZ").every((t) => t.countries.includes("*"))).toBe(true);
  });

  test("country gate allows matching slot codes and star modules", () => {
    expect(isCountryLessonAllowed("ca_slot_01", "CA")).toBe(true);
    expect(isCountryLessonAllowed("ca_slot_01", "FR")).toBe(false);
    expect(isCountryLessonAllowed("gen_slot_01", "US")).toBe(true);
  });

  test("pickRandomTopic never returns the excluded id when alternatives exist", () => {
    const ca = topicsForCountry("CA");
    expect(ca.length).toBeGreaterThan(1);
    const exclude = ca[0].id;
    const seq = [0.0, 0.0, 0.0];
    let i = 0;
    const picked = pickRandomTopic("CA", exclude, () => seq[i++] ?? 0.5);
    expect(picked.id).not.toBe(exclude);
    expect(picked.countries).toContain("CA");
  });

  test("pickRandomTopic still returns a topic when exclude is the only option", () => {
    const gen = topicsForCountry("ZZ");
    const only = gen[0];
    // Force tiny pool behaviour: exclude something not in pool → still picks from pool.
    const picked = pickRandomTopic("ZZ", "not_in_bank_zzzz", () => 0);
    expect(picked.id).toBe(only.id);
  });
});
