import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { logger } from "../shared/logger";
import { XP_CONFIG, xpToLevel } from "../shared/xpConfig";
import { initialGameStatePayload, normalizeGameState } from "../shared/gameState";
import {
  BudgetDayOutcome,
  effectiveTransactionCents,
  evaluateBudgetDay,
  readMonthlyIncomeCents,
} from "../shared/budgetDay";

const db = (): Firestore => getFirestore();

/** Upper bound of expenses read per day; more expenses can only raise the total, never lower it. */
const MAX_DAY_TRANSACTIONS = 500;

export type BudgetDayResult = BudgetDayOutcome | "already-awarded";

/**
 * Evaluates one finished local day (`dayKey`) and, when the user stayed under their daily budget,
 * awards `XP_CONFIG.budgetDayUnder` XP exactly once (marker `dailyXp/{dayKey}.fromBudgetDay`).
 *
 * Called by `dailyRollover` for the day that just ended. It is idempotent: a retry or a second
 * call for the same day changes nothing.
 */
export async function awardBudgetDayIfEarned(
  uid: string,
  userData: Record<string, unknown>,
  dayKey: string
): Promise<BudgetDayResult> {
  const incomeCents = readMonthlyIncomeCents(userData);
  if (incomeCents <= 0) return "no-budget";

  const dailyRef = db().doc(`users/${uid}/dailyXp/${dayKey}`);
  const alreadyDaily = await dailyRef.get();
  if (typeof alreadyDaily.data()?.fromBudgetDay === "number") return "already-awarded";

  const [fixedSnap, txSnap] = await Promise.all([
    db().collection(`users/${uid}/fixedExpenses`).where("active", "==", true).get(),
    db()
      .collection(`users/${uid}/transactions`)
      .where("date", "==", dayKey)
      .limit(MAX_DAY_TRANSACTIONS)
      .get(),
  ]);

  let fixedCents = 0;
  for (const doc of fixedSnap.docs) {
    const amount = (doc.data() as { amountCents?: unknown }).amountCents;
    if (typeof amount === "number" && Number.isFinite(amount)) {
      fixedCents += Math.max(0, Math.trunc(amount));
    }
  }

  let spentCents = 0;
  let expenseCount = 0;
  for (const doc of txSnap.docs) {
    const cents = effectiveTransactionCents(doc.data());
    if (cents > 0) {
      spentCents += cents;
      expenseCount += 1;
    }
  }

  const outcome = evaluateBudgetDay({
    incomeCents,
    fixedCents,
    dayKey,
    spentCents,
    expenseCount,
    noSpendConfirmed: alreadyDaily.data()?.noSpend === true,
  });
  if (outcome !== "under") return outcome;

  const gameRef = db().doc(`users/${uid}/game/state`);
  const publicRef = db().doc(`publicProfiles/${uid}`);
  const xp = XP_CONFIG.budgetDayUnder;

  const awarded = await db().runTransaction(async (tx) => {
    const [dailySnap, gameSnap] = await Promise.all([tx.get(dailyRef), tx.get(gameRef)]);
    if (typeof dailySnap.data()?.fromBudgetDay === "number") return false;

    const base = gameSnap.exists
      ? normalizeGameState(gameSnap.data())
      : normalizeGameState(initialGameStatePayload());
    const newXp = base.xp + xp;
    const newLevel = xpToLevel(newXp);

    tx.set(
      gameRef,
      {
        xp: newXp,
        level: newLevel,
        gems: base.gems,
        weeklyXp: base.weeklyXp + xp,
        streak: base.streak,
        badges: base.badges,
        leagueId: base.leagueId,
        // Lets the client show the reward and celebrate it (game/state is already streamed).
        lastBudgetDay: { dayKey, xp },
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
    tx.set(
      dailyRef,
      { fromBudgetDay: xp, updatedAt: FieldValue.serverTimestamp() },
      { merge: true }
    );
    tx.set(
      publicRef,
      { level: newLevel, league: base.leagueId, updatedAt: FieldValue.serverTimestamp() },
      { merge: true }
    );
    return true;
  });

  if (!awarded) return "already-awarded";
  logger.info("budget day awarded", { uid, dayKey, spentCents, fixedCents, xp });
  return "under";
}
