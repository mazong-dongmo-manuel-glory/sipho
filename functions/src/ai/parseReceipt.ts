import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { ParseReceiptInputSchema } from "../shared/validators";
import { logger } from "../shared/logger";
import { idempotencyKey, checkAndMarkIdempotencyKey } from "../shared/idempotency";

const db = () => getFirestore();

/**
 * Callable (optional): server-side receipt parsing via Gemini Vision.
 *
 * Client sends: { storagePath }  — the receipt image path in Firebase Storage.
 * Server returns: { amountCents, currency, category, merchant, date }
 */
export const parseReceipt = onCall(
  {
    region: "us-central1",
    enforceAppCheck: true,
    timeoutSeconds: 60,
  },
  async (request) => {
    if (!request.auth) throw new HttpsError("unauthenticated", "Login required");
    const uid = request.auth.uid;

    const parsed = ParseReceiptInputSchema.safeParse(request.data);
    if (!parsed.success) {
      throw new HttpsError("invalid-argument", parsed.error.message);
    }
    const { storagePath } = parsed.data;

    // Verify the path belongs to this user
    if (!storagePath.startsWith(`receipts/${uid}/`)) {
      throw new HttpsError("permission-denied", "Cannot access another user's receipt");
    }

    const ikey = idempotencyKey("parseReceipt", uid, storagePath);
    if (await checkAndMarkIdempotencyKey(ikey, 60 * 60 * 1000 /* 1h */)) {
      logger.info("parseReceipt: duplicate request", { uid });
      throw new HttpsError("already-exists", "Receipt already being processed");
    }

    logger.info("parseReceipt started", { uid, storagePath });

    // Download image from Storage
    const bucket = getStorage().bucket();
    const [imageBuffer] = await bucket.file(storagePath).download();
    const base64Image = imageBuffer.toString("base64");
    const mimeType = storagePath.endsWith(".png") ? "image/png" : "image/jpeg";

    // Call Gemini (using REST API via firebase-admin AI or HTTP)
    const result = await callGeminiVision(base64Image, mimeType);

    // Store parsed result in Firestore (attached to the receipt doc)
    const receiptId = storagePath.split("/").pop()?.split(".")[0] ?? "unknown";
    await db().doc(`users/${uid}/receipts/${receiptId}`).set(
      {
        parsedAt: FieldValue.serverTimestamp(),
        parsedResult: result,
        storagePath,
      },
      { merge: true }
    );

    logger.info("parseReceipt completed", { uid, receiptId });
    return result;
  }
);

interface ParsedReceipt {
  amountCents: number;
  currency: string;
  category: string;
  merchant: string;
  date: string;
  confidence: number;
}

async function callGeminiVision(
  base64Image: string,
  mimeType: string
): Promise<ParsedReceipt> {
  // Using Gemini 1.5 Flash via Google AI SDK
  // In production, use @google/generative-ai or the firebase_ai package
  const API_KEY = process.env.GEMINI_API_KEY ?? "";
  if (!API_KEY) {
    logger.warn("GEMINI_API_KEY not set, returning mock");
    return mockParsedReceipt();
  }

  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${API_KEY}`;

  const payload = {
    contents: [
      {
        parts: [
          {
            inline_data: { mime_type: mimeType, data: base64Image },
          },
          {
            text: `Extract from this receipt:
1. Total amount (integer cents)
2. Currency code (ISO 4217, 3 letters)
3. Category (one of: food, transport, utilities, health, entertainment, clothing, other)
4. Merchant name (1-50 chars, no PII)
5. Date (YYYY-MM-DD)

Respond ONLY with valid JSON: {"amountCents":int,"currency":"XXX","category":"...","merchant":"...","date":"YYYY-MM-DD","confidence":0.0-1.0}`,
          },
        ],
      },
    ],
    generationConfig: {
      responseMimeType: "application/json",
      maxOutputTokens: 200,
    },
  };

  const response = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    throw new HttpsError("internal", "Gemini API error");
  }

  const data = (await response.json()) as {
    candidates?: Array<{ content?: { parts?: Array<{ text?: string }> } }>;
  };
  const text = data.candidates?.[0]?.content?.parts?.[0]?.text ?? "{}";

  return JSON.parse(text) as ParsedReceipt;
}

function mockParsedReceipt(): ParsedReceipt {
  return {
    amountCents: 1234,
    currency: "CAD",
    category: "food",
    merchant: "Grocery Store",
    date: new Date().toISOString().slice(0, 10),
    confidence: 0.5,
  };
}
