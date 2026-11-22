import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { z } from "zod";
import {
  SECURE_CALLABLE_OPTIONS,
  enforceRateLimit,
  parseInput,
  requireAuthUid,
} from "../shared/security";
import {
  FRIEND_CHALLENGE_TEMPLATE_IDS,
  MAX_ACTIVE_CHALLENGES_PER_USER,
  MAX_PENDING_PER_PAIR,
  templateById,
} from "../shared/friendChallenges";
import { friendPairId } from "../shared/friends";
import { logger } from "../shared/logger";

const db = (): Firestore => getFirestore();

const CreateInputSchema = z.object({
  friendUid: z.string().trim().min(1).max(128),
  templateId: z.enum(FRIEND_CHALLENGE_TEMPLATE_IDS),
  locale: z.enum(["fr", "en"]).optional().default("fr"),
});

const RespondInputSchema = z.object({
  pairId: z
    .string()
    .trim()
    .min(3)
    .max(200)
    .regex(/^[A-Za-z0-9_-]+$/),
  challengeId: z
    .string()
    .trim()
    .min(1)
    .max(128)
    .regex(/^[A-Za-z0-9_-]+$/),
  accept: z.boolean(),
});

/**
 * Callable: create a pending 1v1 challenge from a server-owned template.
 * Client never chooses XP, target or duration.
 */
export const createFriendChallenge = onCall(
  SECURE_CALLABLE_OPTIONS,
  async (request) => {
    const uid = requireAuthUid(request);
    const { friendUid, templateId, locale } = parseInput(
      CreateInputSchema,
      request.data
    );

    if (friendUid === uid) {
      throw new HttpsError("invalid-argument", "Cannot challenge yourself.");
    }

    await enforceRateLimit({
      uid,
      action: "createFriendChallenge",
      maxRequests: 20,
      windowMs: 24 * 60 * 60 * 1000,
    });

    const template = templateById(templateId);
    if (!template) {
      throw new HttpsError("invalid-argument", "Unknown template.");
    }

    const pairId = friendPairId(uid, friendUid);
    const friendshipRef = db().doc(`friendships/${pairId}`);
    const friendshipSnap = await friendshipRef.get();
    if (!friendshipSnap.exists || friendshipSnap.data()?.status !== "accepted") {
      throw new HttpsError("failed-precondition", "You are not friends.");
    }

    const myActive = await countActivePointers(uid);
    if (myActive >= MAX_ACTIVE_CHALLENGES_PER_USER) {
      throw new HttpsError("resource-exhausted", "Too many open challenges.");
    }

    const pendingSnap = await friendshipRef
      .collection("challenges")
      .where("status", "==", "pending")
      .limit(MAX_PENDING_PER_PAIR)
      .get();
    if (pendingSnap.size >= MAX_PENDING_PER_PAIR) {
      throw new HttpsError(
        "failed-precondition",
        "A challenge is already pending with this friend."
      );
    }

    const [senderProfile, receiverProfile] = await Promise.all([
      db().doc(`publicProfiles/${uid}`).get(),
      db().doc(`publicProfiles/${friendUid}`).get(),
    ]);
    const senderName =
      (senderProfile.data()?.pseudo as string | undefined)?.trim() || "Toi";
    const receiverName =
      (receiverProfile.data()?.pseudo as string | undefined)?.trim() || "Ami";

    const now = new Date();
    const expiresAt = new Date(
      now.getTime() + template.durationDays * 24 * 60 * 60 * 1000
    );
    const title = locale === "en" ? template.title.en : template.title.fr;
    const description =
      locale === "en" ? template.description.en : template.description.fr;

    const challengeRef = friendshipRef.collection("challenges").doc();
    await challengeRef.set({
      pairId,
      templateId: template.id,
      metric: template.metric,
      category: template.category,
      senderUid: uid,
      receiverUid: friendUid,
      senderName,
      receiverName,
      title,
      description,
      targetCount: template.targetCount,
      rewardXp: template.rewardXp,
      senderProgress: 0,
      receiverProgress: 0,
      status: "pending",
      createdAt: FieldValue.serverTimestamp(),
      expiresAt,
      updatedAt: FieldValue.serverTimestamp(),
    });

    logger.info("friend challenge created", {
      uid,
      friendUid,
      templateId,
      challengeId: challengeRef.id,
    });

    return { challengeId: challengeRef.id, pairId };
  }
);

