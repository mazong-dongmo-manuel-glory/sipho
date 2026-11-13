/// Parses a keypad string into integer cents.
///
/// Accepts `18,50`, `18.5` and `18`. A missing fraction is treated as zero
/// cents, so `18` is 1800. At most two decimal digits are kept.
class AmountInput {
  const AmountInput._();

  static const int maxCents = 9999999;

  static int parseCents(String raw) {
    final cleaned = raw.trim().replaceAll(' ', '').replaceAll('\u00a0', '');
    if (cleaned.isEmpty) return 0;

    final normalized = cleaned.replaceAll(',', '.');
    if (normalized == '.') return 0;

    final parts = normalized.split('.');
    if (parts.length > 2) return 0;

    final whole = int.tryParse(parts[0].isEmpty ? '0' : parts[0]) ?? 0;
    var fraction = parts.length == 2 ? parts[1] : '';
    if (fraction.length > 2) fraction = fraction.substring(0, 2);
    fraction = fraction.padRight(2, '0');
    final cents = whole * 100 + (int.tryParse(fraction) ?? 0);
    if (cents < 0) return 0;
    if (cents > maxCents) return maxCents;
    return cents;
  }

  /// Whether [key] can be appended without exceeding [maxCents] or two decimals.
  static bool canAppend(String digits, String key) {
    if (key == '⌫') return digits.isNotEmpty;
    final isSeparator = key == ',' || key == '.';
    if (isSeparator) {
      return !digits.contains(',') && !digits.contains('.');
    }
    if (int.tryParse(key) == null) return false;
    if (digits.length >= 8) return false;

    final separator =
        digits.contains(',') ? ',' : (digits.contains('.') ? '.' : null);
    if (separator != null) {
      final fraction = digits.split(separator).last;
      if (fraction.length >= 2) return false;
    }

    return parseCents('$digits$key') <= maxCents;
  }
}
