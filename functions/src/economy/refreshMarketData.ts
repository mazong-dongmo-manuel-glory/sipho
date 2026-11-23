import { onCall } from "firebase-functions/v2/https";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { fetchCountryNews } from "./economyNewsFetch";
import { DEFAULT_FX_FEED_URL, parseFxFeedPayload } from "./fxRates";
import { ECONOMY_NEWS_COUNTRIES, EconomyNewsCountry } from "../shared/economyNews";
import { logger } from "../shared/logger";
import {
  SECURE_CALLABLE_OPTIONS,
  enforceRateLimit,
  requireAuthUid,
} from "../shared/security";

/**
 * Fills `fx/latest` and `economyNews/{country}` for the signed-in user.
 * Staging (and any environment) can show rates and headlines without waiting for the daily job.
 */
export const refreshMarketData = onCall(SECURE_CALLABLE_OPTIONS, async (request) => {
  const uid = requireAuthUid(request);
  await enforceRateLimit({
    uid,
    action: "refreshMarketData",
    maxRequests: 6,
    windowMs: 60 * 60 * 1000,
  });

  const user = (await getFirestore().doc(`users/${uid}`).get()).data() ?? {};
  const rawCountry = typeof user.countryCode === "string" ? user.countryCode.trim().toUpperCase() : "";
  const country: EconomyNewsCountry = (ECONOMY_NEWS_COUNTRIES as readonly string[]).includes(rawCountry)
    ? (rawCountry as EconomyNewsCountry)
    : "WORLD";

  const fx = await writeFxLatest();
  const news = await writeNews(country);

  return { fx, newsCountry: country, newsItems: news };
});

export async function writeFxLatest(): Promise<boolean> {
  const feedUrl = (process.env.FX_FEED_URL ?? "").trim() || DEFAULT_FX_FEED_URL;
  try {
    const response = await fetch(feedUrl, { headers: { Accept: "application/json" } });
    if (!response.ok) {
      logger.warn("refreshMarketData: fx HTTP error", { status: response.status });
      return false;
    }
    const payload = parseFxFeedPayload(await response.json());
    if (!payload) return false;
    await getFirestore().doc("fx/latest").set(
      {
        base: payload.base,
        rates: payload.rates,
        asOf: payload.asOf ?? FieldValue.serverTimestamp(),
        source: feedUrl,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
    return true;
  } catch (err) {
    logger.warn("refreshMarketData: fx failed", {
      error: err instanceof Error ? err.message : String(err),
    });
    return false;
  }
}

async function writeNews(country: EconomyNewsCountry): Promise<number> {
  try {
    const gnewsKey = (process.env.GNEWS_API_KEY ?? "").trim();
    const doc = await fetchCountryNews(country, gnewsKey);
    await getFirestore().doc(`economyNews/${country}`).set(doc, { merge: false });
    if (country !== "WORLD") {
      const world = await fetchCountryNews("WORLD", gnewsKey);
      await getFirestore().doc("economyNews/WORLD").set(world, { merge: false });
    }
    return doc.items.length;
  } catch (err) {
    logger.warn("refreshMarketData: news failed", {
      country,
      error: err instanceof Error ? err.message : String(err),
    });
    return 0;
  }
}
