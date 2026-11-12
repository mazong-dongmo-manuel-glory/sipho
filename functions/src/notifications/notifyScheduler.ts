import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { logger } from "../shared/logger";
import { pickTemplate, NotifType } from "./templates";

const db = () => getFirestore();
const fcm = () => getMessaging();

/**
 * Runs every 15 minutes.
 * Sends personalized push notifications:
 *   - Streak reminders (once/day, respecting quiet hours)
 *   - Budget alerts (triggered by user events, with escalation)
 *   - Quest expiry warnings (2h before)
 */
export const notifyScheduler = onSchedule(
  {
    schedule: "every 15 minutes",
    region: "us-central1",
    timeoutSeconds: 540,
  },
  async (_event) => {
    const now = new Date();
    logger.info("notifyScheduler tick", { now: now.toISOString() });

    await Promise.allSettled([
      sendStreakReminders(now),
      sendQuestExpiryWarnings(now),
      sendUnreadBudgetAlerts(now),
    ]);
  }
);

// ─── Streak reminders ─────────────────────────────────────────────────────────

async function sendStreakReminders(now: Date): Promise<void> {
  const hour = now.getUTCHours();

  // Find users whose local time is 18:00–19:59 (prime reminder window)
  // We store timezoneOffset in hours (e.g. -5 for EST)
  const targetOffsets = [-hour + 18, -hour + 19]; // UTC offsets where local hour = 18 or 19

  for (const offset of targetOffsets) {
    const usersSnap = await db()
      .collection("users")
      .where("timezoneOffset", "==", offset)
      .where("notifPrefs.streakReminder", "==", true)
      .limit(500)
      .get();

    for (const userDoc of usersSnap.docs) {
      await maybeSendStreakReminder(userDoc.id, userDoc.data() as UserProfile, now);
    }
  }
}

async function maybeSendStreakReminder(uid: string, profile: UserProfile, now: Date): Promise<void> {
  const today = now.toISOString().slice(0, 10);

  // Skip if already notified today
  const notifRef = db().doc(`users/${uid}/notifState/streak`);
  const notifSnap = await notifRef.get();
  if (notifSnap.data()?.lastReminderDate === today) return;

  // Skip if lesson already done today
  const gameSnap = await db().doc(`users/${uid}/game/state`).get();
  if (gameSnap.data()?.lastLessonDate === today) return;

  const locale = profile.locale ?? "fr";
  const tpl = pickTemplate("STREAK_REMINDER", locale as "fr" | "en");
  await sendToUser(uid, tpl.title, tpl.body, { type: "STREAK_REMINDER" });
  await notifRef.set({ lastReminderDate: today }, { merge: true });
}

// ─── Quest expiry ─────────────────────────────────────────────────────────────

async function sendQuestExpiryWarnings(now: Date): Promise<void> {
  const in2h = new Date(now.getTime() + 2 * 3600 * 1000);

  // Find all active quests expiring in next 2 hours that haven't been warned
  const questsSnap = await db()
    .collectionGroup("quests")
    .where("status", "==", "active")
    .where("expiresAt", "<=", Timestamp.fromDate(in2h))
    .where("expiresAt", ">", Timestamp.fromDate(now))
    .where("expireWarningSent", "==", false)
    .limit(200)
    .get();

  for (const doc of questsSnap.docs) {
    const pathParts = doc.ref.path.split("/");
    const uid = pathParts[1]; // users/{uid}/quests/{questId}
    const quest = doc.data() as { name: string; expiresAt: Timestamp; locale?: string };
    const hoursLeft = Math.round((quest.expiresAt.toMillis() - now.getTime()) / 3600000);
    const locale = (quest.locale ?? "fr") as "fr" | "en";
    const tpl = pickTemplate("QUEST_EXPIRING", locale, {
      questName: quest.name,
      hours: String(hoursLeft),
    });
    await sendToUser(uid, tpl.title, tpl.body, { type: "QUEST_EXPIRING", questId: doc.id });
    await doc.ref.update({ expireWarningSent: true });
  }
}

// ─── Unread budget alerts ─────────────────────────────────────────────────────

async function sendUnreadBudgetAlerts(now: Date): Promise<void> {
  // Find budget alerts created in the last 15 min that haven't been pushed
  const since = new Date(now.getTime() - 15 * 60 * 1000);

  const alertsSnap = await db()
    .collectionGroup("alerts")
    .where("type", "in", ["BUDGET_WARNING", "BUDGET_EXCEEDED"])
    .where("createdAt", ">", Timestamp.fromDate(since))
    .where("pushed", "!=", true)
    .limit(200)
    .get();

  for (const doc of alertsSnap.docs) {
    const pathParts = doc.ref.path.split("/");
    const uid = pathParts[1];
    const alert = doc.data() as {
      type: NotifType;
      category: string;
      pct: number;
      locale?: string;
    };
    const locale = (alert.locale ?? "fr") as "fr" | "en";
    const tpl = pickTemplate(alert.type, locale, {
      category: alert.category,
      pct: String(alert.pct),
    });
    await sendToUser(uid, tpl.title, tpl.body, { type: alert.type, category: alert.category });
    await doc.ref.update({ pushed: true });
  }
}

// ─── FCM helper ───────────────────────────────────────────────────────────────

interface UserProfile {
  locale?: string;
  timezoneOffset?: number;
  notifPrefs?: Record<string, boolean>;
}

async function sendToUser(
  uid: string,
  title: string,
  body: string,
  data: Record<string, string>
): Promise<void> {
  // Fetch FCM tokens
  const devicesSnap = await db()
    .collection(`users/${uid}/devices`)
    .where("active", "==", true)
    .limit(5)
    .get();

  const tokens = devicesSnap.docs
    .map((d) => d.data().fcmToken as string)
    .filter(Boolean);
  if (tokens.length === 0) return;

  try {
    await fcm().sendEachForMulticast({
      tokens,
      notification: { title, body },
      data,
      android: { priority: "normal" },
      apns: { payload: { aps: { sound: "default" } } },
    });
    logger.info("notification sent", { uid, type: data.type });
  } catch (err) {
    logger.error("FCM send failed", { uid, error: String(err) });
  }
}
