import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { XP_CONFIG, xpToLevel } from "../shared/xpConfig";
import {
  initialGameStatePayload,
  normalizeGameState,
} from "../shared/gameState";
import { logger } from "../shared/logger";

const db = () => getFirestore();

/** Distinct local active days before the delayed referral reward unlocks. */
export const REFERRAL_ACTIVE_DAYS_REQUIRED = 7;

/**
 * Records one local active day toward a pending referral reward for the invitee.
 * When the invitee reaches 7 distinct active days, awards:
 * - inviter: XP_CONFIG.referralInviter XP + gems + rare chest flag (NOT weeklyXp)
 * - invitee: XP_CONFIG.referralInvitee XP + gems (NOT weeklyXp)
 *
 * Safe to call often; failures are logged and never throw to the caller.
 */
export async function trackReferralActiveDay(
  inviteeUid: string,
  dayKey: string
): Promise<void> {
  try {
    await trackReferralActiveDayUnsafe(inviteeUid, dayKey);
  } catch (err) {
    logger.error("referral active day tracking failed", {
      inviteeUid,
      dayKey,
      err: String(err),
    });
  }
}

async function trackReferralActiveDayUnsafe(
  inviteeUid: string,
  dayKey: string
): Promise<void> {
  const redemptionRef = db().doc(`users/${inviteeUid}/referral/redemption`);

  await db().runTransaction(async (tx) => {
    const redemptionSnap = await tx.get(redemptionRef);
    if (!redemptionSnap.exists) return;

    const data = redemptionSnap.data() as {
      status?: unknown;
      ownerUid?: unknown;
      activeDays?: unknown;
      rewardedAt?: unknown;
    };

    if (data.status === "rewarded" || data.rewardedAt) return;
    if (data.status !== "pending") return;

    const ownerUid = typeof data.ownerUid === "string" ? data.ownerUid : "";
    if (!ownerUid) return;

    const days = Array.isArray(data.activeDays)
      ? data.activeDays.filter((d): d is string => typeof d === "string")
      : [];
    if (days.includes(dayKey)) return;

    const nextDays = [...days, dayKey].slice(-30);
    if (nextDays.length < REFERRAL_ACTIVE_DAYS_REQUIRED) {
      tx.set(
        redemptionRef,
        {
          activeDays: nextDays,
          activeDayCount: nextDays.length,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
      return;
    }

    // Threshold reached: pay both sides, XP outside the league weeklyXp.
    const inviteeGameRef = db().doc(`users/${inviteeUid}/game/state`);
    const inviterGameRef = db().doc(`users/${ownerUid}/game/state`);
    const inviteePublicRef = db().doc(`publicProfiles/${inviteeUid}`);
    const inviterPublicRef = db().doc(`publicProfiles/${ownerUid}`);

    const [inviteeGameSnap, inviterGameSnap] = await Promise.all([
      tx.get(inviteeGameRef),
      tx.get(inviterGameRef),
    ]);

    const inviteeBase = inviteeGameSnap.exists
      ? normalizeGameState(inviteeGameSnap.data())
      : normalizeGameState(initialGameStatePayload());
    const inviterBase = inviterGameSnap.exists
      ? normalizeGameState(inviterGameSnap.data())
      : normalizeGameState(initialGameStatePayload());

    const inviteeXp = inviteeBase.xp + XP_CONFIG.referralInvitee;
    const inviterXp = inviterBase.xp + XP_CONFIG.referralInviter;

    tx.set(
      inviteeGameRef,
      {
        xp: inviteeXp,
        level: xpToLevel(inviteeXp),
        gems: inviteeBase.gems + 5,
        // Intentionally NOT touching weeklyXp (anti-league farming).
        // onGameXpChange subtracts skipLeagueXp from the league delta.
        skipLeagueXp: XP_CONFIG.referralInvitee,
        streak: inviteeBase.streak,
        badges: inviteeBase.badges,
        leagueId: inviteeBase.leagueId,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
    tx.set(
      inviterGameRef,
      {
        xp: inviterXp,
        level: xpToLevel(inviterXp),
        gems: inviterBase.gems + 20,
        skipLeagueXp: XP_CONFIG.referralInviter,
        streak: inviterBase.streak,
        badges: inviterBase.badges,
        leagueId: inviterBase.leagueId,
        // Rare "Sipho gift" flag — client can open a chest animation.
        pendingReferralChest: "gold",
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
    tx.set(
      inviteePublicRef,
      { level: xpToLevel(inviteeXp), updatedAt: FieldValue.serverTimestamp() },
      { merge: true }
    );
    tx.set(
      inviterPublicRef,
      { level: xpToLevel(inviterXp), updatedAt: FieldValue.serverTimestamp() },
      { merge: true }
    );

    tx.set(
      redemptionRef,
      {
        status: "rewarded",
        activeDays: nextDays,
        activeDayCount: nextDays.length,
        rewardedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    logger.info("referral reward granted after active days", {
      inviteeUid,
      ownerUid,
      days: nextDays.length,
    });
  });
}
