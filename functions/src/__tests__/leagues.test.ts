import {
  LEAGUE_TIERS,
  leagueTierId,
  leagueTierIndex,
  leagueWeekEnd,
  leagueWeekKey,
  leagueWeekStart,
  planLeagueOutcomes,
} from "../shared/leagues";

describe("league week (Sunday 20:00 UTC → Sunday 20:00 UTC)", () => {
  test("a Wednesday belongs to the week that started the previous Sunday", () => {
    const now = new Date("2026-11-11T12:00:00Z"); // Wednesday
    expect(leagueWeekStart(now).toISOString()).toBe("2026-11-08T20:00:00.000Z");
    expect(leagueWeekKey(now)).toBe("2026-11-08");
    expect(leagueWeekEnd(now).toISOString()).toBe("2026-11-15T20:00:00.000Z");
  });

  test("the boundary: 19:59:59 is still the old week, 20:00:00 starts the next", () => {
    expect(leagueWeekKey(new Date("2026-11-15T19:59:59Z"))).toBe("2026-11-08");
    expect(leagueWeekKey(new Date("2026-11-15T20:00:00Z"))).toBe("2026-11-15");
  });

  test("a Sunday morning is still in the week that started the Sunday before", () => {
    expect(leagueWeekKey(new Date("2026-11-15T08:00:00Z"))).toBe("2026-11-08");
  });

  test("crosses month and year boundaries", () => {
    expect(leagueWeekKey(new Date("2027-01-02T10:00:00Z"))).toBe("2026-12-27");
  });
});

describe("league tiers", () => {
  test("unknown values fall back to the lowest tier, indexes are clamped", () => {
    expect(leagueTierIndex(undefined)).toBe(0);
    expect(leagueTierIndex("platinum")).toBe(0);
    expect(leagueTierIndex("gold")).toBe(2);
    expect(leagueTierId(-3)).toBe("bronze");
    expect(leagueTierId(99)).toBe(LEAGUE_TIERS[LEAGUE_TIERS.length - 1]);
  });
});

describe("planLeagueOutcomes", () => {
  const group = (n: number, xp: (i: number) => number): { uid: string; weeklyXp: number }[] =>
    Array.from({ length: n }, (_, i) => ({ uid: `u${String(i).padStart(2, "0")}`, weeklyXp: xp(i) }));

  test("top 7 are promoted, last 5 relegated, ranking by weekly XP", () => {
    const outcomes = planLeagueOutcomes(group(30, (i) => 300 - i * 10), 2);
    expect(outcomes.map((o) => o.rank)).toEqual(Array.from({ length: 30 }, (_, i) => i + 1));
    expect(outcomes.filter((o) => o.result === "promoted").map((o) => o.rank)).toEqual([1, 2, 3, 4, 5, 6, 7]);
    expect(outcomes.filter((o) => o.result === "relegated").map((o) => o.rank)).toEqual([26, 27, 28, 29, 30]);
    expect(outcomes[0]).toMatchObject({ fromTier: "gold", toTier: "sapphire" });
    expect(outcomes[29]).toMatchObject({ fromTier: "gold", toTier: "silver" });
    expect(outcomes[10]).toMatchObject({ result: "stayed", toTier: "gold" });
  });

  test("nobody is promoted for earning 0 XP", () => {
    const outcomes = planLeagueOutcomes(group(30, (i) => (i < 3 ? 50 : 0)), 0);
    expect(outcomes.filter((o) => o.result === "promoted")).toHaveLength(3);
  });

  test("bottom tier cannot be relegated, top tier cannot be promoted", () => {
    const low = planLeagueOutcomes(group(30, (i) => 100 - i), 0);
    expect(low.some((o) => o.result === "relegated")).toBe(false);
    const high = planLeagueOutcomes(group(30, (i) => 100 - i), LEAGUE_TIERS.length - 1);
    expect(high.some((o) => o.result === "promoted")).toBe(false);
    expect(high.filter((o) => o.result === "relegated")).toHaveLength(5);
  });

  test("small groups are never relegated (no churn), but can still promote", () => {
    const outcomes = planLeagueOutcomes(group(10, (i) => 100 - i), 3);
    expect(outcomes.some((o) => o.result === "relegated")).toBe(false);
    expect(outcomes.filter((o) => o.result === "promoted")).toHaveLength(7);
  });

  test("promotion and relegation zones never overlap, even in a group of 15", () => {
    const outcomes = planLeagueOutcomes(group(15, (i) => 100 - i), 4);
    expect(outcomes.filter((o) => o.result === "promoted")).toHaveLength(7);
    expect(outcomes.filter((o) => o.result === "relegated")).toHaveLength(5);
    expect(outcomes.filter((o) => o.result === "stayed")).toHaveLength(3);
  });

  test("ties are broken deterministically", () => {
    const a = planLeagueOutcomes([{ uid: "b", weeklyXp: 5 }, { uid: "a", weeklyXp: 5 }], 0);
    expect(a.map((o) => o.uid)).toEqual(["a", "b"]);
  });

  test("an empty group is fine", () => {
    expect(planLeagueOutcomes([], 0)).toEqual([]);
  });
});
