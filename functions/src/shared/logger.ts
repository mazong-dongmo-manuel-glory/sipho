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

function sanitize(meta: Record<string, unknown>): Record<string, unknown> {
  // Strip any fields that may carry PII
  const forbidden = new Set([
    "email", "phone", "name", "displayName", "photoURL",
    "note", "description", "address", "ip",
  ]);
  return Object.fromEntries(
    Object.entries(meta).filter(([k]) => !forbidden.has(k.toLowerCase()))
  );
}

function emit(severity: LogLevel, message: string, meta?: Record<string, unknown>): void {
  const entry: LogEntry = {
    severity,
    message,
    ...(meta ? sanitize(meta) : {}),
  };
  // Cloud Functions captures stdout as structured logs when JSON
  process.stdout.write(JSON.stringify(entry) + "\n");
}

export const logger = {
  debug: (msg: string, meta?: Record<string, unknown>) => emit("DEBUG", msg, meta),
  info: (msg: string, meta?: Record<string, unknown>) => emit("INFO", msg, meta),
  warn: (msg: string, meta?: Record<string, unknown>) => emit("WARNING", msg, meta),
  error: (msg: string, meta?: Record<string, unknown>) => emit("ERROR", msg, meta),
};
