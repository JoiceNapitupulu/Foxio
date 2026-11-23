import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
            destinations: [
              NavigationDestination(
                icon: const Icon(
                  PhosphorIconsRegular.house,
                  color: AppColors.textMuted,
                ),
                selectedIcon: const Icon(
                  PhosphorIconsFill.house,
                  color: AppColors.primary,
                ),
                label: 'Today',
              ),
              NavigationDestination(
                icon: const Icon(
                  PhosphorIconsRegular.calendarBlank,
                  color: AppColors.textMuted,
                ),
                selectedIcon: const Icon(
                  PhosphorIconsFill.calendarBlank,
                  color: AppColors.primary,
                ),
                label: 'Calendar',
              ),
              NavigationDestination(
                icon: const Icon(
                  PhosphorIconsRegular.chartBar,
                  color: AppColors.textMuted,
                ),
                selectedIcon: const Icon(
                  PhosphorIconsFill.chartBar,
                  color: AppColors.primary,
                ),
                label: 'Stats',
              ),
              NavigationDestination(
                icon: const Icon(
                  PhosphorIconsRegular.userCircle,
                  color: AppColors.textMuted,
                ),
                selectedIcon: const Icon(
                  PhosphorIconsFill.userCircle,
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
