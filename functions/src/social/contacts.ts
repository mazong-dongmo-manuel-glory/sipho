import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { z } from "zod";
import {
  SECURE_CALLABLE_OPTIONS,
  enforceRateLimit,
  parseInput,
  requireAuthUid,
} from "../shared/security";
import {
  MAX_CONTACT_HASHES_PER_CALL,
  MAX_CONTACT_MATCHES,
  identityHashes,
  storedHashes,
  uniqueValidHashes,
} from "../shared/contacts";
import { createFriendRequest } from "./friends";
import { removeFromContactIndex } from "./contactIndex";
import { logger } from "../shared/logger";

const db = (): Firestore => getFirestore();

const SetDiscoveryInputSchema = z.object({ enabled: z.boolean() });
const FindContactsInputSchema = z.object({
  hashes: z.array(z.string().max(64)).min(1).max(MAX_CONTACT_HASHES_PER_CALL),
});
const ContactRequestInputSchema = z.object({
  targetUid: z.string().trim().min(1).max(128),
});

/** Where a user's opt-in is stored (client-readable, server-written). */
const discoveryRef = (uid: string): FirebaseFirestore.DocumentReference =>
  db().doc(`users/${uid}/social/contacts`);

async function isDiscoverable(uid: string): Promise<boolean> {
  const snap = await discoveryRef(uid).get();
  return (snap.data() as { enabled?: unknown } | undefined)?.enabled === true;
}

/**
 * Callable: opts the caller in or out of contact discovery.
 *
 * Opting in publishes the SHA-256 of the caller's verified e-mail and / or verified phone number
 * in `contactIndex` (server-only), so people who have that address or number in their phone book
 * can find them, and lets the caller look their own contacts up. Calling it again after the
 * account gained a verified number indexes the number too. Opting out removes every entry.
 * Discovery is reciprocal on purpose: it makes the lookup useless as a way to scrape accounts
 * without being findable yourself.
 */
export const setContactDiscovery = onCall(
  SECURE_CALLABLE_OPTIONS,
  async (request) => {
    const uid = requireAuthUid(request);
    const { enabled } = parseInput(SetDiscoveryInputSchema, request.data);

    await enforceRateLimit({
      uid,
      action: "setContactDiscovery",
      maxRequests: 20,
      windowMs: 60 * 60 * 1000,
    });

    const stateRef = discoveryRef(uid);
    const previous = storedHashes(
      (await stateRef.get()).data() as
        { hashes?: unknown; emailHash?: unknown } | undefined,
    );

    if (!enabled) {
      await removeFromContactIndex(uid, previous);
      await stateRef.set({
        enabled: false,
        hashes: [],
        updatedAt: FieldValue.serverTimestamp(),
      });
      logger.info("contact discovery disabled", { uid });
      return { enabled: false };
    }

    // Findable under every verified identity the account has: e-mail and / or phone number.
    const authUser = await admin.auth().getUser(uid);
    const hashes = identityHashes({
      email: authUser.email,
      emailVerified: authUser.emailVerified,
      phoneNumber: authUser.phoneNumber,
    });
    if (hashes.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "A verified e-mail address or phone number is required.",
      );
    }

    // An identity that changed since the last opt-in (new e-mail, number removed): drop its entry.
    await removeFromContactIndex(
      uid,
      previous.filter((hash) => !hashes.includes(hash)),
    );

    const batch = db().batch();
    for (const hash of hashes) {
      batch.set(db().doc(`contactIndex/${hash}`), {
        uid,
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
    batch.set(stateRef, {
      enabled: true,
      hashes,
      updatedAt: FieldValue.serverTimestamp(),
    });
    await batch.commit();

    logger.info("contact discovery enabled", {
      uid,
      identities: hashes.length,
    });
    return {
      enabled: true,
      hasEmail: authUser.emailVerified && !!authUser.email,
      hasPhone: !!authUser.phoneNumber,
    };
  },
);

/**
 * Callable: given the SHA-256 of normalized e-mails from the caller's address book, returns the
 * Sipho users who are discoverable. Requires the caller to be discoverable too. The server never
 * learns the address of a contact who is not a user, and nothing is stored from the request.
 */
export const findContacts = onCall(SECURE_CALLABLE_OPTIONS, async (request) => {
  const uid = requireAuthUid(request);
  const { hashes: rawHashes } = parseInput(
    FindContactsInputSchema,
    request.data,
  );

  await enforceRateLimit({
    uid,
    action: "findContacts",
    maxRequests: 10,
    windowMs: 24 * 60 * 60 * 1000,
  });

  if (!(await isDiscoverable(uid))) {
    throw new HttpsError(
      "failed-precondition",
      "Enable contact discovery first.",
    );
  }

  const hashes = uniqueValidHashes(rawHashes);
  const matches: { hash: string; uid: string }[] = [];

  for (
    let i = 0;
    i < hashes.length && matches.length < MAX_CONTACT_MATCHES;
    i += 300
  ) {
    const refs = hashes
      .slice(i, i + 300)
      .map((hash) => db().doc(`contactIndex/${hash}`));
    const snaps = await db().getAll(...refs);
    for (const snap of snaps) {
      const owner = (snap.data() as { uid?: unknown } | undefined)?.uid;
      if (snap.exists && typeof owner === "string" && owner !== uid) {
        matches.push({ hash: snap.id, uid: owner });
      }
    }
  }

  logger.info("contacts looked up", {
    uid,
    submitted: hashes.length,
    matched: matches.length,
  });
  return { matches: matches.slice(0, MAX_CONTACT_MATCHES) };
});

/**
 * Callable: friend request to a user found through `findContacts`. Only discoverable users can be
 * reached this way, from a discoverable caller; anyone else must share a friend code.
 */
export const sendContactFriendRequest = onCall(
  SECURE_CALLABLE_OPTIONS,
  async (request) => {
    const uid = requireAuthUid(request);
    const { targetUid } = parseInput(ContactRequestInputSchema, request.data);

    await enforceRateLimit({
      uid,
      action: "sendFriendRequest",
      maxRequests: 20,
      windowMs: 24 * 60 * 60 * 1000,
    });

    if (!(await isDiscoverable(uid)) || !(await isDiscoverable(targetUid))) {
      throw new HttpsError(
        "not-found",
        "This person cannot be reached from your contacts.",
      );
    }

    return createFriendRequest(uid, targetUid, "contacts");
  },
);
