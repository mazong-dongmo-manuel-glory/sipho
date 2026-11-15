import { onCall } from "firebase-functions/v2/https";
import { getFirestore, Firestore } from "firebase-admin/firestore";
import { ensureDailyQuests } from "../shared/dailyQuests";
import { SECURE_CALLABLE_OPTIONS, enforceRateLimit, requireAuthUid } from "../shared/security";
import { resolveUserTime } from "../shared/timezone";

const db = (): Firestore => getFirestore();

/**
 * Callable: makes sure today's daily quests exist for the caller (local day).
 *
 * Quests are normally created by `onUserProfileCreate` and renewed by `dailyRollover` just after
 * local midnight. This heals the gaps: a rollover that has not reached the user yet, a failed run,
 * or a new quest template that was deployed during the day. Creation is idempotent (deterministic
 * ids), so calling it repeatedly never duplicates or resets a quest.
 */
export const refreshDailyQuests = onCall(SECURE_CALLABLE_OPTIONS, async (request) => {
  const uid = requireAuthUid(request);

  await enforceRateLimit({
    uid,
    action: "refreshDailyQuests",
    maxRequests: 20,
    windowMs: 60 * 60 * 1000,
  });

  const userSnap = await db().doc(`users/${uid}`).get();
  const data = userSnap.data();
  if (!data) return { created: 0 };

  const locale = data.locale === "en" ? "en" : "fr";
  const created = await ensureDailyQuests(db(), uid, resolveUserTime(data), locale, new Date());
  return { created };
});
