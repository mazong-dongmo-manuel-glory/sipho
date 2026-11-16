import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { getMessaging, Messaging } from "firebase-admin/messaging";
import { forEachDocument } from "../shared/pagination";
import { localMinuteOfDay, minuteInWindow, offsetRangesForLocalWindow, UserTime } from "../shared/timezone";
import { logger } from "../shared/logger";

/** Shared by every notification job: who to visit, quiet hours, the daily cap, FCM delivery. */

export const db = (): Firestore => getFirestore();
const fcm = (): Messaging => getMessaging();

export const MAX_ENGAGEMENT_NOTIFS_PER_DAY = 2;
export const QUIET_HOURS: [number, number] = [21 * 60 + 30, 8 * 60]; // 21:30–08:00 (wraps midnight)

export interface UserProfile {
  locale?: string;
  timezone?: string;
  utcOffsetMinutes?: number;
  timezoneOffset?: number;
  notifPrefs?: Record<string, boolean>;
}

export function isQuietHour(now: Date, time: UserTime): boolean {
  return minuteInWindow(localMinuteOfDay(now, time), QUIET_HOURS[0], QUIET_HOURS[1]);
}

/**
 * Visits users whose stored UTC offset places them inside the local-time window. The caller must
 * re-check the exact local time with the IANA zone (the stored offset may lag behind a DST change).
 */
export async function forEachUserInLocalWindow(
  now: Date,
  window: [number, number],
  label: string,
  shouldStop: () => boolean,
  handler: (uid: string, profile: UserProfile) => Promise<void>
): Promise<void> {
  for (const [lo, hi] of offsetRangesForLocalWindow(now, window[0], window[1])) {
    const result = await forEachDocument(
      db()
        .collection("users")
        .where("utcOffsetMinutes", ">=", lo)
        .where("utcOffsetMinutes", "<=", hi),
      (doc) => handler(doc.id, doc.data() as UserProfile),
      { label, shouldStop }
    );
    if (result.stoppedEarly) return;
  }
}

export async function canConsumeDailyQuota(uid: string, today: string): Promise<boolean> {
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

/** Whether the user has at least one device able to receive a push. */
export async function hasActiveDevice(uid: string): Promise<boolean> {
  const snap = await db()
    .collection(`users/${uid}/devices`)
    .where("active", "==", true)
    .limit(1)
    .get();
  return !snap.empty;
}

// ─── FCM helper with dead-token cleanup ───────────────────────────────────────

export async function sendToUser(
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
