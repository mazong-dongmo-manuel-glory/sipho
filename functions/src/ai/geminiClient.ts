import { logger } from "../shared/logger";

export const DEFAULT_GEMINI_MODEL = "gemini-3.5-flash-lite";
export const FALLBACK_GEMINI_MODELS = [
  DEFAULT_GEMINI_MODEL,
  "gemini-3.8-flash",
  "gemini-4-hydrogen",
] as const;

const RETIRED_PREFIXES = ["gemini-1.", "gemini-2.0", "gemini-2.5"];

function resolveModelChain(): string[] {
  const configured = (process.env.GEMINI_MODEL ?? "").trim();
  const chain: string[] = [];
  if (
    configured.length > 0 &&
    !RETIRED_PREFIXES.some((prefix) => configured.toLowerCase().startsWith(prefix))
  ) {
    chain.push(configured);
  }
  for (const model of FALLBACK_GEMINI_MODELS) {
    if (!chain.includes(model)) {
      chain.push(model);
    }
  }
  return chain;
}

export interface GeminiPartInput {
  text?: string;
  inline_data?: {
    mime_type: string;
    data: string;
  };
}

export interface CallGeminiJsonOptions {
  apiKey: string;
  parts: GeminiPartInput[];
  maxOutputTokens?: number;
  contextLabel: string;
  uid?: string;
}

interface GeminiApiCandidatePart {
  text?: string;
  thought?: boolean;
}

interface GeminiApiResponse {
  candidates?: Array<{
    content?: {
      parts?: GeminiApiCandidatePart[];
    };
  }>;
}

/**
 * Calls the Gemini Developer API (`generativelanguage.googleapis.com`) using
 * current supported models (`gemini-3.5-flash-lite` -> `gemini-3.8-flash` fallback),
 * omitting legacy `temperature` and filtering internal `thought: true` parts.
 */
export async function callGeminiJson(options: CallGeminiJsonOptions): Promise<string | null> {
  const { apiKey, parts, maxOutputTokens = 1536, contextLabel, uid } = options;
  const models = resolveModelChain();

  for (const model of models) {
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts }],
        generationConfig: {
          responseMimeType: "application/json",
          maxOutputTokens,
        },
      }),
    });

    if (!response.ok) {
      const status = response.status;
      logger.warn(`Gemini API HTTP ${status} in ${contextLabel}`, {
        uid,
        model,
        status,
      });
      if (status === 404 || status === 400) {
        continue;
      }
      return null;
    }

    const data = (await response.json()) as GeminiApiResponse;
    const candidateParts = data.candidates?.[0]?.content?.parts ?? [];
    const nonThought = candidateParts.filter(
      (p) => p.thought !== true && typeof p.text === "string" && p.text.trim().length > 0
    );
    if (nonThought.length > 0) {
      return nonThought.map((p) => p.text ?? "").join("\n").trim();
    }

    const anyText = candidateParts.find(
      (p) => typeof p.text === "string" && p.text.trim().length > 0
    );
    if (anyText?.text) {
      return anyText.text.trim();
    }
  }

  return null;
}
