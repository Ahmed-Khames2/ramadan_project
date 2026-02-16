import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/features/quran/domain/entities/quran_page.dart';
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';
import 'mushaf/mushaf_verse_body.dart';
import 'mushaf/surah_header_widget.dart';
import 'mushaf/basmala_widget.dart';
import 'mushaf/page_footer_widget.dart';

class ContinuousMushafPageWidget extends StatefulWidget {
  final int pageNumber;
  final double fontScale;

  const ContinuousMushafPageWidget({
    super.key,
    required this.pageNumber,
    this.fontScale = 1.0,
  });

  @override
  State<ContinuousMushafPageWidget> createState() =>
      _ContinuousMushafPageWidgetState();
}

class _ContinuousMushafPageWidgetState
    extends State<ContinuousMushafPageWidget> {
  static const EdgeInsets _pagePadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 20,
  );
  late Future<QuranPage> _pageData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(ContinuousMushafPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageNumber != widget.pageNumber) _loadData();
  }

  void _loadData() {
    _pageData = context.read<QuranRepository>().getPage(widget.pageNumber);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<QuranPage>(
      future: _pageData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text("Error loading ayahs", style: theme.textTheme.titleMedium),
              ],
            ),
          );
        }

        if (!snapshot.hasData) return const SizedBox.shrink();

        final page = snapshot.data!;
        final isDefaultScale = (widget.fontScale - 1.0).abs() < 0.01;
        final contentScale = isDefaultScale ? 1.0 : widget.fontScale;

        // Determine if we need to show Surah Header and Basmala
        // Only on the first page of a Surah
        final firstAyah = page.ayahs.first;
        final isFirstPageOfSurah = firstAyah.ayahNumber == 1;
        final showBasmala =
            isFirstPageOfSurah &&
            firstAyah.surahNumber != 1 &&
            firstAyah.surahNumber != 9;

        return LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: isDefaultScale
                        ? const NeverScrollableScrollPhysics()
                        : const BouncingScrollPhysics(),
                    child: Padding(
                      padding: _pagePadding,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight:
                              constraints.maxHeight -
                              _pagePadding.vertical -
                              60, // Subtract footer height approx
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Vertically center for short surahs
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (isFirstPageOfSurah) ...[
                              SurahHeaderWidget(
                                surahNumber: firstAyah.surahNumber,
                                scale: contentScale,
                              ),
                              if (showBasmala)
                                BasmalaWidget(scale: contentScale),
                            ],
                            MushafVerseBody(page: page, scale: contentScale),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                PageFooterWidget(pageNumber: widget.pageNumber),
              ],
            );
          },
        );
      },
    );
  }
}
