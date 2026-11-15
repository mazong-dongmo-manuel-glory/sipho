import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { ReferralRedeemInputSchema } from "../shared/validators";
import { XP_CONFIG, xpToLevel } from "../shared/xpConfig";
import {
  SECURE_CALLABLE_OPTIONS,
  enforceRateLimit,
  parseInput,
  requireAuthUid,
} from "../shared/security";
import { initialGameStatePayload, normalizeGameState } from "../shared/gameState";
import { friendPairId } from "../shared/friends";
import { logger } from "../shared/logger";

const db = (): Firestore => getFirestore();

/**
 * Callable (v2, authenticated): redeem a referral code atomically.
 * - Cannot redeem your own code
 * - Each user can redeem at most ONE referral code ever. The source of truth is the
 *   server-only marker `users/{uid}/referral/redemption` (clients cannot write it); the
 *   `redeemedReferralCode` profile field is a convenience copy that clients cannot modify either
 *   (see firestore.rules `touchesServerOnlyUserFields`).
 * - Awards server-side XP to both inviter and invitee
 */
export const referralRedeem = onCall(SECURE_CALLABLE_OPTIONS, async (request) => {
  const uid = requireAuthUid(request);
  const { referralCode } = parseInput(ReferralRedeemInputSchema, request.data);

  await enforceRateLimit({
    uid,
    action: "referralRedeem",
    maxRequests: 10,
    windowMs: 24 * 60 * 60 * 1000,
  });

  const referralRef = db().doc(`referrals/${referralCode}`);
  const inviteeUserRef = db().doc(`users/${uid}`);
  const inviteeGameRef = db().doc(`users/${uid}/game/state`);
  const redemptionRef = db().doc(`users/${uid}/referral/redemption`);

  await db().runTransaction(async (tx) => {
    const [referralSnap, inviteeUserSnap, inviteeGameSnap, redemptionSnap] = await Promise.all([
      tx.get(referralRef),
      tx.get(inviteeUserRef),
      tx.get(inviteeGameRef),
      tx.get(redemptionRef),
    ]);

    if (!referralSnap.exists) {
      throw new HttpsError("not-found", "Referral code not found.");
    }
    const codeOwner = (referralSnap.data() as { ownerUid?: unknown }).ownerUid;
    const friendRef =
      typeof codeOwner === "string" ? db().doc(`friendships/${friendPairId(uid, codeOwner)}`) : null;
    const friendSnap = friendRef ? await tx.get(friendRef) : null;

    const refData = referralSnap.data() as {
      ownerUid?: unknown;
      uses?: unknown;
      maxUses?: unknown;
    };

    const ownerUid = typeof refData.ownerUid === "string" ? refData.ownerUid : "";
    if (!ownerUid || ownerUid === uid) {
      throw new HttpsError("invalid-argument", "Cannot redeem your own code.");
    }

    if (redemptionSnap.exists || inviteeUserSnap.data()?.redeemedReferralCode) {
      throw new HttpsError("already-exists", "You have already redeemed a referral code.");
    }

    const uses = Array.isArray(refData.uses)
      ? refData.uses.filter((u): u is string => typeof u === "string")
      : [];
    if (uses.includes(uid)) {
      throw new HttpsError("already-exists", "Referral code already used.");
    }

    const maxUses = typeof refData.maxUses === "number" ? refData.maxUses : 50;
    if (uses.length >= maxUses) {
      throw new HttpsError("resource-exhausted", "Referral code has reached its limit.");
    }

    const inviterGameRef = db().doc(`users/${ownerUid}/game/state`);
    const inviterGameSnap = await tx.get(inviterGameRef);

    const inviteeBase = inviteeGameSnap.exists
      ? normalizeGameState(inviteeGameSnap.data())
      : normalizeGameState(initialGameStatePayload());
    const inviterBase = inviterGameSnap.exists
      ? normalizeGameState(inviterGameSnap.data())
      : normalizeGameState(initialGameStatePayload());

    const inviteeXp = inviteeBase.xp + XP_CONFIG.referralInvitee;
    const inviterXp = inviterBase.xp + XP_CONFIG.referralInviter;

    tx.update(referralRef, {
      uses: FieldValue.arrayUnion(uid),
      updatedAt: FieldValue.serverTimestamp(),
    });

    tx.set(redemptionRef, {
      referralCode,
      ownerUid,
      redeemedAt: FieldValue.serverTimestamp(),
    });

    // Inviter and invitee become friends right away (no request needed: the invitation was it).
    if (friendRef && friendSnap?.data()?.status !== "accepted") {
      if (friendSnap?.exists) {
        tx.update(friendRef, { status: "accepted", acceptedAt: FieldValue.serverTimestamp() });
      } else {
        tx.set(friendRef, {
          users: [uid, ownerUid].sort(),
          status: "accepted",
          requesterUid: ownerUid,
          via: "referral",
          createdAt: FieldValue.serverTimestamp(),
          acceptedAt: FieldValue.serverTimestamp(),
        });
      }
    }

    tx.set(
      inviteeUserRef,
      {
        redeemedReferralCode: referralCode,
        referredByUid: ownerUid,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    tx.set(
      inviteeGameRef,
      {
        xp: inviteeXp,
        level: xpToLevel(inviteeXp),
        gems: inviteeBase.gems + 5,
        weeklyXp: inviteeBase.weeklyXp + XP_CONFIG.referralInvitee,
        streak: inviteeBase.streak,
        leagueId: inviteeBase.leagueId,
        badges: inviteeBase.badges,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    tx.set(
      inviterGameRef,
      {
        xp: inviterXp,
        level: xpToLevel(inviterXp),
        gems: inviterBase.gems + 10,
        weeklyXp: inviterBase.weeklyXp + XP_CONFIG.referralInviter,
        streak: inviterBase.streak,
        leagueId: inviterBase.leagueId,
        badges: inviterBase.badges,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  });

  logger.info("referral redeemed successfully", { uid, referralCode });
  return {
    success: true,
    xpGained: XP_CONFIG.referralInvitee,
  };
});
