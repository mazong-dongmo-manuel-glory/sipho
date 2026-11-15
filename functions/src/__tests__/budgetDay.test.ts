import {
  dailyBudgetCents,
  daysInMonth,
  effectiveTransactionCents,
  evaluateBudgetDay,
  readMonthlyIncomeCents,
} from "../shared/budgetDay";
import { XP_CONFIG } from "../shared/xpConfig";

const DAY = "2026-11-10"; // November: 30 days

describe("daysInMonth", () => {
  test("handles 28, 29, 30 and 31 day months", () => {
    expect(daysInMonth("2026-02-10")).toBe(28);
    expect(daysInMonth("2028-02-10")).toBe(29);
    expect(daysInMonth("2026-11-10")).toBe(30);
    expect(daysInMonth("2026-12-31")).toBe(31);
  });

  test("rejects a malformed day key", () => {
    expect(() => daysInMonth("2026-13-01")).toThrow();
    expect(() => daysInMonth("nope")).toThrow();
  });
});

describe("dailyBudgetCents", () => {
  test("is (income - fixed) / days in month, in whole cents", () => {
    expect(dailyBudgetCents(300_000, 60_000, DAY)).toBe(8_000);
    expect(dailyBudgetCents(100_000, 0, DAY)).toBe(3_333); // 3333.33 -> floored
  });

  test("never goes negative when fixed expenses exceed income", () => {
    expect(dailyBudgetCents(100_000, 150_000, DAY)).toBe(0);
  });

  test("ignores garbage values", () => {
    expect(dailyBudgetCents(Number.NaN, 0, DAY)).toBe(0);
    expect(dailyBudgetCents(-5, 0, DAY)).toBe(0);
  });
});

describe("evaluateBudgetDay", () => {
  const base = { incomeCents: 300_000, fixedCents: 60_000, dayKey: DAY }; // budget 8 000

  test("under budget with at least one expense is rewarded", () => {
    expect(evaluateBudgetDay({ ...base, spentCents: 5_000, expenseCount: 2 })).toBe("under");
  });

  test("spending exactly the budget still counts", () => {
    expect(evaluateBudgetDay({ ...base, spentCents: 8_000, expenseCount: 1 })).toBe("under");
  });

  test("one cent over the budget does not", () => {
    expect(evaluateBudgetDay({ ...base, spentCents: 8_001, expenseCount: 1 })).toBe("over");
  });

  test("logging nothing is never rewarded (no reward for not tracking)", () => {
    expect(evaluateBudgetDay({ ...base, spentCents: 0, expenseCount: 0 })).toBe("no-activity");
  });

  test("a confirmed 'no spending' day is eligible, but never excuses an over-budget day", () => {
    expect(
      evaluateBudgetDay({ ...base, spentCents: 0, expenseCount: 0, noSpendConfirmed: true })
    ).toBe("under");
    expect(
      evaluateBudgetDay({ ...base, spentCents: 9_000, expenseCount: 1, noSpendConfirmed: true })
    ).toBe("over");
    expect(
      evaluateBudgetDay({ ...base, spentCents: 0, expenseCount: 0, noSpendConfirmed: false })
    ).toBe("no-activity");
  });

  test("without income, or with no money left after fixed expenses, the rule does not apply", () => {
    expect(
      evaluateBudgetDay({ ...base, incomeCents: 0, spentCents: 100, expenseCount: 1 })
    ).toBe("no-budget");
    expect(
      evaluateBudgetDay({ ...base, fixedCents: 300_000, spentCents: 100, expenseCount: 1 })
    ).toBe("no-budget");
  });
});

describe("effectiveTransactionCents", () => {
  test("prefers the main-currency amount", () => {
    expect(effectiveTransactionCents({ amountCents: 500, amountMainCents: 700 })).toBe(700);
    expect(effectiveTransactionCents({ amountCents: 500 })).toBe(500);
  });

  test("rejects zero, negative, non-numeric and absurd amounts", () => {
    expect(effectiveTransactionCents({ amountCents: 0 })).toBe(0);
    expect(effectiveTransactionCents({ amountCents: -10 })).toBe(0);
    expect(effectiveTransactionCents({ amountCents: "12" })).toBe(0);
    expect(effectiveTransactionCents({ amountCents: 100_000_000 })).toBe(0);
    expect(effectiveTransactionCents({})).toBe(0);
  });
});

describe("readMonthlyIncomeCents", () => {
  test("reads the current field, falls back to the legacy one, else 0", () => {
    expect(readMonthlyIncomeCents({ monthlyIncomeCents: 250_000 })).toBe(250_000);
    expect(readMonthlyIncomeCents({ incomeMonthlyCents: 90_000 })).toBe(90_000);
    expect(readMonthlyIncomeCents({})).toBe(0);
    expect(readMonthlyIncomeCents(undefined)).toBe(0);
    expect(readMonthlyIncomeCents({ monthlyIncomeCents: -1 })).toBe(0);
  });
});

describe("budget day XP", () => {
  test("matches the README 5.2 value", () => {
    expect(XP_CONFIG.budgetDayUnder).toBe(15);
  });
});
