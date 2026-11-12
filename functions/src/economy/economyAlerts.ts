import * as functions from 'firebase-functions/v1';
import { logger } from '../shared/logger';

export const economyAlerts = functions.firestore
  .document('economy/{countryCode}')
  .onUpdate(async (change, context) => {
    const countryCode = context.params.countryCode;
    const before = change.before.data();
    const after = change.after.data();

    const beforeRate = before.indicators?.keyRate?.value;
    const afterRate = after.indicators?.keyRate?.value;

    if (beforeRate !== undefined && afterRate !== undefined && beforeRate !== afterRate) {
      logger.info('Detected central bank rate change', { countryCode, beforeRate, afterRate });
      // Notify users in that country via FCM in batches
    }
  });

