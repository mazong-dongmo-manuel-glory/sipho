import 'package:sipho/app/l10n/app_localizations.dart';

/// Localized name of a league tier id (`gold` → "Or" / "Gold").
String leagueTierLabel(AppLocalizations l10n, String tier) {
  return switch (tier) {
    'silver' => l10n.leagueTierSilver,
    'gold' => l10n.leagueTierGold,
    'sapphire' => l10n.leagueTierSapphire,
    'ruby' => l10n.leagueTierRuby,
    'emerald' => l10n.leagueTierEmerald,
    'amethyst' => l10n.leagueTierAmethyst,
    'pearl' => l10n.leagueTierPearl,
    'obsidian' => l10n.leagueTierObsidian,
    'diamond' => l10n.leagueTierDiamond,
    _ => l10n.leagueTierBronze,
  };
}

/// "2 j 5 h" while at least a day is left, "5 h 12 min" afterwards.
String leagueRemainingLabel(AppLocalizations l10n, Duration remaining) {
  if (remaining.inDays >= 1) {
    return l10n.leagueDurationDaysHours(
      remaining.inDays,
      remaining.inHours.remainder(24),
    );
  }
  return l10n.leagueDurationHoursMinutes(
    remaining.inHours,
    remaining.inMinutes.remainder(60),
  );
}
