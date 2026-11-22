import { HttpsError, onCall } from "firebase-functions/v2/https";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { z } from "zod";
import { callGeminiJson } from "../ai/geminiClient";
import {
  isAwardableSlot,
  pickRandomTopic,
  slotById,
  slotsForCountry,
  topicById,
  type TopicSeed,
} from "../shared/countryLessonTopics";
import { logger } from "../shared/logger";
import {
  SECURE_CALLABLE_OPTIONS,
  enforceRateLimit,
  parseInput,
  requireAuthUid,
} from "../shared/security";

const db = () => getFirestore();

const InputSchema = z.object({
  /** Awardable slot to fill. Defaults to the first slot for the user's country. */
  slotId: z
    .string()
    .trim()
    .min(3)
    .max(64)
    .regex(/^[a-z0-9_]+$/)
    .optional(),
  /** When true, always regenerate even if a lesson already exists for the slot. */
  /** When true, regenerate even if a lesson already exists for the slot. Default: reuse. */
  forceNew: z.boolean().optional().default(false),
});

/** Monolingual lesson payload (language = user locale). */
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

export type AiLessonPayload = z.infer<typeof AiLessonSchema>;

interface EconomyHeadline {
  plainTitle?: string;
  takeaway?: string;
  source?: string;
}

/**
 * Fills one awardable country **slot** with a fresh monolingual AI lesson.
 * Topic is picked at random (≠ lastTopicId). XP is claimed later via `completeLesson(slotId)`.
 */
