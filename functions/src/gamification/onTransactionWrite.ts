import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { getFirestore, FieldValue, Firestore, Timestamp } from "firebase-admin/firestore";
import { logger } from "../shared/logger";
import { XP_CONFIG, xpToLevel } from "../shared/xpConfig";
import {
  idempotencyKey,
  checkAndMarkIdempotencyKey,
  clearIdempotencyKey,
} from "../shared/idempotency";
import {
  computeNextStreak,
  initialGameStatePayload,
  normalizeGameState,
} from "../shared/gameState";
import { localDateKey, resolveUserTime } from "../shared/timezone";
import { bumpFriendChallenges } from "../social/challengeProgress";
import { trackReferralActiveDay } from "../referrals/referralReward";

const db = (): Firestore => getFirestore();

interface StoredTransaction {
  amountCents?: number;
  amountMainCents?: number;
  category?: string;
  date?: string | Timestamp;
  source?: string;
}

/**
 * Triggered on every transaction create/update/delete under `users/{uid}/transactions/{txId}`.
 * Handles:
 *   1. Accurate monthly aggregates (create, edit delta, and delete)
 *   2. Daily-capped XP + streak on creation (never re-awarded on edits). The cap and the streak
 *      are keyed on the SERVER's current local day, never on the user-supplied `date`, so
 *      backdating an expense cannot open a fresh daily cap.
 *   3. Quest progress on creation
 *   4. Budget/envelope alerts (80% warning, 100% exceeded) deduplicated per month & threshold
 */
export const onTransactionWrite = onDocumentWritten(
  {
    document: "users/{uid}/transactions/{txId}",
    region: "us-central1",
  },
  async (event) => {
    const uid = event.params.uid;
    const txId = event.params.txId;
    const eventKey = idempotencyKey("onTransactionWrite", event.id);
    if (await checkAndMarkIdempotencyKey(eventKey)) return;

    try {
      const beforeData = event.data?.before.exists
        ? (event.data.before.data() as StoredTransaction)
        : undefined;
      const afterData = event.data?.after.exists
        ? (event.data.after.data() as StoredTransaction)
        : undefined;

      if (!beforeData && !afterData) return;

      const isCreate = !beforeData && Boolean(afterData);
      const batch = db().batch();

      // ── 1. Monthly aggregates (supports create, update across categories/months, delete) ─
      const touchedCategoryMonths = new Set<string>();

      if (beforeData) {
        const prevCents = effectiveCents(beforeData);
        const prevCat = safeCategory(beforeData.category);
        const prevMonth = extractMonthKey(beforeData.date);
        if (prevCents > 0 && prevMonth) {
          const prevMonthRef = db().doc(`users/${uid}/months/${prevMonth}`);
          batch.set(
            prevMonthRef,
            {
              totalVariableCents: FieldValue.increment(-prevCents),
              expenses: { [prevCat]: FieldValue.increment(-prevCents) },
              updatedAt: FieldValue.serverTimestamp(),
            },
            { merge: true }
          );
        }
      }

      if (afterData) {
        const nextCents = effectiveCents(afterData);
        const nextCat = safeCategory(afterData.category);
        const nextMonth = extractMonthKey(afterData.date);
        if (nextCents > 0 && nextMonth) {
          const nextMonthRef = db().doc(`users/${uid}/months/${nextMonth}`);
          batch.set(
            nextMonthRef,
            {
              totalVariableCents: FieldValue.increment(nextCents),
              expenses: { [nextCat]: FieldValue.increment(nextCents) },
              updatedAt: FieldValue.serverTimestamp(),
            },
            { merge: true }
          );
          touchedCategoryMonths.add(`${nextMonth}::${nextCat}`);
        }
      }

      await batch.commit();

      // ── 2. XP + quest progress on new transaction only ───────────────────────
      if (isCreate && afterData) {
        const dayKey = await recordTransactionActivity(uid, txId, new Date());
        await updateQuestProgress(uid, "ADD_TRANSACTION", 1);
        if (dayKey) {
          await bumpFriendChallenges(uid, "activity_day", dayKey);
          await trackReferralActiveDay(uid, dayKey);
        }
      }

      // ── 3. Budget / envelope alert check ─────────────────────────────────────
      for (const pair of touchedCategoryMonths) {
        const [monthKey, category] = pair.split("::");
        if (monthKey && category) {
          await checkBudgetAlert(uid, monthKey, category);
        }
      }
    } catch (err) {
      // Allow Cloud Functions retries to re-run work if we failed mid-handler.
      await clearIdempotencyKey(eventKey);
      throw err;
    }
  }
);

