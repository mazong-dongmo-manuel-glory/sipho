/**
 * Integration tests for the XP / streak / quest logic, run against the Firestore emulator:
 *   npm run test:emulator
 */
import * as admin from "firebase-admin";
import { getFirestore, Firestore, Timestamp } from "firebase-admin/firestore";
import { completeLesson } from "../gamification/completeLesson";
import { syncBadges } from "../gamification/badges";
import { buyShopItem } from "../gamification/shop";
import { markFixedPaid } from "../gamification/markFixedPaid";
import { recordTransactionActivity } from "../gamification/onTransactionWrite";
import { processUserRollover } from "../gamification/dailyRollover";
import { awardBudgetDayIfEarned } from "../gamification/budgetDay";
import { confirmNoSpend } from "../gamification/confirmNoSpend";
import { referralRedeem } from "../referrals/referralRedeem";
import {
  getInviteCode,
  removeFriend,
  respondFriendRequest,
  sendFriendRequest,
} from "../social/friends";
import { friendPairId, inviteCodeFor } from "../shared/friends";
import { DAILY_QUEST_TEMPLATES, dailyQuestId, ensureDailyQuests } from "../shared/dailyQuests";
import { forEachDocument } from "../shared/pagination";
import { addLeagueXp, closeLeagueGroup, ensureLeagueMembership } from "../shared/leagueService";
import { localDateKey, localMonthKey, resolveUserTime, shiftDateKey } from "../shared/timezone";

const PROJECT_ID = "sipho-test";
const TORONTO = "America/Toronto";

let db: Firestore;

type CallableRun = { run: (req: never) => unknown };

async function call<T>(fn: unknown, uid: string, data: Record<string, unknown>): Promise<T> {
  const request = { data, auth: { uid, token: {} }, rawRequest: {}, acceptsStreaming: false };
  return (await (fn as CallableRun).run(request as never)) as T;
}

async function callError(fn: unknown, uid: string, data: Record<string, unknown>): Promise<string> {
  try {
    await call(fn, uid, data);
  } catch (err) {
    return (err as { code?: string }).code ?? String(err);
  }
  return "no-error";
}

async function clearAll(): Promise<void> {
  const host = process.env.FIRESTORE_EMULATOR_HOST;
  await fetch(`http://${host}/emulator/v1/projects/${PROJECT_ID}/databases/(default)/documents`, {
    method: "DELETE",
  });
}

async function seedUser(uid: string, extra: Record<string, unknown> = {}): Promise<void> {
  await db.doc(`users/${uid}`).set({
    displayName: "Test",
    locale: "fr",
    timezone: TORONTO,
    utcOffsetMinutes: -300,
    onboardingDone: true,
    ...extra,
  });
  await db.doc(`users/${uid}/game/state`).set({
    xp: 0,
    level: 1,
    gems: 0,
    weeklyXp: 0,
    leagueId: "bronze",
    badges: [],
    streak: { current: 0, best: 0, lastActiveDay: null, freezes: 2 },
  });
}

interface GameDoc {
  xp: number;
  weeklyXp: number;
  badges: string[];
  lastRolloverDay?: string;
  streak: { current: number; best: number; lastActiveDay: string | null; freezes: number };
}

interface QuestDoc {
  status: string;
  progress: number;
  expiresAt: Timestamp;
}

async function game(uid: string): Promise<GameDoc> {
  return (await db.doc(`users/${uid}/game/state`).get()).data() as GameDoc;
}

const toronto = resolveUserTime({ timezone: TORONTO });

beforeAll(() => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) {
    throw new Error("Run with `npm run test:emulator` (needs FIRESTORE_EMULATOR_HOST).");
  }
  admin.initializeApp({ projectId: PROJECT_ID });
  db = getFirestore();
});

beforeEach(clearAll);

describe("transactions: XP is capped per SERVER day and the streak advances", () => {
  test("logging expenses cannot exceed the daily XP cap, however many (or however backdated)", async () => {
    await seedUser("u1");
    const now = new Date();
    // recordTransactionActivity never sees the user-supplied `date`: a transaction dated
    // 2019 or 2099 is counted against the same server day as any other.
    for (let i = 0; i < 12; i++) await recordTransactionActivity("u1", `tx${i}`, now);

    const state = await game("u1");
    expect(state.xp).toBe(10);
    expect(state.weeklyXp).toBe(10);
    const dailyDocs = await db.collection("users/u1/dailyXp").get();
    expect(dailyDocs.size).toBe(1);
    expect(dailyDocs.docs[0].id).toBe(localDateKey(now, toronto));
  });

  test("logging an expense advances the streak (once per day), without lessons", async () => {
    await seedUser("u2");
    const day1 = new Date("2026-11-10T15:00:00Z");
    const day2 = new Date("2026-11-11T15:00:00Z");
    const day4 = new Date("2026-11-13T15:00:00Z");

    await recordTransactionActivity("u2", "a", day1);
    await recordTransactionActivity("u2", "b", day1);
    expect((await game("u2")).streak.current).toBe(1);

    await recordTransactionActivity("u2", "c", day2);
    let state = await game("u2");
    expect(state.streak.current).toBe(2);
    expect(state.streak.lastActiveDay).toBe("2026-11-11");
    expect((await db.doc("publicProfiles/u2").get()).data()?.streak).toBe(2);

    await recordTransactionActivity("u2", "d", day4); // skipped a day
    state = await game("u2");
    expect(state.streak.current).toBe(1);
    expect(state.streak.best).toBe(2);
  });
});

