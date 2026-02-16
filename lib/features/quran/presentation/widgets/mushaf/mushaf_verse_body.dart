import 'package:flutter/material.dart';
import 'package:ramadan_project/features/quran/domain/entities/quran_page.dart';
import 'ayah_symbol.dart';

class MushafVerseBody extends StatelessWidget {
  final QuranPage page;
  final double scale;

  const MushafVerseBody({super.key, required this.page, required this.scale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spans = <InlineSpan>[];

    final baseTextStyle =
        theme.textTheme.bodyLarge?.copyWith(
          fontFamily: 'UthmanTaha',
          fontSize: (20 * scale).clamp(16, 40),
          height: 2.0,
          color: theme.colorScheme.onSurface.withOpacity(0.85),
        ) ??
        const TextStyle();

    for (int i = 0; i < page.ayahs.length; i++) {
      final ayah = page.ayahs[i];

      spans.add(TextSpan(text: ayah.text, style: baseTextStyle));

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: AyahSymbol(ayahNumber: ayah.ayahNumber, scale: scale),
        ),
      );

      // Add a small space between ayahs if needed,
      // though typically symbols handle this.
      spans.add(const TextSpan(text: ' '));
    }

    return RichText(
      text: TextSpan(children: spans),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
      softWrap: true,
    );
  }
}
