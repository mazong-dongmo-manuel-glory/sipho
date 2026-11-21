import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { MarkFixedPaidInputSchema } from "../shared/validators";
import { XP_CONFIG, xpToLevel } from "../shared/xpConfig";
import { idempotencyKey, encodeKey } from "../shared/idempotency";
import {
  SECURE_CALLABLE_OPTIONS,
  enforceRateLimit,
  parseInput,
  requireAuthUid,
} from "../shared/security";
import { initialGameStatePayload, normalizeGameState } from "../shared/gameState";
import { localDateKey, resolveUserTime } from "../shared/timezone";
import { logger } from "../shared/logger";
import { bumpFriendChallenges } from "../social/challengeProgress";

const db = (): Firestore => getFirestore();

/**
 * Callable: mark a fixed expense from `users/{uid}/fixedExpenses/{fixedId}`
 * as paid for the user's CURRENT local month and award server-side XP once per bill per month.
 *
 * Anti-abuse:
 *  - `monthKey` must be the current local month (no inventing past / future months),
 *  - only active bills can be paid (envelopes are budgets, not bills),
 *  - XP is capped per local day, so deleting and re-creating bills cannot farm XP.
 */
export const markFixedPaid = onCall(SECURE_CALLABLE_OPTIONS, async (request) => {
  const uid = requireAuthUid(request);
  const { fixedId, monthKey } = parseInput(MarkFixedPaidInputSchema, request.data);

  await enforceRateLimit({
    uid,
    action: "markFixedPaid",
    maxRequests: 30,
    windowMs: 60 * 60 * 1000,
  });

  const userRef = db().doc(`users/${uid}`);
  const fixedRef = db().doc(`users/${uid}/fixedExpenses/${fixedId}`);
  const monthFixedRef = db().doc(`users/${uid}/months/${monthKey}/fixed/${fixedId}`);
  const monthRef = db().doc(`users/${uid}/months/${monthKey}`);
  const gameRef = db().doc(`users/${uid}/game/state`);
  const idemKey = idempotencyKey("markFixedPaid", uid, fixedId, monthKey);
  const idemRef = db().collection("_idempotency").doc(encodeKey(idemKey));
  const now = new Date();

  const outcome = await db().runTransaction(async (tx) => {
    const [userSnap, fixedSnap, idemSnap, gameSnap] = await Promise.all([
      tx.get(userRef),
      tx.get(fixedRef),
      tx.get(idemRef),
      tx.get(gameRef),
    ]);

    const today = localDateKey(now, resolveUserTime(userSnap.data()));
    if (monthKey !== today.slice(0, 7)) {
      throw new HttpsError(
        "failed-precondition",
        "Only the current month can be marked as paid."
      );
    }

    if (!fixedSnap.exists) {
      throw new HttpsError("not-found", "Fixed expense not found.");
    }
    const fixed = fixedSnap.data() as { active?: unknown; type?: unknown };
    if (fixed.active === false || fixed.type === "envelope") {
      throw new HttpsError("failed-precondition", "This expense cannot be marked as paid.");
    }

    if (idemSnap.exists) {
      return { xpGained: 0, levelUp: false, alreadyPaid: true };
    }

    const dailyRef = db().doc(`users/${uid}/dailyXp/${today}`);
    const dailySnap = await tx.get(dailyRef);
    const earnedToday =
      typeof dailySnap.data()?.fromFixedPaid === "number"
        ? (dailySnap.data()?.fromFixedPaid as number)
        : 0;

    const baseGame = gameSnap.exists
      ? normalizeGameState(gameSnap.data())
      : normalizeGameState(initialGameStatePayload());

    const xpGained = Math.max(
      0,
      Math.min(XP_CONFIG.fixedPaid, XP_CONFIG.fixedPaidMax - earnedToday)
    );
    const newXp = baseGame.xp + xpGained;
    const newLevel = xpToLevel(newXp);
    const levelUp = newLevel > baseGame.level;

    tx.set(idemRef, {
      key: idemKey,
      processedAt: FieldValue.serverTimestamp(),
    });

    tx.set(
      monthFixedRef,
      { paidAt: FieldValue.serverTimestamp(), paid: true },
      { merge: true }
    );

    // NOTE: `set()` does not interpret dotted keys as field paths (only `update()` does), so
    // the nested map must be written explicitly or the month doc would get literal "a.b.c" keys.
    tx.set(
      monthRef,
      {
        fixedPaid: {
          [fixedId]: { paid: true, paidAt: FieldValue.serverTimestamp() },
        },
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    if (xpGained > 0) {
      tx.set(
        dailyRef,
        { fromFixedPaid: earnedToday + xpGained, updatedAt: FieldValue.serverTimestamp() },
        { merge: true }
      );
      tx.set(
        gameRef,
        {
          xp: newXp,
          level: newLevel,
          gems: baseGame.gems,
          weeklyXp: baseGame.weeklyXp + xpGained,
          streak: baseGame.streak,
          leagueId: baseGame.leagueId,
          badges: baseGame.badges,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    }

    return { xpGained, levelUp, alreadyPaid: false };
  });

  if (!outcome.alreadyPaid) {
    await bumpFriendChallenges(uid, "fixed_paid");
  }

  logger.info("fixed expense marked paid", {
    uid,
    fixedId,
    monthKey,
    xpGained: outcome.xpGained,
    alreadyPaid: outcome.alreadyPaid,
  });

  return outcome;
});
