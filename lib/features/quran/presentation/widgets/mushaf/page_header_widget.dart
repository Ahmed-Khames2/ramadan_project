import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadan_project/features/quran/domain/entities/quran_page.dart';
import '../../utils/arabic_digits_ext.dart';

class PageHeaderWidget extends StatelessWidget {
  final QuranPage page;

  const PageHeaderWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surahNames = _getSurahNamesOnPage();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Surah Name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
            ),
            child: Text(
              'سورة ${surahNames.join("، ")}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: 'UthmanTaha',
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Divider(
                color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                thickness: 1,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.secondary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              'الجزء ${page.juzNumber.toArabicDigits()}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: 'UthmanTaha',
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getSurahNamesOnPage() {
    final surahNumbers = page.ayahs.map((e) => e.surahNumber).toSet().toList();
    surahNumbers.sort();
    return surahNumbers.map((s) => quran.getSurahNameArabic(s)).toList();
  }
}
