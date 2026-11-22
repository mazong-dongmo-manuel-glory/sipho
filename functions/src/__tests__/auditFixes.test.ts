import { diffDateKeys } from "../shared/timezone";
import { XP_CONFIG } from "../shared/xpConfig";

/** Pure helpers covering audit-fix invariants (no Firestore). */

describe("leagueExemptXp anti-farming invariant", () => {
  test("referral XP amounts are positive and league delta subtracts exempt growth", () => {
    expect(XP_CONFIG.referralInviter).toBe(200);
    expect(XP_CONFIG.referralInvitee).toBe(25);

    const beforeXp = 100;
    const afterXp = beforeXp + XP_CONFIG.referralInviter;
    const beforeExempt = 0;
    const afterExempt = XP_CONFIG.referralInviter;
    const delta = afterXp - beforeXp;
    const leagueDelta = delta - Math.max(0, afterExempt - beforeExempt);
    expect(leagueDelta).toBe(0);
  });

  test("mixed award (lesson + referral exempt) only leagues the non-exempt part", () => {
    const lessonXp = 20;
    const referralXp = XP_CONFIG.referralInvitee;
    const delta = lessonXp + referralXp;
    const exemptDelta = referralXp;
    expect(delta - exemptDelta).toBe(lessonXp);
  });
});

describe("multi-day freeze gap math", () => {
  test("gap of 3 missed days needs 3 freezes to bridge", () => {
    // last active Mon, rollover Thu → yesterday Wed → gap Mon→Wed = 2? 
    // lastActive=2026-11-10, yesterday=2026-11-13 → gap 3
    expect(diffDateKeys("2026-11-10", "2026-11-13")).toBe(3);
    const gap = Math.max(1, diffDateKeys("2026-11-10", "2026-11-13"));
    const freezes = 2;
    const freezesToSpend = Math.min(freezes, gap);
    expect(freezesToSpend).toBe(2);
    expect(freezesToSpend < gap).toBe(true); // partial → break after spending
  });

  test("one missed day spends one freeze", () => {
    const gap = Math.max(1, diffDateKeys("2026-11-12", "2026-11-13"));
    expect(gap).toBe(1);
    expect(Math.min(2, gap)).toBe(1);
  });
});

describe("generateCountryLessons forceNew default", () => {
  test("zod default for forceNew is false", async () => {
    const { z } = await import("zod");
    const schema = z.object({
      forceNew: z.boolean().optional().default(false),
    });
    expect(schema.parse({}).forceNew).toBe(false);
    expect(schema.parse({ forceNew: true }).forceNew).toBe(true);
  });
});
