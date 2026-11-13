import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { z } from "zod";
import { ALLOWED_LESSON_IDS } from "../shared/validators";
import {
  SECURE_CALLABLE_OPTIONS,
  enforceRateLimit,
  parseInput,
  requireAuthUid,
} from "../shared/security";
import { logger } from "../shared/logger";
import { callGeminiJson } from "./geminiClient";

const db = (): Firestore => getFirestore();

const GenerateInsightInputSchema = z.object({
  monthKey: z
    .string()
    .regex(/^\d{4}-\d{2}$/)
    .optional(),
  focusTopic: z.enum(["spending", "fixed", "goal", "general"]).default("general"),
  acceptQuest: z.boolean().default(false),
});

const GeminiCoachAdviceSchema = z.object({
  title: z.string().trim().min(3).max(90),
  body: z.string().trim().min(10).max(500),
  actionStep: z.string().trim().min(5).max(200),
  recommendedLessonId: z.enum(ALLOWED_LESSON_IDS).default("track_spending"),
  suggestedQuest: z
    .object({
      name: z.string().trim().min(3).max(80),
      description: z.string().trim().min(5).max(160),
      type: z.enum(["ADD_TRANSACTION", "COMPLETE_LESSON"]),
      target: z.number().int().min(1).max(7),
    })
    .optional(),
});

export type CoachAdvicePayload = z.infer<typeof GeminiCoachAdviceSchema>;

/**
 * Callable: generates a personalized educational coaching card from the user's
 * real integer-cent numbers (income, fixed base, month category totals, goal),
 * stores it in `users/{uid}/insights/{id}`, and optionally activates the suggested quest.
 */
export const generateInsight = onCall(
  {
    ...SECURE_CALLABLE_OPTIONS,
    timeoutSeconds: 45,
  },
  async (request) => {
    const uid = requireAuthUid(request);
    const input = parseInput(GenerateInsightInputSchema, request.data ?? {});

    await enforceRateLimit({
      uid,
      action: "generateInsight",
      maxRequests: 10,
      windowMs: 24 * 60 * 60 * 1000,
    });

    const now = new Date();
    const monthKey =
      input.monthKey ??
      `${now.getUTCFullYear()}-${String(now.getUTCMonth() + 1).padStart(2, "0")}`;

    const [userSnap, fixedSnap, txSnap] = await Promise.all([
      db().doc(`users/${uid}`).get(),
      db()
        .collection(`users/${uid}/fixedExpenses`)
        .where("active", "==", true)
        .get(),
      db()
        .collection(`users/${uid}/transactions`)
        .where("date", ">=", `${monthKey}-01`)
        .where("date", "<=", `${monthKey}-31`)
        .get(),
    ]);

    const userData = (userSnap.data() ?? {}) as Record<string, unknown>;
    const locale = userData.locale === "en" ? "en" : "fr";
    const countryCode =
      typeof userData.countryCode === "string" && userData.countryCode.length === 2
        ? userData.countryCode
        : "CA";
    const currency =
      typeof userData.currency === "string" && userData.currency.length === 3
        ? userData.currency
        : "CAD";
    const goal = typeof userData.goal === "string" ? userData.goal : "understand_money";
    const incomeCents =
      typeof userData.monthlyIncomeCents === "number"
        ? Math.max(0, Math.trunc(userData.monthlyIncomeCents))
        : 0;
    const completedLessons = Array.isArray(userData.completedLessonIds)
      ? userData.completedLessonIds.filter((x): x is string => typeof x === "string")
      : [];

    let fixedCents = 0;
    const envelopeLimits: Record<string, number> = {};
    for (const doc of fixedSnap.docs) {
      const d = doc.data() as Record<string, unknown>;
      const amount = typeof d.amountCents === "number" ? Math.max(0, Math.trunc(d.amountCents)) : 0;
      fixedCents += amount;
      if (d.type === "envelope" && typeof d.category === "string" && amount > 0) {
        envelopeLimits[d.category] = amount;
      }
    }

    let variableCents = 0;
    const categoryCents: Record<string, number> = {};
    for (const doc of txSnap.docs) {
      const d = doc.data() as Record<string, unknown>;
      const mainCents = d.amountMainCents;
      const baseCents = d.amountCents;
      const raw = typeof mainCents === "number" ? mainCents : baseCents;
      const cents = typeof raw === "number" ? Math.max(0, Math.trunc(raw)) : 0;
      const cat = typeof d.category === "string" ? d.category : "other";
      if (cents > 0) {
        variableCents += cents;
        categoryCents[cat] = (categoryCents[cat] ?? 0) + cents;
      }
    }

    if (incomeCents <= 0 && fixedCents <= 0 && variableCents <= 0) {
      throw new HttpsError(
        "failed-precondition",
        "Add at least one expense, bill, or monthly income before requesting advice."
      );
    }

    const remainingCents = incomeCents > 0 ? incomeCents - fixedCents - variableCents : null;

    const focusTopic = input.focusTopic ?? "general";

    const prompt = buildCoachPrompt({
      locale,
      countryCode,
      currency,
      monthKey,
      goal,
      focusTopic,
      incomeCents,
      fixedCents,
      variableCents,
      remainingCents,
      categoryCents,
      envelopeLimits,
      completedLessons,
    });

    const advice = await callGeminiCoach(prompt, uid);

    const insightRef = db().collection(`users/${uid}/insights`).doc();
    await insightRef.set({
      title: advice.title,
      content: advice.body,
      actionStep: advice.actionStep,
      recommendedLessonId: advice.recommendedLessonId,
      questSuggestions: advice.suggestedQuest ? [advice.suggestedQuest] : [],
      focusTopic,
      monthKey,
      locale,
      dismissed: false,
      source: "ai_on_demand",
      createdAt: FieldValue.serverTimestamp(),
    });

    if (input.acceptQuest && advice.suggestedQuest) {
      await db()
        .collection(`users/${uid}/quests`)
        .add({
          templateId: "ai_coach",
          name: advice.suggestedQuest.name,
          description: advice.suggestedQuest.description,
          type: advice.suggestedQuest.type,
          target: advice.suggestedQuest.target,
          progress: 0,
          rewardXp: 20,
          status: "active",
          source: "ai_coach",
          locale,
          expireWarningSent: false,
          createdAt: FieldValue.serverTimestamp(),
          expiresAt: new Date(Date.now() + 7 * 86_400_000),
        });
    }

    logger.info("on-demand insight generated", {
      uid,
      insightId: insightRef.id,
      focusTopic,
    });

    return {
      id: insightRef.id,
      ...advice,
    };
  }
);

