import { ALL_LESSON_IDS, LessonId } from "./lessonPath";

/**
 * Personalised financial-advice notifications: the pure rules.
 *
 * What the push may talk about is decided here, by rules, from the learner's real data (budget,
 * spending, goal, lesson results, life stage). Among the topics that apply and are not on
 * cooldown, one is drawn at random (weighted, stable for a learner on a given day). The AI only
 * words it, in light of how far the learner has come; if the AI is unavailable or answers
 * something unsafe, a template built from the same facts is sent instead. Nothing in this file
 * touches Firestore or the network, so all of it is unit-tested.
 */

export type AdviceLocale = "fr" | "en";

export type AdviceFocus =
  | "budget_over"
  | "weak_lesson"
  | "top_category"
  | "no_tracking"
  | "next_lesson"
  | "goal"
  | "general";

/** Order of importance: the first focus that applies and is not on cooldown wins. */
export const ADVICE_FOCUS_PRIORITY: readonly AdviceFocus[] = [
  "budget_over",
  "weak_lesson",
  "top_category",
  "no_tracking",
  "next_lesson",
  "goal",
  "general",
];

/** Days before the same kind of advice may come back. */
export const ADVICE_COOLDOWN_DAYS: Record<AdviceFocus, number> = {
  budget_over: 3,
  weak_lesson: 7,
  top_category: 7,
  no_tracking: 5,
  next_lesson: 7,
  goal: 14,
  general: 14,
};

/** Minimum days between two advice pushes, whatever their focus. */
export const ADVICE_MIN_GAP_DAYS = 3;

/** A lesson finished with a score under this is treated as "not mastered yet". */
export const WEAK_SCORE_BELOW = 80;

/** A category weighing at least this share of the month's spending is worth a word. */
export const TOP_CATEGORY_MIN_SHARE_PCT = 40;
export const TOP_CATEGORY_MIN_TRANSACTIONS = 3;

export const ADVICE_GOALS = [
  "stop_overdraft",
  "save_for_project",
  "understand_money",
  "prepare_future",
] as const;
export type AdviceGoal = (typeof ADVICE_GOALS)[number];

/** Same values as the onboarding life-stage step. Anything else is dropped before the prompt. */
export const ADVICE_LIFE_STAGES = [
  "student",
  "first_job",
  "family",
  "pre_retirement",
  "retired",
] as const;
export type AdviceLifeStage = (typeof ADVICE_LIFE_STAGES)[number];

/** How often a topic is drawn when several apply. Urgent ones come up more, none is guaranteed. */
export const ADVICE_FOCUS_WEIGHT: Record<AdviceFocus, number> = {
  budget_over: 5,
  weak_lesson: 4,
  top_category: 3,
  no_tracking: 3,
  next_lesson: 2,
  goal: 2,
  general: 1,
};

const LIFE_STAGE_FACT: Record<AdviceLifeStage, string> = {
  student: "student",
  first_job: "first job",
  family: "raising a family",
  pre_retirement: "approaching retirement",
  retired: "retired",
};

/** Plain-language topic of each lesson, for the prompt (English) and the fallback text. */
export const LESSON_TOPICS: Record<LessonId, { en: string; fr: string }> = {
  emergency_fund: { en: "building an emergency fund", fr: "le fonds d'urgence" },
  needs_wants: { en: "telling needs from wants", fr: "la différence entre besoins et envies" },
  track_spending: { en: "tracking spending", fr: "le suivi des dépenses" },
  savings_goal: { en: "setting a savings goal", fr: "se fixer un objectif d'épargne" },
  pay_yourself_first: { en: "paying yourself first", fr: "s'épargner en premier" },
  small_amounts: { en: "the power of small amounts", fr: "la force des petits montants" },
  debt_basics: { en: "understanding debt and credit", fr: "les dettes et le crédit" },
  inflation_101: { en: "understanding inflation", fr: "l'inflation et le pouvoir d'achat" },
  spotting_scams: { en: "spotting financial scams", fr: "repérer les arnaques financières" },
  investing_basics: { en: "investing basics", fr: "les bases de l'investissement" },
  compound_interest: { en: "the magic of compound interest", fr: "les intérêts composés" },
  smart_budget_503020: { en: "the 50/30/20 budget rule", fr: "la règle du 50/30/20" },
};

