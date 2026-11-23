import {
  Firestore,
  FieldValue,
  QueryDocumentSnapshot,
  Timestamp,
} from "firebase-admin/firestore";
import {
  LEAGUE_GROUP_SIZE,
  leagueTierId,
  leagueTierIndex,
  leagueWeekEnd,
  leagueWeekKey,
  planLeagueOutcomes,
  LeagueOutcome,
} from "./leagues";
import { logger } from "./logger";

export interface LeagueMembership {
  leagueKey: string;
  tier: string;
  week: string;
  endsAtMs: number;
}

function toMembership(data: FirebaseFirestore.DocumentData): LeagueMembership {
  const endsAt = data.endsAt instanceof Timestamp ? data.endsAt.toMillis() : 0;
  return {
    leagueKey: String(data.leagueKey),
    tier: String(data.tier),
    week: String(data.week),
    endsAtMs: endsAt,
  };
}

function cleanPseudo(value: unknown): string {
  return typeof value === "string" && value.trim() ? value.trim().slice(0, 40) : "Sipho";
}

const CONTENTION_CODES = new Set([10, 4]); // ABORTED, DEADLINE_EXCEEDED (lock timeouts)

/**
 * Many players can open the app at the same minute (start of the week), all trying to take a seat
 * in the same open group. Firestore then aborts some transactions on lock timeout: retry them
 * with a random delay instead of failing the player.
 */
async function withContentionRetry<T>(run: () => Promise<T>, attempts = 8): Promise<T> {
  for (let attempt = 1; ; attempt++) {
    try {
      return await run();
    } catch (error) {
      const code = (error as { code?: unknown }).code;
      if (attempt >= attempts || typeof code !== "number" || !CONTENTION_CODES.has(code)) {
        throw error;
      }
      const delay = Math.random() * Math.min(2000, 100 * 2 ** attempt);
      await new Promise((resolve) => setTimeout(resolve, delay));
    }
  }
}

/**
 * Makes sure the user belongs to a group for the CURRENT league week and returns it.
 *
 * Idempotent: a user already in this week's group keeps it. Otherwise they join an open group of
 * their tier (tier = `game/state.leagueId`) or start a new one. Everything runs in one
 * transaction, so two players can never overfill a group.
 */
export function ensureLeagueMembership(
  db: Firestore,
  uid: string,
  now: Date = new Date()
): Promise<LeagueMembership> {
  return withContentionRetry(() => joinOnce(db, uid, now));
}

async function joinOnce(db: Firestore, uid: string, now: Date): Promise<LeagueMembership> {
  const week = leagueWeekKey(now);
  const endsAt = Timestamp.fromDate(leagueWeekEnd(now));
  const membershipRef = db.doc(`users/${uid}/league/current`);

  return db.runTransaction(async (tx) => {
    const [membershipSnap, gameSnap, profileSnap] = await Promise.all([
      tx.get(membershipRef),
      tx.get(db.doc(`users/${uid}/game/state`)),
      tx.get(db.doc(`publicProfiles/${uid}`)),
    ]);

    const existing = membershipSnap.data();
    if (existing && existing.week === week && typeof existing.leagueKey === "string") {
      return toMembership(existing);
    }

    const game = gameSnap.data() ?? {};
    const tier = leagueTierId(leagueTierIndex(game.leagueId));
    const openGroups = await tx.get(
      db
        .collection("leagues")
        .where("week", "==", week)
        .where("tier", "==", tier)
        .where("open", "==", true)
        .limit(1)
    );

    let groupRef: FirebaseFirestore.DocumentReference;
    if (!openGroups.empty) {
      const group = openGroups.docs[0];
      groupRef = group.ref;
      const count = (Number(group.data().memberCount) || 0) + 1;
      tx.update(groupRef, { memberCount: count, open: count < LEAGUE_GROUP_SIZE });
    } else {
      groupRef = db.collection("leagues").doc();
      tx.set(groupRef, {
        week,
        tier,
        open: true,
        processed: false,
        memberCount: 1,
        endsAt,
        createdAt: FieldValue.serverTimestamp(),
      });
    }

    const profile = profileSnap.data() ?? {};
    tx.set(groupRef.collection("members").doc(uid), {
      uid,
      pseudo: cleanPseudo(profile.pseudo),
      avatar: typeof profile.avatar === "string" ? profile.avatar : "tisserin_default",
      level: typeof game.level === "number" ? Math.max(1, Math.trunc(game.level)) : 1,
      weeklyXp: 0,
      lastEventId: null,
      joinedAt: FieldValue.serverTimestamp(),
    });
    tx.set(membershipRef, {
      leagueKey: groupRef.id,
      tier,
      week,
      endsAt,
      joinedAt: FieldValue.serverTimestamp(),
    });

    return { leagueKey: groupRef.id, tier, week, endsAtMs: endsAt.toMillis() };
  });
}

