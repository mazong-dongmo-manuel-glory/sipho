import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { missingBadges } from "../shared/badges";
import { normalizeGameState } from "../shared/gameState";
import { logger } from "../shared/logger";

const db = (): Firestore => getFirestore();

/**
 * Awards every badge the user now qualifies for and returns the ids that were newly added.
 *
 * Idempotent and safe to run any number of times: badges come from state that only grows
 * (see shared/badges.ts) and are added with `arrayUnion`, so a concurrent run cannot drop one.
 * Badges are cosmetic (no XP), so awarding never feeds the XP or league economy.
 */
export async function syncBadges(uid: string): Promise<string[]> {
  const gameRef = db().doc(`users/${uid}/game/state`);
  const [gameSnap, userSnap] = await Promise.all([gameRef.get(), db().doc(`users/${uid}`).get()]);
  if (!gameSnap.exists) return [];

  const game = normalizeGameState(gameSnap.data());
  const completed: unknown = userSnap.data()?.completedLessonIds;
  const completedLessonIds = new Set<string>(
    Array.isArray(completed)
      ? (completed as unknown[]).filter((id): id is string => typeof id === "string")
      : []
  );

  const added = missingBadges(
    {
      level: game.level,
      bestStreak: game.streak.best,
      leagueId: game.leagueId,
      completedLessonIds,
      onboardingDone: userSnap.data()?.onboardingDone === true,
    },
    game.badges
  );
  if (added.length === 0) return [];

  await gameRef.update({ badges: FieldValue.arrayUnion(...added) });
  // Friends read the public profile only (never amounts): badges are shown there too.
  await db()
    .doc(`publicProfiles/${uid}`)
    .set({ badges: FieldValue.arrayUnion(...added) }, { merge: true });
  return added;
}

/**
 * Every award path (lessons, streaks, XP, leagues) writes `users/{uid}/game/state`, so one
 * trigger covers them all and no path can forget to check badges. Writing the badges triggers it
 * once more, which finds nothing to add and stops.
 */
export const onGameBadgeCheck = onDocumentWritten(
  { document: "users/{uid}/game/state", region: "us-central1" },
  async (event) => {
    if (!event.data?.after.exists) return;
    const uid = event.params.uid;
    const added = await syncBadges(uid);
    if (added.length > 0) logger.info("badges awarded", { uid, badges: added });
  }
);

/**
 * Client finishes onboarding by setting `users/{uid}.onboardingDone` only (cannot write
 * `game/state`). Award the builder badge when that flag flips to true.
 */
export const onUserOnboardingDone = onDocumentWritten(
  { document: "users/{uid}", region: "us-central1" },
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!after || after.onboardingDone !== true || before?.onboardingDone === true) {
      return;
    }
    const uid = event.params.uid;
    const added = await syncBadges(uid);
    if (added.length > 0) {
      logger.info("badges awarded after onboarding", { uid, badges: added });
    }
  }
);
