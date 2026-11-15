/**
 * "Journée sous budget" (ADR-009, rule 9): pure decision logic, no Firestore here.
 *
 * Daily budget = max(0, monthly income - active fixed expenses) / days in the month. It is a
 * stable figure (it does not move with each purchase), so the user knows the target in advance.
 * The day only counts when at least one expense was logged: otherwise logging nothing would
 * always "stay under budget", rewarding the absence of tracking.
 */

export type BudgetDayOutcome =
  /** Spent no more than the daily budget, with at least one expense logged. */
  | "under"
  /** Spent more than the daily budget. No reward, no penalty. */
  | "over"
  /** No expense logged that day: not eligible. */
  | "no-activity"
  /** No income set, or fixed expenses leave nothing to spend: the rule does not apply. */
  | "no-budget";

export interface BudgetDayInput {
  incomeCents: number;
  fixedCents: number;
  /** Local day being evaluated, `YYYY-MM-DD`. */
  dayKey: string;
  spentCents: number;
  /** Number of valid expenses logged for that day. */
  expenseCount: number;
  /**
   * The user explicitly confirmed "no spending today" (`confirmNoSpend`). That is tracking too, so
   * a day without any expense becomes eligible; it can never excuse an over-budget day.
   */
  noSpendConfirmed?: boolean;
}

export function daysInMonth(dayKey: string): number {
  const match = /^(\d{4})-(\d{2})-\d{2}$/.exec(dayKey);
  if (!match) throw new Error(`Invalid day key: ${dayKey}`);
  const year = Number(match[1]);
  const month = Number(match[2]);
  if (month < 1 || month > 12) throw new Error(`Invalid day key: ${dayKey}`);
  return new Date(Date.UTC(year, month, 0)).getUTCDate();
}

function safeCents(value: number): number {
  return Number.isFinite(value) ? Math.max(0, Math.trunc(value)) : 0;
}

/** Integer cents the user may spend on one day of `dayKey`'s month. */
export function dailyBudgetCents(incomeCents: number, fixedCents: number, dayKey: string): number {
  const disposable = Math.max(0, safeCents(incomeCents) - safeCents(fixedCents));
  return Math.floor(disposable / daysInMonth(dayKey));
}

export function evaluateBudgetDay(input: BudgetDayInput): BudgetDayOutcome {
  const budget = dailyBudgetCents(input.incomeCents, input.fixedCents, input.dayKey);
  if (safeCents(input.incomeCents) <= 0 || budget <= 0) return "no-budget";
  if (input.expenseCount <= 0 && input.noSpendConfirmed !== true) return "no-activity";
  return safeCents(input.spentCents) <= budget ? "under" : "over";
}

/**
 * Amount of a stored transaction in the user's main currency, or 0 when it is not a valid
 * positive amount. Mirrors what the monthly aggregates and the client's "reste à vivre" count.
 */
export function effectiveTransactionCents(tx: {
  amountCents?: unknown;
  amountMainCents?: unknown;
}): number {
  const raw = typeof tx.amountMainCents === "number" ? tx.amountMainCents : tx.amountCents;
  if (typeof raw !== "number" || !Number.isFinite(raw)) return 0;
  const value = Math.trunc(raw);
  return value > 0 && value < 100_000_000 ? value : 0;
}

/** Monthly income from a user document (same fallbacks as `generateMonth`). */
export function readMonthlyIncomeCents(userData: Record<string, unknown> | undefined): number {
  const raw =
    typeof userData?.monthlyIncomeCents === "number"
      ? userData.monthlyIncomeCents
      : typeof userData?.incomeMonthlyCents === "number"
        ? userData.incomeMonthlyCents
        : 0;
  return safeCents(raw);
}