// ─── Helpers ──────────────────────────────────────────────────────────────────

function effectiveCents(tx: StoredTransaction): number {
  const raw = typeof tx.amountMainCents === "number" ? tx.amountMainCents : tx.amountCents;
  if (typeof raw !== "number" || !Number.isFinite(raw)) return 0;
  const intVal = Math.trunc(raw);
  return intVal > 0 && intVal < 100_000_000 ? intVal : 0;
}

function safeCategory(category?: string): string {
  if (!category || typeof category !== "string") return "other";
  const cleaned = category.trim().replace(/[^a-zA-Z0-9_-]/g, "");
  return cleaned.length > 0 ? cleaned.slice(0, 40) : "other";
}

function extractDateKey(date?: string | Timestamp): string {
  if (typeof date === "string" && /^\d{4}-\d{2}-\d{2}/.test(date)) {
    return date.slice(0, 10);
  }
  if (date && typeof (date as Timestamp).toDate === "function") {
    return (date as Timestamp).toDate().toISOString().slice(0, 10);
  }
  return new Date().toISOString().slice(0, 10);
}

function extractMonthKey(date?: string | Timestamp): string {
  return extractDateKey(date).slice(0, 7);
}

/**
 * Records that the user was active today (server-side local day):
 *  - advances the streak (logging an expense counts, like finishing a lesson),
 *  - awards capped XP (`XP_CONFIG.transactionMax` per local day).
 */