/**
 * Adds XP earned by the user to their current group (joining one if needed).
 * `eventId` makes a redelivered trigger event count only once.
 */
export async function addLeagueXp(
  db: Firestore,
  uid: string,
  deltaXp: number,
  level: number,
  eventId: string,
  now: Date = new Date()
): Promise<void> {
  if (!(deltaXp > 0)) return;
  const membership = await ensureLeagueMembership(db, uid, now);
  const memberRef = db.doc(`leagues/${membership.leagueKey}/members/${uid}`);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(memberRef);
    if (!snap.exists || snap.data()?.lastEventId === eventId) return;
    tx.update(memberRef, {
      weeklyXp: FieldValue.increment(Math.trunc(deltaXp)),
      level: Math.max(1, Math.trunc(level)),
      lastEventId: eventId,
    });
  });
}

/**
 * Closes one finished group: ranks it, moves players up/down (`game/state.leagueId`), resets their
 * weekly XP and records each player's result in `users/{uid}/league/lastResult`.
 * The whole group is written in one batch, so a failure leaves it untouched and retryable.
 */
export async function closeLeagueGroup(
  db: Firestore,
  group: QueryDocumentSnapshot,
  now: Date = new Date()
): Promise<LeagueOutcome[]> {
  const data = group.data();
  if (data.processed === true) return [];

  const tierIndex = leagueTierIndex(data.tier);
  const membersSnap = await group.ref.collection("members").get();
  const gameRefs = membersSnap.docs.map((m) => db.doc(`users/${m.id}/game/state`));
  const gameSnaps = gameRefs.length > 0 ? await db.getAll(...gameRefs) : [];
  const alive = new Set(gameSnaps.filter((s) => s.exists).map((s) => s.ref.parent.parent?.id));

  const scored = membersSnap.docs
    .filter((m) => alive.has(m.id)) // deleted accounts do not count
    .map((m) => ({ uid: m.id, weeklyXp: Math.max(0, Number(m.data().weeklyXp) || 0) }));
  const outcomes = planLeagueOutcomes(scored, tierIndex);

  const batch = db.batch();
  for (const o of outcomes) {
    batch.set(
      db.doc(`users/${o.uid}/game/state`),
      { leagueId: o.toTier, weeklyXp: 0 },
      { merge: true }
    );
    batch.set(db.doc(`publicProfiles/${o.uid}`), { league: o.toTier }, { merge: true });
    batch.set(db.doc(`users/${o.uid}/league/lastResult`), {
      week: String(data.week),
      rank: o.rank,
      groupSize: outcomes.length,
      weeklyXp: o.weeklyXp,
      result: o.result,
      fromTier: o.fromTier,
      toTier: o.toTier,
      createdAt: FieldValue.serverTimestamp(),
    });
    batch.update(group.ref.collection("members").doc(o.uid), {
      rank: o.rank,
      result: o.result,
    });
  }
  batch.update(group.ref, {
    processed: true,
    open: false,
    processedAt: Timestamp.fromDate(now),
  });
  await batch.commit();

  logger.info("league group closed", {
    group: group.id,
    tier: data.tier,
    week: data.week,
    members: outcomes.length,
    promoted: outcomes.filter((o) => o.result === "promoted").length,
    relegated: outcomes.filter((o) => o.result === "relegated").length,
  });
  return outcomes;
}
