import { getFirestore } from "firebase-admin/firestore";

/**
 * Removes `contactIndex/{hash}` entries that belong to `uid`. An entry now owned by someone else
 * (the same address moved to another account) is left alone.
 */
export async function removeFromContactIndex(
  uid: string,
  hashes: readonly string[],
): Promise<void> {
  const db = getFirestore();
  for (const hash of hashes) {
    const ref = db.doc(`contactIndex/${hash}`);
    const owner = (await ref.get()).data() as { uid?: unknown } | undefined;
    if (owner?.uid === uid) await ref.delete();
  }
}