interface CoachPromptInput {
  locale: "fr" | "en";
  countryCode: string;
  currency: string;
  monthKey: string;
  goal: string;
  focusTopic: string;
  incomeCents: number;
  fixedCents: number;
  variableCents: number;
  remainingCents: number | null;
  categoryCents: Record<string, number>;
  envelopeLimits: Record<string, number>;
  completedLessons: string[];
}

function buildCoachPrompt(ctx: CoachPromptInput): string {
  const lang = ctx.locale === "fr" ? "French" : "English";
  const categoryLines =
    Object.entries(ctx.categoryCents)
      .sort(([, a], [, b]) => b - a)
      .map(([cat, cents]) => `${cat}: ${cents} cents`)
      .join(", ") || "none";
  const envelopeLines =
    Object.entries(ctx.envelopeLimits)
      .map(([cat, cents]) => `${cat} limit: ${cents} cents`)
      .join(", ") || "none";
  const nextUnfinishedLesson =
    ALLOWED_LESSON_IDS.find((id) => !ctx.completedLessons.includes(id)) ?? "track_spending";

  return `You are Sipho, a warm educational money coach. Reply in ${lang}.
STRICT RULES:
- Use ONLY the integer-cent figures provided below (100 cents = 1 unit of ${ctx.currency}).
- NEVER invent inflation rates, interest rates, tax brackets, percentages not directly computable from the integers below, or prices.
- NEVER name any bank, card, broker, ETF, or specific financial product.
- Educational guidance only — never personalized tax, legal, or investment advice.

Context (no PII):
- Country code: ${ctx.countryCode}, Currency: ${ctx.currency}, Month: ${ctx.monthKey}
- User goal: ${ctx.goal}, Requested focus: ${ctx.focusTopic}
- Monthly net income: ${ctx.incomeCents > 0 ? `${ctx.incomeCents} cents` : "not set"}
- Active fixed base total: ${ctx.fixedCents} cents (envelopes: ${envelopeLines})
- Variable spending this month: ${ctx.variableCents} cents (${categoryLines})
- Remaining after income and fixed base: ${ctx.remainingCents === null ? "unknown (income not set)" : `${ctx.remainingCents} cents`}
- Next unfinished lesson ID: ${nextUnfinishedLesson}

Return valid JSON only:
{
  "title": "short warm title (max 60 chars)",
  "body": "2-3 concise sentences interpreting the user's real numbers",
  "actionStep": "1 concrete habit for this week",
  "recommendedLessonId": "${nextUnfinishedLesson}",
  "suggestedQuest": {
    "name": "short quest title",
    "description": "1 sentence quest",
    "type": "ADD_TRANSACTION",
    "target": 3
  }
}`;
}

async function callGeminiCoach(prompt: string, uid: string): Promise<CoachAdvicePayload> {
  const apiKey = process.env.GEMINI_API_KEY ?? "";
  if (!apiKey) {
    throw new HttpsError("failed-precondition", "AI coach is not configured on the server.");
  }

  const text = await callGeminiJson({
    apiKey,
    parts: [{ text: prompt }],
    maxOutputTokens: 1536,
    contextLabel: "generateInsight",
    uid,
  });

  if (!text) {
    throw new HttpsError("internal", "Could not generate advice right now.");
  }

  let rawJson: unknown;
  try {
    rawJson = JSON.parse(text);
  } catch {
    throw new HttpsError("internal", "Invalid AI response format.");
  }

  const parsed = GeminiCoachAdviceSchema.safeParse(rawJson);
  if (!parsed.success) {
    throw new HttpsError("internal", "AI response failed safety validation.");
  }

  return parsed.data;
}
