import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import { logger } from "../shared/logger";
import {
  ECONOMY_NEWS_COUNTRIES,
  EconomyNewsCountry,
  EconomyNewsDoc,
  feedLang,
  gnewsTopHeadlinesUrl,
  googleNewsRssUrl,
  parseGnewsJson,
  parseGoogleNewsRss,
} from "../shared/economyNews";

const USER_AGENT =
  "SiphoEconomyBot/1.0 (+https://sipho.app; educational finance app)";

/**
 * Once per day: fetch local economic headlines per priority country.
 * Default provider = Google News RSS (free, no key, ~6 requests/day total).
 * Optional `GNEWS_API_KEY` for CA/FR/WORLD only (free tier ≈ 100 req/day — we use ≤ 3/day).
 */
export const economyNewsFetch = onSchedule(
  {
    schedule: "15 7 * * *", // 07:15 UTC
    region: "us-central1",
    timeoutSeconds: 120,
  },
  async () => {
    const db = admin.firestore();
    const gnewsKey = (process.env.GNEWS_API_KEY ?? "").trim();
    let ok = 0;
    let fail = 0;

    for (const country of ECONOMY_NEWS_COUNTRIES) {
      try {
        const doc = await fetchCountryNews(country, gnewsKey);
        await db.doc(`economyNews/${country}`).set(doc, { merge: false });
        ok += 1;
        logger.info("economyNewsFetch: wrote", {
          country,
          provider: doc.provider,
          count: doc.items.length,
        });
      } catch (err) {
        fail += 1;
        logger.warn("economyNewsFetch: country failed", {
          country,
          error: err instanceof Error ? err.message : String(err),
        });
      }
    }

    logger.info("economyNewsFetch: done", { ok, fail });
  }
);

export async function fetchCountryNews(
  country: EconomyNewsCountry,
  gnewsKey: string
): Promise<EconomyNewsDoc> {
  const lang = feedLang(country);
  const gnewsUrl = gnewsTopHeadlinesUrl(country, gnewsKey);

  if (gnewsUrl) {
    try {
      const json = await fetchJson(gnewsUrl);
      const items = parseGnewsJson(json, lang);
      if (items.length > 0) {
        return {
          countryCode: country,
          fetchedAt: new Date().toISOString(),
          provider: "gnews",
          items,
        };
      }
    } catch (err) {
      logger.warn("economyNewsFetch: gnews failed, falling back to RSS", {
        country,
        error: err instanceof Error ? err.message : String(err),
      });
    }
  }

  const rssUrl = googleNewsRssUrl(country);
  const xml = await fetchText(rssUrl);
  const items = parseGoogleNewsRss(xml, lang);
  return {
    countryCode: country,
    fetchedAt: new Date().toISOString(),
    provider: items.length > 0 ? "google_news_rss" : "none",
    items,
  };
}

async function fetchText(url: string): Promise<string> {
  const res = await fetch(url, {
    headers: {
      "User-Agent": USER_AGENT,
      Accept: "application/rss+xml, application/xml, text/xml, */*",
    },
    redirect: "follow",
  });
  if (!res.ok) {
    throw new Error(`HTTP ${res.status} for ${url.slice(0, 80)}`);
  }
  return res.text();
}

async function fetchJson(url: string): Promise<unknown> {
  const res = await fetch(url, {
    headers: {
      "User-Agent": USER_AGENT,
      Accept: "application/json",
    },
  });
  if (!res.ok) {
    throw new Error(`HTTP ${res.status} gnews`);
  }
  return res.json();
}
