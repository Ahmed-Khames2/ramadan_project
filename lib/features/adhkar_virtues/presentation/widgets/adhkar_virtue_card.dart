import 'package:flutter/material.dart';
import '../../domain/entities/adhkar_virtue.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';

class AdhkarVirtueCard extends StatelessWidget {
  final AdhkarVirtue adhk;
  final String searchQuery;
  final VoidCallback onTap;
  final bool isRead;
  final VoidCallback onToggleRead;

  const AdhkarVirtueCard({
    super.key,
    required this.adhk,
    required this.onTap,
    required this.isRead,
    required this.onToggleRead,
    this.searchQuery = '',
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
                      _buildHighlightedText(
                        adhk.content,
                        theme.textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                          fontFamily: 'Cairo',
                          height: 1.4,
                          color: isRead ? AppTheme.textGrey : null,
                          decoration: isRead
                              ? TextDecoration.lineThrough
                              : null,
                        ),
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

  Widget _buildHighlightedText(String text, TextStyle? style) {
    if (searchQuery.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final String normalizedQuery = searchQuery.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final regexString = _buildSearchRegex(normalizedQuery);
    final regex = RegExp(regexString, caseSensitive: false);

    final matches = regex.allMatches(text);
    if (matches.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final spans = <TextSpan>[];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: const TextStyle(
            backgroundColor: AppTheme.accentGold,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(style: style, children: spans),
    );
  }

  String _buildSearchRegex(String query) {
    String normalized = query
        .replaceAll(RegExp(r'[\u064B-\u0652]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');

    final buffer = StringBuffer();
    const diacritics = r'[\u064B-\u0652]*';

    for (int i = 0; i < normalized.length; i++) {
      final char = normalized[i];
      if (char == ' ') {
        buffer.write(r'\s+');
        continue;
      }
      if (char == 'ا') {
        buffer.write('[اأإآ]$diacritics');
      } else if (char == 'ه') {
        buffer.write('[هة]$diacritics');
      } else if (char == 'ي') {
        buffer.write('[يى]$diacritics');
      } else {
        buffer.write('${RegExp.escape(char)}$diacritics');
      }
    }
    return buffer.toString();
  }
}
