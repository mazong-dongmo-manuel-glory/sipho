import { onCall } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { DeleteAccountInputSchema } from "../shared/validators";
import {
  SECURE_CALLABLE_OPTIONS,
  enforceRateLimit,
  parseInput,
  requireAuthUid,
} from "../shared/security";
import { logger } from "../shared/logger";
import { storedHashes } from "../shared/contacts";
import { removeFromContactIndex } from "../social/contactIndex";

/**
 * Callable (v2, authenticated): full GDPR / Loi 25 erasure.
 * Requires explicit confirmation phrase `{ confirmPhrase: "DELETE MY ACCOUNT" }`.
 */
export const deleteAccount = onCall(
  { ...SECURE_CALLABLE_OPTIONS, timeoutSeconds: 120 },
  async (request) => {
    const uid = requireAuthUid(request);
    parseInput(DeleteAccountInputSchema, request.data);

    await enforceRateLimit({
      uid,
      action: "deleteAccount",
      maxRequests: 3,
      windowMs: 24 * 60 * 60 * 1000,
    });

    logger.info("deleting user account and associated personal data", { uid });

    const db = admin.firestore();
    const bucket = admin.storage().bucket();

    // 0. Leave the current league group (the ranking must not show a deleted account)
    const league = await db.doc(`users/${uid}/league/current`).get();
    const leagueKey: unknown = (
      league.data() as { leagueKey?: unknown } | undefined
    )?.leagueKey;
    if (typeof leagueKey === "string" && leagueKey.length > 0) {
      await db
        .doc(`leagues/${leagueKey}/members/${uid}`)
        .delete()
        .catch(() => undefined);
    }

    // 0b. Withdraw from contact discovery (the hash must not outlive the account)
    const discovery = await db.doc(`users/${uid}/social/contacts`).get();
    await removeFromContactIndex(
      uid,
      storedHashes(
        discovery.data() as
          { hashes?: unknown; emailHash?: unknown } | undefined,
      ),
    ).catch(() => undefined);

    // 1. Delete user document and all nested subcollections
    await db.recursiveDelete(db.doc(`users/${uid}`));

    // 2. Delete public profile and owned referral codes
    const referralsSnap = await db
      .collection("referrals")
      .where("ownerUid", "==", uid)
      .limit(20)
      .get();

    // Friendships (accepted and pending) must not outlive the account.
    const friendshipsSnap = await db
      .collection("friendships")
      .where("users", "array-contains", uid)
      .limit(200)
      .get();

    const cleanupBatch = db.batch();
    cleanupBatch.delete(db.doc(`publicProfiles/${uid}`));
    for (const friendDoc of friendshipsSnap.docs) {
      cleanupBatch.delete(friendDoc.ref);
    }
    for (const refDoc of referralsSnap.docs) {
      cleanupBatch.delete(refDoc.ref);
    }
    await cleanupBatch.commit().catch(() => undefined);

    // 3. Delete uploaded receipts & avatars in Cloud Storage
    await Promise.allSettled([
      bucket.deleteFiles({ prefix: `receipts/${uid}/` }),
      bucket.deleteFiles({ prefix: `avatars/${uid}/` }),
    ]);

    // 4. Delete Firebase Auth account
    await admin.auth().deleteUser(uid);

    logger.info("account deleted successfully", { uid });
    return { success: true };
  },
);
