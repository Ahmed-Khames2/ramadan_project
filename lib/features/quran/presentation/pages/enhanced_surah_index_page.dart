import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'package:ramadan_project/domain/entities/surah_info.dart';
import 'package:ramadan_project/features/favorites/presentation/pages/favorites_page.dart';
import 'package:ramadan_project/features/quran/presentation/pages/mushaf_page_view.dart';
import 'package:ramadan_project/presentation/blocs/search_bloc.dart';
import 'package:ramadan_project/presentation/widgets/custom_search_bar.dart';


class EnhancedSurahIndexPage extends StatefulWidget {
  const EnhancedSurahIndexPage({super.key});

  @override
  State<EnhancedSurahIndexPage> createState() => _EnhancedSurahIndexPageState();
}

class _EnhancedSurahIndexPageState extends State<EnhancedSurahIndexPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late final List<SurahInfo> _surahList;
  late TabController _tabController;

  String? _selectedRevelationType; // null, 'Makkah', 'Madinah'
  int? _selectedJuz; // 1-30

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _surahList = _getSurahList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Clear search when returning to this page
    if (_searchController.text.isNotEmpty) {
      _searchController.clear();
      context.read<SearchBloc>().add(ClearSearch());
    }
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

  List<SurahInfo> get _filteredSurahs {
    var filtered = _surahList;

    if (_selectedRevelationType != null) {
      filtered = filtered
          .where((s) => s.revelationType == _selectedRevelationType)
          .toList();
    }

    if (_selectedJuz != null) {
      filtered = filtered.where((s) {
        final juz = quran.getJuzNumber(s.number, 1);
        return juz == _selectedJuz;
      }).toList();
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'فهرس القرآن',
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentGold,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: 'السور'),
            Tab(text: 'الأجزاء'),
          ],
        ),
      ),
      body: DecorativeBackground(
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacing4,
                AppTheme.spacing2,
                AppTheme.spacing4,
                AppTheme.spacing4,
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
                hintText: 'ابحث عن سورة أو آية...',
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

            // Filters (only when not searching)
            if (_searchController.text.isEmpty) _buildFilters(),

            // Content
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryEmerald,
                      ),
                    );
                  }

                  if (state is SearchLoaded && state.query.trim().isNotEmpty) {
                    if (state.results.isEmpty) {
                      return _buildEmptySearchState(state.query);
                    }
                    return _buildSearchResults(state.results, state.query);
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [_buildSurahList(), _buildJuzList()],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing3,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          children: [
            // Makki/Madani Filter
            _buildFilterChip(
              label: 'الكل',
              isSelected: _selectedRevelationType == null,
              onTap: () => setState(() => _selectedRevelationType = null),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'مكية',
              isSelected: _selectedRevelationType == 'Makkah',
              onTap: () => setState(() => _selectedRevelationType = 'Makkah'),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'مدنية',
              isSelected: _selectedRevelationType == 'Madinah',
              onTap: () => setState(() => _selectedRevelationType = 'Madinah'),
            ),
            const SizedBox(width: 16),
            // Juz Filter (Dropdown)
            _buildJuzDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? AppTheme.primaryEmerald : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryEmerald
                  : AppTheme.primaryEmerald.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.primaryEmerald,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJuzDropdown() {
    return DropdownButton<int?>(
      value: _selectedJuz,
      hint: Text('اختر الجزء', style: GoogleFonts.cairo(fontSize: 14)),
      underline: const SizedBox(),
      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryEmerald),
      items: [
        DropdownMenuItem<int?>(
          value: null,
          child: Text('كل الأجزاء', style: GoogleFonts.cairo()),
        ),
        ...List.generate(30, (i) => i + 1).map((juz) {
          return DropdownMenuItem<int?>(
            value: juz,
            child: Text('الجزء $juz', style: GoogleFonts.cairo()),
          );
        }),
      ],
      onChanged: (value) => setState(() => _selectedJuz = value),
    );
  }

  Widget _buildSurahList() {
    final surahs = _filteredSurahs;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing4,
      ),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        return _buildSurahTile(surahs[index]);
      },
    );
  }

  Widget _buildJuzList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing4,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNumber = index + 1;
        return _buildJuzTile(juzNumber);
      },
    );
  }

  Widget _buildSurahTile(SurahInfo surah) {
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
                      '${surah.ayahCount} آيات • الصفحة ${surah.startPage}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: AppTheme.textGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJuzTile(int juzNumber) {
    // Find first surah in this juz
    final firstSurahInJuz = _surahList.firstWhere(
      (s) => quran.getJuzNumber(s.number, 1) == juzNumber,
      orElse: () => _surahList[0],
    );
    final juzStartPage = quran.getPageNumber(
      quran.getSurahAndVersesFromJuz(juzNumber).keys.first,
      quran.getSurahAndVersesFromJuz(juzNumber).values.first[0],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: IslamicCard(
        padding: EdgeInsets.zero,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MushafPageView(initialPage: juzStartPage),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryEmerald, Color(0xFF1A5E20)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'الجزء',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '$juzNumber',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الصفحة $juzStartPage',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'يبدأ من ${firstSurahInJuz.nameArabic}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: AppTheme.textGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<Map<String, dynamic>> results, String query) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing4,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        final isSurah = result['type'] == 'surah';
        return Container(
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
                  builder: (context) => MushafPageView(initialPage: page),
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
                          (isSurah
                                  ? AppTheme.primaryEmerald
                                  : AppTheme.accentGold)
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
                        Text(
                          result['text'],
                          style: TextStyle(
                            fontFamily: 'UthmanTaha',
                            fontSize: isSurah ? 20 : 18,
                            fontWeight: isSurah
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: AppTheme.textDark,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result['subtitle'],
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: AppTheme.textGrey,
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
      },
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
              Icons.search_off_rounded,
              size: 80,
              color: AppTheme.accentGold.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد نتائج',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryEmerald,
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