describe("completeLesson", () => {
  test("a fake lesson id earns nothing", async () => {
    await seedUser("u3");
    const code = await callError(completeLesson, "u3", {
      lessonId: "totally_fake",
      score: 100,
      durationSeconds: 30,
    });
    expect(code).toBe("invalid-argument");
    expect((await game("u3")).xp).toBe(0);
  });

  test("replaying a lesson with fresh attemptIds is capped per day", async () => {
    await seedUser("u4");
    const base = { lessonId: "emergency_fund", score: 100, durationSeconds: 30 };
    const first = await call<{ xpGained: number }>(completeLesson, "u4", { ...base, attemptId: "a0" });
    expect(first.xpGained).toBe(20);

    for (let i = 1; i <= 15; i++) {
      await call(completeLesson, "u4", { ...base, attemptId: `a${i}` });
    }
    // 20 for the first completion + at most 10 practice XP for replays on one day.
    expect((await game("u4")).xp).toBeLessThanOrEqual(20 + 10);
    expect((await game("u4")).xp).toBeGreaterThanOrEqual(20 + 10);
  });

  test("a locked lesson is refused and earns nothing", async () => {
    await seedUser("u4l");
    const code = await callError(completeLesson, "u4l", {
      lessonId: "needs_wants",
      score: 100,
      durationSeconds: 30,
    });
    expect(code).toBe("failed-precondition");
    expect((await game("u4l")).xp).toBe(0);
    expect((await db.doc("users/u4l/lessonProgress/needs_wants").get()).exists).toBe(false);

    // the first lesson of unit 2 stays locked until unit 1 is done
    const unit2 = await callError(completeLesson, "u4l", {
      lessonId: "savings_goal",
      score: 100,
      durationSeconds: 30,
    });
    expect(unit2).toBe("failed-precondition");
  });

  test("finishing a unit pays a one-time bonus and unlocks the next unit", async () => {
    await seedUser("u4u");
    type Result = {
      xpGained: number;
      seedsGained: number;
      unitCompleted: string | null;
      unitBonusXp: number;
    };
    const lesson = (lessonId: string, attemptId: string): Promise<Result> =>
      call<Result>(completeLesson, "u4u", { lessonId, score: 100, durationSeconds: 30, attemptId });

    const first = await lesson("emergency_fund", "u0");
    const second = await lesson("needs_wants", "u1");
    expect(first.unitCompleted).toBeNull();
    expect(second.unitCompleted).toBeNull();
    expect(second.unitBonusXp).toBe(0);

    const last = await lesson("track_spending", "u2");
    expect(last.unitCompleted).toBe("unit_1");
    expect(last.unitBonusXp).toBe(30);
    expect(last.xpGained).toBe(20 + 30);
    expect(last.seedsGained).toBe(5 + 10);
    expect((await game("u4u")).xp).toBe(20 + 20 + 20 + 30);

    // replaying the last lesson pays no second bonus
    const replay = await lesson("track_spending", "u3");
    expect(replay.unitCompleted).toBeNull();
    expect(replay.unitBonusXp).toBe(0);
    expect(replay.seedsGained).toBe(0);

    // unit 2 is now open
    const next = await lesson("savings_goal", "u4");
    expect(next.unitCompleted).toBeNull();
    expect(next.xpGained).toBe(20);
  });

  test("completing a lesson completes today's lesson quest (and not the expenses one)", async () => {
    await seedUser("u4q");
    await ensureDailyQuests(db, "u4q", toronto, "fr", new Date());
    const lessonQuests = await db
      .collection("users/u4q/quests")
      .where("templateId", "==", "daily_lesson")
      .get();
    expect(lessonQuests.size).toBe(1);

    await call(completeLesson, "u4q", {
      lessonId: "emergency_fund",
      score: 100,
      durationSeconds: 30,
      attemptId: "q0",
    });

    const lesson = (await lessonQuests.docs[0].ref.get()).data() as QuestDoc;
    expect(lesson.status).toBe("completed");
    expect(lesson.progress).toBe(1);
    const expenses = (await db.collection("users/u4q/quests").where("templateId", "==", "log_expenses").get())
      .docs[0].data() as QuestDoc;
    expect(expenses.status).toBe("active");
    expect(expenses.progress).toBe(0);
  });
});

