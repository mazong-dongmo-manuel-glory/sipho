import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { logger } from "../shared/logger";
import { XP_CONFIG, xpToLevel } from "../shared/xpConfig";
import { idempotencyKey, checkAndMarkIdempotencyKey } from "../shared/idempotency";

const db = () => getFirestore();

/**
 * Triggered on every transaction write (create/update/delete).
 * Responsibilities:
 *   1. Update monthly aggregates (income / expenses by category)
 *   2. Award XP (capped per day) for new transactions
 *   3. Update active quest progress
 *   4. Emit budget alert when spending > threshold
 */
export const onTransactionWrite = onDocumentWritten(
  {
    document: "users/{uid}/transactions/{txId}",
    region: "us-central1",
  },
  async (event) => {
    const uid = event.params.uid;
    const txId = event.params.txId;

    const before = event.data?.before;
    const after = event.data?.after;

    // Skip deletes
    if (!after?.exists) return;

    const tx = after.data() as {
      amountCents: number;
      category: string;
      type: "income" | "expense";
      date: FirebaseFirestore.Timestamp;
      processed?: boolean;
    };

    const ikey = idempotencyKey("onTransactionWrite", uid, txId, after.updateTime?.toMillis().toString() ?? "0");
    if (await checkAndMarkIdempotencyKey(ikey)) return;

    const monthKey = toMonthKey(tx.date.toDate());
    const isNew = !before?.exists;

    const batch = db().batch();

    // ── 1. Monthly aggregates ──────────────────────────────────────────────────
    const monthRef = db().doc(`users/${uid}/months/${monthKey}`);
    const field = tx.type === "income"
      ? `income.${tx.category}`
      : `expenses.${tx.category}`;

    batch.set(
      monthRef,
      { [field]: FieldValue.increment(tx.amountCents), updatedAt: FieldValue.serverTimestamp() },
      { merge: true }
    );

    // ── 2. XP (new transaction only, capped per day) ───────────────────────────
    if (isNew) {
      const today = toDateKey(tx.date.toDate());
      const dailyRef = db().doc(`users/${uid}/dailyXp/${today}`);
      const dailySnap = await dailyRef.get();
      const earnedToday = (dailySnap.data()?.fromTransactions ?? 0) as number;

      if (earnedToday < XP_CONFIG.transactionMax) {
        const xpGain = XP_CONFIG.transactionAdd;
        const gameRef = db().doc(`users/${uid}/game/state`);
        batch.set(gameRef, { xp: FieldValue.increment(xpGain) }, { merge: true });
        batch.set(
          dailyRef,
          { fromTransactions: FieldValue.increment(xpGain) },
          { merge: true }
        );
        logger.info("xp awarded for transaction", { uid, xpGain, today });
      }

      // ── 3. Quest progress ───────────────────────────────────────────────────
      await updateQuestProgress(uid, "ADD_TRANSACTION", 1);
    }

    // ── 4. Budget alert ───────────────────────────────────────────────────────
    if (tx.type === "expense") {
      await checkBudgetAlert(uid, monthKey, tx.category);
    }

    await batch.commit();

    // Update level after XP change
    if (isNew) {
      await recalculateLevel(uid);
    }
  }
);

// ─── Helpers ──────────────────────────────────────────────────────────────────

function toMonthKey(date: Date): string {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}`;
}

function toDateKey(date: Date): string {
  return date.toISOString().slice(0, 10);
}

async function updateQuestProgress(uid: string, type: string, increment: number): Promise<void> {
  const questsSnap = await db()
    .collection(`users/${uid}/quests`)
    .where("type", "==", type)
    .where("status", "==", "active")
    .limit(5)
    .get();

  const batch = db().batch();
  for (const doc of questsSnap.docs) {
    const quest = doc.data() as { target: number; progress: number };
    const newProgress = Math.min(quest.target, (quest.progress ?? 0) + increment);
    const done = newProgress >= quest.target;
    batch.update(doc.ref, {
      progress: newProgress,
      ...(done ? { status: "completed", completedAt: FieldValue.serverTimestamp() } : {}),
    });
  }
  await batch.commit();
}

async function checkBudgetAlert(uid: string, monthKey: string, category: string): Promise<void> {
  const [monthSnap, budgetSnap] = await Promise.all([
    db().doc(`users/${uid}/months/${monthKey}`).get(),
    db().doc(`users/${uid}/budgets/${category}`).get(),
  ]);

  if (!budgetSnap.exists) return;

  const spent = (monthSnap.data()?.expenses?.[category] ?? 0) as number;
  const limit = budgetSnap.data()?.limitCents as number;

  if (spent >= limit * 0.9 && spent < limit) {
    await db().collection(`users/${uid}/alerts`).add({
      type: "BUDGET_WARNING",
      category,
      spentCents: spent,
      limitCents: limit,
      pct: Math.round((spent / limit) * 100),
      createdAt: FieldValue.serverTimestamp(),
      read: false,
    });
    logger.info("budget warning alert created", { uid, category, pct: Math.round((spent / limit) * 100) });
  } else if (spent >= limit) {
    await db().collection(`users/${uid}/alerts`).add({
      type: "BUDGET_EXCEEDED",
      category,
      spentCents: spent,
      limitCents: limit,
      pct: Math.round((spent / limit) * 100),
      createdAt: FieldValue.serverTimestamp(),
      read: false,
    });
    logger.info("budget exceeded alert created", { uid, category });
  }
}

async function recalculateLevel(uid: string): Promise<void> {
  const gameRef = db().doc(`users/${uid}/game/state`);
  const snap = await gameRef.get();
  if (!snap.exists) return;
  const xp = (snap.data()?.xp ?? 0) as number;
  const newLevel = xpToLevel(xp);
  const currentLevel = (snap.data()?.level ?? 0) as number;
  if (newLevel !== currentLevel) {
    await gameRef.update({ level: newLevel });
    logger.info("level up", { uid, newLevel });
  }
}