export const CATEGORY_LABELS: Record<string, { en: string; fr: string }> = {
  rent: { en: "rent", fr: "le loyer" },
  internet: { en: "internet", fr: "internet" },
  energy: { en: "energy", fr: "l'énergie" },
  phone: { en: "phone", fr: "le téléphone" },
  groceries: { en: "groceries", fr: "les courses" },
  transport: { en: "transport", fr: "le transport" },
  restaurants: { en: "eating out", fr: "les restos" },
  shopping: { en: "shopping", fr: "les achats" },
  other: { en: "other expenses", fr: "les autres dépenses" },
};

export interface LessonResultSummary {
  lessonId: string;
  /** Score of the latest attempt, 0–100. */
  lastScore: number;
  bestScore: number;
  attempts: number;
}

/** Raw facts about one learner, as read from the database. Integer cents only, no free text. */
export interface AdviceInput {
  incomeCents: number;
  fixedCents: number;
  /** Variable spending of the current month. */
  variableCents: number;
  categoryCents: Record<string, number>;
  /** Transactions logged this month. */
  monthTransactionCount: number;
  /** Whether anything was logged during the last 7 days. */
  loggedLastWeek: boolean;
  currency: string;
  goal: string;
  completedLessonIds: string[];
  lessons: LessonResultSummary[];
  streak: number;
  /** Onboarding life stage; unknown values are ignored. */
  lifeStage?: string;
  /** Game level, 1 when missing. */
  level?: number;
}

export interface AdviceContext {
  currency: string;
  incomeCents: number;
  fixedCents: number;
  variableCents: number;
  /** Income − fixed − variable; null when the income is unknown. */
  remainingCents: number | null;
  topCategory: { category: string; cents: number; sharePct: number } | null;
  monthTransactionCount: number;
  loggedLastWeek: boolean;
  /** The lesson the learner struggled with most, if any. */
  weakLesson: { lessonId: LessonId; score: number } | null;
  /** First lesson of the path not completed yet. */
  nextLessonId: LessonId | null;
  completedCount: number;
  goal: AdviceGoal | null;
  streak: number;
  lifeStage: AdviceLifeStage | null;
  level: number;
  /** Lessons whose latest score is at least {@link WEAK_SCORE_BELOW}. */
  masteredCount: number;
  totalLessons: number;
}

function safeCents(value: unknown): number {
  return typeof value === "number" && Number.isFinite(value) ? Math.max(0, Math.trunc(value)) : 0;
}

const isLessonId = (id: string): id is LessonId =>
  (ALL_LESSON_IDS as readonly string[]).includes(id);

