/**
 * Country AI lessons: awardable **slots** (stable ids for XP) + a large **topic bank**
 * (themes / news-politics angles). Content is generated on demand by Gemini into the
 * user's locale — topics are never awardable themselves.
 *
 * Keep slot ids in sync with the Flutter country learn UI when it lists slots.
 */

export const SLOTS_PER_COUNTRY = 10;

export interface CountrySlot {
  id: string;
  countries: readonly string[];
}

export interface TopicSeed {
  id: string;
  countries: readonly string[];
  theme: string;
  /** News / political-economy angle — educational, no invented figures. */
  angle: string;
  sourceHint: string;
}

type CountryPack = {
  prefix: string;
  countries: readonly string[];
  sourceHint: string;
  themes: readonly string[];
};

/** Shared angles: how to frame a theme against current economic / political context. */
const NEWS_ANGLES: readonly string[] = [
  "how today's headlines may affect household cash flow (no invented rates)",
  "what a policy debate means for savers in plain language",
  "spotting hype vs facts when politicians talk about the cost of living",
  "why media 'market moves' rarely need an immediate personal reaction",
  "linking a labour-market story to paycheck timing habits",
  "housing / rent stories: questions to ask before changing your budget",
  "inflation talk: separating official stats talk from shop-floor prices",
  "public benefits or transfers in the news: verify on official pages",
  "tax or levy debates: educational awareness only, never advice",
  "central bank or currency talk without inventing numbers",
  "election-season spending promises: how to stay calm with your plan",
  "subsidy or fuel-price stories: track impact, don't panic-buy",
  "remittance / FX headlines: fee hygiene without quoting fake rates",
  "scam waves that follow big news events",
  "strikes or supply shocks: short-term budget buffers",
  "minimum-wage or salary news: budgeting without overreacting",
  "bank fee or regulation stories: read your own contract",
  "digital payment outages in the news: backup cash habits",
  "climate or disaster aid stories: emergency buffer mindset",
  "youth employment programs in the news: skills vs hype",
  "informal economy debates: tontine / cash safety reminders",
  "corruption or transparency stories: protect your own documents",
  "trade / import stories: shopping habits without inventing prices",
  "energy bill headlines: usage tracking, not tariff invention",
  "interest-rate speculation in media: ignore exact guesses",
  "pension or social-security debates: official sources only",
  "small-business tax talk: employees vs owners, stay educational",
  "tourism or CFA/euro stories: travel cash planning",
  "agriculture / food price narratives: meal planning resilience",
  "public debt debates: what households can still control",
  "fintech licensing news: check official apps only",
  "identity-theft waves after data-breach headlines",
  "cost-of-living protests: keep personal tracking habits",
  "school / fee calendar news: sinking-fund habits",
  "healthcare cost stories: emergency buffer awareness",
  "urban transport fare debates: commute budget review",
  "housing aid programs in the news: verify eligibility officially",
  "consumer credit crackdowns: reading loan contracts carefully",
  "savings-product marketing after rate headlines: compare terms yourself",
  "diaspora investment hype after political news: pause and verify",
];

const CA_THEMES: readonly string[] = [
  "TFSA / CELI account basics",
  "RRSP / REER basics",
  "FHSA / CELIAPP first-home basics",
  "Chequing vs savings in Canada",
  "GST/HST/PST awareness (no rates invented)",
  "Credit report & score basics in Canada",
  "RESP education savings basics",
  "CPP/QPP and OAS public retirement awareness",
  "Payday rhythm and bill timing in CAD",
  "Common Canadian money scams",
  "Banking fees and Interac habits",
  "Provincial vs federal benefit awareness",
  "Renters' insurance mindset in Canada",
  "Student loan repayment awareness (Canada)",
  "Emergency fund in a Canadian winter context",
  "Comparing big-bank vs credit-union talk",
  "Payroll deductions awareness (no tax advice)",
  "Cross-border shopping fee hygiene",
  "Canadian phishing and CRA-impersonation scams",
  "Building a simple monthly CAD budget",
];

