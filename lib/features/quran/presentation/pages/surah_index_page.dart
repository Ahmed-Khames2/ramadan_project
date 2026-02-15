import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'package:ramadan_project/domain/entities/surah_info.dart';
import 'package:ramadan_project/features/favorites/presentation/pages/favorites_page.dart';
import 'package:ramadan_project/presentation/blocs/search_bloc.dart';
import 'package:ramadan_project/presentation/widgets/custom_search_bar.dart';
import 'mushaf_page_view.dart';

class SurahIndexPage extends StatefulWidget {
  const SurahIndexPage({super.key});

  @override
  State<SurahIndexPage> createState() => _SurahIndexPageState();
}

class _SurahIndexPageState extends State<SurahIndexPage> {
  final TextEditingController _searchController = TextEditingController();
  late final List<SurahInfo> _surahList;

  @override
  void initState() {
    super.initState();
    _surahList = _getSurahList();
  }

  List<SurahInfo> _getSurahList() {
    return List.generate(114, (index) {
      final surahNumber = index + 1;
      return SurahInfo(
        number: surahNumber,
        nameArabic: quran.getSurahNameArabic(surahNumber),
        nameEnglish: quran.getSurahName(surahNumber),
        revelationType: quran.getPlaceOfRevelation(surahNumber),
        ayahCount: quran.getVerseCount(surahNumber),
        startPage: quran.getPageNumber(surahNumber, 1),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'فهرس السور',
          style: TextStyle(
            fontFamily: 'UthmanTaha',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryEmerald,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
            tooltip: 'المفضلة',
          ),
        ],
      ),
      body: DecorativeBackground(
        child: Column(
          children: [
            // Premium Search Bar Section
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacing4,
                AppTheme.spacing2,
                AppTheme.spacing4,
                AppTheme.spacing6,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.primaryEmerald,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.spacing8),
                  bottomRight: Radius.circular(AppTheme.spacing8),
                ),
              ),
              child: CustomSearchBar(
                controller: _searchController,
                hintText: 'ابحث عن سورة، آية، أو كلمة...',
                onChanged: (value) {
                  context.read<SearchBloc>().add(SearchQueryChanged(value));
                  setState(() {});
                },
                onClear: () {
                  _searchController.clear();
                  context.read<SearchBloc>().add(ClearSearch());
                  setState(() {});
                },
              ),
            ),

            // Search Results or Surah List
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                buildWhen: (previous, current) {
                  if (previous is SearchLoaded && current is SearchLoaded) {
                    return previous.results != current.results ||
                        previous.query != current.query;
                  }
                  return true;
                },
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryEmerald,
                        strokeWidth: 3,
                      ),
                    );
                  }

                  if (state is SearchLoaded && state.query.trim().isNotEmpty) {
                    if (state.results.isEmpty) {
                      return _buildEmptySearchState(state.query);
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing4,
                        vertical: AppTheme.spacing4,
                      ),
                      itemCount: state.results.length,
                      itemBuilder: (context, index) {
                        final result = state.results[index];
                        return SearchResultTile(
                          result: result,
                          query: state.query,
                        );
                      },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing4,
                      vertical: AppTheme.spacing4,
                    ),
                    itemCount: _surahList.length,
                    itemBuilder: (context, index) {
                      return SurahTile(surah: _surahList[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearchState(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 80,
              color: AppTheme.accentGold.withOpacity(0.2),
            ),
            const SizedBox(height: 24),
            Text(
              'ابحث في كتاب الله...',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryEmerald.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لا توجد نتائج للبحث عن "$query"',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 14, color: AppTheme.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MushafPageView(
                initialPage: quran.getPageNumber(result['surahNumber'], 1),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      (isSurah ? AppTheme.primaryEmerald : AppTheme.accentGold)
                          .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSurah
                      ? Icons.menu_book_rounded
                      : Icons.format_quote_rounded,
                  size: 20,
                  color: isSurah
                      ? AppTheme.primaryEmerald
                      : AppTheme.accentGold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _highlightMatchedText(
                      result['text'],
                      query,
                      isSurah
                          ? const TextStyle(
                              fontFamily: 'UthmanTaha',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            )
                          : const TextStyle(
                              fontFamily: 'UthmanTaha',
                              fontSize: 18,
                              color: AppTheme.textDark,
                              height: 1.6,
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result['subtitle'],
                      style: GoogleFonts.cairo(
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

  List<TextRange> _getMatchRanges(String text, String query) {
    final ranges = <TextRange>[];
    int start = 0;
    while (true) {
      final index = text.indexOf(query, start);
      if (index == -1) break;
      ranges.add(TextRange(start: index, end: index + query.length));
      start = index + query.length;
    }
    return ranges;
  }
}

class SurahTile extends StatelessWidget {
  final SurahInfo surah;

  const SurahTile({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: IslamicCard(
        padding: EdgeInsets.zero,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MushafPageView(initialPage: surah.startPage),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.star_outline_rounded,
                    size: 48,
                    color: AppTheme.accentGold.withOpacity(0.3),
                  ),
                  Text(
                    '${surah.number}',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryEmerald,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          surah.nameArabic,
                          style: const TextStyle(
                            fontFamily: 'UthmanTaha',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        RevelationBadge(isMakki: surah.isMakki),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      surah.nameEnglish,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryEmerald.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryEmerald.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  '${surah.ayahCount} آيات',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryEmerald,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
