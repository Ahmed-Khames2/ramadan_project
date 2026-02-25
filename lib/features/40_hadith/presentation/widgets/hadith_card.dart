import 'package:flutter/material.dart';
import '../../domain/entities/hadith.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';

class HadithCard extends StatelessWidget {
  final Hadith hadith;
  final String searchQuery;
  final VoidCallback onTap;

  const HadithCard({
    super.key,
    required this.hadith,
    required this.onTap,
    this.searchQuery = '',
  });

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
                        style: const TextStyle(
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
                        _buildHighlightedText(
                          hadith.content.replaceAll('\n', ' '),
                          theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white70 : AppTheme.textGrey,
                            height: 1.4,
                            fontFamily: 'Cairo',
                          ),
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

  Widget _buildHighlightedText(String text, TextStyle? style) {
    if (searchQuery.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final String normalizedQuery = searchQuery.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Build regex to match query regardless of diacritics and Arabic variations
    final regexString = _buildSearchRegex(normalizedQuery);
    final regex = RegExp(regexString, caseSensitive: false);

    final matches = regex.allMatches(text);
    if (matches.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final spans = <TextSpan>[];
    int lastIndex = 0;

    // We only care about the first match for the snippet if we are showing maxLines: 1
    // but we can highlight multiple if they fit.
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
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(style: style, children: spans),
    );
  }

  String _buildSearchRegex(String query) {
    // Basic normalization for building regex
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
