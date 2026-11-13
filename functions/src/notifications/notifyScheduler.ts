import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore, FieldValue, Firestore, Timestamp } from "firebase-admin/firestore";
import { getMessaging, Messaging } from "firebase-admin/messaging";
import { normalizeGameState } from "../shared/gameState";
import { userLocalDateKey } from "../shared/security";
import { logger } from "../shared/logger";
import { pickTemplate, NotifType } from "./templates";

const db = (): Firestore => getFirestore();
const fcm = (): Messaging => getMessaging();

const MAX_ENGAGEMENT_NOTIFS_PER_DAY = 2;

interface UserProfile {
  locale?: string;
  timezoneOffset?: number;
  notifPrefs?: Record<string, boolean>;
}

/**
 * Runs every 15 minutes.
 * Respects quiet hours (21:30–08:00 local), per-type preferences,
 * max 2 engagement pushes per day, and cleans up dead FCM tokens.
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
      sendFixedDueReminders(now),
      sendQuestExpiryWarnings(now),
      sendUnreadBudgetAlerts(now),
    ]);
  }
);

function isQuietHour(now: Date, offsetHours = 0): boolean {
  const shifted = new Date(now.getTime() + offsetHours * 3_600_000);
  const minutes = shifted.getUTCHours() * 60 + shifted.getUTCMinutes();
  // Quiet hours: 21:30 (1290) through 08:00 (480)
  return minutes >= 21 * 60 + 30 || minutes < 8 * 60;
}

async function canConsumeDailyQuota(uid: string, today: string): Promise<boolean> {
  const stateRef = db().doc(`users/${uid}/notifState/quota`);
  return db().runTransaction(async (tx) => {
    const snap = await tx.get(stateRef);
    const data = snap.data() as { date?: string; count?: number } | undefined;
    const current = data?.date === today ? (data.count ?? 0) : 0;
    if (current >= MAX_ENGAGEMENT_NOTIFS_PER_DAY) return false;
    tx.set(
      stateRef,
      {
        date: today,
        count: current + 1,
        lastSentAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
    return true;
  });
}

// ─── Streak reminders (18:00–19:59 local) ─────────────────────────────────────

async function sendStreakReminders(now: Date): Promise<void> {
  const hour = now.getUTCHours();
  const rawOffsets = [18 - hour, 19 - hour, 18 - hour - 24, 19 - hour - 24, 18 - hour + 24, 19 - hour + 24];
  const targetOffsets = Array.from(
    new Set(rawOffsets.filter((o) => o >= -12 && o <= 14))
  );

  for (const offset of targetOffsets) {
    const usersSnap = await db()
      .collection("users")
      .where("timezoneOffset", "==", offset)
      .where("notifPrefs.streakReminder", "==", true)
      .limit(250)
      .get();

    for (const userDoc of usersSnap.docs) {
      await maybeSendStreakReminder(userDoc.id, userDoc.data() as UserProfile, now);
    }
  }
}

async function maybeSendStreakReminder(
  uid: string,
  profile: UserProfile,
  now: Date
): Promise<void> {
  const offset = typeof profile.timezoneOffset === "number" ? profile.timezoneOffset : 0;
  if (isQuietHour(now, offset)) return;

  const today = userLocalDateKey(now, offset);
  const notifRef = db().doc(`users/${uid}/notifState/streak`);
  const notifSnap = await notifRef.get();
  if (notifSnap.data()?.lastReminderDate === today) return;

  const gameSnap = await db().doc(`users/${uid}/game/state`).get();
  const game = normalizeGameState(gameSnap.data());
  if (game.streak.lastActiveDay === today) return;

  if (!(await canConsumeDailyQuota(uid, today))) return;

  const locale = profile.locale === "en" ? "en" : "fr";
  const tpl = pickTemplate("STREAK_REMINDER", locale);
  await sendToUser(uid, tpl.title, tpl.body, {
    type: "STREAK_REMINDER",
    route: "/home",
  });
  await notifRef.set({ lastReminderDate: today }, { merge: true });
}

// ─── Fixed expense due tomorrow (manual bills) ────────────────────────────────

async function sendFixedDueReminders(now: Date): Promise<void> {
  const hour = now.getUTCHours();
  const rawOffsets = [10 - hour, 10 - hour - 24, 10 - hour + 24];
  const targetOffsets = Array.from(
    new Set(rawOffsets.filter((o) => o >= -12 && o <= 14))
  );

  for (const offset of targetOffsets) {
    const usersSnap = await db()
      .collection("users")
      .where("timezoneOffset", "==", offset)
      .where("notifPrefs.fixedDue", "==", true)
      .limit(200)
      .get();

    for (const userDoc of usersSnap.docs) {
      await maybeSendFixedDue(userDoc.id, userDoc.data() as UserProfile, now);
    }
  }
}

async function maybeSendFixedDue(uid: string, profile: UserProfile, now: Date): Promise<void> {
  const offset = typeof profile.timezoneOffset === "number" ? profile.timezoneOffset : 0;
  if (isQuietHour(now, offset)) return;

  const tomorrow = new Date(now.getTime() + (offset + 24) * 3_600_000);
  const tomorrowDay = tomorrow.getUTCDate();
  const today = userLocalDateKey(now, offset);

  const dueSnap = await db()
    .collection(`users/${uid}/fixedExpenses`)
    .where("active", "==", true)
    .where("payMode", "==", "manual")
    .where("dueDay", "==", tomorrowDay)
    .limit(1)
    .get();

  if (dueSnap.empty) return;

  const notifRef = db().doc(`users/${uid}/notifState/fixedDue`);
  const notifSnap = await notifRef.get();
  if (notifSnap.data()?.lastReminderDate === today) return;

  if (!(await canConsumeDailyQuota(uid, today))) return;

  const locale = profile.locale === "en" ? "en" : "fr";
  const billName = String(dueSnap.docs[0].data().name ?? "");
  const title = locale === "en" ? "📅 Bill due tomorrow" : "📅 Échéance demain";
  const body =
    locale === "en"
      ? `${billName} is due tomorrow. Ready?`
      : `Demain c'est ${billName}. Tout est prêt ?`;

  await sendToUser(uid, title, body, {
    type: "FIXED_DUE",
    route: "/fixed-expenses",
  });
  await notifRef.set({ lastReminderDate: today }, { merge: true });
}

// ─── Quest expiry ─────────────────────────────────────────────────────────────

async function sendQuestExpiryWarnings(now: Date): Promise<void> {
  const in2h = new Date(now.getTime() + 2 * 3_600_000);

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
    const uid = pathParts[1];
    if (!uid) continue;

    const userSnap = await db().doc(`users/${uid}`).get();
    const profile = (userSnap.data() ?? {}) as UserProfile;
    const offset = typeof profile.timezoneOffset === "number" ? profile.timezoneOffset : 0;
    if (isQuietHour(now, offset)) continue;

    const quest = doc.data() as { name?: string; expiresAt: Timestamp; locale?: string };
    const hoursLeft = Math.max(1, Math.round((quest.expiresAt.toMillis() - now.getTime()) / 3_600_000));
    const locale = quest.locale === "en" || profile.locale === "en" ? "en" : "fr";
    const tpl = pickTemplate("QUEST_EXPIRING", locale, {
      questName: quest.name ?? "Sipho",
      hours: String(hoursLeft),
    });

    await sendToUser(uid, tpl.title, tpl.body, {
      type: "QUEST_EXPIRING",
      questId: doc.id,
      route: "/home",
    });
    await doc.ref.update({ expireWarningSent: true });
  }
}

// ─── Unread budget alerts ─────────────────────────────────────────────────────

async function sendUnreadBudgetAlerts(now: Date): Promise<void> {
  const since = new Date(now.getTime() - 30 * 60 * 1000);

  const alertsSnap = await db()
    .collectionGroup("alerts")
    .where("type", "in", ["BUDGET_WARNING", "BUDGET_EXCEEDED"])
    .where("createdAt", ">", Timestamp.fromDate(since))
    .where("pushed", "==", false)
    .limit(200)
    .get();

  for (const doc of alertsSnap.docs) {
    const pathParts = doc.ref.path.split("/");
    const uid = pathParts[1];
    if (!uid) continue;

    const userSnap = await db().doc(`users/${uid}`).get();
    const profile = (userSnap.data() ?? {}) as UserProfile;
    if (profile.notifPrefs?.budgetAlert === false) {
      await doc.ref.update({ pushed: true });
      continue;
    }

    const offset = typeof profile.timezoneOffset === "number" ? profile.timezoneOffset : 0;
    if (isQuietHour(now, offset)) continue;

    const alert = doc.data() as {
      type: NotifType;
      category: string;
      pct: number;
      locale?: string;
    };
    const locale = alert.locale === "en" || profile.locale === "en" ? "en" : "fr";
    const tpl = pickTemplate(alert.type, locale, {
      category: alert.category,
      pct: String(alert.pct),
    });
    await sendToUser(uid, tpl.title, tpl.body, {
      type: alert.type,
      category: alert.category,
      route: "/budget",
    });
    await doc.ref.update({ pushed: true });
  }
}

// ─── FCM helper with dead-token cleanup ───────────────────────────────────────

async function sendToUser(
  uid: string,
  title: string,
  body: string,
  data: Record<string, string>
): Promise<void> {
  const devicesSnap = await db()
    .collection(`users/${uid}/devices`)
    .where("active", "==", true)
    .limit(5)
    .get();

  const entries = devicesSnap.docs
    .map((d) => ({ ref: d.ref, token: d.data().fcmToken as string | undefined }))
    .filter((e): e is { ref: FirebaseFirestore.DocumentReference; token: string } =>
      typeof e.token === "string" && e.token.length > 0
    );

  if (entries.length === 0) return;

  try {
    const res = await fcm().sendEachForMulticast({
      tokens: entries.map((e) => e.token),
      notification: { title, body },
      data,
      android: { priority: "normal" },
      apns: { payload: { aps: { sound: "default" } } },
    });

    // Deactivate unregistered / invalid tokens automatically
    const staleRefs: FirebaseFirestore.DocumentReference[] = [];
    res.responses.forEach((r, idx) => {
      const code = r.error?.code ?? "";
      if (
        !r.success &&
        (code.includes("registration-token-not-registered") ||
          code.includes("invalid-registration-token"))
      ) {
        staleRefs.push(entries[idx].ref);
      }
    });

    if (staleRefs.length > 0) {
      const batch = db().batch();
      for (const ref of staleRefs) {
        batch.update(ref, { active: false, updatedAt: FieldValue.serverTimestamp() });
      }
      await batch.commit();
    }

    logger.info("notification sent", { uid, type: data.type, sent: res.successCount });
  } catch (err) {
    logger.error("FCM send failed", { uid, error: String(err) });
  }
}
