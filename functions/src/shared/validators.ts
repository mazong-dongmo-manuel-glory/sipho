import { z } from "zod";

// ─── Primitive validators ─────────────────────────────────────────────────────

export const AmountCentsSchema = z
  .number()
  .int("amountCents must be an integer")
  .gt(0, "amountCents must be > 0")
  .lt(10_000_000, "amountCents must be < 10,000,000");

export const CurrencyCodeSchema = z
  .string()
  .length(3, "Currency must be a 3-letter ISO 4217 code")
  .toUpperCase();

export const CategorySchema = z.string().min(1).max(50);

export const SourceSchema = z.enum(["manual", "receipt"]);

export const LocaleSchema = z.enum(["fr", "en"]).default("fr");

export const CountryCodeSchema = z
  .string()
  .length(2, "Country must be a 2-letter ISO 3166-1 alpha-2 code")
  .toUpperCase();

// ─── Transaction ──────────────────────────────────────────────────────────────

export const TransactionInputSchema = z.object({
  amountCents: AmountCentsSchema,
  currency: CurrencyCodeSchema,
  category: CategorySchema,
  source: SourceSchema,
  note: z.string().max(200).optional(),
  date: z.string().datetime().optional(), // ISO 8601
});

export type TransactionInput = z.infer<typeof TransactionInputSchema>;

// ─── Lesson completion ────────────────────────────────────────────────────────

export const CompleteLessonInputSchema = z.object({
  lessonId: z.string().min(1).max(100),
  score: z.number().int().min(0).max(100),
  durationSeconds: z.number().int().min(0),
});

export type CompleteLessonInput = z.infer<typeof CompleteLessonInputSchema>;

// ─── Mark fixed paid ──────────────────────────────────────────────────────────

export const MarkFixedPaidInputSchema = z.object({
  fixedId: z.string().min(1).max(100),
  monthKey: z.string().regex(/^\d{4}-\d{2}$/, "monthKey must be YYYY-MM"),
});

export type MarkFixedPaidInput = z.infer<typeof MarkFixedPaidInputSchema>;

// ─── Delete account ───────────────────────────────────────────────────────────

export const DeleteAccountInputSchema = z.object({
  confirmPhrase: z.literal("DELETE MY ACCOUNT"),
});

export type DeleteAccountInput = z.infer<typeof DeleteAccountInputSchema>;

// ─── Referral ─────────────────────────────────────────────────────────────────

export const ReferralRedeemInputSchema = z.object({
  code: z.string().min(4).max(20).toUpperCase(),
});

export type ReferralRedeemInput = z.infer<typeof ReferralRedeemInputSchema>;

// ─── Parse receipt ────────────────────────────────────────────────────────────

export const ParseReceiptInputSchema = z.object({
  storagePath: z
    .string()
    .regex(/^receipts\/[a-zA-Z0-9_-]+\/[a-zA-Z0-9_.-]+$/, "Invalid storage path"),
});

export type ParseReceiptInput = z.infer<typeof ParseReceiptInputSchema>;
