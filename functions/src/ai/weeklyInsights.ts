import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { logger } from "../shared/logger";

const db = () => getFirestore();

/**
 * Weekly scheduler (every Monday at 06:00 UTC).
 * For each active user: aggregate last 7 days of data,
 * call Gemini, store personalized insights + suggest quests.
 */
export const weeklyInsights = onSchedule(
  {
    schedule: "every monday 06:00",
    region: "us-central1",
    timeoutSeconds: 540,
    memory: "512MiB",
  },
  async (_event) => {
    logger.info("weeklyInsights started");

    // Process active users (last lesson within 14 days)
    const twoWeeksAgo = new Date(Date.now() - 14 * 86400000).toISOString().slice(0, 10);
    const usersSnap = await db()
      .collection("users")
      .where("lastActiveDate", ">=", twoWeeksAgo)
      .limit(500)
      .get();

    logger.info("weekly insights: processing users", { count: usersSnap.size });

    // Process in batches of 10 to avoid rate limits
    const batchSize = 10;
    for (let i = 0; i < usersSnap.docs.length; i += batchSize) {
      const batch = usersSnap.docs.slice(i, i + batchSize);
      await Promise.allSettled(batch.map((doc) => generateUserInsight(doc.id, doc.data() as UserProfile)));
      // Rate limit pause
      await sleep(1000);
    }

    logger.info("weeklyInsights completed");
  }
);

interface UserProfile {
  locale?: string;
  country?: string;
}

async function generateUserInsight(uid: string, profile: UserProfile): Promise<void> {
  const locale = (profile.locale ?? "fr") as "fr" | "en";
  const country = profile.country ?? "generic";

  // Aggregate last 7 days
  const summary = await buildWeeklySummary(uid);

  const prompt = buildInsightPrompt(summary, locale, country);
  const insight = await callGemini(prompt, uid);

  if (!insight) return;

  // Store insight
  const weekKey = getWeekKey();
  await db().doc(`users/${uid}/insights/${weekKey}`).set({
    weekKey,
    locale,
    content: insight.text,
    questSuggestions: insight.quests,
    createdAt: FieldValue.serverTimestamp(),
  });

  // Optionally push quests
  if (insight.quests.length > 0) {
    const batch = db().batch();
    for (const quest of insight.quests.slice(0, 2)) {
      const ref = db().collection(`users/${uid}/quests`).doc();
      batch.set(ref, {
        ...quest,
        status: "active",
        source: "ai_weekly",
        createdAt: FieldValue.serverTimestamp(),
        expiresAt: new Date(Date.now() + 7 * 86400000),
        progress: 0,
        expireWarningSent: false,
      });
    }
    await batch.commit();
  }

  logger.info("weekly insight stored", { uid, weekKey });
}

interface WeeklySummary {
  totalExpenseCents: number;
  topCategories: Array<{ category: string; cents: number }>;
  lessonCount: number;
  streak: number;
  savingsRatePct: number;
}

async function buildWeeklySummary(uid: string): Promise<WeeklySummary> {
  const [gameSnap, txSnap] = await Promise.all([
    db().doc(`users/${uid}/game/state`).get(),
    db()
      .collection(`users/${uid}/transactions`)
      .where("date", ">=", new Date(Date.now() - 7 * 86400000))
      .where("type", "==", "expense")
      .get(),
  ]);

  const categoryMap: Record<string, number> = {};
  let totalExpenseCents = 0;

  for (const doc of txSnap.docs) {
    const tx = doc.data() as { amountCents: number; category: string };
    categoryMap[tx.category] = (categoryMap[tx.category] ?? 0) + tx.amountCents;
    totalExpenseCents += tx.amountCents;
  }

  const topCategories = Object.entries(categoryMap)
    .sort(([, a], [, b]) => b - a)
    .slice(0, 3)
    .map(([category, cents]) => ({ category, cents }));

  return {
    totalExpenseCents,
    topCategories,
    lessonCount: (gameSnap.data()?.weeklyLessons ?? 0) as number,
    streak: (gameSnap.data()?.streak ?? 0) as number,
    savingsRatePct: 0, // Would compute from income vs expense
  };
}

function buildInsightPrompt(summary: WeeklySummary, locale: string, country: string): string {
  const lang = locale === "fr" ? "French" : "English";
  return `You are Sipho, a friendly financial coach for ${country}. 
In ${lang}, write a 2-3 sentence personalized weekly insight based on:
- Total spent: ${(summary.totalExpenseCents / 100).toFixed(2)}
- Top categories: ${summary.topCategories.map((c) => `${c.category}: ${(c.cents / 100).toFixed(2)}`).join(", ")}
- Lessons completed: ${summary.lessonCount}
- Streak: ${summary.streak} days

Also suggest 1-2 short quests (JSON array) that would help this user improve.
Quest format: {"name": "...", "type": "...", "target": int, "description": "..."}

Respond with valid JSON: {"text": "...", "quests": [...]}
Keep the insight encouraging and actionable. No PII.`;
}

interface GeminiInsight {
  text: string;
  quests: Array<{ name: string; type: string; target: number; description: string }>;
}

async function callGemini(prompt: string, uid: string): Promise<GeminiInsight | null> {
  const API_KEY = process.env.GEMINI_API_KEY ?? "";
  if (!API_KEY) {
    logger.warn("GEMINI_API_KEY not set, skipping insight", { uid });
    return null;
  }

  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${API_KEY}`;
  const response = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      contents: [{ parts: [{ text: prompt }] }],
      generationConfig: { responseMimeType: "application/json", maxOutputTokens: 500 },
    }),
  });

  if (!response.ok) {
    logger.error("Gemini API error for weeklyInsights", { uid, status: response.status });
    return null;
  }

  const data = (await response.json()) as {
    candidates?: Array<{ content?: { parts?: Array<{ text?: string }> } }>;
  };
  const text = data.candidates?.[0]?.content?.parts?.[0]?.text ?? "{}";

  try {
    return JSON.parse(text) as GeminiInsight;
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
  return Math.ceil(((d.getTime() - yearStart.getTime()) / 86400000 + 1) / 7);
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
