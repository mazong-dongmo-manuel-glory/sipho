/**
 * 1v1 friend challenges — server is the only authority on templates, progress and XP.
 * Keep display copy in sync with Flutter `PredefinedChallengeTemplate.catalog`.
 */

export type ChallengeMetric =
  | "lesson_complete"
  | "budget_day"
  | "fixed_paid"
  | "activity_day";

export type ChallengeCategory = "learning" | "budget" | "saving";

export interface FriendChallengeTemplate {
  id: string;
  category: ChallengeCategory;
  metric: ChallengeMetric;
  targetCount: number;
  rewardXp: number;
  durationDays: number;
  title: { fr: string; en: string };
  description: { fr: string; en: string };
}

export const FRIEND_CHALLENGE_TEMPLATES: readonly FriendChallengeTemplate[] = [
  {
    id: "marathon_savoir",
    category: "learning",
    metric: "lesson_complete",
    targetCount: 3,
    rewardXp: 50,
    durationDays: 7,
    title: { fr: "Marathon Savoir", en: "Knowledge Marathon" },
    description: {
      fr: "Termine 3 leçons financières cette semaine avant ton ami.",
      en: "Finish 3 money lessons this week before your friend.",
    },
  },
  {
    id: "zero_ecart",
    category: "budget",
    metric: "budget_day",
    targetCount: 3,
    rewardXp: 40,
    durationDays: 5,
    title: { fr: "3 Jours Zéro Écart", en: "3 Days Under Budget" },
    description: {
      fr: "3 jours sans dépasser ton budget de dépenses variables.",
      en: "Stay under your variable-spend budget for 3 days.",
    },
  },
  {
    id: "boost_epargne",
    category: "saving",
    metric: "fixed_paid",
    targetCount: 1,
    rewardXp: 30,
    durationDays: 3,
    title: { fr: "Boost Épargne", en: "Savings Boost" },
    description: {
      fr: "Coche une dépense fixe payée (un pas vers ton nid).",
      en: "Mark one fixed expense as paid (one step for your nest).",
    },
  },
  {
    id: "semaine_champion",
    category: "budget",
    metric: "activity_day",
    targetCount: 5,
    rewardXp: 75,
    durationDays: 7,
    title: { fr: "Semaine Champion", en: "Champion Week" },
    description: {
      fr: "Enregistre tes dépenses ou une journée sans dépense, 5 jours.",
      en: "Log spending or a no-spend day on 5 different days.",
    },
  },
] as const;

export const FRIEND_CHALLENGE_TEMPLATE_IDS = FRIEND_CHALLENGE_TEMPLATES.map(
  (t) => t.id
) as unknown as [string, ...string[]];

export function templateById(id: string): FriendChallengeTemplate | null {
  return FRIEND_CHALLENGE_TEMPLATES.find((t) => t.id === id) ?? null;
}

/** At most this many pending+active challenges a user may have across all friendships. */
export const MAX_ACTIVE_CHALLENGES_PER_USER = 5;

/** At most one pending challenge between the same pair at a time. */
export const MAX_PENDING_PER_PAIR = 1;
