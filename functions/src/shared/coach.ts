/**
 * Progressive financial coach — pure rules (no I/O).
 *
 * Education stage is derived from platform progress (lessons, streak, level, income, goals).
 * Tips are stage-gated, never consecutive, prefer unseen recent ids, stable draw per hour.
 * Educational only: no rates, products, or personalized investment/tax advice.
 */

export type CoachLocale = "fr" | "en";

export type CoachStageId =
  | "foundation"
  | "habits"
  | "saving"
  | "protect"
  | "grow";

/** 0 = foundation … 4 = grow */
export type CoachStage = 0 | 1 | 2 | 3 | 4;

export type CoachTipCategory =
  | "economy"
  | "saving"
  | "habit"
  | "budget"
  | "security"
  | "progress";

export interface CoachTipDef {
  id: string;
  /** Minimum education stage required to unlock this tip. */
  minStage: CoachStage;
  category: CoachTipCategory;
  emoji: string;
  title: Record<CoachLocale, string>;
  body: Record<CoachLocale, string>;
}

export interface EducationInput {
  lessonsCompleted: number;
  streakBest: number;
  level: number;
  hasIncome: boolean;
  hasGoal: boolean;
  underBudgetDayCount: number;
}

export interface EducationProgress {
  stage: CoachStage;
  stageId: CoachStageId;
  /** 0–100 composite score. */
  educationScore: number;
  lessonsCompleted: number;
}

export interface PickCoachTipInput {
  stage: CoachStage;
  lastTipId: string | null;
  recentTipIds: readonly string[];
  locale: CoachLocale;
  /** Stable roll in [0, 1). */
  roll: number;
}

export interface PickedCoachTip {
  tip: CoachTipDef;
  title: string;
  body: string;
}

export const COACH_STAGE_IDS: readonly CoachStageId[] = [
  "foundation",
  "habits",
  "saving",
  "protect",
  "grow",
] as const;

/** How many recent tip ids to remember (anti-repeat window). */
export const COACH_RECENT_WINDOW = 24;

/** Local hours (inclusive) when hourly coach tips may be generated. Quiet hours stay off. */
export const COACH_ACTIVE_HOUR_START = 8;
export const COACH_ACTIVE_HOUR_END = 21;

