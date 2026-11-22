import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { z } from "zod";
import {
  SECURE_CALLABLE_OPTIONS,
  enforceRateLimit,
  parseInput,
  requireAuthUid,
} from "../shared/security";
import { ReferralRedeemInputSchema } from "../shared/validators";
import {
  INVITE_CODE_MAX_USES,
  MAX_FRIEND_LINKS,
  canRespondToRequest,
  classifyFriendRequest,
  friendPairId,
  inviteCodeFor,
} from "../shared/friends";
import { logger } from "../shared/logger";

const db = (): Firestore => getFirestore();

const PairIdSchema = z
  .string()
  .trim()
  .min(3)
  .max(200)
  .regex(/^[A-Za-z0-9_-]+$/, "Invalid pairId");

const RespondInputSchema = z.object({ pairId: PairIdSchema, accept: z.boolean() });
const RemoveInputSchema = z.object({ pairId: PairIdSchema });

/** Friend links (pending + accepted) the user already has. */
export async function countFriendLinks(uid: string): Promise<number> {
  const snap = await db()
    .collection("friendships")
    .where("users", "array-contains", uid)
    .count()
    .get();
  return snap.data().count;
}

export async function assertFriendCapacity(...uids: string[]): Promise<void> {
  for (const id of uids) {
    if ((await countFriendLinks(id)) >= MAX_FRIEND_LINKS) {
      throw new HttpsError("resource-exhausted", "Friend list is full.");
    }
  }
}

/**
 * Callable: the caller's invite code (also their friend code). Created on first use together with
 * its `referrals/{code}` document, which `referralRedeem` consumes. Stable afterwards.
 */
export const getInviteCode = onCall(SECURE_CALLABLE_OPTIONS, async (request) => {
  const uid = requireAuthUid(request);

  await enforceRateLimit({
    uid,
    action: "getInviteCode",
    maxRequests: 30,
    windowMs: 60 * 60 * 1000,
  });

  const codeRef = db().doc(`users/${uid}/referral/code`);

  const code = await db().runTransaction(async (tx) => {
    const existing = await tx.get(codeRef);
    const stored = (existing.data() as { code?: unknown } | undefined)?.code;
    if (typeof stored === "string" && stored.length > 0) return stored;

    for (let attempt = 0; attempt < 5; attempt++) {
      const candidate = inviteCodeFor(uid, attempt);
      const referralRef = db().doc(`referrals/${candidate}`);
      const referralSnap = await tx.get(referralRef);
      const owner = (referralSnap.data() as { ownerUid?: unknown } | undefined)?.ownerUid;

      if (referralSnap.exists && owner !== uid) continue; // collision with someone else's code

      if (!referralSnap.exists) {
        tx.set(referralRef, {
          ownerUid: uid,
          uses: [],
          maxUses: INVITE_CODE_MAX_USES,
          createdAt: FieldValue.serverTimestamp(),
        });
      }
      tx.set(codeRef, { code: candidate, createdAt: FieldValue.serverTimestamp() });
      return candidate;
    }
    throw new HttpsError("internal", "Could not allocate an invite code.");
  });

  return { code };
});

/**
 * Callable: asks the owner of `code` to become friends. A request that crosses an incoming one
 * is accepted on the spot. Friends only ever see each other's public profile (no amounts).
 */
export const sendFriendRequest = onCall(SECURE_CALLABLE_OPTIONS, async (request) => {
  const uid = requireAuthUid(request);
  const { referralCode: code } = parseInput(ReferralRedeemInputSchema, request.data);

  await enforceRateLimit({
    uid,
    action: "sendFriendRequest",
    maxRequests: 20,
    windowMs: 24 * 60 * 60 * 1000,
  });

  const referralSnap = await db().doc(`referrals/${code}`).get();
  const ownerUid = (referralSnap.data() as { ownerUid?: unknown } | undefined)?.ownerUid;
  if (!referralSnap.exists || typeof ownerUid !== "string") {
    throw new HttpsError("not-found", "Friend code not found.");
  }

  return createFriendRequest(uid, ownerUid, "code");
});

