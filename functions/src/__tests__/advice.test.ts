import {
  ADVICE_COOLDOWN_DAYS,
  ADVICE_FOCUS_PRIORITY,
  ADVICE_BODY_MAX,
  ADVICE_ROUTES,
  ADVICE_TITLE_MAX,
  AdviceContext,
  AdviceFocus,
  AdviceInput,
  LESSON_TOPICS,
  adviceFacts,
  adviceViolations,
  allowedNumbers,
  buildAdviceContext,
  buildAdvicePrompt,
  adviceRoll,
  chooseAdviceFocus,
  dateKeyDiffDays,
  pickAdviceFocus,
  numberTokens,
  recommendedLessonFor,
  templateAdvice,
} from "../shared/advice";
import { ALL_LESSON_IDS } from "../shared/lessonPath";
import { composeAdvice } from "../notifications/adviceCompose";

function input(overrides: Partial<AdviceInput> = {}): AdviceInput {
  return {
    incomeCents: 400_000,
    fixedCents: 150_000,
    variableCents: 50_000,
    categoryCents: { groceries: 15_000, restaurants: 12_000, transport: 12_000, shopping: 11_000 },
    monthTransactionCount: 8,
    loggedLastWeek: true,
    currency: "CAD",
    goal: "save_for_project",
    completedLessonIds: [],
    lessons: [],
    streak: 0,
    ...overrides,
  };
}

const ctxOf = (overrides: Partial<AdviceInput> = {}): AdviceContext =>
  buildAdviceContext(input(overrides));

describe("buildAdviceContext", () => {
  test("remaining is income minus fixed minus variable, null without income", () => {
    expect(ctxOf().remainingCents).toBe(200_000);
    expect(ctxOf({ variableCents: 300_000 }).remainingCents).toBe(-50_000);
    expect(ctxOf({ incomeCents: 0 }).remainingCents).toBeNull();
  });

  test("finds the heaviest category and its share", () => {
    const ctx = ctxOf({ categoryCents: { groceries: 10_000, restaurants: 30_000 } });
    expect(ctx.topCategory).toEqual({ category: "restaurants", cents: 30_000, sharePct: 75 });
    expect(ctxOf({ categoryCents: {} }).topCategory).toBeNull();
  });

  test("the weak lesson is the lowest latest score under the threshold", () => {
    const ctx = ctxOf({
      lessons: [
        { lessonId: "emergency_fund", lastScore: 100, bestScore: 100, attempts: 1 },
        { lessonId: "needs_wants", lastScore: 60, bestScore: 60, attempts: 1 },
        { lessonId: "track_spending", lastScore: 50, bestScore: 75, attempts: 2 },
      ],
    });
    expect(ctx.weakLesson).toEqual({ lessonId: "track_spending", score: 50 });
  });

  test("a tie goes to the earliest lesson of the path", () => {
    const ctx = ctxOf({
      lessons: [
        { lessonId: "track_spending", lastScore: 50, bestScore: 50, attempts: 1 },
        { lessonId: "needs_wants", lastScore: 50, bestScore: 50, attempts: 1 },
      ],
    });
    expect(ctx.weakLesson?.lessonId).toBe("needs_wants");
  });

  test("a lesson replayed to a good score is no longer weak; unknown ids are ignored", () => {
    const ctx = ctxOf({
      lessons: [
        { lessonId: "needs_wants", lastScore: 90, bestScore: 90, attempts: 3 },
        { lessonId: "made_up", lastScore: 10, bestScore: 10, attempts: 1 },
      ],
    });
    expect(ctx.weakLesson).toBeNull();
  });

  test("the next lesson is the first one of the path not completed", () => {
    expect(ctxOf().nextLessonId).toBe("emergency_fund");
    expect(ctxOf({ completedLessonIds: ["emergency_fund", "needs_wants"] }).nextLessonId).toBe(
      "track_spending"
    );
    expect(ctxOf({ completedLessonIds: [...ALL_LESSON_IDS] }).nextLessonId).toBeNull();
  });

  test("only known goals are kept (free text never reaches the AI)", () => {
    expect(ctxOf({ goal: "save_for_project" }).goal).toBe("save_for_project");
    expect(ctxOf({ goal: "Pay off my cousin Marc" }).goal).toBeNull();
  });

  test("a malformed currency falls back to CAD", () => {
    expect(ctxOf({ currency: "dollars" }).currency).toBe("CAD");
    expect(ctxOf({ currency: "XOF" }).currency).toBe("XOF");
  });
});

