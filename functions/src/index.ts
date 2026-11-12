import * as admin from 'firebase-admin';

admin.initializeApp();

// Gamification
export { onTransactionWrite } from './gamification/onTransactionWrite';
export { completeLesson } from './gamification/completeLesson';
export { markFixedPaid } from './gamification/markFixedPaid';
export { dailyRollover } from './gamification/dailyRollover';

// Stats & Users
export { onUserCreate } from './stats/onUserCreate';
export { generateMonth } from './stats/generateMonth';

// Notifications
export { notifyScheduler } from './notifications/notifyScheduler';

// AI
export { parseReceipt } from './ai/parseReceipt';
export { weeklyInsights } from './ai/weeklyInsights';
export { economySummaries } from './ai/economySummaries';

// Economy
export { economyFetch } from './economy/economyFetch';
export { fxRates } from './economy/fxRates';
export { economyAlerts } from './economy/economyAlerts';

// Account & Referrals
export { deleteAccount } from './account/deleteAccount';
export { referralRedeem } from './referrals/referralRedeem';

