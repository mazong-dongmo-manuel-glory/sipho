import { Query, QueryDocumentSnapshot } from "firebase-admin/firestore";
import { logger } from "./logger";

export interface PaginateOptions {
  /** Documents fetched per Firestore page. */
  pageSize?: number;
  /** Documents handled concurrently inside a page. */
  concurrency?: number;
  /** Pause between concurrent chunks (simple throttle for rate-limited upstream APIs). */
  pauseMsBetweenChunks?: number;
  /** Stops early (e.g. before the function timeout). Return true to stop. */
  shouldStop?: () => boolean;
  /** Label used in logs. */
  label?: string;
}

export interface PaginateResult {
  processed: number;
  failed: number;
  stoppedEarly: boolean;
}

/**
 * Walks every document matched by `query`, page by page, so scheduled jobs keep working
 * beyond a few hundred users.
 *
 * The query must have a deterministic order. Equality-only queries are ordered by document
 * id and range queries by the range field then document id, so a snapshot cursor is always valid.
 * Per-document failures are logged and counted; they never abort the run.
 */
export async function forEachDocument(
  query: Query,
  handler: (doc: QueryDocumentSnapshot) => Promise<void>,
  options: PaginateOptions = {}
): Promise<PaginateResult> {
  const pageSize = options.pageSize ?? 300;
  const concurrency = Math.max(1, options.concurrency ?? 20);
  const label = options.label ?? "forEachDocument";
  let cursor: QueryDocumentSnapshot | undefined;
  let processed = 0;
  let failed = 0;

  for (;;) {
    if (options.shouldStop?.()) {
      logger.warn("pagination stopped early", { label, processed });
      return { processed, failed, stoppedEarly: true };
    }

    const page = await (cursor ? query.startAfter(cursor) : query).limit(pageSize).get();
    if (page.empty) break;

    for (let i = 0; i < page.docs.length; i += concurrency) {
      const slice = page.docs.slice(i, i + concurrency);
      if (i > 0 && options.pauseMsBetweenChunks) {
        await new Promise((resolve) => setTimeout(resolve, options.pauseMsBetweenChunks));
      }
      const results = await Promise.allSettled(slice.map((doc) => handler(doc)));
      results.forEach((result, idx) => {
        processed += 1;
        if (result.status === "rejected") {
          failed += 1;
          logger.error("pagination handler failed", {
            label,
            path: slice[idx].ref.path,
            error: String(result.reason),
          });
        }
      });
    }

    cursor = page.docs[page.docs.length - 1];
    if (page.size < pageSize) break;
  }

  return { processed, failed, stoppedEarly: false };
}

/** Deadline helper: returns a `shouldStop` that trips shortly before the function timeout. */
export function deadlineGuard(timeoutSeconds: number, marginSeconds = 30): () => boolean {
  const deadline = Date.now() + Math.max(10, timeoutSeconds - marginSeconds) * 1000;
  return () => Date.now() >= deadline;
}
