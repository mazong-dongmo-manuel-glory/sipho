import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { FieldValue } from "firebase-admin/firestore";
import { deadlineGuard, forEachDocument } from "../shared/pagination";
import { localDateKey, resolveUserTime } from "../shared/timezone";
import { logger } from "../shared/logger";
import {
  canConsumeDailyQuota,
  db,
  hasActiveDevice,
  isQuietHour,
  sendToUser,
  UserProfile,
} from "../notifications/delivery";
import { pickTemplate } from "../notifications/templates";

interface EconomyIndicator {
  value?: number;
  date?: string;
  source?: string;
  unit?: string;
}

interface EconomyDoc {
  indicators?: Record<string, EconomyIndicator | undefined>;
}

const RATE_KEYS = ["policy_rate", "keyRate", "key_rate"] as const;
const FANOUT_TIMEOUT_SECONDS = 120;

/**
 * When an official policy / key rate changes for a country pack, notify opted-in
 * users of that country (notifPrefs.economy === true). Counts toward the daily
 * engagement push cap and respects quiet hours.
 */
export const economyAlerts = onDocumentUpdated(
  {
    document: "economy/{countryCode}",
    region: "us-central1",
    timeoutSeconds: FANOUT_TIMEOUT_SECONDS,
  },
  async (event) => {
    const countryCode = String(event.params.countryCode || "").toUpperCase();
    if (!countryCode) return;

    const before = event.data?.before.data() as EconomyDoc | undefined;
    const after = event.data?.after.data() as EconomyDoc | undefined;
    const change = detectRateChange(before, after);
    if (!change) return;

    logger.info("economyAlerts: rate change detected", {
      countryCode,
      ...change,
    });

    const shouldStop = deadlineGuard(FANOUT_TIMEOUT_SECONDS);
    let sent = 0;
    let skipped = 0;

    const result = await forEachDocument(
      db().collection("users").where("countryCode", "==", countryCode),
      async (doc) => {
        const profile = doc.data() as UserProfile & {
          countryCode?: unknown;
          onboardingDone?: unknown;
        };
        const ok = await maybeNotifyRateChange(doc.id, profile, countryCode, change);
        if (ok) sent += 1;
        else skipped += 1;
      },
      {
        label: "economyAlerts",
        shouldStop,
        pageSize: 100,
        concurrency: 5,
      }
    );

    logger.info("economyAlerts: fan-out done", {
      countryCode,
      sent,
      skipped,
      processed: result.processed,
      failed: result.failed,
      stoppedEarly: result.stoppedEarly,
    });
  }
);

export function detectRateChange(
  before: EconomyDoc | undefined,
  after: EconomyDoc | undefined
): { before: number; after: number; source: string; date: string; key: string } | null {
  if (!after?.indicators) return null;
  for (const key of RATE_KEYS) {
    const beforeRate = before?.indicators?.[key]?.value;
    const afterInd = after.indicators[key];
    const afterRate = afterInd?.value;
    const source = afterInd?.source;
    const date = afterInd?.date;
    if (
      typeof beforeRate === "number" &&
      typeof afterRate === "number" &&
      beforeRate !== afterRate &&
      typeof source === "string" &&
      source.trim() &&
      typeof date === "string" &&
      date.trim()
    ) {
      return {
        key,
        before: beforeRate,
        after: afterRate,
        source: source.trim(),
        date: date.trim(),
      };
    }
  }
  return null;
}

async function maybeNotifyRateChange(
  uid: string,
  profile: UserProfile & { onboardingDone?: unknown },
  countryCode: string,
  change: { before: number; after: number; source: string; date: string }
): Promise<boolean> {
  if (profile.notifPrefs?.economy !== true) return false;
  if (profile.onboardingDone !== true) return false;

  const time = resolveUserTime(profile as Record<string, unknown>);
  const now = new Date();
  if (isQuietHour(now, time)) return false;

  const dayKey = localDateKey(now, time);
  const dedupeKey = `${countryCode}:${change.date}:${change.before}->${change.after}`;
  const notifRef = db().doc(`users/${uid}/notifState/economyRate`);
  const notifSnap = await notifRef.get();
  if (notifSnap.data()?.lastChangeKey === dedupeKey) return false;

  if (!(await hasActiveDevice(uid))) return false;
  if (!(await canConsumeDailyQuota(uid, dayKey))) return false;

  const locale = profile.locale === "en" ? "en" : "fr";
  const tpl = pickTemplate("ECONOMY_RATE_CHANGE", locale, {
    country: countryCode,
    before: formatRate(change.before),
    after: formatRate(change.after),
    source: change.source,
    date: change.date,
  });

  await sendToUser(uid, tpl.title, tpl.body, {
    type: "ECONOMY_RATE_CHANGE",
    route: "/economy",
    country: countryCode,
  });
  await notifRef.set(
    {
      lastChangeKey: dedupeKey,
      lastSentAt: FieldValue.serverTimestamp(),
      country: countryCode,
    },
    { merge: true }
  );
  return true;
}

function formatRate(value: number): string {
  return Number.isInteger(value) ? String(value) : value.toFixed(2);
}
