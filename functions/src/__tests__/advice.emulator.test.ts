/**
 * Personalised advice notifications against the Firestore emulator (FCM is faked):
 *   npm run test:emulator
 */
import * as admin from "firebase-admin";
import { getFirestore, Firestore } from "firebase-admin/firestore";
import { completeLesson } from "../gamification/completeLesson";
import { maybeSendAdvice } from "../notifications/adviceNotifier";
import type { UserProfile } from "../notifications/delivery";

const mockSent: Array<{ uid: string; title: string; body: string; data: Record<string, string> }> = [];
let mockHasDevice = true;

jest.mock("../notifications/delivery", () => {
  const actual = jest.requireActual<typeof import("../notifications/delivery")>(
    "../notifications/delivery"
  );
  return {
    ...actual,
    hasActiveDevice: jest.fn(() => Promise.resolve(mockHasDevice)),
    sendToUser: jest.fn((uid: string, title: string, body: string, data: Record<string, string>) => {
      mockSent.push({ uid, title, body, data });
      return Promise.resolve();
    }),
  };
});

const PROJECT_ID = "sipho-test";
// 12:30 in Toronto (UTC-5 in November): inside the 12:00–13:59 advice window.
const LUNCH = new Date("2026-11-15T17:30:00Z");
const DAY = (n: number): Date => new Date(LUNCH.getTime() + n * 86_400_000);

let db: Firestore;

type CallableRun = { run: (req: never) => unknown };
async function call<T>(fn: unknown, uid: string, data: Record<string, unknown>): Promise<T> {
  const request = { data, auth: { uid, token: {} }, rawRequest: {}, acceptsStreaming: false };
  return (await (fn as CallableRun).run(request as never)) as T;
}

async function clearAll(): Promise<void> {
  const host = process.env.FIRESTORE_EMULATOR_HOST;
  await fetch(`http://${host}/emulator/v1/projects/${PROJECT_ID}/databases/(default)/documents`, {
    method: "DELETE",
  });
}