describe("badges", () => {
  test("syncBadges awards what the state qualifies for, once, and mirrors it publicly", async () => {
    await seedUser("ub1", { completedLessonIds: ["emergency_fund"] });
    await db.doc("users/ub1/game/state").set(
      { level: 5, streak: { current: 1, best: 7, lastActiveDay: null, freezes: 2 } },
      { merge: true }
    );

    const first = await syncBadges("ub1");
    expect(first).toEqual(["first_lesson", "streak_7", "level_5"]);
    expect((await game("ub1")).badges.sort()).toEqual(
      ["first_lesson", "level_5", "streak_7"].sort()
    );
    const pub = (await db.doc("publicProfiles/ub1").get()).data() as { badges: string[] };
    expect(pub.badges.sort()).toEqual(["first_lesson", "level_5", "streak_7"].sort());

    // running again adds nothing (the trigger re-fires on its own write)
    expect(await syncBadges("ub1")).toEqual([]);
  });

  test("a user with no game state, or nothing earned, gets nothing", async () => {
    await db.doc("users/ub2").set({ displayName: "NoGame" });
    expect(await syncBadges("ub2")).toEqual([]);

    await seedUser("ub3");
    expect(await syncBadges("ub3")).toEqual([]);
    expect((await game("ub3")).badges).toEqual([]);
  });

  test("finishing a unit through completeLesson makes the unit badge available", async () => {
    await seedUser("ub4");
    for (const [i, lessonId] of ["emergency_fund", "needs_wants", "track_spending"].entries()) {
      await call(completeLesson, "ub4", {
        lessonId,
        score: 100,
        durationSeconds: 30,
        attemptId: `b${i}`,
      });
    }
    // the trigger is not running in this suite: evaluate as it would
    expect(await syncBadges("ub4")).toEqual(["first_lesson", "unit_1"]);
  });
});

describe("buyShopItem", () => {
  type Reason = { details?: { reason?: string } };
  async function refusal(uid: string, itemId: string): Promise<string | undefined> {
    try {
      await call(buyShopItem, uid, { itemId });
    } catch (err) {
      return (err as Reason).details?.reason ?? (err as { code?: string }).code;
    }
    return undefined;
  }

  test("buying a cosmetic spends the seeds, grants it, and cannot be repeated", async () => {
    await seedUser("us1");
    await db.doc("users/us1/game/state").update({ gems: 200 });

    const bought = await call<{ gems: number }>(buyShopItem, "us1", { itemId: "sun_hat" });
    expect(bought.gems).toBe(80);
    const state = (await db.doc("users/us1/game/state").get()).data() as {
      gems: number;
      ownedItems: string[];
    };
    expect(state.gems).toBe(80);
    expect(state.ownedItems).toEqual(["sun_hat"]);

    expect(await refusal("us1", "sun_hat")).toBe("already-owned");
    expect((await game("us1")).xp).toBe(0);
  });

  test("not enough seeds is refused and nothing changes", async () => {
    await seedUser("us2");
    await db.doc("users/us2/game/state").update({ gems: 50 });
    expect(await refusal("us2", "scarf_green")).toBe("insufficient-seeds");
    const state = (await db.doc("users/us2/game/state").get()).data() as { gems: number };
    expect(state.gems).toBe(50);
  });

  test("freezes go up to the stock cap, then the purchase is refused", async () => {
    await seedUser("us3"); // starts with 2 freezes = already at the cap
    await db.doc("users/us3/game/state").update({ gems: 500 });
    expect(await refusal("us3", "streak_freeze")).toBe("max-stock");

    await db.doc("users/us3/game/state").update({ "streak.freezes": 1 });
    const bought = await call<{ freezes: number; gems: number }>(buyShopItem, "us3", {
      itemId: "streak_freeze",
    });
    expect(bought.freezes).toBe(2);
    expect(bought.gems).toBe(440);
    expect((await game("us3")).streak.freezes).toBe(2);
    expect(await refusal("us3", "streak_freeze")).toBe("max-stock");
  });

  test("an unknown item is rejected as an invalid argument", async () => {
    await seedUser("us4");
    expect(await callError(buyShopItem, "us4", { itemId: "free_money" })).toBe("invalid-argument");
  });
});

