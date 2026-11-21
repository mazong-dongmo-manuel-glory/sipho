import {
  getFirestore,
  FieldValue,
  Transaction,
} from "firebase-admin/firestore";
import { xpToLevel } from "../shared/xpConfig";
import {
  ChallengeMetric,
  templateById,
} from "../shared/friendChallenges";
import {
  initialGameStatePayload,
  normalizeGameState,
} from "../shared/gameState";
import { logger } from "../shared/logger";

const db = () => getFirestore();

/**
 * Bumps every active challenge for `uid` whose metric matches.
 * Progress is +1 per call (one lesson, one budget day, one fixed paid, one activity day).
 * First player to reach the target wins and receives `rewardXp` (counts toward weeklyXp).
 *
 * Failures are logged and swallowed so a challenge bug never blocks XP / streaks.
 */
export async function bumpFriendChallenges(
  uid: string,
  metric: ChallengeMetric,
  dayKey?: string
): Promise<void> {
  try {
    await bumpFriendChallengesUnsafe(uid, metric, dayKey);
  } catch (err) {
    logger.error("friend challenge progress failed", {
      uid,
      metric,
      err: String(err),
    });
  }
}

async function bumpFriendChallengesUnsafe(
  uid: string,
  metric: ChallengeMetric,
  dayKey?: string
): Promise<void> {
  const pointers = await db()
    .collection(`users/${uid}/challengePointers`)
    .where("metric", "==", metric)
    .where("status", "==", "active")
    .limit(10)
    .get();

  if (pointers.empty) return;

  for (const pointer of pointers.docs) {
    const data = pointer.data() as {
      pairId?: unknown;
      challengeId?: unknown;
      lastDayKey?: unknown;
    };
    const pairId = typeof data.pairId === "string" ? data.pairId : "";
    const challengeId =
      typeof data.challengeId === "string" ? data.challengeId : pointer.id;
    if (!pairId || !challengeId) continue;

    // activity_day / budget_day: at most once per local day per challenge.
    if (
      dayKey &&
      (metric === "activity_day" || metric === "budget_day") &&
      data.lastDayKey === dayKey
    ) {
      continue;
    }

    await applyProgress(uid, pairId, challengeId, dayKey);
  }
}

async function applyProgress(
  uid: string,
  pairId: string,
  challengeId: string,
  dayKey?: string
): Promise<void> {
  const challengeRef = db().doc(
    `friendships/${pairId}/challenges/${challengeId}`
  );

  await db().runTransaction(async (tx) => {
    const snap = await tx.get(challengeRef);
    if (!snap.exists) {
      tx.delete(db().doc(`users/${uid}/challengePointers/${challengeId}`));
      return;
    }

    const c = snap.data() as {
      status?: unknown;
      senderUid?: unknown;
      receiverUid?: unknown;
      senderProgress?: unknown;
      receiverProgress?: unknown;
      targetCount?: unknown;
      rewardXp?: unknown;
      templateId?: unknown;
      expiresAt?: unknown;
      rewarded?: unknown;
    };

    if (c.status !== "active") {
      tx.delete(db().doc(`users/${uid}/challengePointers/${challengeId}`));
      return;
    }

    const expiresAt = readDate(c.expiresAt);
    if (expiresAt && expiresAt.getTime() < Date.now()) {
      tx.update(challengeRef, {
        status: "expired",
        updatedAt: FieldValue.serverTimestamp(),
      });
      clearPointers(tx, challengeId, c.senderUid, c.receiverUid);
      return;
    }

    const senderUid = typeof c.senderUid === "string" ? c.senderUid : "";
    const receiverUid = typeof c.receiverUid === "string" ? c.receiverUid : "";
    if (uid !== senderUid && uid !== receiverUid) return;

    const isSender = uid === senderUid;
    const field = isSender ? "senderProgress" : "receiverProgress";
    const current = Math.max(
      0,
      Math.trunc(Number(isSender ? c.senderProgress : c.receiverProgress) || 0)
    );
    const target = Math.max(1, Math.trunc(Number(c.targetCount) || 1));
    if (current >= target) return;

    const next = current + 1;
    const won = next >= target;
    const rewardXp = Math.max(
      0,
      Math.trunc(
        Number(c.rewardXp) ||
          templateById(typeof c.templateId === "string" ? c.templateId : "")
            ?.rewardXp ||
          0
      )
    );
    const shouldAward = won && rewardXp > 0 && c.rewarded !== true;

    // Firestore requires every read before any write in a transaction.
    // Prefetch game state when this bump would grant the winner XP.
    const gameRef = db().doc(`users/${uid}/game/state`);
    const publicRef = db().doc(`publicProfiles/${uid}`);
    const gameSnap = shouldAward ? await tx.get(gameRef) : null;

    const patch: Record<string, unknown> = {
      [field]: next,
      updatedAt: FieldValue.serverTimestamp(),
    };

    if (won) {
      patch.status = "completed";
      patch.winnerUid = uid;
      patch.completedAt = FieldValue.serverTimestamp();
      if (shouldAward) patch.rewarded = true;
    }

    tx.update(challengeRef, patch);

    const myPointer = db().doc(`users/${uid}/challengePointers/${challengeId}`);
    if (dayKey) {
      tx.set(myPointer, { lastDayKey: dayKey }, { merge: true });
    }

    if (!shouldAward) {
      if (won) clearPointers(tx, challengeId, senderUid, receiverUid);
      return;
    }

    const base = gameSnap?.exists
      ? normalizeGameState(gameSnap.data())
      : normalizeGameState(initialGameStatePayload());
    const newXp = base.xp + rewardXp;
    const level = xpToLevel(newXp);

    tx.set(
      gameRef,
      {
        xp: newXp,
        level,
        gems: base.gems,
        weeklyXp: base.weeklyXp + rewardXp,
        streak: base.streak,
        badges: base.badges,
        leagueId: base.leagueId,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
    tx.set(
      publicRef,
      { level, updatedAt: FieldValue.serverTimestamp() },
      { merge: true }
    );
    clearPointers(tx, challengeId, senderUid, receiverUid);

    logger.info("friend challenge won", { uid, pairId, challengeId, rewardXp });
  });
}

function clearPointers(
  tx: Transaction,
  challengeId: string,
  senderUid: unknown,
  receiverUid: unknown
): void {
  if (typeof senderUid === "string" && senderUid) {
    tx.delete(db().doc(`users/${senderUid}/challengePointers/${challengeId}`));
  }
  if (typeof receiverUid === "string" && receiverUid) {
    tx.delete(db().doc(`users/${receiverUid}/challengePointers/${challengeId}`));
  }
}

function readDate(value: unknown): Date | null {
  if (!value) return null;
  if (value instanceof Date) return value;
  if (
    typeof value === "object" &&
    value !== null &&
    typeof (value as { toDate?: unknown }).toDate === "function"
  ) {
    return (value as { toDate: () => Date }).toDate();
  }
  if (typeof value === "string") {
    const parsed = Date.parse(value);
    return Number.isFinite(parsed) ? new Date(parsed) : null;
  }
  return null;
}