export function buildAdviceContext(input: AdviceInput): AdviceContext {
  const income = safeCents(input.incomeCents);
  const fixed = safeCents(input.fixedCents);
  const variable = safeCents(input.variableCents);

  let topCategory: AdviceContext["topCategory"] = null;
  const total = Object.values(input.categoryCents).reduce((sum, c) => sum + safeCents(c), 0);
  if (total > 0) {
    const [category, cents] = Object.entries(input.categoryCents)
      .map(([key, value]) => [key, safeCents(value)] as const)
      .sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]))[0];
    topCategory = { category, cents, sharePct: Math.round((100 * cents) / total) };
  }

  // The weakest lesson: lowest latest score among known lessons, earliest in the path on a tie.
  let weakLesson: AdviceContext["weakLesson"] = null;
  for (const lesson of input.lessons) {
    if (!isLessonId(lesson.lessonId)) continue;
    const score = Math.max(0, Math.min(100, Math.trunc(lesson.lastScore)));
    if (score >= WEAK_SCORE_BELOW) continue;
    const better =
      weakLesson === null ||
      score < weakLesson.score ||
      (score === weakLesson.score &&
        ALL_LESSON_IDS.indexOf(lesson.lessonId) < ALL_LESSON_IDS.indexOf(weakLesson.lessonId));
    if (better) weakLesson = { lessonId: lesson.lessonId, score };
  }

  const completed = new Set(input.completedLessonIds);
  const nextLessonId = ALL_LESSON_IDS.find((id) => !completed.has(id)) ?? null;

  const mastered = new Set<LessonId>();
  for (const lesson of input.lessons) {
    if (!isLessonId(lesson.lessonId)) continue;
    const score = Math.max(0, Math.min(100, Math.trunc(lesson.lastScore)));
    if (score >= WEAK_SCORE_BELOW) mastered.add(lesson.lessonId);
  }

  const lifeStage = (ADVICE_LIFE_STAGES as readonly string[]).includes(input.lifeStage ?? "")
    ? (input.lifeStage as AdviceLifeStage)
    : null;
  const level =
    typeof input.level === "number" && Number.isFinite(input.level)
      ? Math.max(1, Math.trunc(input.level))
      : 1;

  return {
    currency: /^[A-Z]{3}$/.test(input.currency) ? input.currency : "CAD",
    incomeCents: income,
    fixedCents: fixed,
    variableCents: variable,
    remainingCents: income > 0 ? income - fixed - variable : null,
    topCategory,
    monthTransactionCount: Math.max(0, Math.trunc(input.monthTransactionCount)),
    loggedLastWeek: input.loggedLastWeek,
    weakLesson,
    nextLessonId,
    completedCount: ALL_LESSON_IDS.filter((id) => completed.has(id)).length,
    goal: (ADVICE_GOALS as readonly string[]).includes(input.goal)
      ? (input.goal as AdviceGoal)
      : null,
    streak: Math.max(0, Math.trunc(input.streak)),
    lifeStage,
    level,
    masteredCount: mastered.size,
    totalLessons: ALL_LESSON_IDS.length,
  };
}

/** Whether a focus has something real to say for this learner. */
export function focusApplies(focus: AdviceFocus, ctx: AdviceContext): boolean {
  switch (focus) {
    case "budget_over":
      return ctx.remainingCents !== null && ctx.remainingCents < 0;
    case "weak_lesson":
      return ctx.weakLesson !== null;
    case "top_category":
      return (
        ctx.topCategory !== null &&
        ctx.topCategory.category !== "other" &&
        ctx.topCategory.sharePct >= TOP_CATEGORY_MIN_SHARE_PCT &&
        ctx.monthTransactionCount >= TOP_CATEGORY_MIN_TRANSACTIONS
      );
    case "no_tracking":
      // Only meaningful for someone who already set the app up.
      return !ctx.loggedLastWeek && (ctx.incomeCents > 0 || ctx.fixedCents > 0);
    case "next_lesson":
      return ctx.nextLessonId !== null;
    case "goal":
      return ctx.goal !== null;
    case "general":
      return true;
  }
}

export interface RecentAdvice {
  focus: AdviceFocus;
  /** How many days ago it was sent. */
  daysAgo: number;
}

/** Topics that have something to say and have not been used within their cooldown. */
export function eligibleAdviceFocuses(
  ctx: AdviceContext,
  recent: readonly RecentAdvice[]
): AdviceFocus[] {
  return ADVICE_FOCUS_PRIORITY.filter((focus) => {
    if (!focusApplies(focus, ctx)) return false;
    return !recent.some((r) => r.focus === focus && r.daysAgo < ADVICE_COOLDOWN_DAYS[focus]);
  });
}

/**
 * Most important eligible topic. Kept for tests and for a roll of 0, which always lands on it.
 */
export function chooseAdviceFocus(
  ctx: AdviceContext,
  recent: readonly RecentAdvice[]
): AdviceFocus | null {
  return eligibleAdviceFocuses(ctx, recent)[0] ?? null;
}

/**
 * Draws one eligible topic. `roll` is in `[0, 1)`: 0 picks the most urgent, values closer to 1
 * reach the lighter topics. The same roll always returns the same topic.
 */
