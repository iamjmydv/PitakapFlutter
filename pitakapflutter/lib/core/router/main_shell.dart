import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pitakapflutter/core/resources/strings.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      label: Strings.navDashboard,
    ),
    NavigationDestination(
      icon: Icon(Icons.autorenew_outlined),
      label: Strings.navSubscriptions,
    ),
    NavigationDestination(
      icon: Icon(Icons.account_balance_wallet_outlined),
      label: Strings.navExpenses,
    ),
    NavigationDestination(
      icon: Icon(Icons.pie_chart_outline),
      label: Strings.navStats,
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      label: Strings.navSettings,
    ),
  ];

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: _destinations,
      ),
    );
  }
}
