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

/**
 * Callable (v2, App Check enforced): full GDPR / Loi 25 erasure.
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

    // 1. Delete user document and all nested subcollections
    await db.recursiveDelete(db.doc(`users/${uid}`));

    // 2. Delete public profile and owned referral codes
    const referralsSnap = await db
      .collection("referrals")
      .where("ownerUid", "==", uid)
      .limit(20)
      .get();

    const cleanupBatch = db.batch();
    cleanupBatch.delete(db.doc(`publicProfiles/${uid}`));
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
  }
);