/**
 * Callable: accept or decline a pending challenge. Only the receiver may respond.
 * On accept, writes challengePointers for both users so progress hooks can find them.
 */
export const respondFriendChallenge = onCall(
  SECURE_CALLABLE_OPTIONS,
  async (request) => {
    const uid = requireAuthUid(request);
    const { pairId, challengeId, accept } = parseInput(
      RespondInputSchema,
      request.data
    );

    await enforceRateLimit({
      uid,
      action: "respondFriendChallenge",
      maxRequests: 40,
      windowMs: 24 * 60 * 60 * 1000,
    });

    const challengeRef = db().doc(
      `friendships/${pairId}/challenges/${challengeId}`
    );

    if (accept) {
      const probe = await challengeRef.get();
      const senderUid =
        typeof probe.data()?.senderUid === "string"
          ? (probe.data()?.senderUid as string)
          : "";
      const myActive = await countActivePointers(uid);
      if (myActive >= MAX_ACTIVE_CHALLENGES_PER_USER) {
        throw new HttpsError("resource-exhausted", "Too many open challenges.");
      }
      if (senderUid) {
        const senderActive = await countActivePointers(senderUid);
        if (senderActive >= MAX_ACTIVE_CHALLENGES_PER_USER) {
          throw new HttpsError(
            "resource-exhausted",
            "Your friend has too many open challenges."
          );
        }
      }
    }

    await db().runTransaction(async (tx) => {
      const snap = await tx.get(challengeRef);
      if (!snap.exists) {
        throw new HttpsError("not-found", "Challenge not found.");
      }
      const data = snap.data() as {
        status?: unknown;
        senderUid?: unknown;
        receiverUid?: unknown;
        metric?: unknown;
        templateId?: unknown;
      };

      if (data.status !== "pending") {
        throw new HttpsError(
          "failed-precondition",
          "Challenge is not pending."
        );
      }
      if (data.receiverUid !== uid) {
        throw new HttpsError(
          "permission-denied",
          "Only the challenged friend can respond."
        );
      }

      if (!accept) {
        tx.update(challengeRef, {
          status: "declined",
          updatedAt: FieldValue.serverTimestamp(),
        });
        return;
      }

      const senderUid =
        typeof data.senderUid === "string" ? data.senderUid : "";
      const metric = typeof data.metric === "string" ? data.metric : "";
      const templateId =
        typeof data.templateId === "string" ? data.templateId : "";
      if (!senderUid || !metric) {
        throw new HttpsError("internal", "Challenge is incomplete.");
      }

      tx.update(challengeRef, {
        status: "active",
        acceptedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });

      const pointerPayload = {
        pairId,
        challengeId,
        metric,
        templateId,
        status: "active",
        updatedAt: FieldValue.serverTimestamp(),
      };
      tx.set(db().doc(`users/${uid}/challengePointers/${challengeId}`), {
        ...pointerPayload,
        otherUid: senderUid,
      });
      tx.set(db().doc(`users/${senderUid}/challengePointers/${challengeId}`), {
        ...pointerPayload,
        otherUid: uid,
      });
    });

    return { status: accept ? "active" : "declined" };
  }
);

async function countActivePointers(uid: string): Promise<number> {
  const snap = await db()
    .collection(`users/${uid}/challengePointers`)
    .where("status", "==", "active")
    .count()
    .get();
  return snap.data().count;
}
