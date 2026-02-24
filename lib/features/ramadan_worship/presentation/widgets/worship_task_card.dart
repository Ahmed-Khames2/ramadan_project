import 'package:flutter/material.dart';

import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/ramadan_worship/domain/entities/worship_task.dart';
import 'package:ramadan_project/core/utils/string_extensions.dart';

class WorshipTaskCard extends StatelessWidget {
  final WorshipTask task;
  final VoidCallback onToggle;
  final Function(int) onProgressUpdate;

  const WorshipTaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onProgressUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? AppTheme.primaryEmerald.withValues(alpha: 0.1)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isCompleted
              ? AppTheme.primaryEmerald
              : (isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: _buildIcon(),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: task.isCompleted
                ? AppTheme.primaryEmerald
                : theme.colorScheme.onSurface,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: _buildAction(context),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    switch (task.type) {
      case WorshipTaskType.prayer:
        iconData = Icons.mosque;
        break;
      case WorshipTaskType.checkbox:
        iconData = Icons.check_circle_outline;
        break;
      case WorshipTaskType.count:
        iconData = Icons.calculate_outlined;
        break;
    }
    return Icon(
      iconData,
      color: task.isCompleted ? AppTheme.primaryEmerald : AppTheme.accentGold,
    );
  }

  Widget _buildAction(BuildContext context) {
    if (task.type == WorshipTaskType.count) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () => onProgressUpdate(task.currentProgress - 1),
            color: Colors.red[300],
          ),
          Text(
            "${task.currentProgress.toArabic()} / ${task.target.toArabic()}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => onProgressUpdate(task.currentProgress + 1),
            color: AppTheme.primaryEmerald,
          ),
        ],
      );
    }

    return Checkbox(
      value: task.isCompleted,
      activeColor: AppTheme.primaryEmerald,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      onChanged: (_) => onToggle(),
    );
  }
}
