import { onSchedule } from "firebase-functions/v2/scheduler";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { logger } from "../shared/logger";

export type FxLatestDoc = {
  base: string;
  rates: Record<string, number>;
  asOf: FirebaseFirestore.FieldValue | Date;
  source: string;
  updatedAt: FirebaseFirestore.FieldValue;
};

/** ECB reference rates via Frankfurter. No API key. Used when FX_FEED_URL is unset. */
export const DEFAULT_FX_FEED_URL = "https://api.frankfurter.app/latest?from=USD";

/** Parse a frankfurter / exchangerate-style JSON payload into base + rates. */
export function parseFxFeedPayload(raw: unknown): {
  base: string;
  rates: Record<string, number>;
  asOf: Date | null;
} | null {
  if (!raw || typeof raw !== "object") return null;
  const data = raw as Record<string, unknown>;
  const base = typeof data.base === "string" ? data.base.toUpperCase() : "";
  if (!base) return null;
  const rawRates = data.rates;
  if (!rawRates || typeof rawRates !== "object") return null;
  const rates: Record<string, number> = {};
  for (const [key, value] of Object.entries(rawRates as Record<string, unknown>)) {
    if (typeof value === "number" && Number.isFinite(value) && value > 0) {
      rates[key.toUpperCase()] = value;
    }
  }
  if (Object.keys(rates).length === 0) return null;
  const dateRaw = data.date ?? data.asOf;
  let asOf: Date | null = null;
  if (typeof dateRaw === "string") {
    const parsed = Date.parse(dateRaw);
    if (!Number.isNaN(parsed)) asOf = new Date(parsed);
  }
  return { base, rates, asOf };
}

/**
 * Daily scheduler (07:00 UTC) for FX reference rates.
 * Writes `fx/latest` from `FX_FEED_URL`, or Frankfurter (ECB) when that env is empty.
 * Never invents a rate: a bad payload is skipped.
 */
export const fxRates = onSchedule(
  {
    schedule: "0 7 * * *",
    region: "us-central1",
  },
  async (_event) => {
    const feedUrl = (process.env.FX_FEED_URL ?? "").trim() || DEFAULT_FX_FEED_URL;

    const response = await fetch(feedUrl, {
      headers: { Accept: "application/json" },
    });
    if (!response.ok) {
      logger.warn("fxRates: feed HTTP error", {
        status: response.status,
        statusText: response.statusText,
      });
      return;
    }

    const payload = parseFxFeedPayload(await response.json());
    if (!payload) {
      logger.warn("fxRates: feed payload rejected");
      return;
    }

    await getFirestore()
      .doc("fx/latest")
      .set(
        {
          base: payload.base,
          rates: payload.rates,
          asOf: payload.asOf ?? FieldValue.serverTimestamp(),
          source: feedUrl,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

    logger.info("fxRates: wrote fx/latest", {
      base: payload.base,
      currencies: Object.keys(payload.rates).length,
    });
  }
);
