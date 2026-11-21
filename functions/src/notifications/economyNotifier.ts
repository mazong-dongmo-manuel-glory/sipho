import { onSchedule } from "firebase-functions/v2/scheduler";
import { deadlineGuard } from "../shared/pagination";
import {
  localDateKey,
  localMinuteOfDay,
  minuteInWindow,
  resolveUserTime,
} from "../shared/timezone";
import { logger } from "../shared/logger";
import {
  UserProfile,
  canConsumeDailyQuota,
  db,
  forEachUserInLocalWindow,
  hasActiveDevice,
  isQuietHour,
  sendToUser,
} from "./delivery";
import { pickTemplate } from "./templates";

const TIMEOUT_SECONDS = 540;

/** Mid-morning local: after fixed-due window, before lunchtime advice. */
const ECONOMY_DIGEST_WINDOW: [number, number] = [9 * 60, 11 * 60];

/**
 * Daily country economy digest for users who opted into `notifPrefs.economy`.
 * Picks the top headline from `economyNews/{countryCode}` (fallback WORLD).
 */
export const economyNotifier = onSchedule(
  {
    schedule: "every 15 minutes",
    region: "us-central1",
    timeoutSeconds: TIMEOUT_SECONDS,
  },
  async (_event) => {
    const now = new Date();
    const shouldStop = deadlineGuard(TIMEOUT_SECONDS);
    await forEachUserInLocalWindow(
      now,
      ECONOMY_DIGEST_WINDOW,
      "economyNotifier",
      shouldStop,
      (uid, profile) => maybeSendEconomyDigest(uid, profile, now)
    );
  }
);

export async function maybeSendEconomyDigest(
  uid: string,
  profile: UserProfile & { countryCode?: unknown; onboardingDone?: unknown },
  now: Date
): Promise<void> {
  if (profile.notifPrefs?.economy !== true) return;
  if (profile.onboardingDone !== true) return;

  const time = resolveUserTime(profile as Record<string, unknown>);
  if (
    !minuteInWindow(
      localMinuteOfDay(now, time),
      ECONOMY_DIGEST_WINDOW[0],
      ECONOMY_DIGEST_WINDOW[1]
    )
  ) {
    return;
  }
  if (isQuietHour(now, time)) return;

  const today = localDateKey(now, time);
  const notifRef = db().doc(`users/${uid}/notifState/economyDigest`);
  const notifSnap = await notifRef.get();
  if (notifSnap.data()?.lastSentDate === today) return;

  if (!(await hasActiveDevice(uid))) return;
  if (!(await canConsumeDailyQuota(uid, today))) return;

  const country =
    typeof profile.countryCode === "string" && profile.countryCode.trim()
      ? profile.countryCode.trim().toUpperCase()
      : "CA";

  const headline = await loadHeadline(country);
  if (!headline) {
    logger.info("economyNotifier: no headline", { uid, country });
    return;
  }

  const locale = profile.locale === "en" ? "en" : "fr";
  const tpl = pickTemplate("ECONOMY_DIGEST", locale, {
    country,
    headline: truncate(headline, 140),
  });

  await sendToUser(uid, tpl.title, tpl.body, {
    type: "ECONOMY_DIGEST",
    route: "/economy",
    country,
  });
  await notifRef.set({ lastSentDate: today, country, headline }, { merge: true });
}

async function loadHeadline(country: string): Promise<string | null> {
  for (const code of [country, "WORLD"]) {
    const snap = await db().doc(`economyNews/${code}`).get();
    if (!snap.exists) continue;
    const items = snap.data()?.items;
    if (!Array.isArray(items) || items.length === 0) continue;
    for (const raw of items) {
      if (!raw || typeof raw !== "object") continue;
      const item = raw as { title?: unknown; plainTitle?: unknown; emoji?: unknown };
      const title =
        typeof item.plainTitle === "string" && item.plainTitle.trim()
          ? item.plainTitle.trim()
          : typeof item.title === "string"
            ? item.title.trim()
            : "";
      if (!title) continue;
      const emoji = typeof item.emoji === "string" ? item.emoji : "📰";
      return `${emoji} ${title}`;
    }
  }
  return null;
}

function truncate(value: string, max: number): string {
  if (value.length <= max) return value;
  return `${value.slice(0, Math.max(0, max - 1)).trimEnd()}…`;
}