export async function recordTransactionActivity(
  uid: string,
  txId: string,
  now: Date
): Promise<string | null> {
  const userRef = db().doc(`users/${uid}`);
  const gameRef = db().doc(`users/${uid}/game/state`);
  const publicRef = db().doc(`publicProfiles/${uid}`);

  const dayKey = await db().runTransaction(async (t) => {
    const userSnap = await t.get(userRef);
    const dayKey = localDateKey(now, resolveUserTime(userSnap.data()));
    const dailyRef = db().doc(`users/${uid}/dailyXp/${dayKey}`);
    const [dailySnap, gameSnap] = await Promise.all([t.get(dailyRef), t.get(gameRef)]);

    const earnedToday =
      typeof dailySnap.data()?.fromTransactions === "number"
        ? (dailySnap.data()?.fromTransactions as number)
        : 0;
    const xpGain = Math.max(
      0,
      Math.min(XP_CONFIG.transactionAdd, XP_CONFIG.transactionMax - earnedToday)
    );

    const baseGame = gameSnap.exists
      ? normalizeGameState(gameSnap.data())
      : normalizeGameState(initialGameStatePayload());
    const { nextStreak } = computeNextStreak(baseGame.streak, dayKey);
    const streakChanged =
      nextStreak.current !== baseGame.streak.current ||
      nextStreak.lastActiveDay !== baseGame.streak.lastActiveDay;

    if (xpGain === 0 && !streakChanged) return dayKey;

    const newXp = baseGame.xp + xpGain;
    const newLevel = xpToLevel(newXp);

    t.set(
      gameRef,
      {
        xp: newXp,
        level: newLevel,
        gems: baseGame.gems,
        weeklyXp: baseGame.weeklyXp + xpGain,
        streak: nextStreak,
        leagueId: baseGame.leagueId,
        badges: baseGame.badges,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    if (xpGain > 0) {
      t.set(
        dailyRef,
        { fromTransactions: earnedToday + xpGain, updatedAt: FieldValue.serverTimestamp() },
        { merge: true }
      );
    }

    if (streakChanged) {
      t.set(
        publicRef,
        {
          level: newLevel,
          streak: nextStreak.current,
          league: baseGame.leagueId,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    }

    t.set(
      userRef,
      { lastActiveDate: dayKey, lastActiveAt: FieldValue.serverTimestamp() },
      { merge: true }
    );

    logger.info("transaction activity recorded", {
      uid,
      txId,
      xpGain,
      dayKey,
      streak: nextStreak.current,
    });
    return dayKey;
  });

  return dayKey;
}

async function updateQuestProgress(uid: string, type: string, increment: number): Promise<void> {
  const questsSnap = await db()
    .collection(`users/${uid}/quests`)
    .where("type", "==", type)
    .where("status", "==", "active")
    .limit(5)
    .get();

  if (questsSnap.empty) return;

  const nowMs = Date.now();
  const batch = db().batch();
  let touched = 0;
  for (const doc of questsSnap.docs) {
    const quest = doc.data() as { target?: number; progress?: number; expiresAt?: Timestamp };
    if (quest.expiresAt && quest.expiresAt.toMillis() <= nowMs) continue;
    touched += 1;
    const target = Math.max(1, quest.target ?? 1);
    const newProgress = Math.min(target, (quest.progress ?? 0) + increment);
    const done = newProgress >= target;
    batch.update(doc.ref, {
      progress: newProgress,
      ...(done ? { status: "completed", completedAt: FieldValue.serverTimestamp() } : {}),
    });
  }
  if (touched > 0) await batch.commit();
}

async function resolveCategoryLimitCents(uid: string, category: string): Promise<number | null> {
  const budgetSnap = await db().doc(`users/${uid}/budgets/${category}`).get();
  const budgetData = budgetSnap.data() as { limitCents?: unknown } | undefined;
  const explicitLimit = budgetData?.limitCents;
  if (typeof explicitLimit === "number" && explicitLimit > 0) {
    return Math.trunc(explicitLimit);
  }

  // Fallback: active envelope in `fixedExpenses` for this category.
  const envSnap = await db()
    .collection(`users/${uid}/fixedExpenses`)
    .where("active", "==", true)
    .where("type", "==", "envelope")
    .where("category", "==", category)
    .limit(1)
    .get();

  const envData = envSnap.docs[0]?.data() as { amountCents?: unknown } | undefined;
  const envAmount = envData?.amountCents;
  if (typeof envAmount === "number" && envAmount > 0) {
    return Math.trunc(envAmount);
  }
  return null;
}

async function checkBudgetAlert(uid: string, monthKey: string, category: string): Promise<void> {
  const [monthSnap, userSnap, limitCents] = await Promise.all([
    db().doc(`users/${uid}/months/${monthKey}`).get(),
    db().doc(`users/${uid}`).get(),
    resolveCategoryLimitCents(uid, category),
  ]);

  if (!limitCents || limitCents <= 0) return;

  const expensesMap = monthSnap.data()?.expenses as Record<string, unknown> | undefined;
  const rawSpent = expensesMap?.[category];
  const spent = typeof rawSpent === "number" ? Math.max(0, Math.trunc(rawSpent)) : 0;
  if (spent <= 0) return;

  const pct = Math.round((spent / limitCents) * 100);
  const locale = userSnap.data()?.locale === "en" ? "en" : "fr";

  const alertType =
    spent >= limitCents
      ? "BUDGET_EXCEEDED"
      : spent >= limitCents * 0.8
        ? "BUDGET_WARNING"
        : null;
  if (!alertType) return;

  // Deterministic ID prevents spamming the user on every subsequent purchase in the same month.
  const alertId = `${monthKey}_${category}_${alertType}`;
  const alertRef = db().doc(`users/${uid}/alerts/${alertId}`);
  const existing = await alertRef.get();
  if (existing.exists) return;

  await alertRef.set({
    type: alertType,
    category,
    monthKey,
    pct,
    locale,
    pushed: false,
    read: false,
    createdAt: FieldValue.serverTimestamp(),
  });

  logger.info("budget alert created", { uid, category, alertType, pct });
}