describe("markFixedPaid", () => {
  async function seedBill(uid: string, id: string, extra: Record<string, unknown> = {}): Promise<void> {
    await db.doc(`users/${uid}/fixedExpenses/${id}`).set({
      name: id,
      category: "rent",
      amountCents: 1000,
      dueDay: 1,
      payMode: "manual",
      type: "bill",
      active: true,
      ...extra,
    });
  }

  test("invented months are refused", async () => {
    await seedUser("u5");
    await seedBill("u5", "rent");
    const thisMonth = localMonthKey(new Date(), toronto);
    const past = shiftDateKey(`${thisMonth}-01`, -40).slice(0, 7);
    const future = shiftDateKey(`${thisMonth}-01`, 40).slice(0, 7);

    expect(await callError(markFixedPaid, "u5", { fixedId: "rent", monthKey: past })).toBe(
      "failed-precondition"
    );
    expect(await callError(markFixedPaid, "u5", { fixedId: "rent", monthKey: future })).toBe(
      "failed-precondition"
    );
    expect(await callError(markFixedPaid, "u5", { fixedId: "rent", monthKey: "2000-01" })).toBe(
      "failed-precondition"
    );
    expect((await game("u5")).xp).toBe(0);
  });

  test("current month: paid once, month doc uses a real nested map", async () => {
    await seedUser("u6");
    await seedBill("u6", "rent");
    const monthKey = localMonthKey(new Date(), toronto);

    const first = await call<{ xpGained: number; alreadyPaid: boolean }>(markFixedPaid, "u6", {
      fixedId: "rent",
      monthKey,
    });
    expect(first).toMatchObject({ xpGained: 5, alreadyPaid: false });
    const again = await call<{ xpGained: number; alreadyPaid: boolean }>(markFixedPaid, "u6", {
      fixedId: "rent",
      monthKey,
    });
    expect(again).toMatchObject({ xpGained: 0, alreadyPaid: true });

    const month = (await db.doc(`users/u6/months/${monthKey}`).get()).data() as {
      fixedPaid: Record<string, { paid: boolean }>;
    };
    expect(month.fixedPaid.rent.paid).toBe(true);
    expect(Object.keys(month).some((k) => k.includes("."))).toBe(false);
    expect((await game("u6")).xp).toBe(5);
  });

  test("envelopes and inactive bills cannot be paid", async () => {
    await seedUser("u7");
    await seedBill("u7", "food", { type: "envelope" });
    await seedBill("u7", "old", { active: false });
    const monthKey = localMonthKey(new Date(), toronto);
    expect(await callError(markFixedPaid, "u7", { fixedId: "food", monthKey })).toBe(
      "failed-precondition"
    );
    expect(await callError(markFixedPaid, "u7", { fixedId: "old", monthKey })).toBe(
      "failed-precondition"
    );
  });

  test("XP per day is capped even with many (re-created) bills", async () => {
    await seedUser("u8");
    const monthKey = localMonthKey(new Date(), toronto);
    for (let i = 0; i < 6; i++) {
      await seedBill("u8", `bill${i}`);
      await call(markFixedPaid, "u8", { fixedId: `bill${i}`, monthKey });
    }
    expect((await game("u8")).xp).toBe(15);
  });
});

describe("referralRedeem", () => {
  test("clearing the profile field does not allow a second redemption", async () => {
    await seedUser("invitee");
    await seedUser("owner1");
    await seedUser("owner2");
    await db.doc("referrals/CODEONE").set({ ownerUid: "owner1", uses: [], maxUses: 50 });
    await db.doc("referrals/CODETWO").set({ ownerUid: "owner2", uses: [], maxUses: 50 });

    await call(referralRedeem, "invitee", { referralCode: "CODEONE" });
    expect((await game("invitee")).xp).toBe(25);

    // Simulate the old exploit: the field is wiped.
    await db.doc("users/invitee").update({ redeemedReferralCode: admin.firestore.FieldValue.delete() });

    expect(await callError(referralRedeem, "invitee", { referralCode: "CODETWO" })).toBe(
      "already-exists"
    );
    expect((await game("invitee")).xp).toBe(25);
  });

  test("redeeming a code makes inviter and invitee friends", async () => {
    await seedUser("inv2");
    await seedUser("own3");
    await db.doc("referrals/CODEFRND").set({ ownerUid: "own3", uses: [], maxUses: 50 });

    await call(referralRedeem, "inv2", { referralCode: "CODEFRND" });

    const pair = (await db.doc(`friendships/${friendPairId("inv2", "own3")}`).get()).data();
    expect(pair?.status).toBe("accepted");
    expect([...(pair?.users as string[])].sort()).toEqual(["inv2", "own3"]);
  });
});