/**
 * Shared by every way of asking someone to be friends (code, contacts): enforces the self / limit
 * rules and the pending / accepted state machine. A request that crosses an incoming one is
 * accepted on the spot.
 */
export async function createFriendRequest(
  uid: string,
  otherUid: string,
  via: "code" | "contacts"
): Promise<{ pairId: string; status: "pending" | "accepted" }> {
  if (otherUid === uid) {
    throw new HttpsError("invalid-argument", "You cannot add yourself.");
  }

  await assertFriendCapacity(uid, otherUid);

  const pairId = friendPairId(uid, otherUid);
  const pairRef = db().doc(`friendships/${pairId}`);

  const status = await db().runTransaction(async (tx) => {
    const snap = await tx.get(pairRef);
    const action = classifyFriendRequest(
      snap.data() as { status?: unknown; requesterUid?: unknown } | undefined,
      uid
    );

    switch (action) {
      case "already-friends":
        throw new HttpsError("already-exists", "You are already friends.");
      case "already-pending":
        throw new HttpsError("already-exists", "Request already sent.");
      case "auto-accept":
        tx.update(pairRef, { status: "accepted", acceptedAt: FieldValue.serverTimestamp() });
        return "accepted" as const;
      case "create":
        tx.set(pairRef, {
          users: [uid, otherUid].sort(),
          status: "pending",
          requesterUid: uid,
          createdAt: FieldValue.serverTimestamp(),
        });
        return "pending" as const;
    }
  });

  logger.info("friend request", { uid, pairId, status, via });
  return { pairId, status };
}

/** Callable: the recipient accepts or declines a pending friend request. */
export const respondFriendRequest = onCall(SECURE_CALLABLE_OPTIONS, async (request) => {
  const uid = requireAuthUid(request);
  const { pairId, accept } = parseInput(RespondInputSchema, request.data);

  await enforceRateLimit({
    uid,
    action: "respondFriendRequest",
    maxRequests: 60,
    windowMs: 24 * 60 * 60 * 1000,
  });

  const pairRef = db().doc(`friendships/${pairId}`);

  if (accept) {
    const snap = await pairRef.get();
    const users = (snap.data() as { users?: unknown } | undefined)?.users;
    const otherUid =
      Array.isArray(users) && typeof users.find((u) => u !== uid) === "string"
        ? (users.find((u) => u !== uid) as string)
        : "";
    await assertFriendCapacity(uid, ...(otherUid ? [otherUid] : []));
  }

  await db().runTransaction(async (tx) => {
    const snap = await tx.get(pairRef);
    const data = snap.data();
    if (!snap.exists || !data) {
      throw new HttpsError("not-found", "Friend request not found.");
    }
    if (!canRespondToRequest(data, uid)) {
      throw new HttpsError("failed-precondition", "This request cannot be answered.");
    }
    if (accept) {
      tx.update(pairRef, { status: "accepted", acceptedAt: FieldValue.serverTimestamp() });
    } else {
      tx.delete(pairRef);
    }
  });

  logger.info("friend request answered", { uid, pairId, accept });
  return { pairId, status: accept ? "accepted" : "declined" };
});

/** Callable: removes a friend, or cancels / declines a pending request. */
export const removeFriend = onCall(SECURE_CALLABLE_OPTIONS, async (request) => {
  const uid = requireAuthUid(request);
  const { pairId } = parseInput(RemoveInputSchema, request.data);

  await enforceRateLimit({
    uid,
    action: "removeFriend",
    maxRequests: 60,
    windowMs: 24 * 60 * 60 * 1000,
  });

  const pairRef = db().doc(`friendships/${pairId}`);
  const snap = await pairRef.get();
  const users = (snap.data() as { users?: unknown } | undefined)?.users;
  if (!snap.exists || !Array.isArray(users) || !users.includes(uid)) {
    throw new HttpsError("not-found", "Friendship not found.");
  }

  await pairRef.delete();
  logger.info("friend removed", { uid, pairId });
  return { pairId };
});