const FR_THEMES: readonly string[] = [
  "Livret A regulated savings",
  "PEA investing wrapper basics",
  "PER retirement plan basics",
  "Assurance-vie as a savings wrapper",
  "LDDS / livret développement durable",
  "PEL / CEL housing savings awareness",
  "Monthly budget in euros (rent, transport, mutuelle)",
  "Consumer credit & fichier des incidents (awareness)",
  "Income tax declaration awareness (not advice)",
  "Common French money scams",
  "Prélèvements automatiques hygiene",
  "APL / housing aid awareness (verify official sites)",
  "Mutuelle and unexpected health costs buffer",
  "Navigo / commute cost tracking",
  "Micro-crédit pitfalls in France",
  "Banque en ligne vs banque traditionnelle fees",
  "Épargne de précaution en euros",
  "Phishing impôts.gouv / AMF awareness",
  "Loyer charges and annual revision talks (no invented %)",
  "Budget étudiant or premier emploi in France",
];

const CM_THEMES: readonly string[] = [
  "Tontines / rotating savings in Cameroon",
  "Mobile money safety (MTN / Orange)",
  "Budgeting in XAF",
  "Microfinance & credit union awareness",
  "Receiving remittances carefully",
  "Mobile money and advance-fee scams",
  "Prices and purchasing power awareness",
  "Cash vs MoMo for market shopping",
  "Airtime and data expense tracking",
  "School fee sinking funds",
  "Informal lender risks",
  "BEAC / CFA talk without inventing rates",
  "Family support transfers planning",
  "SIM-swap and MoMo PIN hygiene",
  "Small trader daily cash discipline",
  "Fuel and transport cost tracking",
  "Health emergency cash buffer",
  "Avoiding fake investment clubs",
  "Document safekeeping for bank/MoMo KYC",
  "Seasonal income smoothing habits",
];

const CI_THEMES: readonly string[] = [
  "Tontines / rotating savings in Côte d'Ivoire",
  "Mobile money (Wave / Orange / MTN)",
  "Budgeting in XOF",
  "Microfinance awareness",
  "Remittances and transfer fees",
  "Payment and identity scams",
  "Prices and purchasing power awareness",
  "Abidjan rent and transport tracking",
  "Wave vs bank account habits",
  "School and ceremony sinking funds",
  "Informal credit risks",
  "BCEAO / CFA talk without inventing rates",
  "Family obligations vs personal buffer",
  "PIN and QR payment hygiene",
  "Market trader cash counting habits",
  "Fuel price headline resilience",
  "Health cash emergency habits",
  "Fake 'placement' WhatsApp schemes",
  "KYC document safety",
  "Harvest or bonus month smoothing",
];

const SN_THEMES: readonly string[] = [
  "Tontines / rotating savings in Senegal",
  "Mobile money (Wave / Orange)",
  "Budgeting in XOF",
  "Microfinance awareness",
  "Remittances carefully",
  "Payment scams",
  "Prices and purchasing power awareness",
  "Dakar transport and food cost tracking",
  "Wave cash-out fee awareness (check your app)",
  "School fee planning",
  "Informal lender risks",
  "BCEAO / CFA talk without inventing rates",
  "Diaspora support transfers planning",
  "QR and PIN hygiene",
  "Market and boutique cash discipline",
  "Energy and water bill tracking",
  "Health emergency buffer",
  "Fake lottery and avance-de-frais scams",
  "KYC and ID document safety",
  "Tabaski / ceremony sinking funds",
];

const GEN_THEMES: readonly string[] = [
  "Interest-bearing savings comparison habits",
  "Spotting bank and card fees",
  "Consumer debt trade-offs",
  "Insurance as risk transfer (basics)",
  "Digital payments hygiene",
  "Local emergency buffer habits",
  "Needs vs wants under media pressure",
  "Building a one-page monthly budget",
  "Payday sequencing: bills then goals",
  "Subscription audit habits",
  "Cash envelope vs app tracking",
  "Avoiding get-rich-quick social posts",
  "Reading a loan contract checklist",
  "Currency conversion fee hygiene when traveling",
  "Family money requests and boundaries",
  "Side-income tracking without mixing pots",
  "Goal sinking funds (rent, school, travel)",
  "Password and 2FA for money apps",
  "When headlines urge panic spending",
  "Reviewing your fixed vs variable spend",
];

