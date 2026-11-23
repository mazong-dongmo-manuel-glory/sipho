import { z } from "zod";
import { ALL_AWARDABLE_LESSON_IDS } from "./lessonPath";

// ─── Allowed categories (aligned with Flutter ExpenseCategory) ───────────────

export const ALLOWED_EXPENSE_CATEGORIES = [
  "rent",
  "internet",
  "energy",
  "phone",
  "groceries",
  "transport",
  "restaurants",
  "shopping",
  "family",
] as const;

/**
 * Lessons that can award XP, derived from the lesson path (shared/lessonPath.ts, mirrored by
 * `kCatalogUnits` in the Flutter app): an unknown id must never earn XP.
 */
export const ALLOWED_LESSON_IDS = ALL_AWARDABLE_LESSON_IDS;

// ─── Primitive validators ─────────────────────────────────────────────────────

export const AmountCentsSchema = z
  .number()
  .int("amountCents must be an integer")
  .gt(0, "amountCents must be > 0")
  .lt(10_000_000, "amountCents must be < 10,000,000");

export const CurrencyCodeSchema = z
  .string()
  .trim()
  .length(3, "Currency must be a 3-letter ISO 4217 code")
  .transform((s) => s.toUpperCase())
  .pipe(z.string().regex(/^[A-Z]{3}$/, "Currency must be A-Z"));

export const CategorySchema = z.enum(ALLOWED_EXPENSE_CATEGORIES);

export const SourceSchema = z.enum(["manual", "receipt"]);

export const LocaleSchema = z.enum(["fr", "en"]).default("fr");

export const CountryCodeSchema = z
  .string()
  .trim()
  .length(2, "Country must be a 2-letter ISO 3166-1 alpha-2 code")
  .transform((s) => s.toUpperCase())
  .pipe(z.string().regex(/^[A-Z]{2}$/, "Country must be A-Z"));

export const IsoDateSchema = z
  .string()
  .regex(/^\d{4}-\d{2}-\d{2}$/, "date must be YYYY-MM-DD");

export const IsoMonthSchema = z
  .string()
  .regex(/^\d{4}-\d{2}$/, "monthKey must be YYYY-MM");

// ─── Transaction ──────────────────────────────────────────────────────────────

export const TransactionInputSchema = z.object({
  amountCents: AmountCentsSchema,
  currency: CurrencyCodeSchema,
  category: CategorySchema,
  source: SourceSchema,
  merchant: z.string().trim().max(80).optional(),
  note: z.string().trim().max(200).optional(),
  date: IsoDateSchema,
});

export type TransactionInput = z.infer<typeof TransactionInputSchema>;

// ─── Lesson completion ────────────────────────────────────────────────────────

const GeneratedLessonIdSchema = z
  .string()
  .regex(/^gen_\d{3}$/, "Unknown lessonId");

export const CompleteLessonInputSchema = z.object({
  lessonId: z.union([
    z.enum(ALLOWED_LESSON_IDS, {
      errorMap: () => ({ message: "Unknown lessonId" }),
    }),
    GeneratedLessonIdSchema,
  ]),
  score: z.number().int().min(0).max(100),
  durationSeconds: z.number().int().min(2, "Duration too short").max(3600),
  attemptId: z
    .string()
    .trim()
    .min(1)
    .max(80)
    .regex(/^[a-zA-Z0-9_-]+$/)
    .optional(),
});

export type CompleteLessonInput = z.infer<typeof CompleteLessonInputSchema>;

// ─── Mark fixed paid ──────────────────────────────────────────────────────────

export const MarkFixedPaidInputSchema = z.object({
  fixedId: z
    .string()
    .trim()
    .min(1)
    .max(100)
    .regex(/^[a-zA-Z0-9_-]+$/, "Invalid fixedId"),
  monthKey: IsoMonthSchema,
});

export type MarkFixedPaidInput = z.infer<typeof MarkFixedPaidInputSchema>;

// ─── Delete account ───────────────────────────────────────────────────────────

export const DeleteAccountInputSchema = z.object({
  confirmPhrase: z.literal("DELETE MY ACCOUNT"),
});

export type DeleteAccountInput = z.infer<typeof DeleteAccountInputSchema>;

// ─── Referral ─────────────────────────────────────────────────────────────────

export const ReferralRedeemInputSchema = z.object({
  referralCode: z
    .string()
    .trim()
    .min(4)
    .max(20)
    .transform((s) => s.toUpperCase())
    .pipe(z.string().regex(/^[A-Z0-9_-]+$/, "Invalid referral code")),
});

export type ReferralRedeemInput = z.infer<typeof ReferralRedeemInputSchema>;

// ─── Parse receipt ────────────────────────────────────────────────────────────

export const ParseReceiptInputSchema = z.object({
  storagePath: z
    .string()
    .max(200)
    .refine((p) => !p.includes(".."), "Path traversal is not allowed")
    .pipe(
      z.string().regex(
        /^receipts\/[a-zA-Z0-9_-]+\/[a-zA-Z0-9_-]+\.(jpg|jpeg|png)$/i,
        "Invalid storage path"
      )
    ),
});

export type ParseReceiptInput = z.infer<typeof ParseReceiptInputSchema>;
