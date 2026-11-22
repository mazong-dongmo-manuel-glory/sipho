/// Whether the lesson player should spin while waiting for a country slot fill.
///
/// After [slotFillFailed], the UI must show not-found instead of an infinite spinner.
bool shouldShowCountrySlotSpinner({
  required bool isCountrySlot,
  required bool isPlayable,
  required bool slotFillFailed,
}) {
  return isCountrySlot && !isPlayable && !slotFillFailed;
}

/// Whether Learn may fire `generateCountryLessons` for empty slots.
///
/// An empty [countryCode] must not burn the one-shot request flag — retry after
/// the finance profile loads a real country.
bool canRequestAiLessonFill({
  required bool alreadyRequested,
  required String? countryCode,
}) {
  if (alreadyRequested) return false;
  return (countryCode?.trim() ?? '').isNotEmpty;
}
