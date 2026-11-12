import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';
import { logger } from '../shared/logger';

export const onUserCreate = functions.auth.user().onCreate(async (user) => {
  const db = admin.firestore();
  const uid = user.uid;

  logger.info('Creating initial user state', { uid });

  const batch = db.batch();

  // 1. Initial Game State
  const gameStateRef = db.doc(`users/${uid}/game/state`);
  batch.set(gameStateRef, {
    xp: 0,
    level: 1,
    gems: 0,
    streak: {
      current: 0,
      best: 0,
      lastActiveDay: null,
      freezes: 2,
    },
    leagueId: 'bronze_default',
    weeklyXp: 0,
    badges: [],
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // 2. Initial Notification State
  const notifStateRef = db.doc(`users/${uid}/notifState/state`);
  batch.set(notifStateRef, {
    prefs: {
      streak_reminder: true,
      budget_alert: true,
      fixed_due: true,
      tips: true,
      economy: true,
      social: true,
    },
    preferredHour: 19,
    sentToday: 0,
    lastSentAt: null,
    inactivityStage: 0,
  });

  // 3. Public Profile (No sensitive money amounts)
  const publicProfileRef = db.doc(`publicProfiles/${uid}`);
  batch.set(publicProfileRef, {
    pseudo: user.displayName || 'Aventurier Sipho',
    avatar: 'tisserin_default',
    level: 1,
    streak: 0,
    league: 'bronze',
    badges: [],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // 4. Initial Onboarding Quests
  const todayStr = new Date().toISOString().split('T')[0];
  const initialQuestRef = db.doc(`users/${uid}/quests/welcome_nest`);
  batch.set(initialQuestRef, {
    templateId: 'build_nest',
    type: 'onboarding',
    progress: 0,
    target: 1,
    rewardXp: 50,
    rewardGems: 10,
    status: 'active',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    expiresAt: null,
  });

  await batch.commit();
  logger.info('User initial state initialized successfully', { uid });
});

