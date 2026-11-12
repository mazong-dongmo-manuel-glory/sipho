import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';
import { logger } from '../shared/logger';

export const deleteAccount = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');
  }

  const uid = context.auth.uid;
  logger.info('Deleting user account and associated personal data (GDPR / Loi 25)', { uid });

  const db = admin.firestore();
  const bucket = admin.storage().bucket();

  // 1. Delete user documents in Firestore
  const userRef = db.doc(`users/${uid}`);
  await db.recursiveDelete(userRef);

  // 2. Delete public profile
  await db.doc(`publicProfiles/${uid}`).delete().catch(() => {});

  // 3. Delete receipts in Storage
  await bucket.deleteFiles({ prefix: `receipts/${uid}/` }).catch(() => {});

  // 4. Delete Auth record
  await admin.auth().deleteUser(uid);

  logger.info('Account deleted successfully', { uid });
  return { success: true };
});

