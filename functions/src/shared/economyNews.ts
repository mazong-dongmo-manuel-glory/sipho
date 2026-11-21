/**
 * Local economic headlines — free Google News RSS by country (no API key).
 * Optional GNews (`GNEWS_API_KEY`) for CA/FR when configured.
 *
 * Design goals: 1 request/country/day, simple plain-language bullets, no invented figures.
 */

export type EconomyNewsCountry = "CA" | "FR" | "CM" | "CI" | "SN" | "WORLD";

export interface EconomyNewsItem {
  id: string;
  title: string;
  plainTitle: string;
  takeaway: string;
  topic: "inflation" | "housing" | "rates" | "jobs" | "purchasing_power" | "general";
  emoji: string;
  source: string;
  url: string;
  publishedAt: string | null;
}

export interface EconomyNewsDoc {
  countryCode: string;
  fetchedAt: string;
  provider: "google_news_rss" | "gnews" | "none";
  items: EconomyNewsItem[];
}

export const ECONOMY_NEWS_COUNTRIES: EconomyNewsCountry[] = [
  "CA",
  "FR",
  "CM",
  "CI",
  "SN",
  "WORLD",
];

interface FeedConfig {
  countryCode: EconomyNewsCountry;
  lang: "fr" | "en";
  /** Google News gl / ceid country */
  gl: string;
  hl: string;
  ceid: string;
  query: string;
}

const FEEDS: Record<EconomyNewsCountry, FeedConfig> = {
  CA: {
    countryCode: "CA",
    lang: "en",
    gl: "CA",
    hl: "en-CA",
    ceid: "CA:en",
    query:
      'inflation OR "cost of living" OR housing OR mortgage OR "Bank of Canada" OR grocery',
  },
  FR: {
    countryCode: "FR",
    lang: "fr",
    gl: "FR",
    hl: "fr",
    ceid: "FR:fr",
    query:
      "inflation OR \"pouvoir d'achat\" OR logement OR loyer OR \"taux directeur\" OR emploi OR essence",
  },
  CM: {
    countryCode: "CM",
    lang: "fr",
    gl: "CM",
    hl: "fr",
    ceid: "CM:fr",
    query:
      "économie OR inflation OR FCFA OR logement OR emploi OR BEAC OR Cameroun",
  },
  CI: {
    countryCode: "CI",
    lang: "fr",
    gl: "CI",
    hl: "fr",
    ceid: "CI:fr",
    query:
      "économie OR inflation OR FCFA OR logement OR emploi OR \"Côte d'Ivoire\" OR Abidjan",
  },
  SN: {
    countryCode: "SN",
    lang: "fr",
    gl: "SN",
    hl: "fr",
    ceid: "SN:fr",
    query:
      "économie OR inflation OR FCFA OR logement OR emploi OR Sénégal OR Dakar",
  },
  WORLD: {
    countryCode: "WORLD",
    lang: "en",
    gl: "US",
    hl: "en",
    ceid: "US:en",
    query: "inflation OR \"central bank\" OR housing OR \"cost of living\" OR oil",
  },
};

export function googleNewsRssUrl(country: EconomyNewsCountry): string {
  const cfg = FEEDS[country];
  const params = new URLSearchParams({
    q: cfg.query,
    hl: cfg.hl,
    gl: cfg.gl,
    ceid: cfg.ceid,
  });
  return `https://news.google.com/rss/search?${params.toString()}`;
}

export function gnewsTopHeadlinesUrl(
  country: EconomyNewsCountry,
  apiKey: string,
  max = 8
): string | null {
  // GNews free country list is limited; only use for CA/FR/WORLD→us.
  const map: Partial<Record<EconomyNewsCountry, { country: string; lang: string }>> = {
    CA: { country: "ca", lang: "en" },
    FR: { country: "fr", lang: "fr" },
    WORLD: { country: "us", lang: "en" },
  };
  const mapped = map[country];
  if (!mapped || !apiKey.trim()) return null;
  const params = new URLSearchParams({
    category: "business",
    country: mapped.country,
    lang: mapped.lang,
    max: String(max),
    apikey: apiKey.trim(),
  });
  return `https://gnews.io/api/v4/top-headlines?${params.toString()}`;
}

/** Strip HTML / Google News " - Publisher" suffix. */
export function plainHeadline(raw: string): string {
  let t = raw
    .replace(/<!\[CDATA\[([\s\S]*?)\]\]>/g, "$1")
    .replace(/<[^>]+>/g, "")
    .replace(/&amp;/g, "&")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .trim();
  // "Title - Source Name"
  const dash = t.lastIndexOf(" - ");
  if (dash > 20) t = t.slice(0, dash).trim();
  if (t.length > 140) t = `${t.slice(0, 137).trim()}…`;
  return t;
}

export function classifyTopic(
  title: string
): EconomyNewsItem["topic"] {
  const t = title.toLowerCase();
  if (/inflation|ipc|cpi|prix|prices|grocery|essence|carburant/.test(t)) {
    return "inflation";
  }
  if (/logement|loyer|housing|mortgage|hypothèque|immobilier|rent/.test(t)) {
    return "housing";
  }
  if (/taux|rate|banque|fed|bce|beac|central bank|directeur/.test(t)) {
    return "rates";
  }
  if (/emploi|chômage|job|unemployment|salaire|wage/.test(t)) {
    return "jobs";
  }
  if (/pouvoir d'achat|cost of living|coût de la vie|achat/.test(t)) {
    return "purchasing_power";
  }
  return "general";
}

