import {
  FRIEND_CHALLENGE_TEMPLATES,
  FRIEND_CHALLENGE_TEMPLATE_IDS,
  templateById,
} from "../shared/friendChallenges";
import { REFERRAL_ACTIVE_DAYS_REQUIRED } from "../referrals/referralReward";
import { XP_CONFIG } from "../shared/xpConfig";
import {
  ALL_AWARDABLE_LESSON_IDS,
  COUNTRY_LESSON_MODULES,
  isCountryLessonAllowed,
  isLessonUnlocked,
} from "../shared/lessonPath";

describe("friend challenge templates", () => {
  test("every template has a stable id used by the client catalog", () => {
    expect(FRIEND_CHALLENGE_TEMPLATE_IDS).toEqual([
      "marathon_savoir",
      "zero_ecart",
      "boost_epargne",
      "semaine_champion",
    ]);
  });

  test("server owns XP and targets (no free-form client values)", () => {
    for (const t of FRIEND_CHALLENGE_TEMPLATES) {
      expect(t.rewardXp).toBeGreaterThan(0);
      expect(t.targetCount).toBeGreaterThan(0);
      expect(t.durationDays).toBeGreaterThan(0);
      expect(templateById(t.id)?.metric).toBe(t.metric);
    }
  });
});

describe("referral delayed reward", () => {
  test("requires 7 active days and pays 200 XP to the inviter", () => {
    expect(REFERRAL_ACTIVE_DAYS_REQUIRED).toBe(7);
    expect(XP_CONFIG.referralInviter).toBe(200);
    expect(XP_CONFIG.referralInvitee).toBe(25);
  });
});

describe("country lesson modules", () => {
  test("pack lesson ids are awardable and gated by country", () => {
    expect(ALL_AWARDABLE_LESSON_IDS).toContain("ca_slot_01");
    expect(ALL_AWARDABLE_LESSON_IDS).toContain("ci_slot_01");
    expect(isCountryLessonAllowed("ca_slot_01", "CA")).toBe(true);
    expect(isCountryLessonAllowed("ca_slot_01", "FR")).toBe(false);
    expect(isCountryLessonAllowed("gen_slot_01", "ZZ")).toBe(true);
    expect(isLessonUnlocked("ca_slot_01", new Set())).toBe(true);
  });

  test("every country module lists at least one country or *", () => {
    for (const mod of COUNTRY_LESSON_MODULES) {
      expect(mod.countries.length).toBeGreaterThan(0);
    }
  });
});
