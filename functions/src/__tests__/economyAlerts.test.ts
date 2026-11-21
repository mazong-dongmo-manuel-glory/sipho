import { detectRateChange } from "../economy/economyAlerts";

describe("detectRateChange", () => {
  test("detects policy_rate changes with dated source", () => {
    const change = detectRateChange(
      {
        indicators: {
          policy_rate: { value: 3.75, source: "BoC", date: "2026-09" },
        },
      },
      {
        indicators: {
          policy_rate: { value: 3.25, source: "Banque du Canada", date: "2026-10" },
        },
      }
    );
    expect(change).toEqual({
      key: "policy_rate",
      before: 3.75,
      after: 3.25,
      source: "Banque du Canada",
      date: "2026-10",
    });
  });

  test("ignores missing source or identical values", () => {
    expect(
      detectRateChange(
        { indicators: { keyRate: { value: 4, source: "X", date: "2026-01" } } },
        { indicators: { keyRate: { value: 4, source: "X", date: "2026-01" } } }
      )
    ).toBeNull();
    expect(
      detectRateChange(
        { indicators: { keyRate: { value: 4, source: "X", date: "2026-01" } } },
        { indicators: { keyRate: { value: 3.5, date: "2026-02" } } }
      )
    ).toBeNull();
  });
});
