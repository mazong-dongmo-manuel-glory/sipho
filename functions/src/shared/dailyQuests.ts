import { Firestore, FieldValue, Timestamp } from "firebase-admin/firestore";
import { logger } from "./logger";
import { localDateKey, startOfNextLocalDay, UserTime } from "./timezone";

export interface DailyQuestTemplate {
  templateId: string;
  /** Matches the quest types advanced by `onTransactionWrite` / `completeLesson`. */
  type: "ADD_TRANSACTION" | "COMPLETE_LESSON";
  target: number;
  rewardXp: number;
  rewardGems: number;
  name: { fr: string; en: string };
  description: { fr: string; en: string };
}

export const DAILY_QUEST_TEMPLATES: readonly DailyQuestTemplate[] = [
  {
    templateId: "log_expenses",
    type: "ADD_TRANSACTION",
    target: 3,
    rewardXp: 15,
    rewardGems: 5,
    name: { fr: "Noter 3 dépenses aujourd'hui", en: "Log 3 expenses today" },
    description: {
      fr: "Garde le fil de ton argent, une dépense à la fois",
      en: "Keep track of your money, one expense at a time",
    },
  },
];

/** Legacy one-shot quest created by the previous `onUserCreate` (never expired). */
export const LEGACY_DAILY_QUEST_ID = "daily_expenses";

/** Expired quests are deleted after this long. */
export const EXPIRED_RETENTION_MS = 14 * 24 * 60 * 60 * 1000;

/** Completed-but-unclaimed daily quests stay claimable this long after their day ends. */
export const CLAIM_GRACE_MS = 24 * 60 * 60 * 1000;

export function dailyQuestId(templateId: string, dayKey: string): string {
  return `daily_${templateId}_${dayKey}`;
}

/**
 * Creates today's daily quests (local day) if they do not exist yet. Deterministic ids make this
 * idempotent: calling it from the rollover, from profile creation, or twice in a row is safe.
 */
export async function ensureDailyQuests(
  db: Firestore,
  uid: string,
  time: UserTime,
  locale: "fr" | "en",
  now: Date
): Promise<number> {
  const dayKey = localDateKey(now, time);
  const expiresAt = Timestamp.fromDate(startOfNextLocalDay(now, time));
  let created = 0;

  for (const tpl of DAILY_QUEST_TEMPLATES) {
    const ref = db.doc(`users/${uid}/quests/${dailyQuestId(tpl.templateId, dayKey)}`);
    try {
      await ref.create({
        templateId: tpl.templateId,
        type: tpl.type,
        period: "daily",
        dayKey,
        name: tpl.name[locale],
        description: tpl.description[locale],
        locale,
        progress: 0,
        target: tpl.target,
        rewardXp: tpl.rewardXp,
        rewardGems: tpl.rewardGems,
        status: "active",
        source: "daily",
        // Daily quests end at local midnight, i.e. inside the 21:30-08:00 quiet hours, so an
        // "expiring soon" push could never be delivered; the streak reminder covers that need.
        expireWarningSent: true,
        createdAt: FieldValue.serverTimestamp(),
        expiresAt,
      });
      created += 1;
    } catch (err) {
      // ALREADY_EXISTS (gRPC code 6) means the quest was already created: expected on replays.
      if ((err as { code?: number }).code !== 6) throw err;
    }
  }

  if (created > 0) logger.info("daily quests created", { uid, dayKey, created });
  return created;
}

/**
 * Expires daily quests whose day is over. Active quests expire immediately; completed quests
 * stay claimable for {@link CLAIM_GRACE_MS}. Also retires the legacy never-expiring quest.
 * Uses the existing (status, expiresAt) composite index.
 */
export async function expireDailyQuests(db: Firestore, uid: string, now: Date): Promise<number> {
  const snap = await db
    .collection(`users/${uid}/quests`)
    .where("status", "in", ["active", "completed"])
    .where("expiresAt", "<=", Timestamp.fromDate(now))
    .get();

  const batch = db.batch();
  let count = 0;
  for (const doc of snap.docs) {
    const data = doc.data() as { status?: string; period?: string; expiresAt?: Timestamp };
    if (data.period !== "daily") continue; // weekly / AI quests keep their own lifecycle
    const expiresMs = data.expiresAt?.toMillis() ?? 0;
    if (data.status === "completed" && expiresMs + CLAIM_GRACE_MS > now.getTime()) continue;
    batch.update(doc.ref, { status: "expired", expiredAt: FieldValue.serverTimestamp() });
    count += 1;
  }

  const legacyRef = db.doc(`users/${uid}/quests/${LEGACY_DAILY_QUEST_ID}`);
  const legacy = await legacyRef.get();
  if (legacy.exists && legacy.data()?.status === "active" && legacy.data()?.period !== "daily") {
    batch.update(legacyRef, { status: "expired", expiredAt: FieldValue.serverTimestamp() });
    count += 1;
  }

  // Housekeeping: drop expired quests after two weeks so the collection stays small.
  const staleSnap = await db
    .collection(`users/${uid}/quests`)
    .where("status", "==", "expired")
    .where("expiresAt", "<=", Timestamp.fromMillis(now.getTime() - EXPIRED_RETENTION_MS))
    .limit(50)
    .get();
  for (const doc of staleSnap.docs) batch.delete(doc.ref);

  if (count > 0 || !staleSnap.empty) await batch.commit();
  return count;
}