describe("chooseAdviceFocus", () => {
  test("an overspent budget comes first", () => {
    const ctx = ctxOf({
      variableCents: 300_000,
      lessons: [{ lessonId: "needs_wants", lastScore: 40, bestScore: 40, attempts: 1 }],
    });
    expect(chooseAdviceFocus(ctx, [])).toBe("budget_over");
  });

  test("a weak lesson comes before spending habits", () => {
    const ctx = ctxOf({
      categoryCents: { restaurants: 40_000, groceries: 5_000 },
      lessons: [{ lessonId: "needs_wants", lastScore: 50, bestScore: 50, attempts: 1 }],
    });
    expect(chooseAdviceFocus(ctx, [])).toBe("weak_lesson");
  });

  test("the same learner gets different advice depending on past lesson answers", () => {
    const weak = ctxOf({
      completedLessonIds: ["emergency_fund"],
      lessons: [{ lessonId: "emergency_fund", lastScore: 50, bestScore: 50, attempts: 1 }],
    });
    const strong = ctxOf({
      completedLessonIds: ["emergency_fund"],
      lessons: [{ lessonId: "emergency_fund", lastScore: 100, bestScore: 100, attempts: 1 }],
    });
    expect(chooseAdviceFocus(weak, [])).toBe("weak_lesson");
    expect(chooseAdviceFocus(strong, [])).not.toBe("weak_lesson");
    expect(buildAdvicePrompt("weak_lesson", weak, "en", [])).toContain("emergency fund");
  });

  test("a dominant category is flagged only with enough data", () => {
    const heavy = { restaurants: 40_000, groceries: 5_000 };
    expect(chooseAdviceFocus(ctxOf({ categoryCents: heavy }), [])).toBe("top_category");
    expect(
      chooseAdviceFocus(ctxOf({ categoryCents: heavy, monthTransactionCount: 2 }), [])
    ).not.toBe("top_category");
    expect(
      chooseAdviceFocus(ctxOf({ categoryCents: { other: 50_000 } }), [])
    ).not.toBe("top_category");
    expect(
      chooseAdviceFocus(
        ctxOf({ categoryCents: { restaurants: 11_000, groceries: 10_000, transport: 9_000 } }),
        []
      )
    ).not.toBe("top_category");
  });

  test("logging nudge only for someone who set the app up", () => {
    expect(chooseAdviceFocus(ctxOf({ loggedLastWeek: false }), [])).toBe("no_tracking");
    expect(
      chooseAdviceFocus(
        ctxOf({ loggedLastWeek: false, incomeCents: 0, fixedCents: 0, variableCents: 0 }),
        []
      )
    ).not.toBe("no_tracking");
  });

  test("falls through to the next lesson, then the goal, then a general tip", () => {
    expect(chooseAdviceFocus(ctxOf(), [])).toBe("next_lesson");
    const done = { completedLessonIds: [...ALL_LESSON_IDS] };
    expect(chooseAdviceFocus(ctxOf(done), [])).toBe("goal");
    expect(chooseAdviceFocus(ctxOf({ ...done, goal: "" }), [])).toBe("general");
  });

  test("a focus used within its cooldown is skipped, the next one is used", () => {
    const ctx = ctxOf({ variableCents: 300_000 });
    expect(chooseAdviceFocus(ctx, [{ focus: "budget_over", daysAgo: 1 }])).toBe("next_lesson");
    expect(
      chooseAdviceFocus(ctx, [{ focus: "budget_over", daysAgo: ADVICE_COOLDOWN_DAYS.budget_over }])
    ).toBe("budget_over");
  });

  test("sends nothing rather than repeating when everything was said recently", () => {
    const ctx = ctxOf({ completedLessonIds: [...ALL_LESSON_IDS], goal: "" });
    expect(chooseAdviceFocus(ctx, [{ focus: "general", daysAgo: 2 }])).toBeNull();
    expect(pickAdviceFocus(ctx, [{ focus: "general", daysAgo: 2 }], 0.5)).toBeNull();
  });

  test("a roll of 0 is the most urgent topic; a roll near 1 reaches a lighter one", () => {
    const ctx = ctxOf({
      variableCents: 300_000,
      lessons: [{ lessonId: "needs_wants", lastScore: 40, bestScore: 40, attempts: 1 }],
      categoryCents: { restaurants: 40_000, groceries: 5_000 },
    });
    expect(pickAdviceFocus(ctx, [], 0)).toBe("budget_over");
    expect(pickAdviceFocus(ctx, [], 0.999)).not.toBe("budget_over");
    const seen = new Set<string>();
    for (let i = 0; i < 20; i++) seen.add(pickAdviceFocus(ctx, [], i / 20) ?? "");
    expect(seen.size).toBeGreaterThan(1);
  });

  test("the same learner and day always draw the same topic", () => {
    expect(adviceRoll("u1:2026-11-15")).toBe(adviceRoll("u1:2026-11-15"));
    expect(adviceRoll("u1:2026-11-15")).not.toBe(adviceRoll("u2:2026-11-15"));
    expect(adviceRoll("u1:2026-11-15")).toBeGreaterThanOrEqual(0);
    expect(adviceRoll("u1:2026-11-15")).toBeLessThan(1);
  });

  test("progress facts follow the learner and drop unknown life stages", () => {
    const ctx = ctxOf({
      lifeStage: "family",
      level: 4,
      streak: 6,
      completedLessonIds: ["emergency_fund"],
      lessons: [{ lessonId: "emergency_fund", lastScore: 90, bestScore: 90, attempts: 1 }],
    });
    expect(ctx.lifeStage).toBe("family");
    expect(ctx.level).toBe(4);
    expect(ctx.masteredCount).toBe(1);
    expect(ctxOf({ lifeStage: "cousin Marc" }).lifeStage).toBeNull();
    const facts = adviceFacts("general", ctx).join(" ");
    expect(facts).toContain("raising a family");
    expect(facts).toContain("level 4");
    expect(facts).toContain("6 days");
    expect(facts).not.toContain("Marc");
  });

  test("every focus has a cooldown and a route the app knows", () => {
    for (const focus of ADVICE_FOCUS_PRIORITY) {
      expect(ADVICE_COOLDOWN_DAYS[focus]).toBeGreaterThan(0);
      expect(["/home", "/learn", "/budget", "/economy"]).toContain(ADVICE_ROUTES[focus]);
    }
  });
});

