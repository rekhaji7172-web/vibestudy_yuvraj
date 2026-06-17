import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/app_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../planner/planner_screen.dart';
import '../timer/timer_screen.dart';
import '../notes/notes_screen.dart';
import '../flashcards/flashcards_screen.dart';
import '../radar/radar_screen.dart';
import '../mindmap/mindmap_screen.dart';
import '../profile/profile_screen.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  static const _screens = [
    DashboardScreen(),
    PlannerScreen(),
    TimerScreen(),
    NotesScreen(),
    FlashcardsScreen(),
    RadarScreen(),
    ProfileScreen(),
    MindMapScreen(),
  ];

  static const _navItems = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.calendar_today_outlined),
      selectedIcon: Icon(Icons.calendar_today_rounded),
      label: 'Planner',
    ),
    NavigationDestination(
      icon: Icon(Icons.timer_outlined),
      selectedIcon: Icon(Icons.timer_rounded),
      label: 'Focus',
    ),
    NavigationDestination(
      icon: Icon(Icons.note_alt_outlined),
      selectedIcon: Icon(Icons.note_alt_rounded),
      label: 'Notes',
    ),
    NavigationDestination(
      icon: Icon(Icons.style_outlined),
      selectedIcon: Icon(Icons.style_rounded),
      label: 'Cards',
    ),
    NavigationDestination(
      icon: Icon(Icons.radar_outlined),
      selectedIcon: Icon(Icons.radar_rounded),
      label: 'Radar',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
    NavigationDestination(
      icon: Icon(Icons.account_tree_outlined),
      selectedIcon: Icon(Icons.account_tree_rounded),
      label: 'Maps',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: AppColors.navySurface,
          ),
          child: Scaffold(
            backgroundColor: AppColors.deepNavy,
            body: IndexedStack(
              index: provider.selectedNavIndex,
              children: _screens,
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: AppColors.navySurface,
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.06),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: NavigationBar(
                selectedIndex: provider.selectedNavIndex,
                onDestinationSelected: provider.setNavIndex,
                backgroundColor: Colors.transparent,
                elevation: 0,
                height: 70,
                labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
                animationDuration: const Duration(milliseconds: 300),
                destinations: _navItems,
              ),
            ),
          ),
        );
      },
    );
  }
}
