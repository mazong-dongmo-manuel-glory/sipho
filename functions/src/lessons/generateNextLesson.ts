import { HttpsError, onCall } from "firebase-functions/v2/https";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { z } from "zod";
import { callGeminiJson } from "../ai/geminiClient";
import { logger } from "../shared/logger";
import {
  ALL_LESSON_IDS,
  corePathCompleted,
  generatedLessonIdFor,
  generatedLessonIndex,
  isGeneratedLessonId,
} from "../shared/lessonPath";
import {
  SECURE_CALLABLE_OPTIONS,
  enforceRateLimit,
  parseInput,
  requireAuthUid,
} from "../shared/security";

const db = () => getFirestore();

const InputSchema = z.object({
  locale: z.enum(["fr", "en"]).optional(),
});

const AiLessonSchema = z.object({
  title: z.string().trim().min(3).max(160),
  objective: z.string().trim().min(3).max(280),
  emoji: z.string().trim().min(1).max(8),
  steps: z
    .array(
      z.discriminatedUnion("type", [
        z.object({
          type: z.literal("info"),
          emoji: z.string().trim().min(1).max(8),
          title: z.string().trim().min(1).max(120),
          body: z.string().trim().min(1).max(600),
          points: z.array(z.string().trim().min(1).max(160)).max(3).optional().default([]),
        }),
        z.object({
          type: z.literal("quiz"),
          question: z.string().trim().min(1).max(280),
          choices: z
            .array(
              z.object({
                text: z.string().trim().min(1).max(160),
                correct: z.boolean(),
              })
            )
            .length(3),
          explanation: z.string().trim().min(1).max(400),
        }),
        z.object({
          type: z.literal("trueFalse"),
          statement: z.string().trim().min(1).max(280),
          answer: z.boolean(),
          explanation: z.string().trim().min(1).max(400),
        }),
      ])
    )
    .min(3)
    .max(6),
  takeaways: z.array(z.string().trim().min(1).max(200)).min(2).max(4),
});

type AiLessonPayload = z.infer<typeof AiLessonSchema>;

/**
 * Appends exactly one new lesson after the static path.
 * The lesson is stored in `users/{uid}/aiLessons/gen_00N`.
 * If an unfinished generated lesson already exists, that one is returned.
 */
