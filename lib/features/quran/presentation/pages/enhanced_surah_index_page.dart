import 'package:flutter/material.dart';

import 'package:quran/quran.dart' as quran;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'package:ramadan_project/domain/entities/surah_info.dart';
import 'package:ramadan_project/presentation/blocs/search_bloc.dart';
import 'package:ramadan_project/presentation/widgets/custom_search_bar.dart';
import '../widgets/index/surah_tile.dart';
import '../widgets/index/search_result_tile.dart';
import '../widgets/index/surah_filter_chip.dart';
import '../widgets/index/juz_picker.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../domain/repositories/quran_repository.dart';
import 'package:ramadan_project/features/quran/presentation/pages/mushaf_page_view.dart';
import 'package:ramadan_project/features/favorites/presentation/pages/favorites_page.dart';

class EnhancedSurahIndexPage extends StatefulWidget {
  const EnhancedSurahIndexPage({super.key});

  @override
  State<EnhancedSurahIndexPage> createState() => _EnhancedSurahIndexPageState();
}

class _EnhancedSurahIndexPageState extends State<EnhancedSurahIndexPage> {
  final TextEditingController _searchController = TextEditingController();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  late final List<SurahInfo> _allSurahs;

  // Mixed list of SurahInfo and Integer (for Juz headers)
  List<dynamic> _displayList = [];

  // Maps Juz number (1-30) to index in _displayList
  final Map<int, int> _juzIndexMap = {};

  String? _selectedRevelationType; // null, 'Makkah', 'Madinah'
  int? _selectedJuz; // 1-30

  // Progress Tracking
  int? _lastReadSurah;
  int? _lastReadPage;

  String? _lastReadSurahName;

  @override
  void initState() {
    super.initState();
    _allSurahs = _getSurahList();
    _updateDisplayList();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = context.read<QuranRepository>().getProgress();
    if (progress != null) {
      setState(() {
        _lastReadSurah = progress.lastReadSurahNumber;
        _lastReadPage = progress.lastReadPage;

        if (_lastReadSurah != null) {
          _lastReadSurahName = quran.getSurahNameArabic(_lastReadSurah!);
        }
      });
    }
  }

  void _updateDisplayList() {
    _displayList.clear();
    _juzIndexMap.clear();

    // 1. Filter Surahs first based on type (Makki/Madani)
    List<SurahInfo> filteredSurahs = _allSurahs;
    if (_selectedRevelationType != null) {
      filteredSurahs = filteredSurahs
          .where((s) => s.revelationType == _selectedRevelationType)
          .toList();
    }

    // 2. Build the display list with Dividers
    int currentJuzTracker = 0;

    for (var surah in filteredSurahs) {
      final startJuz = quran.getJuzNumber(surah.number, 1);

      if (startJuz > currentJuzTracker) {
        _displayList.add(startJuz); // Integer indicates a Header
        currentJuzTracker = startJuz;
      }
      _displayList.add(surah);
    }

    // 3. Build the Scrolling Map (Juz -> Index)
    for (int j = 1; j <= 30; j++) {
      try {
        final Map<int, List<int>> juzData = quran.getSurahAndVersesFromJuz(j);
        final int firstSurahInJuz = juzData.keys.first;

        int foundIndex = -1;
        for (int i = 0; i < _displayList.length; i++) {
          if (_displayList[i] is SurahInfo) {
            if ((_displayList[i] as SurahInfo).number == firstSurahInJuz) {
              foundIndex = i;
              break;
            }
          }
        }

        if (foundIndex != -1) {
          if (foundIndex > 0 && _displayList[foundIndex - 1] is int) {
            if (_displayList[foundIndex - 1] == j) {
              foundIndex--;
            }
          }
          _juzIndexMap[j] = foundIndex;
        }
      } catch (e) {
        // Handle edge case
      }
    }
  }

  Future<void> _scrollToJuz(int juz) async {
    final index = _juzIndexMap[juz];
    if (index != null) {
      _itemScrollController.jumpTo(index: index);
    }
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('فهرس القرآن'),
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
      ),
      body: DecorativeBackground(
        child: Column(
          children: [
            _buildSearchSection(theme),
            if (_searchController.text.isEmpty) _buildFilters(),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    );
                  }

                  if (state is SearchLoaded && state.query.trim().isNotEmpty) {
                    if (state.results.isEmpty) {
                      return _buildEmptySearchState(state.query, theme);
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.spacing4,
                        AppTheme.spacing4,
                        AppTheme.spacing4,
                        110, // Added padding for floating navbar
                      ),
                      itemCount: state.results.length,
                      itemBuilder: (context, index) => SearchResultTile(
                        result: state.results[index],
                        query: state.query,
                      ),
                    );
                  }

                  return _buildSurahList();
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: _lastReadPage != null
          ? Padding(
              padding: const EdgeInsets.only(bottom: 90), // Lift above navbar
              child: FloatingActionButton.extended(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MushafPageView(
                        initialPage: _lastReadPage!,
                        initialSurah: _lastReadSurah,
                      ),
                    ),
                  );
                  _loadProgress(); // Refresh on return
                },
                backgroundColor: AppTheme.primaryEmerald,
                icon: const Icon(Icons.history_edu, color: Colors.white),
                label: Text(
                  'متابعة القراءة: $_lastReadSurahName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
                _loadProgress(); // Refresh on return
              },
              backgroundColor: theme.colorScheme.primary,
              icon: const Icon(Icons.history_edu, color: Colors.white),
              label: Text(
                'متابعة القراءة: $_lastReadSurahName',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSearchSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing2,
        AppTheme.spacing4,
        AppTheme.spacing4,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(
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
              onTap: () {
                setState(() {
                  _selectedRevelationType = null;
                  _updateDisplayList();
                });
              },
            ),
            const SizedBox(width: 8),
            SurahFilterChip(
              label: 'مكية',
              isSelected: _selectedRevelationType == 'Makkah',
              onTap: () {
                setState(() {
                  _selectedRevelationType = 'Makkah';
                  _updateDisplayList();
                });
              },
            ),
            const SizedBox(width: 8),
            SurahFilterChip(
              label: 'مدنية',
              isSelected: _selectedRevelationType == 'Madinah',
              onTap: () {
                setState(() {
                  _selectedRevelationType = 'Madinah';
                  _updateDisplayList();
                });
              },
            ),
            const SizedBox(width: 16),
            JuzPicker(
              selectedJuz: _selectedJuz,
              onChanged: (val) {
                setState(() => _selectedJuz = val);
                if (val != null) {
                  _scrollToJuz(val);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahList() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ScrollablePositionedList.builder(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing4,
        AppTheme.spacing4,
        110, // Added padding for floating navbar
      ),
      itemCount: _displayList.length,
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      itemBuilder: (context, index) {
        final item = _displayList[index];
        if (item is int) {
          // It's a Juz Header
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              children: [
                const OrnamentalDivider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.secondary.withValues(alpha: 0.12)
                          : theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? theme.colorScheme.secondary.withValues(alpha: 0.2)
                            : theme.colorScheme.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      'الجزء $item',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const OrnamentalDivider(),
              ],
            ),
          );
        } else if (item is SurahInfo) {
          final isLastRead = item.number == _lastReadSurah;
          return SurahTile(
            surah: item,
            isLastRead: isLastRead,
            initialPage: isLastRead ? _lastReadPage : null,
            onReturn: _loadProgress,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptySearchState(String query, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: theme.colorScheme.secondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد نتائج',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لا توجد نتائج للبحث عن "$query"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppTheme.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}
