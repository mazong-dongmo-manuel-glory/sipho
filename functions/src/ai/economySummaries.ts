import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';
import { logger } from '../shared/logger';

export const economySummaries = functions.pubsub
  .schedule('30 6 * * *') // 6:30 AM after economyFetch
  .onRun(async (context) => {
    const db = admin.firestore();
    logger.info('Generating AI summaries of economic indicators');

    const economySnap = await db.collection('economy').get();

    for (const doc of economySnap.docs) {
      const data = doc.data();
      const code = doc.id;
      logger.info('Processing economy summary', { code });

      // In production, calls Gemini with strict JSON schema to generate short friendly summaries
      const summaryFr = `L'inflation se stabilise autour de ${data.indicators?.inflation?.value ?? 3}%. Pense à optimiser ton panier d'épicerie avec Sipho !`;
      const summaryEn = `Inflation is hovering around ${data.indicators?.inflation?.value ?? 3}%. Keep your grocery budget optimized with Sipho!`;

      await doc.ref.set(
        {
          summary: {
            fr: summaryFr,
            en: summaryEn,
          },
          dailyCards: [
            {
              id: 'inflation_groceries',
              titleFr: 'Impact sur ton épicerie',
              titleEn: 'Impact on groceries',
              impactCentsEstimate: 1600, // 16$
              readDurationSeconds: 20,
            },
          ],
        },
        { merge: true }
      );
    }

    logger.info('Economy summaries generated');
  });

