import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';
import { logger } from '../shared/logger';

export const generateMonth = functions.pubsub
  .schedule('0 0 1 * *') // 1st of every month at midnight
  .onRun(async (context) => {
    const db = admin.firestore();
    const now = new Date();
    const currentMonthKey = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;

    logger.info('Running generateMonth scheduler', { currentMonthKey });

    const usersSnap = await db.collection('users').get();

    for (const userDoc of usersSnap.docs) {
      const uid = userDoc.id;
      const monthRef = db.doc(`users/${uid}/months/${currentMonthKey}`);
      const monthDoc = await monthRef.get();

      if (!monthDoc.exists) {
        // Fetch active fixed expenses to project totals
        const fixedSnap = await db
          .collection(`users/${uid}/fixedExpenses`)
          .where('active', '==', true)
          .get();

        let totalFixedCents = 0;
        const fixedItems: Record<string, any> = {};

        fixedSnap.forEach((doc) => {
          const data = doc.data();
          totalFixedCents += data.amountCents || 0;
          fixedItems[doc.id] = {
            name: data.name,
            amountCents: data.amountCents,
            dueDay: data.dueDay,
            paid: false,
          };
        });

        const userData = userDoc.data();
        const incomeCents = userData.incomeMonthlyCents || 0;

        await monthRef.set({
          incomeCents,
          totalFixedCents,
          totalVariableCents: 0,
          fixedPaid: fixedItems,
          totals: {},
          remainingCents: incomeCents - totalFixedCents,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    }

    logger.info('generateMonth scheduler completed', { currentMonthKey });
  });

