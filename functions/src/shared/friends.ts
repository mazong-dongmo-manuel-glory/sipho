import { createHash } from "crypto";

/** Pending + accepted friendships a user can be part of (keeps queries and abuse bounded). */
export const MAX_FRIEND_LINKS = 100;

/** Redemptions allowed per invite code (README: referral codes are capped). */
export const INVITE_CODE_MAX_USES = 50;

export const INVITE_CODE_LENGTH = 8;

/** 32 symbols without 0/O/1/I, so a code read aloud or typed on a phone is hard to get wrong. */
const ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

/**
 * Invite / friend code of a user. Deterministic (hash of the uid and an attempt counter) so it is
 * stable and needs no lookup table; `attempt` is only raised on the astronomically rare collision
 * with another owner's code.
 */
export function inviteCodeFor(uid: string, attempt = 0): string {
  const digest = createHash("sha256").update(`${uid}:${attempt}`).digest();
  let code = "";
  for (let i = 0; i < INVITE_CODE_LENGTH; i++) {
    code += ALPHABET[digest[i] % ALPHABET.length];
  }
  return code;
}

/** Document id of the friendship between two users, identical whichever side computes it. */
export function friendPairId(a: string, b: string): string {
  return a < b ? `${a}_${b}` : `${b}_${a}`;
}

export type FriendRequestAction = "create" | "auto-accept" | "already-friends" | "already-pending";

export interface FriendshipLike {
  status?: unknown;
  requesterUid?: unknown;
}

/**
 * What a friend request from `requesterUid` means given the friendship document that may already
 * exist. A request that crosses an incoming one is simply accepted: both sides want it.
 */
export function classifyFriendRequest(
  existing: FriendshipLike | undefined,
  requesterUid: string
): FriendRequestAction {
  if (!existing) return "create";
  if (existing.status === "accepted") return "already-friends";
  if (existing.requesterUid === requesterUid) return "already-pending";
  return "auto-accept";
}

/** Whether `uid` may answer (accept or decline) the pending request stored in `friendship`. */
export function canRespondToRequest(
  friendship: FriendshipLike & { users?: unknown },
  uid: string
): boolean {
  const users = Array.isArray(friendship.users) ? (friendship.users as unknown[]) : [];
  return (
    friendship.status === "pending" &&
    users.includes(uid) &&
    typeof friendship.requesterUid === "string" &&
    friendship.requesterUid !== uid
  );
}
