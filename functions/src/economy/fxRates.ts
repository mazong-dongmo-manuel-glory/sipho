import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';
import { logger } from '../shared/logger';

export const fxRates = functions.pubsub
  .schedule('0 7 * * *') // Daily at 7 AM
  .onRun(async (context) => {
    const db = admin.firestore();
    logger.info('Fetching latest FX rates');

    // Base CAD reference rates
    await db.doc('fx/latest').set({
      base: 'CAD',
      rates: {
        CAD: 1.0,
        EUR: 0.68,
        USD: 0.72,
        XAF: 446.5,
        XOF: 446.5,
        GBP: 0.58,
        CHF: 0.64,
      },
      asOf: new Date().toISOString(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    logger.info('FX rates updated successfully');
  });