describe("helpers", () => {
  test("dateKeyDiffDays crosses month and year boundaries", () => {
    expect(dateKeyDiffDays("2026-11-15", "2026-11-12")).toBe(3);
    expect(dateKeyDiffDays("2026-12-01", "2026-11-28")).toBe(3);
    expect(dateKeyDiffDays("2027-01-02", "2026-12-30")).toBe(3);
    expect(dateKeyDiffDays("2026-11-15", "2026-11-15")).toBe(0);
  });

  test("every lesson of the path has a topic", () => {
    for (const id of ALL_LESSON_IDS) {
      expect(LESSON_TOPICS[id].en.length).toBeGreaterThan(0);
      expect(LESSON_TOPICS[id].fr.length).toBeGreaterThan(0);
    }
  });

  test("the recommended lesson follows the focus", () => {
    const weak = ctxOf({
      lessons: [{ lessonId: "needs_wants", lastScore: 40, bestScore: 40, attempts: 1 }],
    });
    expect(recommendedLessonFor("weak_lesson", weak)).toBe("needs_wants");
    expect(recommendedLessonFor("goal", weak)).toBe("emergency_fund");
    expect(
      recommendedLessonFor("goal", ctxOf({ completedLessonIds: [...ALL_LESSON_IDS] }))
    ).toBe("track_spending");
  });

  test("numberTokens ignores thousands separators", () => {
    expect(numberTokens("1 200 $ et 35 %")).toEqual(["1200", "35"]);
    expect(numberTokens("1,200 CAD")).toEqual(["1200"]);
    expect(numberTokens("pas de chiffre")).toEqual([]);
  });
});

