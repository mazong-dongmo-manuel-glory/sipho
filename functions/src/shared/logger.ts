/**
 * Structured logger — never logs personal data (names, emails, amounts, notes).
 * Uses structured JSON output compatible with Cloud Logging.
 */

type LogLevel = "DEBUG" | "INFO" | "WARNING" | "ERROR";

interface LogEntry {
  severity: LogLevel;
  message: string;
  labels?: Record<string, string>;
  [key: string]: unknown;
}

const FORBIDDEN_PII_KEYS = new Set([
  "email",
  "phone",
  "name",
  "displayname",
  "photourl",
  "note",
  "merchant",
  "amount",
  "amountcents",
  "amountmaincents",
  "incomecents",
  "monthlyincomecents",
  "description",
  "address",
  "ip",
  "fcmtoken",
]);

function sanitize(meta: Record<string, unknown>): Record<string, unknown> {
  return Object.fromEntries(
    Object.entries(meta).filter(([k]) => !FORBIDDEN_PII_KEYS.has(k.toLowerCase()))
  );
}

function emit(severity: LogLevel, message: string, meta?: Record<string, unknown>): void {
  const entry: LogEntry = {
    severity,
    message,
    ...(meta ? sanitize(meta) : {}),
  };
  process.stdout.write(JSON.stringify(entry) + "\n");
}

export const logger = {
  debug: (msg: string, meta?: Record<string, unknown>): void => emit("DEBUG", msg, meta),
  info: (msg: string, meta?: Record<string, unknown>): void => emit("INFO", msg, meta),
  warn: (msg: string, meta?: Record<string, unknown>): void => emit("WARNING", msg, meta),
  error: (msg: string, meta?: Record<string, unknown>): void => emit("ERROR", msg, meta),
};
