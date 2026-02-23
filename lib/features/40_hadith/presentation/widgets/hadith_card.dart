import 'package:flutter/material.dart';
import '../../domain/entities/hadith.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';

class HadithCard extends StatelessWidget {
  final Hadith hadith;
  final VoidCallback onTap;

  const HadithCard({super.key, required this.hadith, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing2,
      ),
      child: IslamicCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        onTap: onTap,
        child: Stack(
          children: [
            // Islamic Ornament Background
            Positioned(
              left: -20,
              top: -20,
              child: Opacity(
                opacity: 0.05,
                child: Icon(
                  Icons.spa_rounded,
                  size: 100,
                  color: AppTheme.accentGold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              child: Row(
                children: [
                  // Index Container with better styling
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.accentGold.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${hadith.index + 1}',
                        style: TextStyle(
                          color: AppTheme.primaryEmerald,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Cairo',
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
                        Text(
                          hadith.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Cairo',
                            color: isDark
                                ? Colors.white
                                : AppTheme.primaryEmerald,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hadith.content.replaceAll('\n', ' '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white70 : AppTheme.textGrey,
                            height: 1.4,
                            fontFamily: 'Cairo',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppTheme.accentGold,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
