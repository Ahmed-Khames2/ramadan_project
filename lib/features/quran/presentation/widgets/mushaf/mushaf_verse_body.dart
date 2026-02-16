import 'package:flutter/material.dart';
import 'package:ramadan_project/features/quran/domain/entities/quran_page.dart';
import 'ayah_symbol.dart';
import 'surah_header_widget.dart';
import 'basmala_widget.dart';

class MushafVerseBody extends StatelessWidget {
  final QuranPage page;
  final double scale;

  const MushafVerseBody({super.key, required this.page, required this.scale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Group ayahs by Surah
    final surahGroups = <int, List<dynamic>>{};
    final surahNumbers = <int>[];

    for (final ayah in page.ayahs) {
      if (!surahGroups.containsKey(ayah.surahNumber)) {
        surahGroups[ayah.surahNumber] = [];
        surahNumbers.add(ayah.surahNumber);
      }
      surahGroups[ayah.surahNumber]!.add(ayah);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: surahNumbers.map((surahNum) {
        final ayahs = surahGroups[surahNum]!;
        final firstAyah = ayahs.first;
        final isNewSurah = firstAyah.ayahNumber == 1;
        final showBasmala = isNewSurah && surahNum != 1 && surahNum != 9;

        final spans = <InlineSpan>[];
        final baseTextStyle =
            theme.textTheme.bodyLarge?.copyWith(
              fontFamily: 'UthmanTaha',
              fontSize: (20 * scale).clamp(16, 40),
              height: 2.0,
              color: theme.colorScheme.onSurface.withOpacity(0.85),
            ) ??
            const TextStyle();

        for (final ayah in ayahs) {
          spans.add(TextSpan(text: ayah.text, style: baseTextStyle));

          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: AyahSymbol(ayahNumber: ayah.ayahNumber, scale: scale),
            ),
          );

          spans.add(const TextSpan(text: ' '));
        }

        return Column(
          children: [
            if (isNewSurah) ...[
              SurahHeaderWidget(surahNumber: surahNum, scale: scale),
              if (showBasmala) BasmalaWidget(scale: scale),
            ],
            RichText(
              text: TextSpan(children: spans),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              softWrap: true,
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}
