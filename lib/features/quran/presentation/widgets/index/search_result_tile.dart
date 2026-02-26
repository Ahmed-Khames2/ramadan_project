import 'package:flutter/material.dart';

import 'package:quran/quran.dart' as quran;
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'package:ramadan_project/features/quran/presentation/pages/mushaf_page_view.dart';

class SearchResultTile extends StatelessWidget {
  final Map<String, dynamic> result;
  final String query;

  const SearchResultTile({
    super.key,
    required this.result,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final isSurah = result['type'] == 'surah';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      child: IslamicCard(
        padding: EdgeInsets.zero,
        onTap: () {
          final page =
              result['page'] ??
              quran.getPageNumber(
                result['surahNumber'],
                result['ayahNumber'] ?? 1,
              );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MushafPageView(
                initialPage: page,
                initialSurah: result['surahNumber'],
                initialAyah: isSurah ? null : result['ayahNumber'],
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeIcon(isSurah),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _highlightMatchedText(
                      result['text'],
                      query,
                      isSurah
                          ? TextStyle(
                              fontFamily: 'UthmanTaha',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            )
                          : TextStyle(
                              fontFamily: 'UthmanTaha',
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.6,
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result['subtitle'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon(bool isSurah) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: (isSurah ? AppTheme.primaryEmerald : AppTheme.accentGold)
            .withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isSurah ? Icons.menu_book_rounded : Icons.format_quote_rounded,
        size: 20,
        color: isSurah ? AppTheme.primaryEmerald : AppTheme.accentGold,
      ),
    );
  }

  Widget _highlightMatchedText(String text, String query, TextStyle style) {
    if (query.isEmpty || !text.contains(query)) {
      return Text(text, style: style, textDirection: TextDirection.rtl);
    }

    final children = <TextSpan>[];
    final ranges = _getMatchRanges(text, query);

    int lastIndex = 0;
    for (final range in ranges) {
      if (range.start > lastIndex) {
        children.add(TextSpan(text: text.substring(lastIndex, range.start)));
      }
      children.add(
        TextSpan(
          text: text.substring(range.start, range.end),
          style: style.copyWith(
            backgroundColor: AppTheme.accentGold.withOpacity(0.2),
            color: AppTheme.primaryEmerald,
          ),
        ),
      );
      lastIndex = range.end;
    }

    if (lastIndex < text.length) {
      children.add(TextSpan(text: text.substring(lastIndex)));
    }

    return RichText(
      text: TextSpan(children: children, style: style),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
    );
  }

  String _normalize(String text) {
    var normalized = text;
    // Remove Tashkeel
    normalized = normalized.replaceAll(
      RegExp(r'[\u064B-\u0652\u0670\u0640]'),
      '',
    );
    // Normalize Alif
    normalized = normalized.replaceAll(RegExp(r'[أإآ]'), 'ا');
    return normalized;
  }

  List<TextRange> _getMatchRanges(String text, String query) {
    if (query.isEmpty) return [];

    final ranges = <TextRange>[];
    final normalizedText = _normalize(text);
    final normalizedQuery = _normalize(query);

    int start = 0;
    while (true) {
      final matchIndex = normalizedText.indexOf(normalizedQuery, start);
      if (matchIndex == -1) break;

      // Map normalized index back to original index
      int originalStart = _mapNormalizedIndexToOriginal(
        text,
        normalizedText,
        matchIndex,
      );
      int originalEnd = _mapNormalizedIndexToOriginal(
        text,
        normalizedText,
        matchIndex + normalizedQuery.length,
      );

      ranges.add(TextRange(start: originalStart, end: originalEnd));
      start = matchIndex + normalizedQuery.length;
    }
    return ranges;
  }

  int _mapNormalizedIndexToOriginal(
    String original,
    String normalized,
    int normalizedIndex,
  ) {
    if (normalizedIndex == 0) return 0;
    if (normalizedIndex >= normalized.length) return original.length;

    int currentNormalizedCount = 0;
    for (int i = 0; i < original.length; i++) {
      final char = original[i];
      // Check if this character was removed during normalization
      // (Tashkeel or Tatweel)
      if (!RegExp(r'[\u064B-\u0652\u0670\u0640]').hasMatch(char)) {
        if (currentNormalizedCount == normalizedIndex) {
          return i;
        }
        currentNormalizedCount++;
      }
    }
    return original.length;
  }
}