describe("friends and invitations", () => {
  async function friendship(a: string, b: string): Promise<Record<string, unknown> | undefined> {
    return (await db.doc(`friendships/${friendPairId(a, b)}`).get()).data();
  }

  test("every user gets a stable invite code whose referral document is usable", async () => {
    await seedUser("f1");
    const first = await call<{ code: string }>(getInviteCode, "f1", {});
    const second = await call<{ code: string }>(getInviteCode, "f1", {});
    expect(first.code).toBe(second.code);
    expect(first.code).toBe(inviteCodeFor("f1"));

    const referral = (await db.doc(`referrals/${first.code}`).get()).data();
    expect(referral).toMatchObject({ ownerUid: "f1", maxUses: 50 });

    // The code the app hands out is the one referralRedeem accepts.
    await seedUser("f1-invitee");
    await call(referralRedeem, "f1-invitee", { referralCode: first.code });
    expect((await friendship("f1", "f1-invitee"))?.status).toBe("accepted");
  });

  test("a friend request is pending until the recipient accepts", async () => {
    await seedUser("a1");
    await seedUser("b1");
    const { code } = await call<{ code: string }>(getInviteCode, "b1", {});

    const sent = await call<{ status: string; pairId: string }>(sendFriendRequest, "a1", {
      referralCode: code,
    });
    expect(sent.status).toBe("pending");
    expect((await friendship("a1", "b1"))?.requesterUid).toBe("a1");

    // The requester cannot accept their own request; a duplicate is refused.
    expect(await callError(respondFriendRequest, "a1", { pairId: sent.pairId, accept: true })).toBe(
      "failed-precondition"
    );
    expect(await callError(sendFriendRequest, "a1", { referralCode: code })).toBe("already-exists");

    await call(respondFriendRequest, "b1", { pairId: sent.pairId, accept: true });
    expect((await friendship("a1", "b1"))?.status).toBe("accepted");
    expect(await callError(sendFriendRequest, "a1", { referralCode: code })).toBe("already-exists");
  });

  test("two requests crossing each other make them friends", async () => {
    await seedUser("a2");
    await seedUser("b2");
    const codeA = (await call<{ code: string }>(getInviteCode, "a2", {})).code;
    const codeB = (await call<{ code: string }>(getInviteCode, "b2", {})).code;

    await call(sendFriendRequest, "a2", { referralCode: codeB });
    const crossed = await call<{ status: string }>(sendFriendRequest, "b2", { referralCode: codeA });
    expect(crossed.status).toBe("accepted");
    expect((await friendship("a2", "b2"))?.status).toBe("accepted");
  });

  test("declining deletes the request, and it can be sent again", async () => {
    await seedUser("a3");
    await seedUser("b3");
    const code = (await call<{ code: string }>(getInviteCode, "b3", {})).code;
    const { pairId } = await call<{ pairId: string }>(sendFriendRequest, "a3", { referralCode: code });

    await call(respondFriendRequest, "b3", { pairId, accept: false });
    expect(await friendship("a3", "b3")).toBeUndefined();
    expect((await call<{ status: string }>(sendFriendRequest, "a3", { referralCode: code })).status).toBe(
      "pending"
    );
  });

  test("you cannot add yourself or use an unknown code", async () => {
    await seedUser("a4");
    const own = (await call<{ code: string }>(getInviteCode, "a4", {})).code;
    expect(await callError(sendFriendRequest, "a4", { referralCode: own })).toBe("invalid-argument");
    expect(await callError(sendFriendRequest, "a4", { referralCode: "ZZZZZZZZ" })).toBe("not-found");
  });

  test("a stranger cannot answer or remove somebody else's friendship", async () => {
    await seedUser("a5");
    await seedUser("b5");
    await seedUser("m5");
    const code = (await call<{ code: string }>(getInviteCode, "b5", {})).code;
    const { pairId } = await call<{ pairId: string }>(sendFriendRequest, "a5", { referralCode: code });

    expect(await callError(respondFriendRequest, "m5", { pairId, accept: true })).toBe(
      "failed-precondition"
    );
    expect(await callError(removeFriend, "m5", { pairId })).toBe("not-found");
    expect((await friendship("a5", "b5"))?.status).toBe("pending");
  });

  test("either friend can remove the friendship", async () => {
    await seedUser("a6");
    await seedUser("b6");
    const code = (await call<{ code: string }>(getInviteCode, "b6", {})).code;
    const { pairId } = await call<{ pairId: string }>(sendFriendRequest, "a6", { referralCode: code });
    await call(respondFriendRequest, "b6", { pairId, accept: true });

    await call(removeFriend, "a6", { pairId });
    expect(await friendship("a6", "b6")).toBeUndefined();
  });
});

