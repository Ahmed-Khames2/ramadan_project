import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'package:ramadan_project/domain/entities/surah_info.dart';
import 'package:ramadan_project/features/favorites/presentation/pages/favorites_page.dart';
import 'package:ramadan_project/presentation/blocs/search_bloc.dart';
import 'package:ramadan_project/presentation/widgets/custom_search_bar.dart';
import 'package:quran/quran.dart' as quran;
import '../widgets/index/surah_tile.dart';
import '../widgets/index/search_result_tile.dart';

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
            _buildSearchHeader(),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
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
                        return SearchResultTile(
                          result: state.results[index],
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

  Widget _buildSearchHeader() {
    return Container(
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