export const COACH_TIPS: readonly CoachTipDef[] = [
  // ── Foundation (0) ────────────────────────────────────────────────────────
  {
    id: "found_track_one",
    minStage: 0,
    category: "habit",
    emoji: "✍️",
    title: {
      fr: "Une dépense, un pas",
      en: "One expense, one step",
    },
    body: {
      fr: "Noter ne serait-ce qu’une dépense aujourd’hui te donne déjà une photo plus claire de ton mois. Sipho t’accompagne sans jugement.",
      en: "Logging even one expense today already gives a clearer picture of your month. Sipho walks with you—no judgment.",
    },
  },
  {
    id: "found_nest_idea",
    minStage: 0,
    category: "budget",
    emoji: "🪺",
    title: {
      fr: "Ton nid, c’est le socle",
      en: "Your nest is the base",
    },
    body: {
      fr: "Loyer, internet, téléphone… les fixes décident d’abord du reste à vivre. Les connaître, c’est déjà maîtriser une partie du mois.",
      en: "Rent, internet, phone… fixed costs decide living money first. Knowing them is already mastering part of the month.",
    },
  },
  {
    id: "found_no_shame",
    minStage: 0,
    category: "progress",
    emoji: "💛",
    title: {
      fr: "Pas de culpabilité",
      en: "No guilt trip",
    },
    body: {
      fr: "Un dépassement arrive. Ce qui compte, c’est de le voir et d’ajuster demain. Sipho récompense le suivi, jamais la dépense.",
      en: "Going over happens. What matters is seeing it and adjusting tomorrow. Sipho rewards tracking—never spending.",
    },
  },
  {
    id: "found_lesson_start",
    minStage: 0,
    category: "progress",
    emoji: "📚",
    title: {
      fr: "2 minutes pour apprendre",
      en: "2 minutes to learn",
    },
    body: {
      fr: "Une micro-leçon du chemin « Apprendre » suffit pour faire progresser ton niveau d’éducation financière. Petit pas, vrai progrès.",
      en: "One short lesson on the Learn path is enough to raise your financial-education level. Small step, real progress.",
    },
  },
  {
    id: "eco_inflation_plain",
    minStage: 0,
    category: "economy",
    emoji: "📈",
    title: {
      fr: "L’inflation, en une phrase",
      en: "Inflation in one line",
    },
    body: {
      fr: "Quand les prix montent plus vite que tes revenus, le même panier coûte plus cher. Suivre ton budget te montre l’impact chez toi—pas dans un journal.",
      en: "When prices rise faster than income, the same basket costs more. Tracking your budget shows the impact on you—not in a headline.",
    },
  },

  // ── Habits (1) ────────────────────────────────────────────────────────────
  {
    id: "habit_same_hour",
    minStage: 1,
    category: "habit",
    emoji: "⏰",
    title: {
      fr: "Même heure, moins d’effort",
      en: "Same time, less effort",
    },
    body: {
      fr: "Ouvre Sipho à un moment fixe (après le café, dans les transports). La régularité construit la série mieux que les sessions longues.",
      en: "Open Sipho at a fixed moment (after coffee, on the commute). Consistency builds streaks better than long sessions.",
    },
  },
  {
    id: "habit_categories",
    minStage: 1,
    category: "budget",
    emoji: "🏷️",
    title: {
      fr: "Nommer pour comprendre",
      en: "Name it to understand it",
    },
    body: {
      fr: "Choisir la bonne catégorie (restos, courses, transport) transforme une liste de montants en carte de tes habitudes.",
      en: "Picking the right category (eating out, groceries, transport) turns a list of amounts into a map of your habits.",
    },
  },
  {
    id: "habit_under_budget_day",
    minStage: 1,
    category: "saving",
    emoji: "🌿",
    title: {
      fr: "Une journée sous budget",
      en: "One day under budget",
    },
    body: {
      fr: "Rester sous ton enveloppe du jour, même une fois, renforce le réflexe. Sipho le célèbre : c’est le suivi qui compte.",
      en: "Staying under today’s envelope even once strengthens the reflex. Sipho celebrates it—tracking is what counts.",
    },
  },
  {
    id: "habit_scan_receipt",
    minStage: 1,
    category: "habit",
    emoji: "📷",
    title: {
      fr: "Le ticket en photo",
      en: "Snap the receipt",
    },
    body: {
      fr: "Un scan évite d’oublier une course. Tu valides toujours les montants : l’IA propose, tu décides.",
      en: "A scan keeps a shop trip from vanishing. You always confirm amounts: AI suggests, you decide.",
    },
  },
  {
    id: "eco_rates_matter",
    minStage: 1,
    category: "economy",
    emoji: "🏦",
    title: {
      fr: "Pourquoi les taux bougent",
      en: "Why rates move",
    },
    body: {
      fr: "Quand la banque centrale change son taux, crédits et épargne réagissent avec le temps. Regarde la carte économie de Sipho pour le contexte de ton pays—sans conseil de produit.",
      en: "When the central bank moves its rate, loans and savings react over time. Check Sipho’s economy card for your country’s context—no product advice.",
    },
  },

  // ── Saving (2) ────────────────────────────────────────────────────────────
  {
    id: "save_first_slice",
    minStage: 2,
    category: "saving",
    emoji: "🌱",
    title: {
      fr: "S’épargner en premier",
      en: "Pay yourself first",
    },
    body: {
      fr: "Mettre de côté un petit montant dès que tu reçois de l’argent, avant le reste, transforme l’épargne en habitude—pas en reste éventuel.",
      en: "Setting aside a little as soon as money arrives—before the rest—turns saving into a habit, not an afterthought.",
    },
  },
  {
    id: "save_goal_visible",
    minStage: 2,
    category: "saving",
    emoji: "🎯",
    title: {
      fr: "Un objectif visible",
      en: "A visible goal",
    },
    body: {
      fr: "Un objectif d’épargne sur l’accueil te rappelle pourquoi tu suis ton budget. Même 1 % du chemin compte.",
      en: "A savings goal on Home reminds you why you track. Even 1% of the way counts.",
    },
  },
  {
    id: "save_small_wins",
    minStage: 2,
    category: "saving",
    emoji: "🪙",
    title: {
      fr: "Les petits montants comptent",
      en: "Small amounts count",
    },
    body: {
      fr: "5 ou 10 unités régulièrement battent un grand geste rare. La constance bat l’intensité.",
      en: "5 or 10 units regularly beat one rare big gesture. Consistency beats intensity.",
    },
  },
  {
    id: "save_envelope_week",
    minStage: 2,
    category: "budget",
    emoji: "✉️",
    title: {
      fr: "Enveloppe de la semaine",
      en: "This week’s envelope",
    },
    body: {
      fr: "Découpe ton budget variable en semaines. Si tu dépasses lundi–mercredi, tu vois le frein avant le week-end.",
      en: "Split variable spend by week. If Mon–Wed runs hot, you see the brake before the weekend.",
    },
  },

  // ── Protect (3) ───────────────────────────────────────────────────────────
  {
    id: "protect_emergency",
    minStage: 3,
    category: "security",
    emoji: "🛟",
    title: {
      fr: "Un coussin avant tout",
      en: "A cushion first",
    },
    body: {
      fr: "Une réserve pour les imprévus (réparation, santé) protège mieux qu’un placement risqué trop tôt. La leçon « fonds d’urgence » pose les bases.",
      en: "A reserve for surprises (repairs, health) protects better than a risky investment too early. The emergency-fund lesson covers the basics.",
    },
  },
  {
    id: "protect_scams",
    minStage: 3,
    category: "security",
    emoji: "🛡️",
    title: {
      fr: "Méfie-toi du « urgent »",
      en: "Beware of “urgent”",
    },
    body: {
      fr: "Un message qui exige ton code ou un virement immédiat est presque toujours une arnaque. Aucun vrai service ne te le demande ainsi.",
      en: "A message that demands your code or an instant transfer is almost always a scam. No real service asks that way.",
    },
  },
  {
    id: "protect_debt_aware",
    minStage: 3,
    category: "budget",
    emoji: "📉",
    title: {
      fr: "Voir la dette clairement",
      en: "See debt clearly",
    },
    body: {
      fr: "Lister ce que tu dois et à quel rythme tu rembourses réduit le stress. La leçon sur les dettes t’aide à poser le cadre—sans conseil de crédit.",
      en: "Listing what you owe and how you repay reduces stress. The debt lesson frames it—without credit advice.",
    },
  },
  {
    id: "eco_purchasing_power",
    minStage: 3,
    category: "economy",
    emoji: "🛒",
    title: {
      fr: "Pouvoir d’achat du panier",
      en: "Basket purchasing power",
    },
    body: {
      fr: "Compare ton poste « courses » au mois dernier dans les graphiques. C’est souvent là que l’inflation se sent en premier.",
      en: "Compare this month’s groceries to last in the charts. That’s often where inflation shows up first.",
    },
  },

  // ── Grow (4) ──────────────────────────────────────────────────────────────
  {
    id: "grow_horizon",
    minStage: 4,
    category: "progress",
    emoji: "🔭",
    title: {
      fr: "Penser plus loin",
      en: "Think further ahead",
    },
    body: {
      fr: "Avec des bases solides (suivi, réserve, budget), tu peux explorer les leçons sur l’investissement et les intérêts composés—toujours en mode éducatif.",
      en: "With solid basics (tracking, reserve, budget), you can explore investing and compound-interest lessons—always educational.",
    },
  },
  {
    id: "grow_diversify_idea",
    minStage: 4,
    category: "economy",
    emoji: "🧩",
    title: {
      fr: "Ne pas tout miser",
      en: "Don’t bet it all",
    },
    body: {
      fr: "Diversifier, c’est répartir—pas chercher le « coup » unique. Sipho explique le principe ; un pro réglementé conseille si besoin.",
      en: "Diversifying means spreading—not chasing one big win. Sipho explains the idea; a regulated pro advises if needed.",
    },
  },
  {
    id: "grow_review_month",
    minStage: 4,
    category: "habit",
    emoji: "🗓️",
    title: {
      fr: "Récap du mois",
      en: "Month in review",
    },
    body: {
      fr: "Le récap mensuel montre tes tendances sans te comparer aux autres. Relis-le : c’est ton accompagnement sur la durée.",
      en: "The monthly recap shows your trends without comparing you to others. Revisit it—that’s long-term coaching.",
    },
  },
  {
    id: "grow_teach_back",
    minStage: 4,
    category: "progress",
    emoji: "🗣️",
    title: {
      fr: "Expliquer pour ancrer",
      en: "Explain to lock it in",
    },
    body: {
      fr: "Si tu peux résumer une leçon à un ami en 30 secondes, tu l’as comprise. Rejoue une leçon du chemin si un sujet flotte encore.",
      en: "If you can summarize a lesson to a friend in 30 seconds, you’ve got it. Replay a path lesson if a topic still feels fuzzy.",
    },
  },
] as const;

