import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/theme/app_colors.dart';

class SiphoBottomNav extends StatelessWidget {
  const SiphoBottomNav({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _TabDef(label: 'Home', icon: Icons.home_outlined, path: '/home'),
    _TabDef(label: 'Budget', icon: Icons.pie_chart_outline, path: '/budget'),
    _TabDef(label: 'Learn', icon: Icons.school_outlined, path: '/learn'),
    _TabDef(
        label: 'Ranking',
        icon: Icons.leaderboard_outlined,
        path: '/leaderboard'),
    _TabDef(label: 'Profile', icon: Icons.person_outline, path: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex =
        _tabs.indexWhere((t) => location.startsWith(t.path));

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex < 0 ? 0 : currentIndex,
        onTap: (i) => context.go(_tabs[i].path),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: _tabs
            .map(
              (t) => BottomNavigationBarItem(
                icon: Icon(t.icon),
                label: t.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TabDef {
  const _TabDef(
      {required this.label, required this.icon, required this.path});

  final String label;
  final IconData icon;
  final String path;
}
