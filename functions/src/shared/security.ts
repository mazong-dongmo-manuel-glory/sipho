import { CallableRequest, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, Firestore, Timestamp } from "firebase-admin/firestore";
import { ZodSchema } from "zod";
import { encodeKey } from "./idempotency";
import { logger } from "./logger";

const db = (): Firestore => getFirestore();

/**
 * Default options for authenticated v2 callables. App Check is NOT enforced (removed on
 * 2026-11-15, see DECISIONS.md ADR-005): protection comes from Firebase Auth, `requireAuthUid`,
 * per-user rate limits (`enforceRateLimit`) and Firestore rules.
 */
export const SECURE_CALLABLE_OPTIONS = {
  region: "us-central1",
  cors: false,
} as const;

/**
 * Extracts the authenticated UID or throws `unauthenticated`.
 */
export function requireAuthUid(request: CallableRequest<unknown>): string {
  const uid = request.auth?.uid;
  if (!uid || typeof uid !== "string") {
    throw new HttpsError("unauthenticated", "Authentication is required.");
  }
  return uid;
}

/**
 * Validates `data` against `schema` or throws `invalid-argument` with a safe message.
 */
export function parseInput<T>(schema: ZodSchema<T>, data: unknown): T {
  const parsed = schema.safeParse(data);
  if (!parsed.success) {
    const issue = parsed.error.issues[0];
    const field = issue?.path.join(".") || "input";
    throw new HttpsError("invalid-argument", `${field}: ${issue?.message ?? "Invalid input"}`);
  }
  return parsed.data;
}

/**
 * Per-user sliding-window rate limiter backed by Firestore transactions.
 * Prevents quota abuse on AI, gamification, and account callables.
 */
export async function enforceRateLimit(params: {
  uid: string;
  action: string;
  maxRequests: number;
  windowMs: number;
}): Promise<void> {
  const { uid, action, maxRequests, windowMs } = params;
  const bucketKey = encodeKey(`rl::${action}::${uid}`);
  const ref = db().collection("_rateLimits").doc(bucketKey);
  const nowMs = Date.now();

  const allowed = await db().runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const data = snap.data() as { count?: number; resetAt?: Timestamp } | undefined;
    const resetAtMs = data?.resetAt?.toMillis() ?? 0;

    if (!snap.exists || resetAtMs <= nowMs) {
      tx.set(ref, {
        uid,
        action,
        count: 1,
        resetAt: Timestamp.fromMillis(nowMs + windowMs),
      });
      return true;
    }

    const current = data?.count ?? 0;
    if (current >= maxRequests) {
      return false;
    }

    tx.update(ref, { count: current + 1 });
    return true;
  });

  if (!allowed) {
    logger.warn("rate limit exceeded", { uid, action, maxRequests });
    throw new HttpsError("resource-exhausted", "Too many requests. Please try again later.");
  }
}
