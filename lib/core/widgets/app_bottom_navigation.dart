import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';  // ✅ import

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({super.key});

  static const List<_NavDestination> _destinations = [
    _NavDestination(
      labelKey: 'dashboard',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      route: '/dashboard',
    ),
    _NavDestination(
      labelKey: 'assessment',
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
      route: '/assessment',
    ),
    _NavDestination(
      labelKey: 'exercise',
      icon: Icons.fitness_center_outlined,
      activeIcon: Icons.fitness_center,
      route: '/exercise',
    ),
    _NavDestination(
      labelKey: 'diary',
      icon: Icons.book_outlined,
      activeIcon: Icons.book,
      route: '/bladder-diary',
    ),
    _NavDestination(
      labelKey: 'education',
      icon: Icons.school_outlined,
      activeIcon: Icons.school,
      route: '/education',
    ),
    _NavDestination(
      labelKey: 'profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;  // ✅ get localizations
    final currentPath = GoRouterState.of(context).uri.path;
    final selectedIndex = _destinations.indexWhere(
      (destination) => destination.route == currentPath,
    );

    return NavigationBar(
      selectedIndex: selectedIndex == -1 ? 0 : selectedIndex,
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFF00897B).withValues(alpha: 0.12),
      onDestinationSelected: (index) {
        final route = _destinations[index].route;
        if (route != currentPath) {
          context.go(route);
        }
      },
      destinations: [
        for (final destination in _destinations)
          NavigationDestination(
            icon: Icon(destination.icon, color: Colors.grey),
            selectedIcon: Icon(destination.activeIcon,
                color: const Color(0xFF00897B)),
            label: _getLabel(l10n, destination.labelKey),  // ✅ dynamic label
          ),
      ],
    );
  }

  String _getLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'dashboard':
        return l10n.dashboard;
      case 'assessment':
        return l10n.navAssessment;
      case 'exercise':
        return l10n.exercise;
      case 'diary':
        return l10n.diary;
      case 'education':
        return l10n.education;
      case 'profile':
        return l10n.profile;
      default:
        return '';
    }
  }
}

class _NavDestination {
  const _NavDestination({
    required this.labelKey,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });

  final String labelKey;
  final IconData icon;
  final IconData activeIcon;
  final String route;
}