describe("facts and prompt", () => {
  test("facts carry the figures, in whole units", () => {
    const facts = adviceFacts("budget_over", ctxOf({ variableCents: 300_000 }));
    expect(facts.join(" ")).toContain("500 CAD");
  });

  test("the prompt has the facts and the safety rules, and no identity or free text", () => {
    const ctx = ctxOf({ goal: "My secret plan to buy a boat for Marc" });
    const prompt = buildAdvicePrompt("goal", ctx, "fr", ["Ancien titre"]);
    expect(prompt).toContain("French");
    expect(prompt).toContain("Never encourage spending");
    expect(prompt).toContain("No investment, credit, tax or legal advice");
    expect(prompt).toContain("Ancien titre");
    expect(prompt).not.toContain("boat");
    expect(prompt).not.toContain("Marc");
  });
});

describe("adviceViolations", () => {
  const facts = adviceFacts("top_category", ctxOf({ categoryCents: { restaurants: 40_000, groceries: 5_000 } }));

  test("a short message using only the facts is accepted", () => {
    expect(
      adviceViolations(
        { title: "🔎 Ton poste n°1", body: "Les restos pèsent 89 % de ton mois, soit 400 CAD. On regarde ?" },
        facts
      )
    ).toEqual([]);
  });

  test("an invented number is refused", () => {
    expect(adviceViolations({ title: "Astuce", body: "Tu peux économiser 150 $ par mois." }, facts))
      .toContain("invented-number");
  });

  test("investment, credit and tax talk is refused", () => {
    for (const body of [
      "Pense à investir dans des ETF.",
      "Ouvre un REER pour moins d'impôts.",
      "Try a crypto account.",
      "Take a loan to cover it.",
    ]) {
      expect(adviceViolations({ title: "Astuce", body }, facts)).toContain("forbidden-topic");
    }
  });

  test("an ordinary word like « prêt » is fine", () => {
    expect(adviceViolations({ title: "Prêt ?", body: "Prêt à rejouer la leçon ?" }, facts)).toEqual([]);
  });

  test("empty and over-long messages are refused", () => {
    expect(adviceViolations({ title: "", body: "ok" }, facts)).toContain("empty");
    expect(adviceViolations({ title: "x".repeat(ADVICE_TITLE_MAX + 1), body: "ok" }, facts)).toContain(
      "title-too-long"
    );
    expect(adviceViolations({ title: "ok", body: "x".repeat(ADVICE_BODY_MAX + 1) }, facts)).toContain(
      "body-too-long"
    );
  });

  test("the whitelist is built from the facts plus tiny counters", () => {
    const allowed = allowedNumbers(["Score 55 out of 100."]);
    expect(allowed.has("55")).toBe(true);
    expect(allowed.has("100")).toBe(true);
    expect(allowed.has("2")).toBe(true);
    expect(allowed.has("56")).toBe(false);
  });
});

