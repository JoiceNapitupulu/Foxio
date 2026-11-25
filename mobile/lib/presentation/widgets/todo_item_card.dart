import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/todo_entity.dart';

class TodoItemCard extends StatelessWidget {
  final TodoEntity todo;
  final VoidCallback onToggleComplete;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TodoItemCard({
    super.key,
    required this.todo,
    required this.onToggleComplete,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = !todo.isCompleted &&
        todo.deadline != null &&
        todo.deadline!.isBefore(DateTime.now());

    final bool hasMeta = todo.deadline != null ||
        (!todo.pointsAwarded && !todo.isCompleted) ||
        !todo.isSynced;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading Checkbox (Muted Sage Green when checked)
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Checkbox(
                  value: todo.isCompleted,
                  onChanged: (_) => onToggleComplete(),
                ),
              ),
              const SizedBox(width: 4),
              // Title, Description & Metadata Chips
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 15.5,
                                  color: todo.isCompleted
                                      ? AppColors.textMuted
                                      : AppColors.textPrimary,
                                  decoration: todo.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationColor: AppColors.textMuted,
                                ),
                      ),
                      if (todo.description != null &&
                          todo.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          todo.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 13,
                                    color: todo.isCompleted
                                        ? AppColors.textMuted
                                        : AppColors.textSecondary,
                                  ),
                        ),
                      ],
                      if (hasMeta) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (todo.deadline != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isOverdue
                                      ? AppColors.error.withValues(alpha: 0.12)
                                      : AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 13,
                                      color: isOverdue
                                          ? AppColors.error
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('d MMM, HH:mm')
                                          .format(todo.deadline!),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: isOverdue
                                                ? AppColors.error
                                                : AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11.5,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            if (!todo.pointsAwarded && !todo.isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.streakLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '+10 pts',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                            if (!todo.isSynced)
                              const Tooltip(
                                message: 'Belum tersinkron ke server',
                                child: Icon(
                                  Icons.cloud_off_rounded,
                                  size: 14,
                                  color: AppColors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'Hapus task',
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
