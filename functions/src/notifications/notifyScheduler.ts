import { onSchedule } from "firebase-functions/v2/scheduler";
import { Timestamp } from "firebase-admin/firestore";
import { normalizeGameState } from "../shared/gameState";
import { deadlineGuard, forEachDocument } from "../shared/pagination";
import { localDateKey, localMinuteOfDay, minuteInWindow, resolveUserTime, shiftDateKey } from "../shared/timezone";
import { logger } from "../shared/logger";
import {
  canConsumeDailyQuota,
  db,
  forEachUserInLocalWindow,
  isQuietHour,
  sendToUser,
  UserProfile,
} from "./delivery";
import { pickTemplate, NotifType } from "./templates";

const TIMEOUT_SECONDS = 540;

// Local-time windows (minutes since local midnight).
const STREAK_REMINDER_WINDOW: [number, number] = [18 * 60, 20 * 60]; // 18:00–19:59
const FIXED_DUE_WINDOW: [number, number] = [10 * 60, 12 * 60]; // 10:00–11:59

/**
 * Runs every 15 minutes.
 * Respects quiet hours (21:30–08:00 local), per-type preferences,
 * max 2 engagement pushes per day, and cleans up dead FCM tokens.
 * Every query is paginated, so the job keeps working beyond a few hundred users.
 */
export const notifyScheduler = onSchedule(
  {
    schedule: "every 15 minutes",
    region: "us-central1",
    timeoutSeconds: TIMEOUT_SECONDS,
  },
  async (_event) => {
    const now = new Date();
    const shouldStop = deadlineGuard(TIMEOUT_SECONDS);
    logger.info("notifyScheduler tick", { now: now.toISOString() });

    await Promise.allSettled([
      sendStreakReminders(now, shouldStop),
      sendFixedDueReminders(now, shouldStop),
      sendQuestExpiryWarnings(now, shouldStop),
      sendUnreadBudgetAlerts(now, shouldStop),
    ]);
  }
);

// ─── Streak reminders (18:00–19:59 local) ─────────────────────────────────────

async function sendStreakReminders(now: Date, shouldStop: () => boolean): Promise<void> {
  await forEachUserInLocalWindow(
    now,
    STREAK_REMINDER_WINDOW,
    "streakReminders",
    shouldStop,
    (uid, profile) => maybeSendStreakReminder(uid, profile, now)
  );
}

async function maybeSendStreakReminder(
  uid: string,
  profile: UserProfile,
  now: Date
): Promise<void> {
  if (profile.notifPrefs?.streakReminder !== true) return;

  const time = resolveUserTime(profile as Record<string, unknown>);
  if (
    !minuteInWindow(
      localMinuteOfDay(now, time),
      STREAK_REMINDER_WINDOW[0],
      STREAK_REMINDER_WINDOW[1]
    )
  ) {
    return;
  }
  if (isQuietHour(now, time)) return;

  const today = localDateKey(now, time);
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

async function sendFixedDueReminders(now: Date, shouldStop: () => boolean): Promise<void> {
  await forEachUserInLocalWindow(
    now,
    FIXED_DUE_WINDOW,
    "fixedDueReminders",
    shouldStop,
    (uid, profile) => maybeSendFixedDue(uid, profile, now)
  );
}

async function maybeSendFixedDue(uid: string, profile: UserProfile, now: Date): Promise<void> {
  if (profile.notifPrefs?.fixedDue !== true) return;

  const time = resolveUserTime(profile as Record<string, unknown>);
  if (
    !minuteInWindow(localMinuteOfDay(now, time), FIXED_DUE_WINDOW[0], FIXED_DUE_WINDOW[1])
  ) {
    return;
  }
  if (isQuietHour(now, time)) return;

  const today = localDateKey(now, time);
  const tomorrowDay = Number(shiftDateKey(today, 1).slice(8, 10));

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

async function sendQuestExpiryWarnings(now: Date, shouldStop: () => boolean): Promise<void> {
  const in2h = new Date(now.getTime() + 2 * 3_600_000);

  // Needs the COLLECTION_GROUP composite index (status, expireWarningSent, expiresAt).
  await forEachDocument(
    db()
      .collectionGroup("quests")
      .where("status", "==", "active")
      .where("expireWarningSent", "==", false)
      .where("expiresAt", "<=", Timestamp.fromDate(in2h))
      .where("expiresAt", ">", Timestamp.fromDate(now)),
    async (doc) => {
      const uid = doc.ref.path.split("/")[1];
      if (!uid) return;

      const userSnap = await db().doc(`users/${uid}`).get();
      const profile = (userSnap.data() ?? {}) as UserProfile;
      const time = resolveUserTime(profile as Record<string, unknown>);
      if (isQuietHour(now, time)) return;

      const quest = doc.data() as { name?: string; expiresAt: Timestamp; locale?: string };
      const hoursLeft = Math.max(
        1,
        Math.round((quest.expiresAt.toMillis() - now.getTime()) / 3_600_000)
      );
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
    },
    { label: "questExpiryWarnings", shouldStop, pageSize: 200, concurrency: 10 }
  );
}

// ─── Unread budget alerts ─────────────────────────────────────────────────────

async function sendUnreadBudgetAlerts(now: Date, shouldStop: () => boolean): Promise<void> {
  const since = new Date(now.getTime() - 30 * 60 * 1000);

  // Needs the COLLECTION_GROUP composite index (pushed, type, createdAt).
  await forEachDocument(
    db()
      .collectionGroup("alerts")
      .where("pushed", "==", false)
      .where("type", "in", ["BUDGET_WARNING", "BUDGET_EXCEEDED"])
      .where("createdAt", ">", Timestamp.fromDate(since)),
    async (doc) => {
      const uid = doc.ref.path.split("/")[1];
      if (!uid) return;

      const userSnap = await db().doc(`users/${uid}`).get();
      const profile = (userSnap.data() ?? {}) as UserProfile;
      if (profile.notifPrefs?.budgetAlert === false) {
        await doc.ref.update({ pushed: true });
        return;
      }

      const time = resolveUserTime(profile as Record<string, unknown>);
      if (isQuietHour(now, time)) return;

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
    },
    { label: "unreadBudgetAlerts", shouldStop, pageSize: 200, concurrency: 10 }
  );
}
