import {
  INVITE_CODE_LENGTH,
  canRespondToRequest,
  classifyFriendRequest,
  friendPairId,
  inviteCodeFor,
} from "../shared/friends";
import { ReferralRedeemInputSchema } from "../shared/validators";

describe("inviteCodeFor", () => {
  test("is deterministic and has the expected shape", () => {
    const code = inviteCodeFor("uid_abc123");
    expect(code).toBe(inviteCodeFor("uid_abc123"));
    expect(code).toHaveLength(INVITE_CODE_LENGTH);
  });

  test("avoids look-alike characters (0, O, 1, I)", () => {
    for (let i = 0; i < 200; i++) {
      expect(inviteCodeFor(`user-${i}`)).toMatch(/^[A-HJ-NP-Z2-9]+$/);
    }
  });

  test("differs between users and between attempts", () => {
    expect(inviteCodeFor("alice")).not.toBe(inviteCodeFor("bob"));
    expect(inviteCodeFor("alice", 0)).not.toBe(inviteCodeFor("alice", 1));
  });

  test("never collides on a few thousand uids", () => {
    const seen = new Set<string>();
    for (let i = 0; i < 5_000; i++) seen.add(inviteCodeFor(`u${i}`));
    expect(seen.size).toBe(5_000);
  });

  test("is accepted by the referral code validator the redeem flow uses", () => {
    const parsed = ReferralRedeemInputSchema.parse({ referralCode: inviteCodeFor("someone") });
    expect(parsed.referralCode).toBe(inviteCodeFor("someone"));
  });

  test("a code typed in lower case or with spaces still validates to the same code", () => {
    const code = inviteCodeFor("someone");
    const typed = ReferralRedeemInputSchema.parse({ referralCode: `  ${code.toLowerCase()} ` });
    expect(typed.referralCode).toBe(code);
  });
});

describe("friendPairId", () => {
  test("is the same whichever side computes it", () => {
    expect(friendPairId("alice", "bob")).toBe(friendPairId("bob", "alice"));
    expect(friendPairId("alice", "bob")).toBe("alice_bob");
  });

  test("differs for different pairs", () => {
    expect(friendPairId("a", "b")).not.toBe(friendPairId("a", "c"));
  });
});

describe("classifyFriendRequest", () => {
  test("creates a request when nothing exists", () => {
    expect(classifyFriendRequest(undefined, "alice")).toBe("create");
  });

  test("refuses to re-send a pending request or to re-add a friend", () => {
    expect(classifyFriendRequest({ status: "pending", requesterUid: "alice" }, "alice")).toBe(
      "already-pending"
    );
    expect(classifyFriendRequest({ status: "accepted", requesterUid: "bob" }, "alice")).toBe(
      "already-friends"
    );
  });

  test("a request crossing an incoming one is accepted", () => {
    expect(classifyFriendRequest({ status: "pending", requesterUid: "bob" }, "alice")).toBe(
      "auto-accept"
    );
  });
});

describe("canRespondToRequest", () => {
  const pending = { users: ["alice", "bob"], status: "pending", requesterUid: "alice" };

  test("only the recipient of a pending request can answer it", () => {
    expect(canRespondToRequest(pending, "bob")).toBe(true);
  });

  test("the requester cannot accept their own request", () => {
    expect(canRespondToRequest(pending, "alice")).toBe(false);
  });

  test("a stranger cannot answer", () => {
    expect(canRespondToRequest(pending, "mallory")).toBe(false);
  });

  test("an accepted friendship has nothing left to answer", () => {
    expect(canRespondToRequest({ ...pending, status: "accepted" }, "bob")).toBe(false);
  });

  test("malformed documents are refused", () => {
    expect(canRespondToRequest({ status: "pending" }, "bob")).toBe(false);
    expect(canRespondToRequest({ users: "bob", status: "pending", requesterUid: "x" }, "bob")).toBe(
      false
    );
  });
});