describe("daily rollover", () => {
  const userData = { locale: "fr", timezone: TORONTO, utcOffsetMinutes: -300 };

  test("creates today's quest, expires yesterday's, and is idempotent", async () => {
    await seedUser("r1", userData);
    const day1 = new Date("2026-11-10T15:00:00Z");
    const day2 = new Date("2026-11-11T15:00:00Z");

    await ensureDailyQuests(db, "r1", toronto, "fr", day1);
    await db.doc("users/r1/quests/daily_log_expenses_2026-11-10").update({ progress: 1 });

    await processUserRollover("r1", userData, day2);
    await processUserRollover("r1", userData, day2); // replay: must change nothing

    const quests = await db.collection("users/r1/quests").get();
    const byId = Object.fromEntries(quests.docs.map((d) => [d.id, d.data() as QuestDoc]));
    expect(byId["daily_log_expenses_2026-11-10"].status).toBe("expired");
    const today = byId[dailyQuestId("log_expenses", "2026-11-11")];
    expect(today.status).toBe("active");
    expect(today.progress).toBe(0);
    // Expires at the user's next LOCAL midnight (Toronto, EST): 2026-11-12T05:00Z.
    expect(today.expiresAt.toDate().toISOString()).toBe("2026-11-12T05:00:00.000Z");
    // Yesterday's quests (expired, kept for a while) + today's: one doc per template and day.
    expect(quests.size).toBe(2 * DAILY_QUEST_TEMPLATES.length);
    for (const tpl of DAILY_QUEST_TEMPLATES) {
      expect(byId[dailyQuestId(tpl.templateId, "2026-11-10")].status).toBe("expired");
      expect(byId[dailyQuestId(tpl.templateId, "2026-11-11")].status).toBe("active");
    }
  });

  test("the legacy never-expiring quest is retired", async () => {
    await seedUser("r2", userData);
    await db.doc("users/r2/quests/daily_expenses").set({
      type: "ADD_TRANSACTION",
      status: "active",
      progress: 0,
      target: 3,
      expiresAt: null,
    });
    await processUserRollover("r2", userData, new Date("2026-11-11T15:00:00Z"));
    expect((await db.doc("users/r2/quests/daily_expenses").get()).data()?.status).toBe("expired");
  });

  test("old expired quests are purged, recent ones are kept", async () => {
    await seedUser("r5", userData);
    const expired = (days: number): Record<string, unknown> => ({
      type: "ADD_TRANSACTION",
      status: "expired",
      progress: 0,
      target: 3,
      expiresAt: Timestamp.fromMillis(Date.parse("2026-11-11T15:00:00Z") - days * 86_400_000),
    });
    await db.doc("users/r5/quests/old").set(expired(20));
    await db.doc("users/r5/quests/recent").set(expired(3));
    await processUserRollover("r5", userData, new Date("2026-11-11T15:00:00Z"));
    expect((await db.doc("users/r5/quests/old").get()).exists).toBe(false);
    expect((await db.doc("users/r5/quests/recent").get()).exists).toBe(true);
  });

  test("a missed day consumes exactly one freeze (even if the job runs twice), then breaks", async () => {
    await seedUser("r3", userData);
    await db.doc("users/r3/game/state").update({
      streak: { current: 5, best: 5, lastActiveDay: "2026-11-09", freezes: 1 },
    });

    const now = new Date("2026-11-11T15:00:00Z"); // yesterday = 2026-11-10, user was last active 11-09
    await processUserRollover("r3", userData, now);
    await processUserRollover("r3", userData, now);
    let state = await game("r3");
    expect(state.streak.freezes).toBe(0);
    expect(state.streak.current).toBe(5);
    expect(state.streak.lastActiveDay).toBe("2026-11-10");

    await processUserRollover("r3", userData, new Date("2026-11-12T15:00:00Z"));
    state = await game("r3");
    expect(state.streak.current).toBe(0);
    expect(state.lastRolloverDay).toBe("2026-11-12");
  });

  test("an active user keeps their streak", async () => {
    await seedUser("r4", userData);
    await db.doc("users/r4/game/state").update({
      streak: { current: 3, best: 3, lastActiveDay: "2026-11-10", freezes: 2 },
    });
    await processUserRollover("r4", userData, new Date("2026-11-11T15:00:00Z"));
    const state = await game("r4");
    expect(state.streak).toMatchObject({ current: 3, freezes: 2 });
  });
});

describe("journée sous budget", () => {
  // November has 30 days: (3000.00 - 600.00 fixed) / 30 = 80.00 per day.
  const userData = {
    locale: "fr",
    timezone: TORONTO,
    utcOffsetMinutes: -300,
    monthlyIncomeCents: 300_000,
  };
  const DAY = "2026-11-10";
  const ROLLOVER = new Date("2026-11-11T15:00:00Z"); // yesterday for the user = 2026-11-10

  async function seed(uid: string, extra: Record<string, unknown> = {}): Promise<void> {
    await seedUser(uid, { ...userData, ...extra });
    await db.doc(`users/${uid}/fixedExpenses/rent`).set({ active: true, amountCents: 60_000 });
    await db.doc(`users/${uid}/fixedExpenses/old`).set({ active: false, amountCents: 999_999 });
  }

  async function spend(uid: string, id: string, date: string, amountCents: number): Promise<void> {
    await db.doc(`users/${uid}/transactions/${id}`).set({ date, amountCents, category: "food" });
  }

  test("under budget with an expense logged earns 15 XP, exactly once", async () => {
    await seed("b1");
    await spend("b1", "t1", DAY, 3_000);
    await spend("b1", "t2", DAY, 2_000);

    await processUserRollover("b1", userData, ROLLOVER);
    await processUserRollover("b1", userData, ROLLOVER); // replay: must change nothing
    expect((await game("b1")).xp).toBe(15);
    expect((await game("b1")).weeklyXp).toBe(15);
    expect((await db.doc(`users/b1/dailyXp/${DAY}`).get()).data()?.fromBudgetDay).toBe(15);

    // Even a direct second evaluation of the same day is a no-op.
    expect(await awardBudgetDayIfEarned("b1", userData, DAY)).toBe("already-awarded");
    expect((await game("b1")).xp).toBe(15);
  });

  test("over budget earns nothing", async () => {
    await seed("b2");
    await spend("b2", "t1", DAY, 9_000);
    await processUserRollover("b2", userData, ROLLOVER);
    expect((await game("b2")).xp).toBe(0);
  });

  test("logging nothing earns nothing", async () => {
    await seed("b3");
    await processUserRollover("b3", userData, ROLLOVER);
    expect((await game("b3")).xp).toBe(0);
  });

  test("only that day's expenses are evaluated", async () => {
    await seed("b4");
    await spend("b4", "t1", "2026-11-09", 3_000); // another day: not counted
    await spend("b4", "t2", "2026-11-11", 3_000);
    await processUserRollover("b4", userData, ROLLOVER);
    expect((await game("b4")).xp).toBe(0);
  });

  test("without income the rule does not apply", async () => {
    await seed("b5", { monthlyIncomeCents: 0 });
    await spend("b5", "t1", DAY, 1_000);
    await processUserRollover("b5", { ...userData, monthlyIncomeCents: 0 }, ROLLOVER);
    expect((await game("b5")).xp).toBe(0);
  });

  test("a confirmed 'no spending' day earns the reward even with no expense", async () => {
    await seed("b6");
    await db.doc(`users/b6/dailyXp/${DAY}`).set({ noSpend: true });
    await processUserRollover("b6", userData, ROLLOVER);
    expect((await game("b6")).xp).toBe(15);
  });

  test("the game state records the reward so the client can show it", async () => {
    await seed("b7");
    await spend("b7", "t1", DAY, 1_000);
    await processUserRollover("b7", userData, ROLLOVER);
    const state = (await db.doc("users/b7/game/state").get()).data();
    expect(state?.lastBudgetDay).toEqual({ dayKey: DAY, xp: 15 });
  });
});

