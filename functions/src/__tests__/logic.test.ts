import { xpToLevel, xpToNextLevel } from "../shared/xpConfig";
import { computeNextStreak, normalizeGameState } from "../shared/gameState";
import {
  ALLOWED_LESSON_IDS,
  CompleteLessonInputSchema,
  ParseReceiptInputSchema,
  TransactionInputSchema,
} from "../shared/validators";
import { callGeminiJson, DEFAULT_GEMINI_MODEL } from "../ai/geminiClient";

describe("Server security & gamification logic", () => {
  test("xpToLevel is 1-based and monotonic", () => {
    expect(xpToLevel(0)).toBe(1);
    expect(xpToLevel(99)).toBe(1);
    expect(xpToLevel(100)).toBe(2);
    expect(xpToLevel(250)).toBe(3);
    expect(xpToNextLevel(0)).toBe(100);
    expect(xpToNextLevel(9_999)).toBe(0);
  });

  test("computeNextStreak increments consecutive days and caps same-day replays", () => {
    const day1 = computeNextStreak(
      { current: 0, best: 0, lastActiveDay: null, freezes: 2 },
      "2026-11-10"
    );
    expect(day1.nextStreak.current).toBe(1);
    expect(day1.streakBonus).toBe(false);

    const sameDay = computeNextStreak(day1.nextStreak, "2026-11-10");
    expect(sameDay.nextStreak.current).toBe(1);

    const day2 = computeNextStreak(day1.nextStreak, "2026-11-11");
    expect(day2.nextStreak.current).toBe(2);
    expect(day2.nextStreak.best).toBe(2);

    const broken = computeNextStreak(
      { current: 8, best: 8, lastActiveDay: "2026-11-01", freezes: 0 },
      "2026-11-10"
    );
    expect(broken.nextStreak.current).toBe(1);
    expect(broken.nextStreak.best).toBe(8);
  });

  test("normalizeGameState handles legacy number streaks safely", () => {
    const normalized = normalizeGameState({
      xp: 120,
      seeds: 9,
      streak: 4,
      lastLessonDate: "2026-11-12",
      freezesAvailable: 1,
    });
    expect(normalized.gems).toBe(9);
    expect(normalized.streak.current).toBe(4);
    expect(normalized.streak.lastActiveDay).toBe("2026-11-12");
    expect(normalized.streak.freezes).toBe(1);
  });

  test("validators reject path traversal, unrealistic durations, and non-integer cents", () => {
    expect(
      ParseReceiptInputSchema.safeParse({
        storagePath: "receipts/uid123/../other/img.jpg",
      }).success
    ).toBe(false);

    expect(
      ParseReceiptInputSchema.safeParse({
        storagePath: "receipts/uid_123/rec_1.jpg",
      }).success
    ).toBe(true);

    expect(
      CompleteLessonInputSchema.safeParse({
        lessonId: "emergency_fund",
        score: 100,
        durationSeconds: 0,
      }).success
    ).toBe(false);

    expect(
      TransactionInputSchema.safeParse({
        amountCents: 12.5,
        currency: "CAD",
        category: "groceries",
        source: "manual",
        date: "2026-11-13",
      }).success
    ).toBe(false);
  });

  test("completeLesson only accepts catalog lesson ids (fake ids earn nothing)", () => {
    const base = { score: 100, durationSeconds: 30 };
    expect(CompleteLessonInputSchema.safeParse({ ...base, lessonId: "fake_lesson_1" }).success).toBe(
      false
    );
    expect(CompleteLessonInputSchema.safeParse({ ...base, lessonId: "track_spending" }).success).toBe(
      true
    );
    expect(CompleteLessonInputSchema.safeParse({ ...base, lessonId: "small_amounts" }).success).toBe(
      true
    );
    expect(ALLOWED_LESSON_IDS).toEqual([
      "emergency_fund",
      "needs_wants",
      "track_spending",
      "savings_goal",
      "pay_yourself_first",
      "small_amounts",
    ]);
  });

  test("callGeminiJson uses active Gemini 3.5+ models, omits temperature, and skips thought parts", async () => {
    const urls: string[] = [];
    const bodies: string[] = [];
    const originalFetch = global.fetch;

    global.fetch = jest.fn(
      (input: Parameters<typeof fetch>[0], init?: Parameters<typeof fetch>[1]) => {
        const url =
          typeof input === "string"
            ? input
            : input instanceof URL
              ? input.href
              : input.url;
        urls.push(url);
        bodies.push(typeof init?.body === "string" ? init.body : "");
        if (url.includes(DEFAULT_GEMINI_MODEL)) {
          return Promise.resolve({
            ok: false,
            status: 404,
            json: () => Promise.resolve({}),
          } as Response);
        }
        return Promise.resolve({
          ok: true,
          status: 200,
          json: () =>
            Promise.resolve({
              candidates: [
                {
                  content: {
                    parts: [
                      { thought: true, text: "thinking..." },
                      { text: '{"title":"OK"}' },
                    ],
                  },
                },
              ],
            }),
        } as Response);
      }
    );

    try {
      const text = await callGeminiJson({
        apiKey: "fake-key",
        parts: [{ text: "hello" }],
        contextLabel: "unit-test",
      });
      expect(text).toBe('{"title":"OK"}');
      expect(urls[0]).toContain("gemini-3.5-flash-lite");
      expect(urls[1]).toContain("gemini-3.8-flash");
      expect(bodies[0]).not.toContain("temperature");
    } finally {
      global.fetch = originalFetch;
    }
  });
});
