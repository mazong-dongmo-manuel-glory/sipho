import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';
import { logger } from '../shared/logger';

export const referralRedeem = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated.');
  }

  const { referralCode } = data;
  if (!referralCode || typeof referralCode !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Valid referral code required.');
  }

  const uid = context.auth.uid;
  const db = admin.firestore();

  const referralRef = db.doc(`referrals/${referralCode.toUpperCase()}`);
  const referralDoc = await referralRef.get();

  if (!referralDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Referral code not found.');
  }

  const refData = referralDoc.data()!;
  if (refData.ownerUid === uid) {
    throw new functions.https.HttpsError('invalid-argument', 'Cannot redeem your own code.');
  }

  const uses = refData.uses || [];
  if (uses.includes(uid)) {
    throw new functions.https.HttpsError('already-exists', 'Referral code already used by this user.');
  }

  await referralRef.update({
    uses: admin.firestore.FieldValue.arrayUnion(uid),
  });

  logger.info('Referral redeemed successfully', { uid, referralCode });
  return { success: true };
});

