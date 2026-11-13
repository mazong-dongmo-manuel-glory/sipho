import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { logger } from "../shared/logger";

const db = (): Firestore => getFirestore();

interface FixedItemProjection {
  category: string;
  dueDay: number;
  amountCents: number;
  paid: boolean;
}

/**
 * Monthly scheduler (1st of every month at 00:00 UTC):
 * creates `users/{uid}/months/{YYYY-MM}` from `monthlyIncomeCents` and active `fixedExpenses`.
 */
export const generateMonth = onSchedule(
  {
    schedule: "0 0 1 * *",
    region: "us-central1",
    timeoutSeconds: 540,
  },
  async (_event) => {
    const now = new Date();
    const currentMonthKey = `${now.getUTCFullYear()}-${String(now.getUTCMonth() + 1).padStart(2, "0")}`;

    logger.info("running generateMonth scheduler", { currentMonthKey });

    const usersSnap = await db().collection("users").limit(500).get();

    for (const userDoc of usersSnap.docs) {
      const uid = userDoc.id;
      const monthRef = db().doc(`users/${uid}/months/${currentMonthKey}`);
      const monthDoc = await monthRef.get();
      if (monthDoc.exists) continue;

      const fixedSnap = await db()
        .collection(`users/${uid}/fixedExpenses`)
        .where("active", "==", true)
        .get();

      let totalFixedCents = 0;
      const fixedItems: Record<string, FixedItemProjection> = {};

      for (const doc of fixedSnap.docs) {
        const data = doc.data();
        const amountCents =
          typeof data.amountCents === "number" ? Math.max(0, Math.trunc(data.amountCents)) : 0;
        const dueDay =
          typeof data.dueDay === "number"
            ? Math.min(31, Math.max(1, Math.trunc(data.dueDay)))
            : 1;
        const category = typeof data.category === "string" ? data.category : "other";

        totalFixedCents += amountCents;
        fixedItems[doc.id] = {
          category,
          amountCents,
          dueDay,
          paid: data.payMode === "auto",
        };
      }

      const userData = userDoc.data();
      const rawIncome =
        typeof userData.monthlyIncomeCents === "number"
          ? userData.monthlyIncomeCents
          : typeof userData.incomeMonthlyCents === "number"
            ? userData.incomeMonthlyCents
            : 0;
      const incomeCents = Math.max(0, Math.trunc(rawIncome));

      await monthRef.set({
        incomeCents,
        totalFixedCents,
        totalVariableCents: 0,
        fixedPaid: fixedItems,
        expenses: {},
        remainingCents: incomeCents - totalFixedCents,
        createdAt: FieldValue.serverTimestamp(),
      });
    }

    logger.info("generateMonth scheduler completed", { currentMonthKey });
  }
);
