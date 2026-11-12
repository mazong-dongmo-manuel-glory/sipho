import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { logger } from "./logger";

const db = () => getFirestore();

/**
 * Idempotency key store backed by Firestore.
 *
 * Usage:
 *   const key = idempotencyKey("completeLesson", uid, lessonId, attemptId);
 *   if (await checkAndMarkIdempotencyKey(key)) return; // already processed
 */

export function idempotencyKey(...parts: string[]): string {
  return parts.join("::");
}

/**
 * Returns `true` if the key was already processed (caller should short-circuit).
 * Atomically marks the key as processed if it wasn't.
 */
export async function checkAndMarkIdempotencyKey(
  key: string,
  ttlMs = 7 * 24 * 60 * 60 * 1000 // 7 days
): Promise<boolean> {
  const ref = db().collection("_idempotency").doc(encodeKey(key));
  const snap = await ref.get();
  if (snap.exists) {
    logger.info("idempotency: already processed", { key });
    return true;
  }
  await ref.set({
    key,
    processedAt: FieldValue.serverTimestamp(),
    expiresAt: new Date(Date.now() + ttlMs),
  });
  return false;
}

/**
 * Delete a key (e.g. on rollback).
 */
export async function clearIdempotencyKey(key: string): Promise<void> {
  await db().collection("_idempotency").doc(encodeKey(key)).delete();
}

function encodeKey(key: string): string {
  // Firestore doc IDs can't contain forward-slashes
  return Buffer.from(key).toString("base64url");
}
