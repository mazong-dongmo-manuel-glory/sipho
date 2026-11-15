/** Bounds applied to any quest reward, whatever the quest document says. */
export const QUEST_REWARD_BOUNDS = {
  xp: { min: 5, max: 100, fallback: 15 },
  gems: { min: 1, max: 25, fallback: 5 },
} as const;

export type ClaimDecision = "claimable" | "already-claimed" | "expired" | "not-completed";

export interface ClaimableQuest {
  status?: unknown;
  progress?: unknown;
  target?: unknown;
}

/**
 * Decides whether a quest can be claimed right now.
 *
 * An `expired` quest is never claimable, even if its progress reached the target: completed daily
 * quests are only kept claimable for a grace period, after which `expireDailyQuests` marks them
 * `expired`. Without this check they could still be claimed until they are purged two weeks later.
 */
export function classifyClaim(quest: ClaimableQuest): ClaimDecision {
  if (quest.status === "claimed") return "already-claimed";
  if (quest.status === "expired") return "expired";
  const progress = typeof quest.progress === "number" ? Math.trunc(quest.progress) : 0;
  const target = typeof quest.target === "number" ? Math.max(1, Math.trunc(quest.target)) : 1;
  return progress >= target || quest.status === "completed" ? "claimable" : "not-completed";
}

function clampReward(raw: unknown, bounds: { min: number; max: number; fallback: number }): number {
  if (typeof raw !== "number" || !Number.isFinite(raw)) return bounds.fallback;
  return Math.min(bounds.max, Math.max(bounds.min, Math.trunc(raw)));
}

export function questRewardXp(raw: unknown): number {
  return clampReward(raw, QUEST_REWARD_BOUNDS.xp);
}

export function questRewardGems(raw: unknown): number {
  return clampReward(raw, QUEST_REWARD_BOUNDS.gems);
}
