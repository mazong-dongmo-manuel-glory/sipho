import * as admin from 'firebase-admin';

admin.initializeApp();

// Gamification
export { onTransactionWrite } from './gamification/onTransactionWrite';
export { completeLesson } from './gamification/completeLesson';
export { generateCountryLessons } from './lessons/generateCountryLessons';
export { markFixedPaid } from './gamification/markFixedPaid';
export { claimQuest } from './gamification/claimQuest';
export { refreshDailyQuests } from './gamification/refreshDailyQuests';
export { confirmNoSpend } from './gamification/confirmNoSpend';
export { repairStreak } from './gamification/repairStreak';
export { dailyRollover } from './gamification/dailyRollover';
export { joinLeague, onGameXpChange, leagueWeekly } from './gamification/league';
export { onGameBadgeCheck, onUserOnboardingDone } from './gamification/badges';
export { buyShopItem } from './gamification/shop';

// Stats & Users
export { onUserCreate } from './stats/onUserCreate';
export { onUserProfileCreate } from './stats/onUserProfileCreate';
export { generateMonth } from './stats/generateMonth';

// Notifications
export { notifyScheduler } from './notifications/notifyScheduler';
export { adviceNotifier } from './notifications/adviceNotifier';
export { coachHourly } from './notifications/coachHourly';
export { economyNotifier } from './notifications/economyNotifier';

// AI
export { parseReceipt } from './ai/parseReceipt';
export { weeklyInsights } from './ai/weeklyInsights';
export { generateInsight } from './ai/generateInsight';
export { economySummaries } from './ai/economySummaries';

// Economy
export { economyFetch } from './economy/economyFetch';
export { economyNewsFetch } from './economy/economyNewsFetch';
export { fxRates } from './economy/fxRates';
export { economyAlerts } from './economy/economyAlerts';

// Friends & invitations
export { getInviteCode, sendFriendRequest, respondFriendRequest, removeFriend } from './social/friends';
export { setContactDiscovery, findContacts, sendContactFriendRequest } from './social/contacts';
export { createFriendChallenge, respondFriendChallenge } from './social/friendChallenges';

// Account & Referrals
export { deleteAccount } from './account/deleteAccount';
export { referralRedeem } from './referrals/referralRedeem';

