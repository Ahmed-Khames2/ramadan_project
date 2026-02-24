import 'package:flutter/material.dart';
import '../../domain/entities/adhkar_virtue.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';

class AdhkarVirtueCard extends StatelessWidget {
  final AdhkarVirtue adhk;
  final VoidCallback onTap;
  final bool isRead;
  final VoidCallback onToggleRead;

  const AdhkarVirtueCard({
    super.key,
    required this.adhk,
    required this.onTap,
    required this.isRead,
    required this.onToggleRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color categoryColor;
    String categoryName;
    switch (adhk.type) {
      case 1:
        categoryColor = Colors.orange;
        categoryName = 'أذكار الصباح';
        break;
      case 2:
        categoryColor = Colors.indigo;
        categoryName = 'أذكار المساء';
        break;
      default:
        categoryColor = AppTheme.primaryEmerald;
        categoryName = 'فضائل عامة';
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isRead
              ? AppTheme.primaryEmerald.withValues(alpha: 0.3)
              : categoryColor.withValues(alpha: isDark ? 0.2 : 0.1),
          width: isRead ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            child: Row(
              children: [
                // Read Status Check Icon
                IconButton(
                  onPressed: onToggleRead,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      isRead
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      key: ValueKey(isRead),
                      color: isRead
                          ? AppTheme.primaryEmerald
                          : AppTheme.textGrey,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing2),
                // Icon/Badge Container
                Opacity(
                  opacity: isRead ? 0.5 : 1.0,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          categoryColor,
                          categoryColor.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        adhk.type == 1
                            ? Icons.wb_sunny_rounded
                            : (adhk.type == 2
                                  ? Icons.nightlight_round
                                  : Icons.star_rounded),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing4),
                // Title and Snippet
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              categoryName,
                              style: TextStyle(
                                color: isRead
                                    ? AppTheme.textGrey
                                    : categoryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                decoration: isRead
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Counter info removed from card if count is 1 or user doesn't want it,
                          // but keeping brief description if relevant.
                          // User said: "الافضال اللي ليها عدد موجود عداد فيها عايزك تشيله خالص"
                          // If they mean the small badge on the card too, I'll remove it.
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        adhk.content,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                          fontFamily: 'Cairo',
                          height: 1.4,
                          color: isRead ? AppTheme.textGrey : null,
                          decoration: isRead
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                ReorderableDragStartListener(
                  index: adhk
                      .order, // This index needs to be carefully handled in ReorderableListView
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.drag_handle_rounded,
                      color: AppTheme.textGrey,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
