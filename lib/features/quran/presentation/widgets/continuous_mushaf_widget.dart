import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/features/quran/domain/entities/quran_page.dart';
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';
import 'package:ramadan_project/features/quran/domain/entities/ayah.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:quran/quran.dart' as quran;

/// Modern Mushaf-style page widget with clean design
class ContinuousMushafPageWidget extends StatefulWidget {
  final int pageNumber;

  const ContinuousMushafPageWidget({super.key, required this.pageNumber});

  @override
  State<ContinuousMushafPageWidget> createState() =>
      _ContinuousMushafPageWidgetState();
}

class _ContinuousMushafPageWidgetState
    extends State<ContinuousMushafPageWidget> {
  late Future<QuranPage> _pageData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(ContinuousMushafPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageNumber != widget.pageNumber) {
      _loadData();
    }
  }

  void _loadData() {
    _pageData = context.read<QuranRepository>().getPage(widget.pageNumber);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuranPage>(
      future: _pageData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final page = snapshot.data!;
        final isFirstPageOfSurah = _isFirstPageOfSurah(page);
        final surahsInPage = _getSurahsInPage(page);

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Header: Surah name and Juz number
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "سورة ${page.surahName}",
                    style: const TextStyle(
                      fontFamily: 'UthmanTaha',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryEmerald,
                    ),
                  ),
                  Text(
                    "الجزء ${page.juzNumber}",
                    style: const TextStyle(
                      fontFamily: 'UthmanTaha',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Basmala if first page of surah (and not Al-Fatiha)
              if (isFirstPageOfSurah && _getSurahNumber(page) != 1) ...[
                Text(
                  "سورة ${page.surahName}",
                  style: const TextStyle(
                    fontFamily: 'UthmanTaha',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryEmerald,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                  style: TextStyle(
                    fontFamily: 'UthmanTaha',
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 16),
              ],

              // Quran text content
              Expanded(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: _buildQuranContent(page, surahsInPage),
                ),
              ),

              const SizedBox(height: 8),

              // Footer: Page number only
              Center(
                child: Text(
                  "${page.pageNumber}",
                  style: const TextStyle(
                    fontFamily: 'UthmanTaha',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryEmerald,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isFirstPageOfSurah(QuranPage page) {
    // Check if this is the first page of the surah
    return page.ayahs.isNotEmpty && page.ayahs.first.ayahNumber == 1;
  }

  int _getSurahNumber(QuranPage page) {
    return page.ayahs.isNotEmpty ? page.ayahs.first.surahNumber : 1;
  }

  List<int> _getSurahsInPage(QuranPage page) {
    final surahs = <int>[];
    for (final ayah in page.ayahs) {
      if (!surahs.contains(ayah.surahNumber)) {
        surahs.add(ayah.surahNumber);
      }
    }
    return surahs;
  }

  Widget _buildQuranContent(QuranPage page, List<int> surahsInPage) {
    final spans = <InlineSpan>[];
    int currentSurah = -1;

    for (final ayah in page.ayahs) {
      // If this is a new surah in the page, add surah header
      if (surahsInPage.length > 1 && ayah.surahNumber != currentSurah) {
        if (currentSurah != -1) {
          spans.add(const TextSpan(text: '\n\n')); // Space between surahs
        }

        spans.add(
          TextSpan(
            text: 'سورة ${quran.getSurahNameArabic(ayah.surahNumber)}\n',
            style: const TextStyle(
              fontFamily: 'UthmanTaha',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryEmerald,
            ),
          ),
        );

        // Add Basmala for surahs other than Al-Fatiha
        if (ayah.surahNumber != 1) {
          spans.add(
            const TextSpan(
              text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n\n',
              style: TextStyle(
                fontFamily: 'UthmanTaha',
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          );
        }

        currentSurah = ayah.surahNumber;
      }

      // Add ayah text
      spans.add(
        TextSpan(
          text: ayah.text,
          style: const TextStyle(
            fontFamily: 'UthmanTaha',
            fontSize: 16, // Smaller font to fit all content
            height: 1.8,
            color: Colors.black87,
          ),
        ),
      );

      // Add ayah number
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFD4AF37),
            ),
            alignment: Alignment.center,
            child: Text(
              "${ayah.ayahNumber}",
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );

      // Add space between ayahs
      spans.add(const TextSpan(text: ' '));
    }

    return RichText(
      text: TextSpan(children: spans),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
    );
  }
}
