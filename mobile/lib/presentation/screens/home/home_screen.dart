import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/todo_provider.dart';
import '../../widgets/cozy_error_banner.dart';
import '../../widgets/minifox_3d_card.dart';
import '../../widgets/todo_form_sheet.dart';
import '../../widgets/todo_item_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _emptyTitleFor(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.active:
        return 'Semua task sudah selesai!';
      case TodoFilter.completed:
        return 'Belum ada task yang selesai';
      case TodoFilter.all:
        return 'Belum ada task hari ini';
    }
  }

  String _emptySubtitleFor(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.active:
        return 'Mini Fox bangga sama kamu! Tambah task baru kapan saja.';
      case TodoFilter.completed:
        return 'Centang task yang sudah selesai untuk dapat +10 poin.';
      case TodoFilter.all:
        return 'Ketuk tombol + Task Baru di bawah untuk mulai hari produktifmu.';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final todoState = ref.watch(todoProvider);
    final todoNotifier = ref.read(todoProvider.notifier);
    final todayLabel = DateFormat('EEEE, d MMM yyyy').format(DateTime.now());
    final filtered = todoState.filteredTodos;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        onPressed: () => TodoFormSheet.show(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Task Baru',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => todoNotifier.loadTodos(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Greeting + Level/Points Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todayLabel,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hi, ${user?.displayName ?? 'Fox Friend'}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontSize: 24,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Warm Honey Level & Points Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.streakLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.streak.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.streak,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Lv.${user?.level ?? 1} · ${user?.totalPoints ?? 0} pts',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Interactive 3D Mini Fox Companion Card + Gamification Reactions
                MiniFox3dCard(
                  mood: todoState.mascotMood,
                  rewardBannerText: todoState.rewardBannerText,
                  completedCount: todoState.completedCount,
                  totalCount: todoState.totalCount,
                ),

                const SizedBox(height: 24),

                // Section Header + Unsynced Offline Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Tasks",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 17,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    if (todoState.unsyncedCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${todoState.unsyncedCount} tersimpan offline',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Filter Chips Row (Semua / Belum Selesai / Selesai)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChipButton(
                        label: 'Semua (${todoState.totalCount})',
                        selected: todoState.filter == TodoFilter.all,
                        onTap: () => todoNotifier.setFilter(TodoFilter.all),
                      ),
                      const SizedBox(width: 8),
                      _FilterChipButton(
                        label:
                            'Belum Selesai (${todoState.totalCount - todoState.completedCount})',
                        selected: todoState.filter == TodoFilter.active,
                        onTap: () => todoNotifier.setFilter(TodoFilter.active),
                      ),
                      const SizedBox(width: 8),
                      _FilterChipButton(
                        label: 'Selesai (${todoState.completedCount})',
                        selected: todoState.filter == TodoFilter.completed,
                        onTap: () =>
                            todoNotifier.setFilter(TodoFilter.completed),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                if (todoState.errorMessage != null) ...[
                  CozyErrorBanner(message: todoState.errorMessage!),
                  const SizedBox(height: 12),
                ],

                if (todoState.isLoading && todoState.todos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  )
                else if (filtered.isEmpty)
                  Card(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 28,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(
                              width: 116,
                              height: 116,
                              child: Image.asset(
                                AppAssets.foxEmpty,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _emptyTitleFor(todoState.filter),
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _emptySubtitleFor(todoState.filter),
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontSize: 13.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      for (int i = 0; i < filtered.length; i++) ...[
                        TodoItemCard(
                          todo: filtered[i],
                          onToggleComplete: () =>
                              todoNotifier.toggleComplete(filtered[i]),
                          onTap: () => TodoFormSheet.show(
                            context,
                            existingTodo: filtered[i],
                          ),
                          onDelete: () =>
                              todoNotifier.deleteTodo(filtered[i].id),
                        ),
                        if (i < filtered.length - 1)
                          const SizedBox(height: 10),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.45)
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    selected ? AppColors.primaryDark : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12.5,
              ),
        ),
      ),
    );
  }
}
