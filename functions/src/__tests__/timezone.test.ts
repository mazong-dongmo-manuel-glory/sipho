import {
  diffDateKeys,
  isValidTimeZone,
  localDateKey,
  localMinuteOfDay,
  localMonthKey,
  minuteInWindow,
  offsetMinutesAt,
  offsetRangesForLocalWindow,
  resolveUserTime,
  shiftDateKey,
  startOfNextLocalDay,
  UserTime,
} from "../shared/timezone";

const zone = (id: string): UserTime => ({ zone: id, fixedOffsetMinutes: 0 });
const at = (iso: string): Date => new Date(iso);

describe("time zones", () => {
  test("half-hour and 45-minute zones keep their exact offset", () => {
    expect(offsetMinutesAt(at("2026-11-14T12:00:00Z"), zone("Asia/Kolkata"))).toBe(330);
    expect(offsetMinutesAt(at("2026-11-14T12:00:00Z"), zone("Asia/Kathmandu"))).toBe(345);
    // Newfoundland: -3:30 in winter, -2:30 in summer.
    expect(offsetMinutesAt(at("2026-01-15T12:00:00Z"), zone("America/St_Johns"))).toBe(-210);
    expect(offsetMinutesAt(at("2026-07-15T12:00:00Z"), zone("America/St_Johns"))).toBe(-150);
  });

  test("daylight saving time moves the offset (a stored whole-hour offset would be wrong)", () => {
    const toronto = zone("America/Toronto");
    expect(offsetMinutesAt(at("2026-03-07T12:00:00Z"), toronto)).toBe(-300); // EST
    expect(offsetMinutesAt(at("2026-03-09T12:00:00Z"), toronto)).toBe(-240); // EDT
  });

  test("local date follows the zone, not UTC", () => {
    // 2026-11-14 23:30 UTC is already the 15th in India but still the 14th in Toronto.
    const instant = at("2026-11-14T23:30:00Z");
    expect(localDateKey(instant, zone("Asia/Kolkata"))).toBe("2026-11-15");
    expect(localDateKey(instant, zone("America/Toronto"))).toBe("2026-11-14");
    expect(localMonthKey(at("2026-12-01T02:00:00Z"), zone("America/Toronto"))).toBe("2026-11");
    expect(localMinuteOfDay(instant, zone("Asia/Kolkata"))).toBe(5 * 60);
  });

  test("startOfNextLocalDay is DST-aware", () => {
    const toronto = zone("America/Toronto");
    // Normal day: local midnight = 05:00Z in winter.
    expect(startOfNextLocalDay(at("2026-01-10T15:00:00Z"), toronto).toISOString()).toBe(
      "2026-01-11T05:00:00.000Z"
    );
    // Spring-forward day (23h): 2026-03-08 -> next midnight is 04:00Z, not 05:00Z.
    expect(startOfNextLocalDay(at("2026-03-08T12:00:00Z"), toronto).toISOString()).toBe(
      "2026-03-09T04:00:00.000Z"
    );
    // Half-hour zone.
    expect(startOfNextLocalDay(at("2026-11-14T12:00:00Z"), zone("Asia/Kolkata")).toISOString()).toBe(
      "2026-11-14T18:30:00.000Z"
    );
  });

  test("date key arithmetic is calendar based", () => {
    expect(shiftDateKey("2026-03-01", -1)).toBe("2026-02-28");
    expect(shiftDateKey("2026-12-31", 1)).toBe("2027-01-01");
    expect(diffDateKeys("2026-11-01", "2026-11-10")).toBe(9);
  });

  test("resolveUserTime prefers a valid IANA id, then minutes, then legacy hours", () => {
    expect(resolveUserTime({ timezone: "Asia/Kolkata", utcOffsetMinutes: 0 }).zone).toBe(
      "Asia/Kolkata"
    );
    // "EST" is not an IANA region id: ignore it and use the stored offset.
    const abbreviation = resolveUserTime({ timezone: "Not/AZone", utcOffsetMinutes: 330 });
    expect(abbreviation).toEqual({ zone: null, fixedOffsetMinutes: 330 });
    expect(resolveUserTime({ timezoneOffset: -5 })).toEqual({ zone: null, fixedOffsetMinutes: -300 });
    expect(resolveUserTime(undefined)).toEqual({ zone: null, fixedOffsetMinutes: 0 });
    expect(isValidTimeZone("Europe/Paris")).toBe(true);
    expect(isValidTimeZone("EST5EDT")).toBe(true);
    expect(isValidTimeZone("garbage")).toBe(false);
  });

  test("offset ranges select exactly the zones inside the local window", () => {
    // 18:30 UTC: local midnight (window 00:00-03:00) is where the offset is +05:30..+08:29.
    const now = at("2026-11-14T18:30:00Z");
    const ranges = offsetRangesForLocalWindow(now, 0, 180);
    const inRange = (offset: number): boolean => ranges.some(([lo, hi]) => offset >= lo && offset <= hi);
    expect(inRange(330)).toBe(true); // India: 00:00 local
    expect(inRange(480)).toBe(true); // China: 02:30 local
    expect(inRange(540)).toBe(false); // Japan: 03:30 local
    expect(inRange(300)).toBe(false); // Pakistan: 23:30 local
    expect(inRange(-300)).toBe(false);
  });

  test("windows may wrap midnight", () => {
    expect(minuteInWindow(22 * 60, 21 * 60 + 30, 8 * 60)).toBe(true);
    expect(minuteInWindow(3 * 60, 21 * 60 + 30, 8 * 60)).toBe(true);
    expect(minuteInWindow(12 * 60, 21 * 60 + 30, 8 * 60)).toBe(false);
  });
});