export const COACH_TIP_IDS = COACH_TIPS.map((t) => t.id);

export function stageIdFor(stage: CoachStage): CoachStageId {
  return COACH_STAGE_IDS[stage] ?? "foundation";
}

export function stageFromScore(score: number): CoachStage {
  const s = Math.max(0, Math.min(100, Math.trunc(score)));
  if (s >= 80) return 4;
  if (s >= 60) return 3;
  if (s >= 40) return 2;
  if (s >= 20) return 1;
  return 0;
}

/**
 * Composite education score from platform progress (not a credit score).
 * Weights favour lessons and habits Sipho can actually observe.
 */
export function computeEducationProgress(input: EducationInput): EducationProgress {
  const lessons = Math.max(0, Math.trunc(input.lessonsCompleted));
  const lessonPts = Math.min(50, lessons * 5);
  const streakPts = Math.min(20, Math.max(0, Math.trunc(input.streakBest)));
  const levelPts = Math.min(15, Math.max(0, Math.trunc(input.level)) * 2);
  const underPts = Math.min(10, Math.max(0, Math.trunc(input.underBudgetDayCount)) * 2);
  const bonus = (input.hasIncome ? 3 : 0) + (input.hasGoal ? 2 : 0);
  const educationScore = Math.min(
    100,
    lessonPts + streakPts + levelPts + underPts + bonus
  );
  const stage = stageFromScore(educationScore);
  return {
    stage,
    stageId: stageIdFor(stage),
    educationScore,
    lessonsCompleted: lessons,
  };
}

