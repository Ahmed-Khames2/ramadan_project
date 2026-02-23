import 'package:flutter/material.dart';
import '../../domain/entities/adhkar_virtue.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';

class AdhkarVirtueCard extends StatelessWidget {
  final AdhkarVirtue adhk;
  final VoidCallback onTap;

  const AdhkarVirtueCard({super.key, required this.adhk, required this.onTap});

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
        vertical: AppTheme.spacing2,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: categoryColor.withValues(alpha: isDark ? 0.2 : 0.1),
          width: 1,
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
                // Icon/Badge Container
                Container(
                  width: 50,
                  height: 50,
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
                    boxShadow: [
                      BoxShadow(
                        color: categoryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      adhk.type == 1
                          ? Icons.wb_sunny_rounded
                          : (adhk.type == 2
                                ? Icons.nightlight_round
                                : Icons.star_rounded),
                      color: Colors.white,
                      size: 24,
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
                                color: categoryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (adhk.count > 1)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                adhk.countDescription,
                                style: const TextStyle(
                                  color: AppTheme.accentGold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        adhk.content,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                          fontFamily: 'Cairo',
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppTheme.accentGold,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