describe("confirmNoSpend", () => {
  const todayKey = (): string => localDateKey(new Date(), toronto);

  test("prolongs the streak, gives no XP by itself, and is idempotent", async () => {
    await seedUser("n1");
    const first = await call<{ alreadyConfirmed: boolean; streak: number }>(confirmNoSpend, "n1", {});
    expect(first).toMatchObject({ alreadyConfirmed: false, streak: 1 });

    const second = await call<{ alreadyConfirmed: boolean }>(confirmNoSpend, "n1", {});
    expect(second.alreadyConfirmed).toBe(true);

    const state = await game("n1");
    expect(state.streak.current).toBe(1);
    expect(state.xp).toBe(0);
    expect((await db.doc("users/n1/game/state").get()).data()?.noSpendDay).toBe(todayKey());
    expect((await db.doc(`users/n1/dailyXp/${todayKey()}`).get()).data()?.noSpend).toBe(true);
  });

  test("is refused when an expense is already logged today", async () => {
    await seedUser("n2");
    await db.doc("users/n2/transactions/t1").set({ date: todayKey(), amountCents: 500 });
    expect(await callError(confirmNoSpend, "n2", {})).toBe("failed-precondition");
    expect((await game("n2")).streak.current).toBe(0);
  });
});

describe("pagination on a real Firestore query", () => {
  test("visits all users beyond one page", async () => {
    const writer = db.batch();
    for (let i = 0; i < 25; i++) {
      writer.set(db.doc(`users/p${String(i).padStart(2, "0")}`), { utcOffsetMinutes: 330 });
    }
    await writer.commit();

    const seen: string[] = [];
    const result = await forEachDocument(
      db.collection("users").where("utcOffsetMinutes", ">=", 300).where("utcOffsetMinutes", "<=", 360),
      (doc) => {
        seen.push(doc.id);
        return Promise.resolve();
      },
      { pageSize: 7, concurrency: 3 }
    );
    expect(result.processed).toBe(25);
    expect(new Set(seen).size).toBe(25);
  });
});