export function topicEmoji(topic: EconomyNewsItem["topic"]): string {
  switch (topic) {
    case "inflation":
      return "📉";
    case "housing":
      return "🏠";
    case "rates":
      return "🏛️";
    case "jobs":
      return "💼";
    case "purchasing_power":
      return "🛒";
    default:
      return "📰";
  }
}

/** Short educational takeaway — no invented numbers. */
export function buildTakeaway(
  title: string,
  topic: EconomyNewsItem["topic"],
  lang: "fr" | "en"
): string {
  const fr = lang === "fr";
  switch (topic) {
    case "inflation":
      return fr
        ? "Si les prix montent, revois ton enveloppe courses/transport avant le reste. Sipho ne cite aucun chiffre hors sources datées."
        : "If prices rise, revisit groceries/transport envelopes first. Sipho never invents rates — only dated sources.";
    case "housing":
      return fr
        ? "Logement : vérifie loyer/prêt dans ton socle et garde une petite réserve. Pas de conseil d’achat immobilier ici."
        : "Housing: check rent/mortgage in your nest and keep a small buffer. This is not property advice.";
    case "rates":
      return fr
        ? "Un changement de taux peut toucher crédit et épargne. Compare sans te précipiter ; l’app reste éducative."
        : "Rate changes can affect borrowing and savings. Compare calmly — Sipho stays educational.";
    case "jobs":
      return fr
        ? "Emploi/revenus : mets à jour ton revenu dans le profil si ta situation change, pour un reste à vivre juste."
        : "Jobs/income: update your income in profile if things change, so living money stays accurate.";
    case "purchasing_power":
      return fr
        ? "Pouvoir d’achat : priorise besoins vs envies cette semaine et note tes dépenses variables."
        : "Purchasing power: prioritise needs vs wants this week and log variable spends.";
    default:
      return fr
        ? `Actu locale : « ${plainHeadline(title)} ». Lis la source si tu veux le détail — Sipho résume sans inventer.`
        : `Local headline: “${plainHeadline(title)}”. Open the source for detail — Sipho summarises without inventing figures.`;
  }
}

export function parseGoogleNewsRss(xml: string, lang: "fr" | "en"): EconomyNewsItem[] {
  const items: EconomyNewsItem[] = [];
  const itemBlocks = xml.match(/<item>[\s\S]*?<\/item>/gi) ?? [];
  for (const block of itemBlocks) {
    const title = matchTag(block, "title");
    const link = matchTag(block, "link");
    const pubDate = matchTag(block, "pubDate");
    const source = matchTag(block, "source") || "Google News";
    if (!title || !link) continue;
    const plain = plainHeadline(title);
    if (plain.length < 12) continue;
    const topic = classifyTopic(plain);
    const publishedAt = pubDate ? safeIso(pubDate) : null;
    items.push({
      id: hashId(plain + link),
      title: plain,
      plainTitle: plain,
      takeaway: buildTakeaway(plain, topic, lang),
      topic,
      emoji: topicEmoji(topic),
      source: plainHeadline(source),
      url: link.trim(),
      publishedAt,
    });
    if (items.length >= 8) break;
  }
  return dedupeByTitle(items).slice(0, 6);
}

export function parseGnewsJson(
  payload: unknown,
  lang: "fr" | "en"
): EconomyNewsItem[] {
  if (!payload || typeof payload !== "object") return [];
  const articles = (payload as { articles?: unknown }).articles;
  if (!Array.isArray(articles)) return [];
  const items: EconomyNewsItem[] = [];
  for (const raw of articles) {
    if (!raw || typeof raw !== "object") continue;
    const a = raw as Record<string, unknown>;
    const title = typeof a.title === "string" ? a.title : "";
    const url = typeof a.url === "string" ? a.url : "";
    if (!title || !url) continue;
    const plain = plainHeadline(title);
    const topic = classifyTopic(plain);
    const sourceName =
      a.source && typeof a.source === "object" && a.source !== null
        ? String((a.source as { name?: string }).name ?? "GNews")
        : "GNews";
    items.push({
      id: hashId(plain + url),
      title: plain,
      plainTitle: plain,
      takeaway: buildTakeaway(plain, topic, lang),
      topic,
      emoji: topicEmoji(topic),
      source: sourceName,
      url,
      publishedAt:
        typeof a.publishedAt === "string" ? a.publishedAt : null,
    });
    if (items.length >= 6) break;
  }
  return dedupeByTitle(items);
}

function matchTag(block: string, tag: string): string {
  const re = new RegExp(`<${tag}[^>]*>([\\s\\S]*?)<\\/${tag}>`, "i");
  const m = block.match(re);
  return m ? m[1].trim() : "";
}

function safeIso(pubDate: string): string | null {
  const d = new Date(pubDate);
  return Number.isNaN(d.getTime()) ? null : d.toISOString();
}

function hashId(input: string): string {
  let h = 0;
  for (let i = 0; i < input.length; i++) {
    h = (h * 31 + input.charCodeAt(i)) | 0;
  }
  return `n_${(h >>> 0).toString(16)}`;
}

function dedupeByTitle(items: EconomyNewsItem[]): EconomyNewsItem[] {
  const seen = new Set<string>();
  const out: EconomyNewsItem[] = [];
  for (const item of items) {
    const key = item.plainTitle.toLowerCase().slice(0, 48);
    if (seen.has(key)) continue;
    seen.add(key);
    out.push(item);
  }
  return out;
}

export function feedLang(country: EconomyNewsCountry): "fr" | "en" {
  return FEEDS[country].lang;
}
