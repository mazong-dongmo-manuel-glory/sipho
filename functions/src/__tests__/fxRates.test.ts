import { parseFxFeedPayload } from "../economy/fxRates";

describe("parseFxFeedPayload", () => {
  test("accepts frankfurter-style payloads", () => {
    const parsed = parseFxFeedPayload({
      base: "usd",
      date: "2026-11-17",
      rates: { cad: 1.39, eur: 0.92, xof: 600 },
    });
    expect(parsed).toEqual({
      base: "USD",
      rates: { CAD: 1.39, EUR: 0.92, XOF: 600 },
      asOf: new Date("2026-11-17"),
    });
  });

  test("rejects empty or invalid rates", () => {
    expect(parseFxFeedPayload(null)).toBeNull();
    expect(parseFxFeedPayload({ base: "USD", rates: {} })).toBeNull();
    expect(parseFxFeedPayload({ base: "USD", rates: { CAD: 0 } })).toBeNull();
    expect(parseFxFeedPayload({ rates: { CAD: 1.3 } })).toBeNull();
  });
});
