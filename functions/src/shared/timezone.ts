/**
 * Time-zone helpers.
 *
 * Users are located by their IANA time-zone id (`users/{uid}.timezone`, e.g.
 * "Asia/Kolkata"), which is exact for half-hour / 45-minute zones and for
 * daylight-saving transitions. `utcOffsetMinutes` (refreshed by the client on each
 * launch) is only used as
 *   1. a coarse index to select "who might be at local midnight / 18:00 now" without
 *      scanning every user, and
 *   2. a fallback when the IANA id is missing or invalid.
 * Legacy `timezoneOffset` (whole hours) is still read for users who have not opened
 * the app since the migration.
 */

export interface UserTime {
  /** Valid IANA zone id, or null when only a fixed offset is known. */
  zone: string | null;
  /** Fixed offset used only when `zone` is null. */
  fixedOffsetMinutes: number;
}

export const MIN_UTC_OFFSET_MINUTES = -12 * 60;
export const MAX_UTC_OFFSET_MINUTES = 14 * 60;

const MS_PER_MINUTE = 60_000;
const MS_PER_DAY = 86_400_000;

const formatterCache = new Map<string, Intl.DateTimeFormat>();

function formatterFor(zone: string): Intl.DateTimeFormat {
  let fmt = formatterCache.get(zone);
  if (!fmt) {
    fmt = new Intl.DateTimeFormat("en-US", {
      timeZone: zone,
      hourCycle: "h23",
      year: "numeric",
      month: "numeric",
      day: "numeric",
      hour: "numeric",
      minute: "numeric",
      second: "numeric",
    });
    formatterCache.set(zone, fmt);
  }
  return fmt;
}

export function isValidTimeZone(zone: unknown): zone is string {
  if (typeof zone !== "string" || zone.length === 0 || zone.length > 64) return false;
  try {
    formatterFor(zone);
    return true;
  } catch {
    return false;
  }
}

function clampOffset(minutes: number): number {
  return Math.max(MIN_UTC_OFFSET_MINUTES, Math.min(MAX_UTC_OFFSET_MINUTES, Math.trunc(minutes)));
}

/**
 * Builds a {@link UserTime} from a `users/{uid}` document.
 * Priority: valid IANA `timezone` > `utcOffsetMinutes` > legacy `timezoneOffset` hours > UTC.
 */
export function resolveUserTime(user?: Record<string, unknown>): UserTime {
  const zone = user?.timezone;
  if (isValidTimeZone(zone)) {
    return { zone, fixedOffsetMinutes: 0 };
  }
  if (typeof user?.utcOffsetMinutes === "number" && Number.isFinite(user.utcOffsetMinutes)) {
    return { zone: null, fixedOffsetMinutes: clampOffset(user.utcOffsetMinutes) };
  }
  if (typeof user?.timezoneOffset === "number" && Number.isFinite(user.timezoneOffset)) {
    return { zone: null, fixedOffsetMinutes: clampOffset(user.timezoneOffset * 60) };
  }
  return { zone: null, fixedOffsetMinutes: 0 };
}

export function utcTime(): UserTime {
  return { zone: "UTC", fixedOffsetMinutes: 0 };
}

/** UTC offset (in minutes, east positive) that applies at `instant`. */
export function offsetMinutesAt(instant: Date, time: UserTime): number {
  if (!time.zone) return time.fixedOffsetMinutes;
  const parts = formatterFor(time.zone).formatToParts(instant);
  const get = (type: string): number => {
    const part = parts.find((p) => p.type === type);
    return part ? Number(part.value) : 0;
  };
  const asUtcMs = Date.UTC(
    get("year"),
    get("month") - 1,
    get("day"),
    get("hour"),
    get("minute"),
    get("second")
  );
  const instantSeconds = Math.floor(instant.getTime() / 1000) * 1000;
  return Math.round((asUtcMs - instantSeconds) / MS_PER_MINUTE);
}

function localMs(instant: Date, time: UserTime): number {
  return instant.getTime() + offsetMinutesAt(instant, time) * MS_PER_MINUTE;
}

/** Local calendar date at `instant`, as YYYY-MM-DD. */
export function localDateKey(instant: Date, time: UserTime): string {
  return new Date(localMs(instant, time)).toISOString().slice(0, 10);
}

/** Local month at `instant`, as YYYY-MM. */
export function localMonthKey(instant: Date, time: UserTime): string {
  return localDateKey(instant, time).slice(0, 7);
}

/** Minutes elapsed since local midnight at `instant` (0–1439). */
export function localMinuteOfDay(instant: Date, time: UserTime): number {
  const ms = localMs(instant, time);
  return Math.floor((((ms % MS_PER_DAY) + MS_PER_DAY) % MS_PER_DAY) / MS_PER_MINUTE);
}

/** Local day of month (1–31) at `instant`. */
export function localDayOfMonth(instant: Date, time: UserTime): number {
  return new Date(localMs(instant, time)).getUTCDate();
}

/** Pure calendar arithmetic on YYYY-MM-DD keys (no time zone involved). */
export function shiftDateKey(dateKey: string, days: number): string {
  const ms = Date.parse(`${dateKey}T00:00:00Z`) + days * MS_PER_DAY;
  return new Date(ms).toISOString().slice(0, 10);
}

/** Calendar days from `fromKey` to `toKey` (positive when `toKey` is later). */
export function diffDateKeys(fromKey: string, toKey: string): number {
  return Math.round((Date.parse(`${toKey}T00:00:00Z`) - Date.parse(`${fromKey}T00:00:00Z`)) / MS_PER_DAY);
}

/** First instant of the next local calendar day (DST-aware). */
export function startOfNextLocalDay(instant: Date, time: UserTime): Date {
  const offsetNow = offsetMinutesAt(instant, time);
  const local = instant.getTime() + offsetNow * MS_PER_MINUTE;
  const msIntoDay = ((local % MS_PER_DAY) + MS_PER_DAY) % MS_PER_DAY;
  let guess = instant.getTime() + (MS_PER_DAY - msIntoDay);
  const offsetThen = offsetMinutesAt(new Date(guess), time);
  guess += (offsetNow - offsetThen) * MS_PER_MINUTE;
  return new Date(guess);
}

/**
 * Ranges of `utcOffsetMinutes` (inclusive) whose local time of day is inside
 * `[startMinute, endMinute)` at `now`. Used to turn "users near local midnight" into
 * Firestore range queries; callers must still verify each user with {@link localMinuteOfDay}
 * because the stored offset can be stale across a DST change.
 */
export function offsetRangesForLocalWindow(
  now: Date,
  startMinute: number,
  endMinute: number
): Array<[number, number]> {
  const utcMinute = now.getUTCHours() * 60 + now.getUTCMinutes();
  const ranges: Array<[number, number]> = [];
  for (let k = -2; k <= 2; k++) {
    const lo = startMinute - utcMinute + 1440 * k;
    const hi = endMinute - utcMinute + 1440 * k - 1;
    const clippedLo = Math.max(lo, MIN_UTC_OFFSET_MINUTES);
    const clippedHi = Math.min(hi, MAX_UTC_OFFSET_MINUTES);
    if (clippedLo <= clippedHi) ranges.push([clippedLo, clippedHi]);
  }
  return ranges;
}

/** Whether `minute` (0–1439) lies in `[start, end)`, supporting windows that wrap midnight. */
export function minuteInWindow(minute: number, start: number, end: number): boolean {
  return start <= end ? minute >= start && minute < end : minute >= start || minute < end;
}