/** Stable float in [0, 1) from a string (uid + day + hour). */
export function coachRoll(...parts: string[]): number {
  let h = 2166136261;
  const s = parts.join("|");
  for (let i = 0; i < s.length; i++) {
    h ^= s.charCodeAt(i);
    h = Math.imul(h, 16777619);
  }
  return ((h >>> 0) % 10_000) / 10_000;
}

/**
 * Picks the next tip: stage-gated, never the previous id, prefers not-recent,
 * slightly prefers tips at the learner's current stage (progressivity).
 */
export function pickCoachTip(input: PickCoachTipInput): PickedCoachTip | null {
  const recent = new Set(input.recentTipIds);
  const eligible = COACH_TIPS.filter((t) => t.minStage <= input.stage);
  if (eligible.length === 0) return null;

  const notLast = eligible.filter((t) => t.id !== input.lastTipId);
  const poolBase = notLast.length > 0 ? notLast : eligible;

  const fresh = poolBase.filter((t) => !recent.has(t.id));
  const pool = fresh.length > 0 ? fresh : poolBase;

  const currentStage = pool.filter((t) => t.minStage === input.stage);
  const prefer =
    currentStage.length > 0 && input.roll < 0.65 ? currentStage : pool;

  const index = Math.min(
    prefer.length - 1,
    Math.floor(input.roll * prefer.length)
  );
  const tip = prefer[index];
  const locale = input.locale === "en" ? "en" : "fr";
  return {
    tip,
    title: tip.title[locale],
    body: tip.body[locale],
  };
}

export function tipById(id: string): CoachTipDef | null {
  return COACH_TIPS.find((t) => t.id === id) ?? null;
}
