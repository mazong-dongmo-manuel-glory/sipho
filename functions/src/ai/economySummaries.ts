import { onSchedule } from "firebase-functions/v2/scheduler";
import { logger } from "../shared/logger";

/**
 * Daily scheduler (06:30 UTC) — intentionally skips writing until dated official
 * indicators exist in `economy/{code}` (never fabricates percentages or money impacts).
 */
export const economySummaries = onSchedule(
  {
    schedule: "30 6 * * *",
    region: "us-central1",
  },
  (_event) => {
    logger.info("economySummaries skipped until a dated source is stored");
  }
);
