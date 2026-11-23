/// Sipho UI language contract: only `fr` or `en`.
String normalizeAppLanguage(String? raw) {
  final code = (raw ?? '').trim().toLowerCase();
  if (code.startsWith('fr')) return 'fr';
  return 'en';
}

bool appLanguagesMatch(String? a, String? b) =>
    normalizeAppLanguage(a) == normalizeAppLanguage(b);