async function seedUser(uid: string, extra: Record<string, unknown> = {}): Promise<void> {
  await db.doc(`users/${uid}`).set({
    displayName: "Amina Dupont",
    locale: "fr",
    timezone: "America/Toronto",
    utcOffsetMinutes: -300,
    onboardingDone: true,
    currency: "CAD",
    goal: "save_for_project",
    monthlyIncomeCents: 400_000,
    completedLessonIds: [],
    notifPrefs: { tips: true },
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

async function send(uid: string, now: Date, ai: (p: string) => Promise<string | null>): Promise<void> {
  const profile = (await db.doc(`users/${uid}`).get()).data() as UserProfile;
  await maybeSendAdvice(uid, profile, now, ai);
}

const noAi = (): Promise<string | null> => Promise.resolve(null);

beforeAll(() => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) {
    throw new Error("Run with `npm run test:emulator` (needs FIRESTORE_EMULATOR_HOST).");
  }
  admin.initializeApp({ projectId: PROJECT_ID });
  db = getFirestore();
});

beforeEach(async () => {
  mockSent.length = 0;
  mockHasDevice = true;
  await clearAll();
});

describe("completeLesson keeps what the advice needs", () => {
  test("records the latest score next to the best one", async () => {
    await seedUser("a1");
    const base = { lessonId: "emergency_fund", durationSeconds: 30 };
    await call(completeLesson, "a1", { ...base, score: 50, attemptId: "x1" });
    let progress = (await db.doc("users/a1/lessonProgress/emergency_fund").get()).data();
    expect(progress?.lastScore).toBe(50);
    expect(progress?.bestScore).toBe(50);

    await call(completeLesson, "a1", { ...base, score: 100, attemptId: "x2" });
    await call(completeLesson, "a1", { ...base, score: 60, attemptId: "x3" });
    progress = (await db.doc("users/a1/lessonProgress/emergency_fund").get()).data();
    expect(progress?.lastScore).toBe(60);
    expect(progress?.bestScore).toBe(100);
  });
});

describe("maybeSendAdvice", () => {
  test("stays silent unless the learner turned tips on", async () => {
    await seedUser("b1", { notifPrefs: { tips: false } });
    await send("b1", LUNCH, noAi);
    await seedUser("b2", { notifPrefs: {} });
    await send("b2", LUNCH, noAi);
    expect(mockSent).toHaveLength(0);
  });

  test("stays silent outside the local lunch window and before onboarding is done", async () => {
    await seedUser("b3");
    await send("b3", new Date("2026-11-15T12:30:00Z"), noAi); // 07:30 in Toronto
    await seedUser("b4", { onboardingDone: false });
    await send("b4", LUNCH, noAi);
    expect(mockSent).toHaveLength(0);
  });

  test("does nothing for a learner without a device", async () => {
    await seedUser("b5");
    mockHasDevice = false;
    await send("b5", LUNCH, noAi);
    expect(mockSent).toHaveLength(0);
    expect((await db.collection("users/b5/adviceHistory").get()).empty).toBe(true);
  });

  test("adapts to the lessons the learner struggled with", async () => {
    await seedUser("c1", { completedLessonIds: ["emergency_fund"] });
    await call(completeLesson, "c1", {
      lessonId: "emergency_fund",
      score: 50,
      durationSeconds: 30,
    });

    let prompt = "";
    await send("c1", LUNCH, (p) => {
      prompt = p;
      return Promise.resolve(
        JSON.stringify({ title: "📚 On la refait ?", body: "Le fonds d'urgence t'a résisté. Rejoue la leçon, 3 minutes." })
      );
    });

    expect(prompt).toContain("emergency fund");
    expect(prompt).toContain("score 50");
    expect(mockSent).toHaveLength(1);
    expect(mockSent[0].data).toMatchObject({ type: "ADVICE", focus: "weak_lesson", route: "/learn" });
    expect(mockSent[0].title).toBe("📚 On la refait ?");

    const history = await db.collection("users/c1/adviceHistory").get();
    expect(history.docs[0].data()).toMatchObject({ focus: "weak_lesson", source: "ai", day: "2026-11-15" });

    // Same advice on the app's coach card, pointing at the lesson to replay.
    const insight = (await db.doc("users/c1/insights/advice_2026-11-15").get()).data();
    expect(insight).toMatchObject({
      content: "Le fonds d'urgence t'a résisté. Rejoue la leçon, 3 minutes.",
      recommendedLessonId: "emergency_fund",
      source: "push_advice",
      dismissed: false,
    });
  });

  test("a learner who aced the lesson is not told to replay it", async () => {
    await seedUser("c2", { completedLessonIds: ["emergency_fund"] });
    await call(completeLesson, "c2", { lessonId: "emergency_fund", score: 100, durationSeconds: 30 });
    await send("c2", LUNCH, noAi);
    expect(mockSent).toHaveLength(1);
    expect(mockSent[0].data.focus).not.toBe("weak_lesson");
  });

  test("adapts to the financial profile: an overspent month is about the budget", async () => {
    await seedUser("d1", { monthlyIncomeCents: 100_000 });
    await db.doc("users/d1/fixedExpenses/rent").set({ active: true, amountCents: 80_000, type: "bill" });
    for (let i = 0; i < 4; i++) {
      await db.doc(`users/d1/transactions/t${i}`).set({
        date: "2026-11-10",
        amountCents: 15_000,
        category: i % 2 === 0 ? "groceries" : "transport",
      });
    }
    let prompt = "";
    await send("d1", LUNCH, (p) => {
      prompt = p;
      return Promise.resolve(null);
    });
    expect(mockSent[0].data).toMatchObject({ focus: "budget_over", route: "/budget" });
    // 1000 − 800 − 600 = −400: the learner is 400 over.
    expect(prompt).toContain("400 CAD");
    expect(mockSent[0].body).toContain("400");
  });

  test("never sends identity or free text to the AI", async () => {
    await seedUser("e1", { goal: "Rembourser mon cousin Marc", completedLessonIds: [] });
    let prompt = "";
    await send("e1", LUNCH, (p) => {
      prompt = p;
      return Promise.resolve(null);
    });
    expect(prompt.length).toBeGreaterThan(0);
    expect(prompt).not.toContain("Amina");
    expect(prompt).not.toContain("Dupont");
    expect(prompt).not.toContain("Marc");
    expect(prompt).not.toContain("e1");
  });

  test("still sends the template when the AI is down or answers something unsafe", async () => {
    await seedUser("f1");
    await send("f1", LUNCH, () => Promise.reject(new Error("quota")));
    expect(mockSent).toHaveLength(1);
    expect(mockSent[0].title.length).toBeGreaterThan(0);
    expect(
      (await db.collection("users/f1/adviceHistory").get()).docs[0].data().source
    ).toBe("template");

    await seedUser("f2");
    await send("f2", LUNCH, () =>
      Promise.resolve(JSON.stringify({ title: "Astuce", body: "Investis 500 $ dans des actions." }))
    );
    expect(mockSent).toHaveLength(2);
    expect(mockSent[1].body).not.toContain("Investis");
  });

  test("waits between two advice pushes and then changes the subject", async () => {
    await seedUser("g1", { completedLessonIds: ["emergency_fund"] });
    await call(completeLesson, "g1", { lessonId: "emergency_fund", score: 50, durationSeconds: 30 });

    await send("g1", LUNCH, noAi);
    expect(mockSent).toHaveLength(1);
    expect(mockSent[0].data.focus).toBe("weak_lesson");

    // Next day and the day after: too soon.
    await send("g1", DAY(1), noAi);
    await send("g1", DAY(2), noAi);
    expect(mockSent).toHaveLength(1);

    // Three days later: allowed again, but the weak-lesson advice is on cooldown for a week.
    await send("g1", DAY(3), noAi);
    expect(mockSent).toHaveLength(2);
    expect(mockSent[1].data.focus).not.toBe("weak_lesson");
    expect(mockSent[1].title).not.toBe(mockSent[0].title);

    // Still within the gap after the second push, then another subject (the third).
    await send("g1", DAY(4), noAi);
    await send("g1", DAY(5), noAi);
    expect(mockSent).toHaveLength(2);
    await send("g1", DAY(6), noAi);
    expect(mockSent).toHaveLength(3);
    expect(new Set(mockSent.slice(0, 3).map((m) => m.data.focus)).size).toBe(3);

    // A week after the first push the lesson may come back, as it is still not mastered.
    await send("g1", DAY(9), noAi);
    expect(mockSent).toHaveLength(4);
    expect(mockSent[3].data.focus).toBe("weak_lesson");
  });

  test("respects the daily cap of engagement pushes", async () => {
    await seedUser("h1");
    await db.doc("users/h1/notifState/quota").set({ date: "2026-11-15", count: 2 });
    await send("h1", LUNCH, noAi);
    expect(mockSent).toHaveLength(0);
    expect((await db.collection("users/h1/adviceHistory").get()).empty).toBe(true);
  });
});
