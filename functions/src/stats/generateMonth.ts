import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { deadlineGuard, forEachDocument } from "../shared/pagination";
import { logger } from "../shared/logger";

const db = (): Firestore => getFirestore();

const TIMEOUT_SECONDS = 540;

interface FixedItemProjection {
  category: string;
  dueDay: number;
  amountCents: number;
  paid: boolean;
}

/**
 * Monthly scheduler (1st of every month at 00:00 UTC):
 * creates `users/{uid}/months/{YYYY-MM}` from `monthlyIncomeCents` and active `fixedExpenses`.
 * Users are paginated, so every user is visited however many there are.
 */
export const generateMonth = onSchedule(
  {
    schedule: "0 0 1 * *",
    region: "us-central1",
    timeoutSeconds: TIMEOUT_SECONDS,
  },
  async (_event) => {
    const now = new Date();
    const currentMonthKey = `${now.getUTCFullYear()}-${String(now.getUTCMonth() + 1).padStart(2, "0")}`;

    logger.info("running generateMonth scheduler", { currentMonthKey });

    const result = await forEachDocument(
      db().collection("users"),
      (userDoc) => generateUserMonth(userDoc.id, userDoc.data(), currentMonthKey),
      { label: "generateMonth", shouldStop: deadlineGuard(TIMEOUT_SECONDS) }
    );

    logger.info("generateMonth scheduler completed", { currentMonthKey, ...result });
  }
);

async function generateUserMonth(
  uid: string,
  userData: Record<string, unknown>,
  currentMonthKey: string
): Promise<void> {
  const monthRef = db().doc(`users/${uid}/months/${currentMonthKey}`);
  const monthDoc = await monthRef.get();
  if (monthDoc.exists) return;

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
      typeof data.dueDay === "number" ? Math.min(31, Math.max(1, Math.trunc(data.dueDay))) : 1;
    const category = typeof data.category === "string" ? data.category : "other";

    totalFixedCents += amountCents;
    fixedItems[doc.id] = {
      category,
      amountCents,
      dueDay,
      paid: data.payMode === "auto",
    };
  }

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
