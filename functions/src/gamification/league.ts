import { onCall } from "firebase-functions/v2/https";
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore, Firestore, Timestamp } from "firebase-admin/firestore";
import {
  SECURE_CALLABLE_OPTIONS,
  enforceRateLimit,
  requireAuthUid,
} from "../shared/security";
import { addLeagueXp, closeLeagueGroup, ensureLeagueMembership } from "../shared/leagueService";
import { deadlineGuard, forEachDocument } from "../shared/pagination";
import { logger } from "../shared/logger";

const db = (): Firestore => getFirestore();

/**
 * Callable: returns the group the user plays in this week, joining one if needed.
 * The client then reads `leagues/{leagueKey}/members` (read-only) to display the ranking.
 */
export const joinLeague = onCall(SECURE_CALLABLE_OPTIONS, async (request) => {
  const uid = requireAuthUid(request);
  await enforceRateLimit({
    uid,
    action: "joinLeague",
    maxRequests: 60,
    windowMs: 60 * 60 * 1000,
  });
  return ensureLeagueMembership(db(), uid);
});

/**
 * Every XP award writes `users/{uid}/game/state`. This trigger turns the XP delta into league
 * points, minus any growth of `leagueExemptXp` (referral rewards — anti-league farming).
 */
export const onGameXpChange = onDocumentWritten(
  { document: "users/{uid}/game/state", region: "us-central1" },
  async (event) => {
    const after = event.data?.after.data();
    if (!after) return;
    const before = event.data?.before.data();
    const afterXp = typeof after.xp === "number" ? after.xp : 0;
    const beforeXp = typeof before?.xp === "number" ? before.xp : 0;
    const delta = afterXp - beforeXp;
    if (delta <= 0) return;

    const afterExempt =
      typeof after.leagueExemptXp === "number" ? Math.max(0, Math.trunc(after.leagueExemptXp)) : 0;
    const beforeExempt =
      typeof before?.leagueExemptXp === "number"
        ? Math.max(0, Math.trunc(before.leagueExemptXp))
        : 0;
    const exemptDelta = Math.max(0, afterExempt - beforeExempt);
    const leagueDelta = delta - exemptDelta;
    if (leagueDelta <= 0) return;

    await addLeagueXp(
      db(),
      event.params.uid,
      leagueDelta,
      typeof after.level === "number" ? after.level : 1,
      event.id
    );
  }
);

const WEEKLY_TIMEOUT_SECONDS = 540;

/**
 * Hourly: closes every group whose week has ended (promotions / relegations).
 * Self-healing: a failed or late run is simply picked up by the next one.
 */
export const leagueWeekly = onSchedule(
  {
    schedule: "every 1 hours",
    region: "us-central1",
    timeoutSeconds: WEEKLY_TIMEOUT_SECONDS,
  },
  async () => {
    const now = new Date();
    const result = await forEachDocument(
      db()
        .collection("leagues")
        .where("processed", "==", false)
        .where("endsAt", "<=", Timestamp.fromDate(now)),
      async (doc) => {
        await closeLeagueGroup(db(), doc, now);
      },
      { pageSize: 50, concurrency: 5, label: "leagueWeekly", shouldStop: deadlineGuard(WEEKLY_TIMEOUT_SECONDS) }
    );
    logger.info("leagueWeekly done", { ...result });
  }
);