export function pickAdviceFocus(
  ctx: AdviceContext,
  recent: readonly RecentAdvice[],
  roll: number
): AdviceFocus | null {
  const pool = eligibleAdviceFocuses(ctx, recent);
  if (pool.length === 0) return null;
  const total = pool.reduce((sum, focus) => sum + ADVICE_FOCUS_WEIGHT[focus], 0);
  const clamped = Number.isFinite(roll) ? Math.min(0.999999, Math.max(0, roll)) : 0;
  let cursor = clamped * total;
  for (const focus of pool) {
    cursor -= ADVICE_FOCUS_WEIGHT[focus];
    if (cursor < 0) return focus;
  }
  return pool[pool.length - 1];
}

/** Stable roll in `[0, 1)` from a seed (learner id + local day), so a retry the same day matches. */
export function adviceRoll(seed: string): number {
  let hash = 2166136261;
  for (let i = 0; i < seed.length; i++) {
    hash ^= seed.charCodeAt(i);
    hash = Math.imul(hash, 16777619);
  }
  return (hash >>> 0) / 4294967296;
}

/** Whole days between two `YYYY-MM-DD` keys (`later` − `earlier`). */
export function dateKeyDiffDays(later: string, earlier: string): number {
  const toMs = (key: string): number => {
    const [y, m, d] = key.split("-").map(Number);
    return Date.UTC(y, (m || 1) - 1, d || 1);
  };
  return Math.round((toMs(later) - toMs(earlier)) / 86_400_000);
}

/** Where the notification takes the learner. Must be a route the app knows. */
export const ADVICE_ROUTES: Record<AdviceFocus, string> = {
  budget_over: "/budget",
  weak_lesson: "/learn",
  top_category: "/budget",
  no_tracking: "/home",
  next_lesson: "/learn",
  goal: "/economy",
  general: "/economy",
};

/** The lesson an advice recommends, so the in-app card can open it. */
export function recommendedLessonFor(focus: AdviceFocus, ctx: AdviceContext): LessonId {
  if (focus === "weak_lesson" && ctx.weakLesson) return ctx.weakLesson.lessonId;
  return ctx.nextLessonId ?? "track_spending";
}

// ─── Facts: the only numbers the AI may use ──────────────────────────────────

/** Whole units of currency (no cents) as a plain integer, for facts and templates. */
export function wholeUnits(cents: number): number {
  return Math.round(cents / 100);
}

export function formatMoney(cents: number, currency: string, locale: AdviceLocale): string {
  try {
    return new Intl.NumberFormat(locale === "fr" ? "fr-CA" : "en-CA", {
      style: "currency",
      currency,
      maximumFractionDigits: 0,
    }).format(wholeUnits(cents));
  } catch {
    return `${wholeUnits(cents)} ${currency}`;
  }
}

function categoryName(category: string, locale: AdviceLocale): string {
  return (CATEGORY_LABELS[category] ?? CATEGORY_LABELS.other)[locale];
}

/**
 * Plain facts handed to the AI for a focus. Every number the AI is allowed to quote appears
 * here as a plain integer; `allowedNumbers` derives the whitelist from this very list.
 */
