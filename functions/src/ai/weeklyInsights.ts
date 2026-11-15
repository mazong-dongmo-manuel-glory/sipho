import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { z } from "zod";
import { normalizeGameState } from "../shared/gameState";
import { deadlineGuard, forEachDocument } from "../shared/pagination";
import { logger } from "../shared/logger";
import { callGeminiJson } from "./geminiClient";

const db = (): Firestore => getFirestore();

const GeminiInsightSchema = z.object({
  text: z.string().trim().min(1).max(600),
  quests: z
    .array(
      z.object({
        name: z.string().trim().min(1).max(80),
        type: z.enum(["ADD_TRANSACTION", "COMPLETE_LESSON"]),
        target: z.number().int().min(1).max(14),
        description: z.string().trim().min(1).max(160),
      })
    )
    .max(2)
    .default([]),
});

type GeminiInsight = z.infer<typeof GeminiInsightSchema>;

interface UserProfile {
  locale?: string;
  countryCode?: string;
}

interface WeeklySummary {
  totalExpenseCents: number;
  topCategories: Array<{ category: string; cents: number }>;
  lessonCount: number;
  streak: number;
}

/**
 * Weekly scheduler (every Monday at 06:00 UTC).
 * Sends ONLY aggregated integer cents (zero PII) to Gemini with strict schema validation.
 */
const TIMEOUT_SECONDS = 1800;

export const weeklyInsights = onSchedule(
  {
    schedule: "every monday 06:00",
    region: "us-central1",
    timeoutSeconds: TIMEOUT_SECONDS,
    memory: "512MiB",
  },
  async (_event) => {
    logger.info("weeklyInsights started");

    // Paginated (no 500-user cap); 10 users in parallel with a 1s pause keeps Gemini under quota.
    const result = await forEachDocument(
      db().collection("users").where("onboardingDone", "==", true),
      (doc) => generateUserInsight(doc.id, doc.data() as UserProfile),
      {
        label: "weeklyInsights",
        pageSize: 100,
        concurrency: 10,
        pauseMsBetweenChunks: 1000,
        shouldStop: deadlineGuard(TIMEOUT_SECONDS),
      }
    );

    logger.info("weeklyInsights completed", { ...result });
  }
);

async function generateUserInsight(uid: string, profile: UserProfile): Promise<void> {
  const locale = profile.locale === "en" ? "en" : "fr";
  const country = typeof profile.countryCode === "string" ? profile.countryCode : "unknown";

  const summary = await buildWeeklySummary(uid);
  if (summary.totalExpenseCents <= 0 && summary.lessonCount <= 0) {
    return;
  }

  const prompt = buildInsightPrompt(summary, locale, country);
  const insight = await callGemini(prompt, uid);
  if (!insight) return;

  const weekKey = getWeekKey();
  await db().doc(`users/${uid}/insights/${weekKey}`).set({
    weekKey,
    locale,
    content: insight.text,
    questSuggestions: insight.quests,
    dismissed: false,
    createdAt: FieldValue.serverTimestamp(),
  });

  if (insight.quests.length > 0) {
    const batch = db().batch();
    for (const quest of insight.quests) {
      const ref = db().collection(`users/${uid}/quests`).doc();
      batch.set(ref, {
        templateId: "ai_weekly",
        name: quest.name,
        description: quest.description,
        type: quest.type,
        target: quest.target,
        rewardXp: 20,
        status: "active",
        source: "ai_weekly",
        locale,
        createdAt: FieldValue.serverTimestamp(),
        expiresAt: new Date(Date.now() + 7 * 86_400_000),
        progress: 0,
        expireWarningSent: false,
      });
    }
    await batch.commit();
  }

  logger.info("weekly insight stored", { uid, weekKey });
}

async function buildWeeklySummary(uid: string): Promise<WeeklySummary> {
  const since = new Date(Date.now() - 7 * 86_400_000).toISOString().slice(0, 10);
  const [userSnap, gameSnap, txSnap] = await Promise.all([
    db().doc(`users/${uid}`).get(),
    db().doc(`users/${uid}/game/state`).get(),
    db()
      .collection(`users/${uid}/transactions`)
      .where("date", ">=", since)
      .get(),
  ]);

  const categoryMap: Record<string, number> = {};
  let totalExpenseCents = 0;

  for (const doc of txSnap.docs) {
    const data = doc.data() as Record<string, unknown>;
    const rawCents: unknown =
      typeof data.amountMainCents === "number" ? data.amountMainCents : data.amountCents;
    const cents = typeof rawCents === "number" ? Math.max(0, Math.trunc(rawCents)) : 0;
    const cat = typeof data.category === "string" ? data.category : "other";
    if (cents > 0) {
      categoryMap[cat] = (categoryMap[cat] ?? 0) + cents;
      totalExpenseCents += cents;
    }
  }

  const topCategories = Object.entries(categoryMap)
    .sort(([, a], [, b]) => b - a)
    .slice(0, 3)
    .map(([category, cents]) => ({ category, cents }));

  const game = normalizeGameState(gameSnap.data());
  const completedLessons = Array.isArray(userSnap.data()?.completedLessonIds)
    ? (userSnap.data()?.completedLessonIds as unknown[]).length
    : 0;

  return {
    totalExpenseCents,
    topCategories,
    lessonCount: completedLessons,
    streak: game.streak.current,
  };
}

function buildInsightPrompt(summary: WeeklySummary, locale: string, country: string): string {
  const lang = locale === "fr" ? "French" : "English";
  return `You are Sipho, a friendly money coach for country code ${country}.
Reply in ${lang}. Use ONLY the integer cents below. Do NOT invent any rate, tax, price, bank, or financial product.
- Total spent in the last 7 days: ${summary.totalExpenseCents} cents
- Top categories: ${summary.topCategories.map((c) => `${c.category}: ${c.cents} cents`).join(", ") || "none"}
- Completed lessons: ${summary.lessonCount}
- Current streak: ${summary.streak}

Also suggest 1-2 short quests.
Allowed quest types: "ADD_TRANSACTION" or "COMPLETE_LESSON".
Respond with valid JSON only: {"text": "...", "quests": [{"name":"...","type":"ADD_TRANSACTION","target":3,"description":"..."}]}
Educational tone only — never personalized tax or investment advice. Zero PII.`;
}

async function callGemini(prompt: string, uid: string): Promise<GeminiInsight | null> {
  const apiKey = process.env.GEMINI_API_KEY ?? "";
  if (!apiKey) {
    logger.warn("GEMINI_API_KEY not set, skipping insight", { uid });
    return null;
  }

  const text = await callGeminiJson({
    apiKey,
    parts: [{ text: prompt }],
    maxOutputTokens: 1536,
    contextLabel: "weeklyInsights",
    uid,
  });

  if (!text) {
    return null;
  }

  try {
    const parsed = GeminiInsightSchema.safeParse(JSON.parse(text));
    return parsed.success ? parsed.data : null;
  } catch {
    logger.error("Failed to parse Gemini response", { uid });
    return null;
  }
}

function getWeekKey(): string {
  const now = new Date();
  const year = now.getUTCFullYear();
  const week = getISOWeek(now);
  return `${year}-W${String(week).padStart(2, "0")}`;
}

function getISOWeek(date: Date): number {
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  d.setUTCDate(d.getUTCDate() + 4 - (d.getUTCDay() || 7));
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  return Math.ceil(((d.getTime() - yearStart.getTime()) / 86_400_000 + 1) / 7);
}
