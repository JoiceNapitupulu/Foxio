import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import '../../../core/theme/app_colors.dart';

class MainShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({
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
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            height: 66,
            backgroundColor: AppColors.surface,
            elevation: 0,
            indicatorColor: AppColors.primaryLight,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: currentIndex,
            onDestinationSelected: _onTap,
            destinations: const [
              NavigationDestination(
                icon: Icon(
                  Icons.home_outlined,
                  color: AppColors.textMuted,
                ),
                selectedIcon: Icon(
                  Icons.home_rounded,
                  color: AppColors.primary,
                ),
                label: 'Today',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textMuted,
                ),
                selectedIcon: Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.primary,
                ),
                label: 'Calendar',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.bar_chart_outlined,
                  color: AppColors.textMuted,
                ),
                selectedIcon: Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.primary,
                ),
                label: 'Stats',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.account_circle_outlined,
                  color: AppColors.textMuted,
                ),
                selectedIcon: Icon(
                  Icons.account_circle_rounded,
                  color: AppColors.primary,
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
