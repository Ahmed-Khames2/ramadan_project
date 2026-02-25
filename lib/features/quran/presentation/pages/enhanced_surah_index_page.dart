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
import 'package:ramadan_project/core/utils/string_extensions.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../domain/repositories/quran_repository.dart';
import 'package:ramadan_project/features/quran/presentation/pages/mushaf_page_view.dart';
// import 'package:ramadan_project/features/favorites/presentation/pages/favorites_page.dart';

class EnhancedSurahIndexPage extends StatefulWidget {
  final bool showBackButton;
  const EnhancedSurahIndexPage({super.key, this.showBackButton = false});

  @override
  State<EnhancedSurahIndexPage> createState() => EnhancedSurahIndexPageState();
}

class EnhancedSurahIndexPageState extends State<EnhancedSurahIndexPage> {
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
  final Set<int> _collapsedJuzs = {};

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
        _updateDisplayList(); // Ensure list is updated after progress is loaded
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
    if (_searchController.text.isEmpty) {
      if (_lastReadPage != null) {
        _displayList.add('CONTINUE_READING_BANNER');
      }
      _displayList.add('FILTERS');
    }

    int currentJuzTracker = 0;

    for (var surah in filteredSurahs) {
      final startJuz = quran.getJuzNumber(surah.number, 1);

      if (startJuz > currentJuzTracker) {
        _displayList.add(startJuz); // Integer indicates a Header
        currentJuzTracker = startJuz;
      }

      // Only add surah if its parent Juz is not collapsed
      if (!_collapsedJuzs.contains(startJuz)) {
        _displayList.add(surah);
      }
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

  void _toggleJuz(int juz) {
    setState(() {
      if (_collapsedJuzs.contains(juz)) {
        _collapsedJuzs.remove(juz);
      } else {
        _collapsedJuzs.add(juz);
      }
      _updateDisplayList();
    });
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

  void clearSearch() {
    _searchController.clear();
    context.read<SearchBloc>().add(ClearSearch());
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: DecorativeBackground(
          child: SafeArea(
            child: Column(
              children: [
                _buildFixedHeader(theme),
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

                      if (state is SearchLoaded &&
                          state.query.trim().isNotEmpty) {
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
        ),
      ),
    );
  }

  Widget _buildFixedHeader(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor, // Ensure unified fixed background
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.showBackButton)
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: AppTheme.primaryEmerald,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'فهرس القرآن',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryEmerald,
                      height: 1.2,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    'ابحث عن السور والآيات',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textGrey.withValues(alpha: 0.7),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          const OrnamentalDivider(width: 40),
          const SizedBox(height: 16),
          _buildSearchSection(theme),
        ],
      ),
    );
  }

  Widget _buildSearchSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: AppTheme.spacing2,
      ),
      child: CustomSearchBar(
        controller: _searchController,
        hintText: 'ابحث عن سورة أو آية...',
        showBorder: true,
        showShadow: false,
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

  Widget _buildContinueReadingBanner(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: IslamicCard(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MushafPageView(
                initialPage: _lastReadPage!,
                initialSurah: _lastReadSurah,
              ),
            ),
          );
          _loadProgress();
        },
        padding: const EdgeInsets.all(16),
        color: AppTheme.primaryEmerald.withOpacity(0.05),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryEmerald,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.history_edu,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'متابعة القراءة',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${_lastReadSurahName ?? 'عودة للمصحف'} - صفحة ${_lastReadPage?.toArabic() ?? ""}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.accentGold.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
        ],
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
        if (item == 'CONTINUE_READING_BANNER') {
          return _buildContinueReadingBanner(theme);
        }
        if (item == 'FILTERS') {
          return _buildFilters();
        }
        if (item is int) {
          // It's a Juz Header
          final isCollapsed = _collapsedJuzs.contains(item);
          return GestureDetector(
            onTap: () => _toggleJuz(item),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left ornament
                  Container(
                    height: 1,
                    width: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppTheme.accentGold.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      isCollapsed
                          ? Icons.keyboard_arrow_left_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppTheme.accentGold.withOpacity(0.7),
                    ),
                  ),

                  // Juz text
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.secondary.withOpacity(0.1)
                          : theme.colorScheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            (isDark
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.primary)
                                .withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      'الجزء ${item.toArabic()}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.primary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),

                  // Right ornament
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      isCollapsed
                          ? Icons.keyboard_arrow_left_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppTheme.accentGold.withOpacity(0.7),
                    ),
                  ),
                  Container(
                    height: 1,
                    width: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentGold.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
