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
import '../widgets/index/surah_tile.dart';
import '../widgets/index/juz_tile.dart';
import '../widgets/index/search_result_tile.dart';
import '../widgets/index/surah_filter_chip.dart';
import '../widgets/index/juz_picker.dart';

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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesPage()),
            ),
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
            _buildSearchSection(),
            if (_searchController.text.isEmpty) _buildFilters(),
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
                    return ListView.builder(
                      padding: const EdgeInsets.all(AppTheme.spacing4),
                      itemCount: state.results.length,
                      itemBuilder: (context, index) => SearchResultTile(
                        result: state.results[index],
                        query: state.query,
                      ),
                    );
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

  Widget _buildSearchSection() {
    return Container(
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
            SurahFilterChip(
              label: 'الكل',
              isSelected: _selectedRevelationType == null,
              onTap: () => setState(() => _selectedRevelationType = null),
            ),
            const SizedBox(width: 8),
            SurahFilterChip(
              label: 'مكية',
              isSelected: _selectedRevelationType == 'Makkah',
              onTap: () => setState(() => _selectedRevelationType = 'Makkah'),
            ),
            const SizedBox(width: 8),
            SurahFilterChip(
              label: 'مدنية',
              isSelected: _selectedRevelationType == 'Madinah',
              onTap: () => setState(() => _selectedRevelationType = 'Madinah'),
            ),
            const SizedBox(width: 16),
            JuzPicker(
              selectedJuz: _selectedJuz,
              onChanged: (val) => setState(() => _selectedJuz = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahList() {
    final surahs = _filteredSurahs;
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      itemCount: surahs.length,
      itemBuilder: (context, index) => SurahTile(surah: surahs[index]),
    );
  }

  Widget _buildJuzList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNumber = index + 1;
        final firstSurahName = _surahList
            .firstWhere(
              (s) => quran.getJuzNumber(s.number, 1) == juzNumber,
              orElse: () => _surahList[0],
            )
            .nameArabic;
        return JuzTile(juzNumber: juzNumber, firstSurahName: firstSurahName);
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