describe("templateAdvice", () => {
  const contexts: AdviceContext[] = [
    ctxOf({
      variableCents: 300_000,
      lessons: [{ lessonId: "needs_wants", lastScore: 40, bestScore: 40, attempts: 1 }],
      categoryCents: { restaurants: 40_000, groceries: 5_000 },
    }),
    ctxOf({ currency: "XOF", variableCents: 9_999_999 }),
  ];

  test.each(ADVICE_FOCUS_PRIORITY.flatMap((f) => (["fr", "en"] as const).map((l) => [f, l] as const)))(
    "%s / %s fits a push and talks about nothing forbidden",
    (focus: AdviceFocus, locale) => {
      for (const ctx of contexts) {
        const message = templateAdvice(focus, ctx, locale);
        expect(message.title.length).toBeGreaterThan(0);
        expect(message.title.length).toBeLessThanOrEqual(ADVICE_TITLE_MAX);
        expect(message.body.length).toBeLessThanOrEqual(ADVICE_BODY_MAX);
        expect(adviceViolations({ title: message.title, body: message.body }, [])).not.toContain(
          "forbidden-topic"
        );
        expect(message.body).not.toMatch(/undefined|NaN|\{|\}/);
      }
    }
  );

  test("the template quotes the learner's real figures", () => {
    const ctx = ctxOf({ variableCents: 300_000 });
    expect(templateAdvice("budget_over", ctx, "en").body).toContain("500");
    const top = ctxOf({ categoryCents: { restaurants: 30_000, groceries: 10_000 } });
    expect(templateAdvice("top_category", top, "fr").body).toContain("75");
  });
});

describe("composeAdvice", () => {
  const ctx = ctxOf({ variableCents: 300_000 });
  const base = { focus: "budget_over" as const, ctx, locale: "fr" as const, recentTitles: [] };

  test("uses the AI wording when it passes every check", async () => {
    const result = await composeAdvice({
      ...base,
      ai: () => Promise.resolve(JSON.stringify({ title: "🧭 Point budget", body: "Tu as dépassé de 500 CAD. Regarde où ça a filé." })),
    });
    expect(result.source).toBe("ai");
    expect(result.title).toBe("🧭 Point budget");
    expect(result.route).toBe("/budget");
    expect(result.rejected).toEqual([]);
  });

  test("falls back to the template when the AI invents a number", async () => {
    const result = await composeAdvice({
      ...base,
      ai: () => Promise.resolve(JSON.stringify({ title: "Astuce", body: "Économise 777 $ ce mois-ci." })),
    });
    expect(result.source).toBe("template");
    expect(result.rejected).toContain("invented-number");
    expect(result.body.length).toBeGreaterThan(0);
  });

  test("falls back when the AI fails, answers nothing, or answers garbage", async () => {
    const failing = await composeAdvice({ ...base, ai: () => Promise.reject(new Error("429")) });
    const silent = await composeAdvice({ ...base, ai: () => Promise.resolve(null) });
    const garbage = await composeAdvice({ ...base, ai: () => Promise.resolve("not json") });
    const wrongShape = await composeAdvice({ ...base, ai: () => Promise.resolve('{"text":"hi"}') });
    for (const result of [failing, silent, garbage, wrongShape]) {
      expect(result.source).toBe("template");
      expect(result.title.length).toBeGreaterThan(0);
    }
    expect(failing.rejected).toEqual(["ai-error"]);
    expect(silent.rejected).toEqual(["no-answer"]);
    expect(wrongShape.rejected).toEqual(["bad-shape"]);
  });

  test("the prompt sent to the AI carries the recent titles to avoid", async () => {
    let seen = "";
    await composeAdvice({
      ...base,
      recentTitles: ["Déjà dit"],
      ai: (prompt) => {
        seen = prompt;
        return Promise.resolve(null);
      },
    });
    expect(seen).toContain("Déjà dit");
    expect(seen).toContain("500 CAD");
  });
});
