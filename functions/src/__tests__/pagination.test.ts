import { Query, QueryDocumentSnapshot } from "firebase-admin/firestore";
import { forEachDocument } from "../shared/pagination";

/** Minimal in-memory stand-in for a Firestore query ordered by id. */
function fakeQuery(ids: string[]): Query {
  const docs = ids.map(
    (id) => ({ id, ref: { path: `users/${id}` } }) as unknown as QueryDocumentSnapshot
  );
  const make = (start: number, max: number): Query =>
    ({
      startAfter: (cursor: QueryDocumentSnapshot) =>
        make(docs.findIndex((d) => d.id === cursor.id) + 1, max),
      limit: (n: number) => make(start, n),
      get: () => {
        const slice = docs.slice(start, start + max);
        return Promise.resolve({ docs: slice, empty: slice.length === 0, size: slice.length });
      },
    }) as unknown as Query;
  return make(0, Number.MAX_SAFE_INTEGER);
}

describe("forEachDocument", () => {
  test("visits every document across pages (no 200/250/500 cap)", async () => {
    const ids = Array.from({ length: 1234 }, (_, i) => `u${i}`);
    const seen: string[] = [];
    const result = await forEachDocument(
      fakeQuery(ids),
      (doc) => {
        seen.push(doc.id);
        return Promise.resolve();
      },
      { pageSize: 100, concurrency: 7 }
    );
    expect(result).toEqual({ processed: 1234, failed: 0, stoppedEarly: false });
    expect(new Set(seen).size).toBe(1234);
  });

  test("one failing document does not abort the run", async () => {
    const result = await forEachDocument(
      fakeQuery(["a", "b", "c", "d"]),
      (doc) => (doc.id === "b" ? Promise.reject(new Error("boom")) : Promise.resolve()),
      { pageSize: 2 }
    );
    expect(result.processed).toBe(4);
    expect(result.failed).toBe(1);
  });

  test("stops early when the deadline guard trips", async () => {
    let pages = 0;
    const result = await forEachDocument(
      fakeQuery(Array.from({ length: 50 }, (_, i) => `u${i}`)),
      () => Promise.resolve(),
      { pageSize: 10, shouldStop: () => ++pages > 2 }
    );
    expect(result.stoppedEarly).toBe(true);
    expect(result.processed).toBe(20);
  });
});