export const generateCountryLessons = onCall(
  {
    ...SECURE_CALLABLE_OPTIONS,
    // ADR-005: enforce App Check on Gemini-cost callables once tokens are wired.
    enforceAppCheck: true,
  },
  async (request) => {
    const uid = requireAuthUid(request);
    const { slotId: requestedSlotId, forceNew } = parseInput(
      InputSchema,
      request.data ?? {}
    );

    await enforceRateLimit({
      uid,
      action: "generateCountryLessons",
      maxRequests: 12,
      windowMs: 60 * 60 * 1000,
    });

  const userSnap = await db().doc(`users/${uid}`).get();
  const user = userSnap.data() ?? {};
  if (user.onboardingDone !== true) {
    throw new HttpsError("failed-precondition", "Finish onboarding first.");
  }

  const countryCode =
    typeof user.countryCode === "string" && user.countryCode.trim()
      ? user.countryCode.trim().toUpperCase()
      : "";

  const availableSlots = slotsForCountry(countryCode || null);
  if (availableSlots.length === 0) {
    throw new HttpsError("failed-precondition", "No country lesson slots available.");
  }

  let slotId = requestedSlotId ?? availableSlots[0].id;
  const slot = slotById(slotId);
  if (!slot || !isAwardableSlot(slotId)) {
    throw new HttpsError("invalid-argument", "Unknown lesson slot.");
  }
  if (!availableSlots.some((s) => s.id === slotId)) {
    throw new HttpsError("invalid-argument", "Lesson not available for your country.");
  }

  const lessonRef = db().doc(`users/${uid}/aiLessons/${slotId}`);
  const metaRef = db().doc(`users/${uid}/aiLessonsMeta/state`);

  if (!forceNew) {
    const existing = await lessonRef.get();
    if (existing.exists && existing.data()?.personalized === true) {
      return {
        slotId,
        topicId: existing.data()?.topicId ?? null,
        locale: existing.data()?.locale ?? (user.locale === "en" ? "en" : "fr"),
        reused: true,
        lesson: existing.data(),
        countryCode: countryCode || null,
      };
    }
  }

  const apiKey = process.env.GEMINI_API_KEY ?? "";
  if (!apiKey) {
    logger.warn("generateCountryLessons: GEMINI_API_KEY missing", { uid });
    return {
      slotId,
      topicId: null,
      locale: user.locale === "en" ? "en" : "fr",
      reused: false,
      generated: false,
      countryCode: countryCode || null,
      reason: "no_api_key",
    };
  }

  const metaSnap = await metaRef.get();
  const lastTopicId =
    typeof metaSnap.data()?.lastTopicId === "string" ? metaSnap.data()?.lastTopicId : null;
  const recentRaw = metaSnap.data()?.recentTopicIds;
  const recentTopicIds = Array.isArray(recentRaw)
    ? recentRaw.filter((x): x is string => typeof x === "string").slice(0, 20)
    : [];

  const topic = pickTopicAvoidingRecent(countryCode || null, lastTopicId, recentTopicIds);

  const locale: "fr" | "en" = user.locale === "en" ? "en" : "fr";
  const currency = typeof user.currency === "string" ? user.currency : "";
  const goal = typeof user.goal === "string" ? user.goal : "";
  const region = typeof user.region === "string" ? user.region : "";
  const incomeCents =
    typeof user.monthlyIncomeCents === "number" && Number.isInteger(user.monthlyIncomeCents)
      ? user.monthlyIncomeCents
      : 0;

  const headlines = await loadEconomyHeadlines(countryCode || "WORLD");

  const payload = await generateOne({
    apiKey,
    uid,
    topic,
    countryCode: countryCode || "ZZ",
    locale,
    currency,
    goal,
    region,
    incomeCents,
    headlines,
  });

  if (!payload) {
    return {
      slotId,
      topicId: topic.id,
      locale,
      reused: false,
      generated: false,
      countryCode: countryCode || null,
      reason: "generation_failed",
    };
  }

  const nextRecent = [topic.id, ...recentTopicIds.filter((id) => id !== topic.id)].slice(0, 20);

  await lessonRef.set(
    {
      lessonId: slotId,
      slotId,
      topicId: topic.id,
      theme: topic.theme,
      angle: topic.angle,
      countryCode: countryCode || null,
      locale,
      personalized: true,
      monolingual: true,
      ...payload,
      generatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  await metaRef.set(
    {
      lastTopicId: topic.id,
      lastSlotId: slotId,
      recentTopicIds: nextRecent,
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  logger.info("generateCountryLessons: wrote", {
    uid,
    slotId,
    topicId: topic.id,
    locale,
  });

  return {
    slotId,
    topicId: topic.id,
    locale,
    reused: false,
    generated: true,
    countryCode: countryCode || null,
    lesson: {
      lessonId: slotId,
      slotId,
      topicId: topic.id,
      theme: topic.theme,
      angle: topic.angle,
      locale,
      personalized: true,
      monolingual: true,
      ...payload,
    },
  };
});

function pickTopicAvoidingRecent(
  countryCode: string | null,
  lastTopicId: string | null,
  recentTopicIds: string[]
): TopicSeed {
  // Prefer excluding last; if still in a tiny pool, pickRandomTopic handles it.
  let exclude = lastTopicId;
  let topic = pickRandomTopic(countryCode, exclude);
  if (recentTopicIds.includes(topic.id) && recentTopicIds.length < 50) {
    // One retry avoiding a random recent id when possible.
    exclude = topic.id;
    topic = pickRandomTopic(countryCode, exclude);
  }
  return topic;
}

async function loadEconomyHeadlines(countryCode: string): Promise<EconomyHeadline[]> {
  const code = countryCode.length === 2 ? countryCode : "WORLD";
  try {
    const [primary, world] = await Promise.all([
      db().doc(`economyNews/${code}`).get(),
      code === "WORLD" ? Promise.resolve(null) : db().doc("economyNews/WORLD").get(),
    ]);
    const items = [
      ...readHeadlines(primary?.data()),
      ...readHeadlines(world?.data()),
    ].slice(0, 3);
    return items;
  } catch {
    return [];
  }
}

function readHeadlines(data: FirebaseFirestore.DocumentData | undefined): EconomyHeadline[] {
  if (!data || !Array.isArray(data.items)) return [];
  return data.items
    .map((item: EconomyHeadline) => ({
      plainTitle: typeof item.plainTitle === "string" ? item.plainTitle : undefined,
      takeaway: typeof item.takeaway === "string" ? item.takeaway : undefined,
      source: typeof item.source === "string" ? item.source : undefined,
    }))
    .filter((h: EconomyHeadline) => Boolean(h.plainTitle));
}

async function generateOne(params: {
  apiKey: string;
  uid: string;
  topic: TopicSeed;
  countryCode: string;
  locale: "fr" | "en";
  currency: string;
  goal: string;
  region: string;
  incomeCents: number;
  headlines: EconomyHeadline[];
}): Promise<AiLessonPayload | null> {
  const prompt = buildPrompt(params);
  const text = await callGeminiJson({
    apiKey: params.apiKey,
    parts: [{ text: prompt }],
    maxOutputTokens: 4096,
    contextLabel: "generateCountryLessons",
    uid: params.uid,
  });
  if (!text) return null;

  try {
    const start = text.indexOf("{");
    const end = text.lastIndexOf("}");
    if (start < 0 || end <= start) return null;
    const raw = JSON.parse(text.slice(start, end + 1));
    const parsed = AiLessonSchema.safeParse(raw);
    if (!parsed.success) {
      logger.warn("generateCountryLessons: schema fail", {
        uid: params.uid,
        topicId: params.topic.id,
        issues: parsed.error.issues.slice(0, 3),
      });
      return null;
    }
    if (!quizHasExactlyOneCorrect(parsed.data)) {
      logger.warn("generateCountryLessons: bad quiz", {
        uid: params.uid,
        topicId: params.topic.id,
      });
      return null;
    }
    return parsed.data;
  } catch (err) {
    logger.warn("generateCountryLessons: parse error", {
      uid: params.uid,
      error: String(err),
    });
    return null;
  }
}

function quizHasExactlyOneCorrect(lesson: AiLessonPayload): boolean {
  for (const step of lesson.steps) {
    if (step.type !== "quiz") continue;
    const correct = step.choices.filter((c) => c.correct).length;
    if (correct !== 1) return false;
  }
  return lesson.steps.some((s) => s.type === "quiz" || s.type === "trueFalse");
}

function buildPrompt(params: {
  topic: TopicSeed;
  countryCode: string;
  locale: "fr" | "en";
  currency: string;
  goal: string;
  region: string;
  incomeCents: number;
  headlines: EconomyHeadline[];
}): string {
  const langName = params.locale === "en" ? "English" : "French";
  const newsBlock =
    params.headlines.length > 0
      ? params.headlines
          .map(
            (h, i) =>
              `${i + 1}. "${h.plainTitle}"${h.takeaway ? ` — ${h.takeaway}` : ""}${
                h.source ? ` (source hint: ${h.source})` : ""
              }`
          )
          .join("\n")
      : "(No live headlines available — stay general, still country-aware, invent no figures.)";

  return `You are Sipho, an educational money coach. Produce ONE micro-lesson as JSON.
ALL user-facing strings must be in ${langName} only (locale=${params.locale}). Do NOT include fr/en maps.

Country focus: ${params.countryCode}.
Theme: ${params.topic.theme}.
News / political-economy angle: ${params.topic.angle}.
Prefer citing "${params.topic.sourceHint}" as places to verify — NEVER invent rates, tax %, ceilings, fees, or prices.

Recent local economy headlines (context only; do not invent numbers from them):
${newsBlock}

User context (use gently; integers only; no PII names):
- currency: ${params.currency || "unknown"}
- region: ${params.region || "unknown"}
- goal tag: ${params.goal || "none"}
- monthlyIncomeCents: ${params.incomeCents} (100 cents = 1 ${params.currency || "unit"}; if 0, do not invent income)

STRICT:
- Educational only, not personalized financial / tax / investment advice.
- No bank, broker, or product brand recommendations.
- Tie the lesson to the country's current economic / political context in plain language.
- Include at least one info step, one quiz (3 choices, exactly one correct), one trueFalse.
- Keep each string short (mobile UI).

Return JSON only:
{
  "emoji": "🌍",
  "title": "...",
  "objective": "...",
  "steps": [
    {"type":"info","emoji":"📦","title":"...","body":"...","points":["..."]},
    {"type":"quiz","question":"...","choices":[{"text":"...","correct":true},{"text":"...","correct":false},{"text":"...","correct":false}],"explanation":"..."},
    {"type":"trueFalse","statement":"...","answer":false,"explanation":"..."}
  ],
  "takeaways": ["...","...","..."]
}`;
}

// Re-export for tests that may look up a topic after generation.
export { topicById };
