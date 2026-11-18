import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { z } from "zod";
import { ALLOWED_EXPENSE_CATEGORIES, ParseReceiptInputSchema } from "../shared/validators";
import { logger } from "../shared/logger";
import { idempotencyKey, checkAndMarkIdempotencyKey } from "../shared/idempotency";
import {
  SECURE_CALLABLE_OPTIONS,
  enforceRateLimit,
  parseInput,
  requireAuthUid,
} from "../shared/security";
import { callGeminiJson } from "./geminiClient";

const db = (): Firestore => getFirestore();

const MAX_RECEIPT_BYTES = 5 * 1024 * 1024;

const GeminiReceiptResponseSchema = z.object({
  isReceipt: z.boolean().default(true),
  amountCents: z.number().int().gt(0).lt(10_000_000),
  currency: z
    .string()
    .trim()
    .length(3)
    .transform((s) => s.toUpperCase()),
  category: z.enum(ALLOWED_EXPENSE_CATEGORIES),
  merchant: z.string().trim().min(1).max(60),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  confidence: z.number().min(0).max(1),
});

export type ParsedReceiptResult = z.infer<typeof GeminiReceiptResponseSchema>;

/**
 * Callable: server-side receipt parsing via Gemini Vision.
 * Enforces App Check, ownership of Storage path, 5 MB file limit, daily quota,
 * and strict Zod validation of the model output.
 */
export const parseReceipt = onCall(
  {
    ...SECURE_CALLABLE_OPTIONS,
    timeoutSeconds: 60,
  },
  async (request) => {
    const uid = requireAuthUid(request);
    const { storagePath } = parseInput(ParseReceiptInputSchema, request.data);

    if (!storagePath.startsWith(`receipts/${uid}/`)) {
      throw new HttpsError("permission-denied", "Cannot access another user's receipt.");
    }

    // README §3.4: free quota 5 scans/day (Remote Config later; server enforces the cap).
    const maxScansPerDay = Number(process.env.SCAN_QUOTA_PER_DAY ?? 5);
    await enforceRateLimit({
      uid,
      action: "parseReceipt",
      maxRequests: Number.isFinite(maxScansPerDay) && maxScansPerDay > 0 ? maxScansPerDay : 5,
      windowMs: 24 * 60 * 60 * 1000,
    });

    const ikey = idempotencyKey("parseReceipt", uid, storagePath);
    if (await checkAndMarkIdempotencyKey(ikey, 60 * 60 * 1000)) {
      logger.info("parseReceipt: duplicate request", { uid });
      throw new HttpsError("already-exists", "Receipt already processed.");
    }

    const file = getStorage().bucket().file(storagePath);
    const [exists] = await file.exists();
    if (!exists) {
      throw new HttpsError("not-found", "Receipt image not found.");
    }

    const [metadata] = await file.getMetadata();
    const byteSize = Number(metadata.size ?? 0);
    if (byteSize <= 0 || byteSize > MAX_RECEIPT_BYTES) {
      throw new HttpsError("invalid-argument", "Receipt image exceeds maximum allowed size.");
    }

    const contentType = metadata.contentType ?? "";
    const mimeType = contentType === "image/png" ? "image/png" : "image/jpeg";

    const [imageBuffer] = await file.download();
    const base64Image = imageBuffer.toString("base64");

    const result = await callGeminiVision(base64Image, mimeType);

    const fileName = storagePath.split("/").pop() ?? "unknown";
    const receiptId = fileName.replace(/\.[^.]+$/, "");
    await db().doc(`users/${uid}/receipts/${receiptId}`).set(
      {
        parsedAt: FieldValue.serverTimestamp(),
        parsedResult: result,
        storagePath,
        status: "parsed",
      },
      { merge: true }
    );

    logger.info("parseReceipt completed", { uid, receiptId, category: result.category });
    return result;
  }
);

async function callGeminiVision(
  base64Image: string,
  mimeType: string
): Promise<ParsedReceiptResult> {
  const apiKey = process.env.GEMINI_API_KEY ?? "";
  if (!apiKey) {
    throw new HttpsError("failed-precondition", "Receipt reading is unavailable.");
  }

  const text = await callGeminiJson({
    apiKey,
    parts: [
      { inline_data: { mime_type: mimeType, data: base64Image } },
      {
        text: `Extract ONLY what is visible on this receipt. Never extract card numbers, addresses, or phone numbers.
1. isReceipt (boolean)
2. amountCents (final total in integer cents)
3. currency (ISO 4217 3-letter code)
4. category (one of: ${ALLOWED_EXPENSE_CATEGORIES.join(", ")})
5. merchant (1-60 chars, no PII)
6. date (YYYY-MM-DD)
7. confidence (0.0-1.0)

Respond ONLY with valid JSON: {"isReceipt":true,"amountCents":int,"currency":"XXX","category":"...","merchant":"...","date":"YYYY-MM-DD","confidence":0.9}`,
      },
    ],
    maxOutputTokens: 1024,
    contextLabel: "parseReceipt",
  });

  if (!text) {
    throw new HttpsError("internal", "Receipt reading failed.");
  }

  let rawJson: unknown;
  try {
    rawJson = JSON.parse(text);
  } catch {
    throw new HttpsError("internal", "Invalid receipt reading format.");
  }

  const validated = GeminiReceiptResponseSchema.safeParse(rawJson);
  if (!validated.success || !validated.data.isReceipt) {
    throw new HttpsError("invalid-argument", "Image could not be validated as a receipt.");
  }

  return validated.data;
}