const PACKS: readonly CountryPack[] = [
  {
    prefix: "ca",
    countries: ["CA"],
    sourceHint: "CRA / FCAC / Service Canada / Canadian Anti-Fraud Centre",
    themes: CA_THEMES,
  },
  {
    prefix: "fr",
    countries: ["FR"],
    sourceHint: "service-public.fr / AMF / impots.gouv.fr / Banque de France",
    themes: FR_THEMES,
  },
  {
    prefix: "cm",
    countries: ["CM"],
    sourceHint: "your operator / licensed MFI / BEAC notices / police",
    themes: CM_THEMES,
  },
  {
    prefix: "ci",
    countries: ["CI"],
    sourceHint: "your operator / licensed MFI / BCEAO notices / police",
    themes: CI_THEMES,
  },
  {
    prefix: "sn",
    countries: ["SN"],
    sourceHint: "your operator / licensed MFI / BCEAO notices / police",
    themes: SN_THEMES,
  },
  {
    prefix: "gen",
    countries: ["*"],
    sourceHint: "your bank contract / lender documents / official regulator sites",
    themes: GEN_THEMES,
  },
];

function buildSlots(): CountrySlot[] {
  const slots: CountrySlot[] = [];
  for (const pack of PACKS) {
    for (let i = 1; i <= SLOTS_PER_COUNTRY; i++) {
      slots.push({
        id: `${pack.prefix}_slot_${String(i).padStart(2, "0")}`,
        countries: pack.countries,
      });
    }
  }
  return slots;
}

function buildTopicBank(): TopicSeed[] {
  const seeds: TopicSeed[] = [];
  for (const pack of PACKS) {
    let n = 0;
    for (const theme of pack.themes) {
      for (const angle of NEWS_ANGLES) {
        n += 1;
        seeds.push({
          id: `${pack.prefix}_topic_${String(n).padStart(4, "0")}`,
          countries: pack.countries,
          theme,
          angle,
          sourceHint: pack.sourceHint,
        });
      }
    }
  }
  return seeds;
}

/** Awardable country lesson ids (stable slots). */
export const COUNTRY_SLOTS: readonly CountrySlot[] = buildSlots();

/** ≥1000 educational topic seeds (themes × news angles). Not awardable. */
export const TOPIC_BANK: readonly TopicSeed[] = buildTopicBank();

/** @deprecated alias kept for older imports — prefer TOPIC_BANK. */
export const COUNTRY_LESSON_TOPICS = TOPIC_BANK;

export type CountryLessonId = (typeof COUNTRY_SLOTS)[number]["id"] | string;

/** Modules used by lessonPath gate + ALL_AWARDABLE_LESSON_IDS (slots only). */
export const COUNTRY_LESSON_MODULES = COUNTRY_SLOTS.map((s) => ({
  id: s.id,
  countries: s.countries,
}));

export function isAwardableSlot(id: string): boolean {
  return COUNTRY_SLOTS.some((s) => s.id === id);
}

export function slotById(id: string): CountrySlot | undefined {
  return COUNTRY_SLOTS.find((s) => s.id === id);
}

export function slotsForCountry(countryCode: string | null | undefined): CountrySlot[] {
  const code = (countryCode ?? "").toUpperCase();
  const specific = COUNTRY_SLOTS.filter(
    (s) => code.length === 2 && s.countries.includes(code)
  );
  if (specific.length > 0) return [...specific];
  return COUNTRY_SLOTS.filter((s) => s.countries.includes("*"));
}

export function topicsForCountry(countryCode: string | null | undefined): TopicSeed[] {
  const code = (countryCode ?? "").toUpperCase();
  const specific = TOPIC_BANK.filter(
    (t) => code.length === 2 && t.countries.includes(code)
  );
  if (specific.length > 0) return [...specific];
  return TOPIC_BANK.filter((t) => t.countries.includes("*"));
}

export function topicById(topicId: string): TopicSeed | undefined {
  return TOPIC_BANK.find((t) => t.id === topicId);
}

/**
 * Picks a random topic for the country, never repeating `excludeTopicId` when alternatives exist.
 */
export function pickRandomTopic(
  countryCode: string | null | undefined,
  excludeTopicId?: string | null,
  random: () => number = Math.random
): TopicSeed {
  const all = topicsForCountry(countryCode);
  if (all.length === 0) {
    throw new Error("TOPIC_BANK is empty for country fallback");
  }
  const pool =
    excludeTopicId && all.length > 1
      ? all.filter((t) => t.id !== excludeTopicId)
      : all;
  const index = Math.min(pool.length - 1, Math.floor(random() * pool.length));
  return pool[index];
}
