import { createHash } from "crypto";

/** Hashes a client may submit in one `findContacts` call. */
export const MAX_CONTACT_HASHES_PER_CALL = 1000;

/** Matches returned by one `findContacts` call (a sane friend list is far below this). */
export const MAX_CONTACT_MATCHES = 200;

/** SHA-256 hex digest, the only shape accepted for a contact hash. */
export const CONTACT_HASH_PATTERN = /^[a-f0-9]{64}$/;

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/**
 * Canonical form of an e-mail address for contact matching: trimmed and lower-cased. Returns
 * `null` for anything that is not plausibly an address. The Flutter client applies the exact same
 * rules (`normalizeContactEmail`), otherwise the hashes would never meet.
 */
export function normalizeEmail(raw: string | null | undefined): string | null {
  if (typeof raw !== "string") return null;
  const email = raw.trim().toLowerCase();
  if (email.length === 0 || email.length > 254) return null;
  return EMAIL_PATTERN.test(email) ? email : null;
}

/** SHA-256 hex of a normalized e-mail: the key of `contactIndex/{hash}`. */
export function hashEmail(normalizedEmail: string): string {
  return createHash("sha256").update(normalizedEmail).digest("hex");
}

const E164_PATTERN = /^\+[1-9][0-9]{7,14}$/;

/**
 * A phone number in strict E.164 form (`+` and 8 to 15 digits), or `null`. Firebase Auth already
 * stores verified numbers this way; the Flutter client builds the same form from a contact's
 * local number (`normalizeContactPhone`).
 */
export function normalizePhone(raw: string | null | undefined): string | null {
  if (typeof raw !== "string") return null;
  const phone = raw.trim();
  return E164_PATTERN.test(phone) ? phone : null;
}

/** SHA-256 hex of an E.164 number: same index as e-mails (they can never collide: no `@`). */
export function hashPhone(e164: string): string {
  return createHash("sha256").update(e164).digest("hex");
}

/**
 * Index keys a user can be found under: the hash of their verified e-mail and the hash of their
 * verified phone number. An unverified e-mail never counts (anyone could claim any address).
 */
export function identityHashes(identity: {
  email?: string | null;
  emailVerified?: boolean;
  phoneNumber?: string | null;
}): string[] {
  const hashes: string[] = [];
  const email = identity.emailVerified ? normalizeEmail(identity.email) : null;
  if (email) hashes.push(hashEmail(email));
  const phone = normalizePhone(identity.phoneNumber);
  if (phone) hashes.push(hashPhone(phone));
  return hashes;
}

/** Hashes recorded in a user's discovery state (`hashes`, or the legacy single `emailHash`). */
export function storedHashes(
  state: { hashes?: unknown; emailHash?: unknown } | undefined,
): string[] {
  const out: string[] = [];
  const add = (value: unknown): void => {
    if (
      typeof value === "string" &&
      CONTACT_HASH_PATTERN.test(value) &&
      !out.includes(value)
    ) {
      out.push(value);
    }
  };
  if (Array.isArray(state?.hashes)) {
    for (const value of state.hashes as unknown[]) add(value);
  }
  add(state?.emailHash);
  return out;
}

/** Keeps the valid, distinct hashes, in their original order. */
export function uniqueValidHashes(hashes: readonly string[]): string[] {
  const seen = new Set<string>();
  for (const hash of hashes) {
    if (CONTACT_HASH_PATTERN.test(hash)) seen.add(hash);
  }
  return [...seen];
}
