import { onSchedule } from "firebase-functions/v2/scheduler";
import { logger } from "../shared/logger";

/**
 * Daily scheduler (07:00 UTC) for FX reference rates.
 * Skips writing hardcoded FX rates unless `FX_FEED_URL` provides a live dated payload.
 */
export const fxRates = onSchedule(
  {
    schedule: "0 7 * * *",
    region: "us-central1",
  },
  async (_event) => {
    const feedUrl = process.env.FX_FEED_URL ?? "";
    if (!feedUrl) {
      logger.info("fxRates: FX_FEED_URL not configured; skipping static FX rates");
      return;
    }
    await Promise.resolve();
    logger.info("fxRates: feed configured");
  }
);
