import { getFirestore, FieldValue, Firestore, Timestamp } from "firebase-admin/firestore";
import { logger } from "./logger";

const db = (): Firestore => getFirestore();

/**
 * Idempotency key store backed by Firestore transactions so concurrent retries
 * cannot both pass the check.
 */
export function idempotencyKey(...parts: string[]): string {
  return parts.join("::");
}

/**
 * Atomically checks and records `key`.
 * Returns `true` if `key` was already processed (and not yet expired).
 */
export async function checkAndMarkIdempotencyKey(
  key: string,
  ttlMs = 7 * 24 * 60 * 60 * 1000
): Promise<boolean> {
  const ref = db().collection("_idempotency").doc(encodeKey(key));
  const nowMs = Date.now();

  const alreadyProcessed = await db().runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (snap.exists) {
      const expiresAt = snap.data()?.expiresAt as Timestamp | undefined;
      if (!expiresAt || expiresAt.toMillis() > nowMs) {
        return true;
      }
    }
    tx.set(ref, {
      key,
      processedAt: FieldValue.serverTimestamp(),
      expiresAt: Timestamp.fromMillis(nowMs + ttlMs),
    });
    return false;
  });

  if (alreadyProcessed) {
    logger.info("idempotency: already processed", { key });
  }
  return alreadyProcessed;
}

export async function clearIdempotencyKey(key: string): Promise<void> {
  await db().collection("_idempotency").doc(encodeKey(key)).delete();
}

export function encodeKey(key: string): string {
  return Buffer.from(key).toString("base64url").slice(0, 500);
}