export function adviceFacts(focus: AdviceFocus, ctx: AdviceContext): string[] {
  const facts: string[] = [];
  const money = (cents: number): string => `${wholeUnits(cents)} ${ctx.currency}`;
  switch (focus) {
    case "budget_over":
      if (ctx.remainingCents !== null) {
        facts.push(`This month the learner spent ${money(Math.abs(ctx.remainingCents))} more than the money available after fixed bills.`);
      }
      break;
    case "weak_lesson":
      if (ctx.weakLesson) {
        facts.push(
          `The learner struggled with the lesson about ${LESSON_TOPICS[ctx.weakLesson.lessonId].en} (score ${ctx.weakLesson.score} out of 100).`
        );
      }
      break;
    case "top_category":
      if (ctx.topCategory) {
        facts.push(
          `${categoryName(ctx.topCategory.category, "en")} is ${ctx.topCategory.sharePct} percent of this month's variable spending (${money(ctx.topCategory.cents)}).`
        );
      }
      break;
    case "no_tracking":
      facts.push("No expense was logged during the last 7 days.");
      break;
    case "next_lesson":
      if (ctx.nextLessonId) {
        facts.push(
          `The next lesson on the path is about ${LESSON_TOPICS[ctx.nextLessonId].en}; ${ctx.completedCount} lessons are completed.`
        );
      }
      break;
    case "goal":
      facts.push(`The learner's goal is "${ctx.goal ?? "understand_money"}".`);
      break;
    case "general":
      facts.push(`The learner has completed ${ctx.completedCount} lessons.`);
      break;
  }
  return facts.concat(evolutionFacts(ctx));
}

/** Where the learner is, added to every prompt so the wording follows their progress. */
function evolutionFacts(ctx: AdviceContext): string[] {
  const facts = [
    `Progress: ${ctx.completedCount} of ${ctx.totalLessons} lessons completed, level ${ctx.level}, ${ctx.masteredCount} currently mastered.`,
  ];
  if (ctx.lifeStage) facts.push(`Life stage: ${LIFE_STAGE_FACT[ctx.lifeStage]}.`);
  if (ctx.streak > 0) facts.push(`Current streak: ${ctx.streak} days.`);
  return facts;
}

/** Digit groups found in a text, with thousands separators removed ("1 200" → "1200"). */
export function numberTokens(text: string): string[] {
  const matches = text.match(/\d(?:[\d\s\u00a0\u202f.,]*\d)?/g) ?? [];
  return matches.map((m) => m.replace(/[\s\u00a0\u202f.,]/g, ""));
}

/** Numbers the AI may quote: those of the facts, plus tiny counters ("1 step", "2 minutes"). */
export function allowedNumbers(facts: readonly string[]): Set<string> {
  const allowed = new Set<string>(["1", "2", "3"]);
  for (const fact of facts) for (const token of numberTokens(fact)) allowed.add(token);
  return allowed;
}

// ─── Safety checks on what the AI wrote ──────────────────────────────────────

export const ADVICE_TITLE_MAX = 45;
export const ADVICE_BODY_MAX = 140;

