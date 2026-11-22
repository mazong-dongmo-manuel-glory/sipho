/// Visibility of the Home floating "+" that opens `/expenses/add`.
///
/// The post-add reward celebration must never hide this button permanently.
bool shouldShowHomeAddExpenseFab({required bool hasPendingReward}) {
  // Intentionally ignore [hasPendingReward]: celebration UI is independent.
  return true;
}

/// How long the Home reward banner stays before auto-clearing.
const Duration kHomeRewardDisplayDuration = Duration(seconds: 3);
