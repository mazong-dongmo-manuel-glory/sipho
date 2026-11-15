import {
  CONTACT_HASH_PATTERN,
  hashEmail,
  hashPhone,
  identityHashes,
  normalizeEmail,
  normalizePhone,
  storedHashes,
  uniqueValidHashes,
} from "../shared/contacts";

describe("normalizeEmail", () => {
  test("trims and lower-cases", () => {
    expect(normalizeEmail("  Awa.Diop@Example.COM ")).toBe("awa.diop@example.com");
  });

  test("rejects anything that is not an address", () => {
    expect(normalizeEmail("")).toBeNull();
    expect(normalizeEmail("   ")).toBeNull();
    expect(normalizeEmail("not-an-email")).toBeNull();
    expect(normalizeEmail("a@b")).toBeNull();
    expect(normalizeEmail("a b@c.com")).toBeNull();
    expect(normalizeEmail(null)).toBeNull();
    expect(normalizeEmail(undefined)).toBeNull();
  });

  test("rejects an address longer than 254 characters", () => {
    expect(normalizeEmail(`${"a".repeat(250)}@b.co`)).toBeNull();
  });
});

describe("hashEmail", () => {
  test("is a SHA-256 hex digest and deterministic", () => {
    const hash = hashEmail("awa@example.com");
    expect(hash).toMatch(CONTACT_HASH_PATTERN);
    expect(hash).toBe(hashEmail("awa@example.com"));
    expect(hash).not.toBe(hashEmail("kofi@example.com"));
  });

  // The Flutter client must produce the same digest; this value is mirrored in its test.
  test("matches the known digest shared with the Flutter client", () => {
    expect(hashEmail("awa@example.com")).toBe(
      "462ca6eb415951837196183616b1ec6e1ea779a1cf66967aaaa4666460dfc36c"
    );
  });
});

describe("normalizePhone", () => {
  test("accepts strict E.164 only", () => {
    expect(normalizePhone("+22507070707")).toBe("+22507070707");
    expect(normalizePhone(" +14165551234 ")).toBe("+14165551234");
  });

  test("rejects local formats, too short, too long and junk", () => {
    expect(normalizePhone("0707070707")).toBeNull();
    expect(normalizePhone("+0123456789")).toBeNull();
    expect(normalizePhone("+1234567")).toBeNull();
    expect(normalizePhone("+1234567890123456")).toBeNull();
    expect(normalizePhone("+225 07 07")).toBeNull();
    expect(normalizePhone("")).toBeNull();
    expect(normalizePhone(null)).toBeNull();
  });
});

describe("hashPhone", () => {
  // Mirrored in the Flutter test: both sides must agree.
  test("matches the known digest shared with the Flutter client", () => {
    expect(hashPhone("+22507070707")).toBe(
      "2bbb8882ffefbff53680ed3f81343e9142c1e2a9ccddb87032b083a87820d9b3"
    );
  });

  test("never collides with an e-mail hash", () => {
    expect(hashPhone("+22507070707")).not.toBe(hashEmail("+22507070707@x.co"));
  });
});

describe("identityHashes", () => {
  test("indexes a verified e-mail and a phone number", () => {
    expect(
      identityHashes({
        email: "Awa@Example.com",
        emailVerified: true,
        phoneNumber: "+22507070707",
      })
    ).toEqual([hashEmail("awa@example.com"), hashPhone("+22507070707")]);
  });

  test("an unverified e-mail is never indexed", () => {
    expect(identityHashes({ email: "a@b.co", emailVerified: false })).toEqual([]);
    expect(
      identityHashes({ email: "a@b.co", emailVerified: false, phoneNumber: "+22507070707" })
    ).toEqual([hashPhone("+22507070707")]);
  });

  test("a phone number alone is enough; nothing at all gives nothing", () => {
    expect(identityHashes({ phoneNumber: "+14165551234" })).toEqual([
      hashPhone("+14165551234"),
    ]);
    expect(identityHashes({})).toEqual([]);
    expect(identityHashes({ phoneNumber: "0707070707" })).toEqual([]);
  });
});

describe("storedHashes", () => {
  const a = hashEmail("a@b.co");
  const b = hashPhone("+22507070707");

  test("reads the hashes list and the legacy emailHash, without duplicates", () => {
    expect(storedHashes({ hashes: [a, b] })).toEqual([a, b]);
    expect(storedHashes({ emailHash: a })).toEqual([a]);
    expect(storedHashes({ hashes: [a], emailHash: a })).toEqual([a]);
  });

  test("ignores malformed values", () => {
    expect(storedHashes({ hashes: ["nope", 3, a] })).toEqual([a]);
    expect(storedHashes({ hashes: "x", emailHash: 4 })).toEqual([]);
    expect(storedHashes(undefined)).toEqual([]);
  });
});

describe("uniqueValidHashes", () => {
  const good = hashEmail("a@b.co");

  test("drops malformed hashes and duplicates, keeping order", () => {
    const other = hashEmail("c@d.co");
    expect(uniqueValidHashes([good, "nope", other, good, good.toUpperCase()])).toEqual([
      good,
      other,
    ]);
  });

  test("accepts an empty list", () => {
    expect(uniqueValidHashes([])).toEqual([]);
  });
});
