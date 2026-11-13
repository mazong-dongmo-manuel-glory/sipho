import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";
import { initialGameStatePayload } from "../shared/gameState";
import { logger } from "../shared/logger";

export const onUserCreate = functions.auth.user().onCreate(async (user) => {
  const db = admin.firestore();
  const uid = user.uid;

  logger.info("creating initial user state", { uid });

  const batch = db.batch();

  const gameStateRef = db.doc(`users/${uid}/game/state`);
  batch.set(gameStateRef, initialGameStatePayload(), { merge: true });

  const notifStateRef = db.doc(`users/${uid}/notifState/state`);
  batch.set(
    notifStateRef,
    {
      prefs: {
        streak_reminder: true,
        budget_alert: true,
        fixed_due: true,
        tips: true,
        economy: false,
        social: true,
      },
      preferredHour: 19,
      sentToday: 0,
      lastSentDate: null,
      lastSentAt: null,
      inactivityStage: 0,
    },
    { merge: true }
  );

  const publicProfileRef = db.doc(`publicProfiles/${uid}`);
  batch.set(
    publicProfileRef,
    {
      pseudo: (user.displayName ?? "").trim().slice(0, 40) || "Sipho",
      avatar: "tisserin_default",
      level: 1,
      streak: 0,
      league: "bronze",
      badges: [],
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  const initialQuestRef = db.doc(`users/${uid}/quests/daily_expenses`);
  batch.set(
    initialQuestRef,
    {
      templateId: "log_expenses",
      type: "ADD_TRANSACTION",
      progress: 0,
      target: 3,
      rewardXp: 15,
      rewardGems: 5,
      status: "active",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt: null,
    },
    { merge: true }
  );

  await batch.commit();
  logger.info("user initial state initialized successfully", { uid });
});
