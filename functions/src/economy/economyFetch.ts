import { onSchedule } from "firebase-functions/v2/scheduler";
import { logger } from "../shared/logger";

/**
 * Daily scheduler (06:00 UTC) for official economic indicators.
 * Never writes fabricated inflation, policy rates, or unemployment numbers:
 * indicators are persisted only when fetched from a live, dated official connector.
 */
export const economyFetch = onSchedule(
  {
    schedule: "0 6 * * *",
    region: "us-central1",
  },
  (_event) => {
    logger.info("economyFetch: no live official connector configured; skipping fabricated values");
  }
);
