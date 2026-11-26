import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/sipho_colors.dart';
import '../core/theme/sipho_palette.dart';
import '../core/theme/sipho_typography.dart';
import 'fab_add_sheet.dart';
import 'l10n/app_localizations.dart';

/// Navigation basse 5 onglets + FAB « + » bas-droite (Figma Épuré).
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentIndex = navigationShell.currentIndex;

    final dark = SiphoPalette.isDark(context);

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: navigationShell,
      floatingActionButton: _FabAdd(onPressed: () => showFabAddSheet(context)),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: SiphoPalette.surface(context),
          border: Border(
            top: BorderSide(color: SiphoPalette.separator(context), width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 72,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: l10n.navHome,
                  isSelected: currentIndex == 0,
                  dark: dark,
                  onTap: () => _onTap(0),
                ),
                _NavItem(
                  icon: Icons.receipt_long_rounded,
                  label: l10n.navExpenses,
                  isSelected: currentIndex == 1,
                  dark: dark,
                  onTap: () => _onTap(1),
                ),
                _NavItem(
                  icon: Icons.school_rounded,
                  label: l10n.navLearn,
                  isSelected: currentIndex == 2,
                  dark: dark,
                  onTap: () => _onTap(2),
                ),
                _NavItem(
                  icon: Icons.emoji_events_rounded,
                  label: l10n.navRanking,
                  isSelected: currentIndex == 3,
                  dark: dark,
                  onTap: () => _onTap(3),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: l10n.navProfile,
                  isSelected: currentIndex == 4,
                  dark: dark,
                  onTap: () => _onTap(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FabAdd extends StatefulWidget {
  final VoidCallback onPressed;

  const _FabAdd({required this.onPressed});

  @override
  State<_FabAdd> createState() => _FabAddState();
}

class _FabAddState extends State<_FabAdd> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: SizedBox(
        width: 64,
        height: 68,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: _pressed ? 4 : 4,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: SiphoPalette.textPrimary(context),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: _pressed ? 4 : 0,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: SiphoColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontFamily: SiphoTypography.fontFamily,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool dark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.dark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? SiphoColors.primary
        : (dark ? SiphoColors.darkTextSecondary : SiphoColors.textSecondary);
    final pill = isSelected
        ? (dark
            ? SiphoColors.primary.withValues(alpha: 0.18)
            : SiphoColors.primaryLight)
        : Colors.transparent;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              height: 54,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: pill,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 25),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: SiphoTypography.label.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
