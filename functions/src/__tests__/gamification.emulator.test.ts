/**
 * Integration tests for the XP / streak / quest logic, run against the Firestore emulator:
 *   npm run test:emulator
 */
import * as admin from "firebase-admin";
import { getFirestore, Firestore, Timestamp } from "firebase-admin/firestore";
import { completeLesson } from "../gamification/completeLesson";
import { markFixedPaid } from "../gamification/markFixedPaid";
import { recordTransactionActivity } from "../gamification/onTransactionWrite";
import { processUserRollover } from "../gamification/dailyRollover";
import { referralRedeem } from "../referrals/referralRedeem";
import { dailyQuestId, ensureDailyQuests } from "../shared/dailyQuests";
import { forEachDocument } from "../shared/pagination";
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
    expect(quests.size).toBe(2);
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
