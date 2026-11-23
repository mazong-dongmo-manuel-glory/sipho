import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_theme.dart';

class SiphoBottomNav extends StatelessWidget {
  const SiphoBottomNav({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final overlay = AppTheme.overlayFor(Theme.of(context).brightness);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        backgroundColor: dark ? AppColors.backgroundDark : AppColors.background,
        body: child,
        bottomNavigationBar: const _NavBar(),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final location = GoRouterState.of(context).matchedLocation;
    final tabs = [
      _Tab(Icons.home_rounded, l10n.navHome, '/home'),
      _Tab(Icons.receipt_long_rounded, l10n.navExpenses, '/expenses'),
      _Tab(Icons.school_rounded, l10n.navLearn, '/learn'),
      _Tab(Icons.emoji_events_rounded, l10n.navRanking, '/leaderboard'),
      _Tab(Icons.person_rounded, l10n.navProfile, '/profile'),
    ];
    final index = tabs.indexWhere((tab) {
      if (tab.path == '/expenses') {
        return location.startsWith('/expenses') ||
            location.startsWith('/charts');
      }
      if (tab.path == '/profile') {
        return location.startsWith('/profile') || location.startsWith('/shop');
      }
      return location.startsWith(tab.path);
    });
    final current = index < 0 ? 0 : index;

    return ColoredBox(
      color: dark ? AppColors.nightNav : AppColors.surface,
      child: SizedBox(
        height: 80,
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(
                child: _NavItem(
                  tab: tabs[i],
                  selected: i == current,
                  dark: dark,
                  onTap: () => context.go(tabs[i].path),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tab {
  const _Tab(this.icon, this.label, this.path);
  final IconData icon;
  final String label;
  final String path;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.dark,
    required this.onTap,
  });

  final _Tab tab;
  final bool selected;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? (dark ? AppColors.nightMint : AppColors.primary)
        : (dark ? AppColors.nightNavIcon : AppColors.textSecondary);
    final pill = dark ? AppColors.nightNavActive : AppColors.mint;
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: selected ? pill : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(tab.icon, color: color, size: 25),
                const SizedBox(height: 2),
                Text(
                  tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