export const generateNextLesson = onCall(SECURE_CALLABLE_OPTIONS, async (request) => {
  const uid = requireAuthUid(request);
  const { locale: localeOverride } = parseInput(InputSchema, request.data ?? {});

  await enforceRateLimit({
    uid,
    action: "generateNextLesson",
    maxRequests: 12,
    windowMs: 60 * 60 * 1000,
  });

  const userSnap = await db().doc(`users/${uid}`).get();
  const user = userSnap.data() ?? {};
  if (user.onboardingDone !== true) {
    throw new HttpsError("failed-precondition", "Finish onboarding first.");
  }

  const completed = await completedLessonIds(uid, user.completedLessonIds);
  if (!corePathCompleted(completed)) {
    return { generated: false, reason: "core_incomplete" };
  }

  const existing = await listGeneratedLessons(uid);
  const open = existing.find((lesson) => !completed.has(lesson.id));
  if (open) {
    return {
      generated: false,
      reused: true,
      lessonId: open.id,
      locale: open.locale,
    };
  }

  const nextIndex = (existing.at(-1)?.index ?? 0) + 1;
  if (nextIndex > 999) {
    throw new HttpsError("resource-exhausted", "Lesson path is full.");
  }
  const lessonId = generatedLessonIdFor(nextIndex);

  const apiKey = process.env.GEMINI_API_KEY ?? "";
  if (!apiKey) {
    logger.warn("generateNextLesson: GEMINI_API_KEY missing", { uid });
    return { generated: false, reason: "no_api_key", lessonId };
  }

  const profileLocale: "fr" | "en" = user.locale === "en" ? "en" : "fr";
  const locale: "fr" | "en" = localeOverride ?? profileLocale;
  const countryCode =
    typeof user.countryCode === "string" && user.countryCode.trim()
      ? user.countryCode.trim().toUpperCase()
      : "ZZ";
  const currency = typeof user.currency === "string" ? user.currency : "";
  const goal = typeof user.goal === "string" ? user.goal : "";
  const recentTitles = existing.map((lesson) => lesson.title).filter(Boolean).slice(-8);

  const payload = await generateOne({
    apiKey,
    uid,
    locale,
    countryCode,
    currency,
    goal,
    recentTitles,
    index: nextIndex,
  });
  if (!payload) {
    return { generated: false, reason: "generation_failed", lessonId };
  }

  await db().doc(`users/${uid}/aiLessons/${lessonId}`).set({
    lessonId,
    slotId: lessonId,
    kind: "generated",
    index: nextIndex,
    countryCode,
    locale,
    personalized: true,
    monolingual: true,
    ...payload,
    generatedAt: FieldValue.serverTimestamp(),
  });

  await db().doc(`users/${uid}/aiLessonsMeta/state`).set(
    {
      lastGeneratedId: lessonId,
      generatedCount: nextIndex,
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  logger.info("generateNextLesson: wrote", { uid, lessonId, locale });
  return {
    generated: true,
    reused: false,
    lessonId,
    locale,
    lesson: { lessonId, slotId: lessonId, locale, ...payload },
  };
});

async function completedLessonIds(uid: string, legacy: unknown): Promise<Set<string>> {
  const done = new Set<string>();
  if (Array.isArray(legacy)) {
    for (const id of legacy) {
      if (typeof id === "string") done.add(id);
    }
  }
  const progress = await db().collection(`users/${uid}/lessonProgress`).get();
  for (const doc of progress.docs) done.add(doc.id);
  return done;
}

async function listGeneratedLessons(
  uid: string
): Promise<Array<{ id: string; index: number; locale: string; title: string }>> {
  const snap = await db().collection(`users/${uid}/aiLessons`).get();
  const lessons = snap.docs
    .filter((doc) => isGeneratedLessonId(doc.id))
    .map((doc) => {
      const data = doc.data();
      const title = typeof data.title === "string" ? data.title : "";
      return {
        id: doc.id,
        index: generatedLessonIndex(doc.id) ?? 0,
        locale: data.locale === "en" ? "en" : "fr",
        title,
      };
    });
  lessons.sort((a, b) => a.index - b.index);
  return lessons;
}

async function generateOne(params: {
  apiKey: string;
  uid: string;
  locale: "fr" | "en";
  countryCode: string;
  currency: string;
  goal: string;
  recentTitles: string[];
  index: number;
}): Promise<AiLessonPayload | null> {
  const langName = params.locale === "en" ? "English" : "French";
  const avoid =
    params.recentTitles.length > 0
      ? params.recentTitles.map((title) => `- ${title}`).join("\n")
      : "(none yet)";
  const covered = (ALL_LESSON_IDS as readonly string[]).join(", ");
  const prompt = `You are Sipho, an educational money coach. Produce ONE new micro-lesson as JSON.
ALL user-facing strings must be in ${langName} only. Never mix languages. Never invent tax rates, legal ceilings, fees, or prices.

This is lesson number ${params.index} AFTER a fixed starter path the learner already finished (${covered}).
Choose a fresh everyday-money topic that is NOT one of those starters and NOT a repeat of the recent titles below.
Country context (plain language only, no legal advice): ${params.countryCode}.
Currency code: ${params.currency || "unknown"}. Goal tag: ${params.goal || "none"}.

Recent titles to avoid:
${avoid}

STRICT:
- Educational only. Not personalized financial, tax, or investment advice.
- No bank, broker, or product brand.
- At least one info step, one quiz with exactly 3 choices and exactly one correct, one trueFalse.
- 3 to 5 steps. Short strings for a phone screen.

Return JSON only:
{
  "emoji": "📘",
  "title": "...",
  "objective": "...",
  "steps": [
    {"type":"info","emoji":"📦","title":"...","body":"...","points":["..."]},
    {"type":"quiz","question":"...","choices":[{"text":"...","correct":true},{"text":"...","correct":false},{"text":"...","correct":false}],"explanation":"..."},
    {"type":"trueFalse","statement":"...","answer":false,"explanation":"..."}
  ],
  "takeaways": ["...","..."]
}`;

  const text = await callGeminiJson({
    apiKey: params.apiKey,
    parts: [{ text: prompt }],
    maxOutputTokens: 4096,
    contextLabel: "generateNextLesson",
    uid: params.uid,
  });
  if (!text) return null;
  try {
    const start = text.indexOf("{");
    const end = text.lastIndexOf("}");
    if (start < 0 || end <= start) return null;
    const parsed = AiLessonSchema.safeParse(JSON.parse(text.slice(start, end + 1)));
    if (!parsed.success) {
      logger.warn("generateNextLesson: schema fail", {
        uid: params.uid,
        issues: parsed.error.issues.slice(0, 3),
      });
      return null;
    }
    const quizOk = parsed.data.steps.every((step) => {
      if (step.type !== "quiz") return true;
      return step.choices.filter((choice) => choice.correct).length === 1;
    });
    const hasQuestion = parsed.data.steps.some(
      (step) => step.type === "quiz" || step.type === "trueFalse"
    );
    if (!quizOk || !hasQuestion) return null;
    return parsed.data;
  } catch (err) {
    logger.warn("generateNextLesson: parse error", { uid: params.uid, error: String(err) });
    return null;
  }
}