describe("leagues", () => {
  const NOW = new Date("2026-11-11T12:00:00Z"); // week 2026-11-08
  const NEXT_WEEK = new Date("2026-11-16T12:00:00Z"); // week 2026-11-15

  async function members(key: string): Promise<Record<string, { weeklyXp: number; result?: string; rank?: number }>> {
    const snap = await db.collection(`leagues/${key}/members`).get();
    return Object.fromEntries(
      snap.docs.map((d) => [d.id, d.data() as { weeklyXp: number; result?: string; rank?: number }])
    );
  }

  test("joining is idempotent and fills a group of 30 before opening another", async () => {
    const keys = new Set<string>();
    for (let i = 0; i < 31; i++) {
      await seedUser(`l${i}`);
      const first = await ensureLeagueMembership(db, `l${i}`, NOW);
      const again = await ensureLeagueMembership(db, `l${i}`, NOW);
      expect(again.leagueKey).toBe(first.leagueKey);
      keys.add(first.leagueKey);
    }
    expect(keys.size).toBe(2);
    const groups = await db.collection("leagues").get();
    const counts = groups.docs.map((d) => d.data().memberCount as number).sort((a, b) => a - b);
    expect(counts).toEqual([1, 30]);
    const full = groups.docs.find((d) => d.data().memberCount === 30);
    expect(full?.data().open).toBe(false);
  });

  test("concurrent joins never overfill a group", async () => {
    // A burst of simultaneous joins (retried on lock contention) must never overfill a group.
    const burst = 12;
    for (let i = 0; i < burst; i++) await seedUser(`c${i}`);
    await Promise.all(
      Array.from({ length: burst }, (_, i) => ensureLeagueMembership(db, `c${i}`, NOW))
    );
    const groups = await db.collection("leagues").get();
    const total = groups.docs.reduce((sum, d) => sum + (d.data().memberCount as number), 0);
    expect(total).toBe(burst);
    for (const g of groups.docs) {
      expect(g.data().memberCount).toBeLessThanOrEqual(30);
      expect((await db.collection(`leagues/${g.id}/members`).get()).size).toBe(g.data().memberCount);
    }
  }, 60_000);

  test("players only share a group with their own tier", async () => {
    await seedUser("t1");
    await seedUser("t2");
    await db.doc("users/t2/game/state").update({ leagueId: "silver" });
    const a = await ensureLeagueMembership(db, "t1", NOW);
    const b = await ensureLeagueMembership(db, "t2", NOW);
    expect(a.leagueKey).not.toBe(b.leagueKey);
    expect(b.tier).toBe("silver");
  });

  test("XP is added to the group once per event, and never for zero/negative deltas", async () => {
    await seedUser("x1");
    await addLeagueXp(db, "x1", 20, 2, "evt-1", NOW);
    await addLeagueXp(db, "x1", 20, 2, "evt-1", NOW); // redelivered event
    await addLeagueXp(db, "x1", 5, 2, "evt-2", NOW);
    await addLeagueXp(db, "x1", 0, 2, "evt-3", NOW);
    await addLeagueXp(db, "x1", -4, 2, "evt-4", NOW);
    const { leagueKey } = await ensureLeagueMembership(db, "x1", NOW);
    expect((await members(leagueKey)).x1.weeklyXp).toBe(25);
  });

  test("closing a group promotes/relegates, resets weekly XP and records the result", async () => {
    const uids: string[] = [];
    for (let i = 0; i < 20; i++) {
      const uid = `w${String(i).padStart(2, "0")}`;
      uids.push(uid);
      await seedUser(uid, {});
      await db.doc(`users/${uid}/game/state`).update({ leagueId: "gold", weeklyXp: 999 });
      await addLeagueXp(db, uid, 200 - i * 10, 3, `e-${uid}`, NOW);
    }
    const { leagueKey } = await ensureLeagueMembership(db, "w00", NOW);
    const groupRef = db.doc(`leagues/${leagueKey}`);
    const outcomes = await closeLeagueGroup(db, await groupRef.get() as never, new Date("2026-11-15T21:00:00Z"));
    expect(outcomes).toHaveLength(20);

    const winner = await game("w00");
    expect((winner as unknown as { leagueId: string }).leagueId).toBe("sapphire");
    expect(winner.weeklyXp).toBe(0);
    const last = await game("w19");
    expect((last as unknown as { leagueId: string }).leagueId).toBe("silver");
    const middle = await game("w10");
    expect((middle as unknown as { leagueId: string }).leagueId).toBe("gold");

    const lastResult = (await db.doc("users/w00/league/lastResult").get()).data();
    expect(lastResult).toMatchObject({ rank: 1, result: "promoted", fromTier: "gold", toTier: "sapphire", groupSize: 20 });
    expect((await db.doc("publicProfiles/w00").get()).exists).toBe(true);
    expect((await groupRef.get()).data()).toMatchObject({ processed: true, open: false });

    // Closing twice does nothing.
    expect(await closeLeagueGroup(db, await groupRef.get() as never)).toEqual([]);
  });

  test("a new week puts the player in a group of their NEW tier, and deleted accounts are skipped", async () => {
    for (const uid of ["n1", "n2", "n3"]) await seedUser(uid);
    await ensureLeagueMembership(db, "n1", NOW);
    const { leagueKey } = await ensureLeagueMembership(db, "n2", NOW);
    await ensureLeagueMembership(db, "n3", NOW);
    await addLeagueXp(db, "n1", 50, 1, "a", NOW);
    await db.recursiveDelete(db.doc("users/n3")); // account deleted mid-week
    await closeLeagueGroup(db, await db.doc(`leagues/${leagueKey}`).get() as never);

    expect((await db.doc("users/n3/game/state").get()).exists).toBe(false);
    expect((await db.doc("users/n3/league/lastResult").get()).exists).toBe(false);

    const next = await ensureLeagueMembership(db, "n1", NEXT_WEEK);
    expect(next.week).toBe("2026-11-15");
    expect(next.leagueKey).not.toBe(leagueKey);
    expect(next.tier).toBe("silver"); // promoted: only 3 players, so top ranks with XP > 0 move up
  });
});
