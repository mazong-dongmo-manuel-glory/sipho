import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { getFirestore } from "firebase-admin/firestore";
import { ensureDailyQuests } from "../shared/dailyQuests";
import { resolveUserTime } from "../shared/timezone";
import { logger } from "../shared/logger";

/**
 * Fires when the client creates `users/{uid}` (after sign-in). The first daily quests need the
 * user's time zone, which only exists on this document, so they are created here rather than in
 * the Auth `onUserCreate` trigger. `dailyRollover` renews them every local day afterwards.
 */
export const onUserProfileCreate = onDocumentCreated(
  {
    document: "users/{uid}",
    region: "us-central1",
  },
  async (event) => {
    const data = event.data?.data();
    if (!data) return;
    const uid = event.params.uid;
    const locale = data.locale === "en" ? "en" : "fr";
    await ensureDailyQuests(getFirestore(), uid, resolveUserTime(data), locale, new Date());
    logger.info("initial daily quests ensured", { uid });
  }
);