const FORBIDDEN_ADVICE =
  /\b(invest\w*|stocks?|crypto\w*|bitcoin|etfs?|loans?|mortgage|interest rates?|taxes|tax|bourse|placements?|investir|investissements?|cr[eé]dits?|hypoth[eè]que|imp[oô]ts?|taux d'int[eé]r[eê]t|reer|rrsp|celi|tfsa)\b/i;

/** Reasons an AI message is refused; empty when it is safe to send. */
export function adviceViolations(
  message: { title: string; body: string },
  facts: readonly string[]
): string[] {
  const problems: string[] = [];
  const text = `${message.title} ${message.body}`;
  if (message.title.trim().length === 0 || message.body.trim().length === 0) problems.push("empty");
  if (message.title.length > ADVICE_TITLE_MAX) problems.push("title-too-long");
  if (message.body.length > ADVICE_BODY_MAX) problems.push("body-too-long");
  if (FORBIDDEN_ADVICE.test(text)) problems.push("forbidden-topic");
  const allowed = allowedNumbers(facts);
  if (numberTokens(text).some((token) => !allowed.has(token))) problems.push("invented-number");
  return problems;
}

// ─── Prompt ──────────────────────────────────────────────────────────────────

export function buildAdvicePrompt(
  focus: AdviceFocus,
  ctx: AdviceContext,
  locale: AdviceLocale,
  recentTitles: readonly string[]
): string {
  const lang = locale === "fr" ? "French" : "English";
  const facts = adviceFacts(focus, ctx);
  return `You are Sipho, a warm and concrete money coach inside a budgeting app. Write ONE push notification in ${lang}.
Facts about the learner (the only facts you may use):
${facts.map((f) => `- ${f}`).join("\n")}
Rules:
- Title: at most ${ADVICE_TITLE_MAX} characters, one emoji allowed. Body: at most ${ADVICE_BODY_MAX} characters.
- Speak to the learner ("tu" in French), kindly, never guilt-tripping, never judging.
- Explain the idea in one short sentence that fits where this learner is (lessons done, life stage, streak).
- Then give ONE tiny action doable in the app today (log an expense, replay a lesson, check the budget).
- Use only numbers that appear in the facts. Do not invent any amount, rate, price, tax, bank or financial product.
- Never encourage spending. No investment, credit, tax or legal advice. Educational tone only.
- Do not mention private details beyond the facts. Do not repeat these recent titles: ${recentTitles.length > 0 ? recentTitles.join(" | ") : "none"}.
Respond with valid JSON only: {"title":"...","body":"..."}`;
}

// ─── Fallback text, built from the same facts ────────────────────────────────

export interface AdviceMessage {
  title: string;
  body: string;
}

export function templateAdvice(
  focus: AdviceFocus,
  ctx: AdviceContext,
  locale: AdviceLocale
): AdviceMessage {
  const fr = locale === "fr";
  switch (focus) {
    case "budget_over": {
      const over = formatMoney(Math.abs(ctx.remainingCents ?? 0), ctx.currency, locale);
      return fr
        ? { title: "🧭 Un petit point budget", body: `Tu as dépassé de ${over} ce mois-ci. Regarde où ça a filé, sans stress.` }
        : { title: "🧭 A quick budget check", body: `You're ${over} over this month. See where it went, no stress.` };
    }
    case "weak_lesson": {
      const topic = ctx.weakLesson ? LESSON_TOPICS[ctx.weakLesson.lessonId] : LESSON_TOPICS.track_spending;
      return fr
        ? { title: "📚 On la refait ensemble ?", body: `${capitalize(topic.fr)} t'a donné du fil à retordre. 3 minutes pour la rejouer.` }
        : { title: "📚 Shall we replay it?", body: `${capitalize(topic.en)} was tricky. Replay it in 3 minutes.` };
    }
    case "top_category": {
      const name = categoryName(ctx.topCategory?.category ?? "other", locale);
      const pct = ctx.topCategory?.sharePct ?? 0;
      return fr
        ? { title: "🔎 Ton poste n°1", body: `${capitalize(name)} pèse ${pct} % de tes dépenses du mois. Ça te va ?` }
        : { title: "🔎 Your #1 category", body: `${capitalize(name)} is ${pct}% of this month's spending. Does that feel right?` };
    }
    case "no_tracking":
      return fr
        ? { title: "📝 30 secondes pour toi", body: "Aucune dépense notée depuis 7 jours. Note la dernière, ça suffit pour repartir." }
        : { title: "📝 30 seconds for you", body: "No expense logged in 7 days. Log the latest one to get going again." };
    case "next_lesson": {
      const topic = ctx.nextLessonId ? LESSON_TOPICS[ctx.nextLessonId] : LESSON_TOPICS.track_spending;
      return fr
        ? { title: "🌱 Ta prochaine leçon t'attend", body: `Au programme : ${topic.fr}. Un petit pas aujourd'hui.` }
        : { title: "🌱 Your next lesson is ready", body: `Up next: ${topic.en}. One small step today.` };
    }
    case "goal":
      return fr
        ? { title: "🎯 Ton objectif avance", body: "Un petit geste régulier compte plus qu'un grand effort rare. Jette un œil à ton budget." }
        : { title: "🎯 Your goal is moving", body: "A small regular habit beats a rare big effort. Take a look at your budget." };
    case "general":
      return fr
        ? { title: "💡 Le conseil de Sipho", body: "Ton reste à vivre est ton meilleur repère. Ouvre l'app pour le voir." }
        : { title: "💡 Sipho's tip", body: "Your money left to live on is your best compass. Open the app to see it." };
  }
}

function capitalize(text: string): string {
  return text.length > 0 ? text[0].toUpperCase() + text.slice(1) : text;
}
