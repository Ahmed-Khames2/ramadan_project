import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/hadith.dart';
import '../../../../core/utils/arabic_normalization.dart';
import '../cubits/hadith_list_cubit.dart';
import 'hadith_detail_page.dart';

class HadithListPage extends StatefulWidget {
  final HadithBook book;
  final HadithChapter chapter;

  const HadithListPage({super.key, required this.book, required this.chapter});

  @override
  State<HadithListPage> createState() => _HadithListPageState();
}

class _HadithListPageState extends State<HadithListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadHadiths();
    _scrollController.addListener(_onScroll);
  }

  void _loadHadiths({bool isLoadMore = false}) {
    context.read<HadithListCubit>().loadHadiths(
      bookKey: widget.book.key,
      chapterId: widget.chapter.chapterId,
      page: _currentPage,
      isLoadMore: isLoadMore,
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<HadithListCubit>().state;
      if (state is HadithListLoaded &&
          !state.hasReachedMax &&
          !state.isLoadingMore &&
          !state.isSearching) {
        _currentPage++;
        _loadHadiths(isLoadMore: true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chapter.titleArabic), elevation: 0),
      body: DecorativeBackground(
        child: BlocBuilder<HadithListCubit, HadithListState>(
          builder: (context, state) {
            // Keep track of the current hadiths and loading state
            final bool isLoading =
                state is HadithListLoading && _currentPage == 0;
            final bool isSearching =
                state is HadithListLoaded && state.isSearching;

            // We only show the full screen loader if we have absolutely no data and are loading the first page
            if (isLoading && _currentPage == 0) {
              return const Center(child: CircularProgressIndicator());
            }

            // At this point we either have data or an error, or we are loading more/searching
            final List<Hadith> hadiths = (state is HadithListLoaded)
                ? state.hadiths
                : (state is HadithListLoading && _currentPage > 0)
                ? (context.read<HadithListCubit>().state as dynamic).hadiths
                : [];

            final HadithListLoaded? loadedState = (state is HadithListLoaded)
                ? state
                : null;

            return Column(
              children: [
                // Search and Header Section
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing4,
                    vertical: AppTheme.spacing2,
                  ),
                  color: Theme.of(context).appBarTheme.backgroundColor,
                  child: Column(
                    children: [
                      // Smart Search Field
                      TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          context.read<HadithListCubit>().searchInChapter(
                            query: value,
                            bookKey: widget.book.key,
                            chapterId: widget.chapter.chapterId,
                          );
                        },
                        decoration: InputDecoration(
                          hintText: 'بحث ذكي في الأحاديث...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                    _loadHadiths();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).scaffoldBackgroundColor.withValues(alpha: 0.5),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing4,
                            vertical: AppTheme.spacing2,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusM,
                            ),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing2),
                      // Stats Row
                      if (loadedState != null)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing3,
                                vertical: AppTheme.spacing1 / 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryEmerald.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusS,
                                ),
                              ),
                              child: Text(
                                'عدد الأحاديث: ${loadedState.totalCount}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryEmerald,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing2),
                            Text(
                              'تم قراءة ${loadedState.readHadithIds.length} حديث',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Hadith List with Scrollbar
                Expanded(
                  child: Stack(
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          scrollbarTheme: ScrollbarThemeData(
                            thumbColor: WidgetStateProperty.all(
                              AppTheme.primaryEmerald.withValues(alpha: 0.5),
                            ),
                            thickness: WidgetStateProperty.all(8),
                            radius: const Radius.circular(AppTheme.radiusM),
                            interactive: true,
                          ),
                        ),
                        child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          child: (hadiths.isEmpty && !isLoading && !isSearching)
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 64,
                                        color: Colors.grey.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: AppTheme.spacing2),
                                      const Text(
                                        'لا توجد أحاديث تطابق بحثك',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.spacing4,
                                    vertical: AppTheme.spacing4,
                                  ),
                                  itemCount:
                                      hadiths.length +
                                      (loadedState != null &&
                                              loadedState.hasReachedMax
                                          ? 0
                                          : 1),
                                  itemBuilder: (context, index) {
                                    if (index >= hadiths.length) {
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: AppTheme.spacing4,
                                          ),
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }

                                    final hadith = hadiths[index];
                                    final isRead =
                                        loadedState?.readHadithIds.contains(
                                          hadith.id,
                                        ) ??
                                        false;

                                    return _HadithCard(
                                      hadith: hadith,
                                      index: index + 1,
                                      isRead: isRead,
                                      searchQuery: _searchQuery,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                HadithDetailPage(
                                                  hadith: hadith,
                                                ),
                                          ),
                                        ).then((_) {
                                          // Auto-load state if needed
                                        });
                                      },
                                      onToggleRead: () {
                                        context
                                            .read<HadithListCubit>()
                                            .toggleReadStatus(hadith.id);
                                      },
                                    );
                                  },
                                ),
                        ),
                      ),
                      // Semi-transparent overlay when searching to provide feedback
                      if (isSearching)
                        Positioned.fill(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: 0.3,
                            child: Container(color: Colors.white10),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  final Hadith hadith;
  final int index;
  final bool isRead;
  final String searchQuery;
  final VoidCallback onTap;
  final VoidCallback onToggleRead;

  const _HadithCard({
    required this.hadith,
    required this.index,
    required this.isRead,
    required this.searchQuery,
    required this.onTap,
    required this.onToggleRead,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: isRead
              ? AppTheme.primaryEmerald.withValues(alpha: 0.2)
              : AppTheme.primaryEmerald.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header of Hadith Card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing4,
                  vertical: AppTheme.spacing2,
                ),
                color: isRead
                    ? AppTheme.primaryEmerald.withValues(alpha: 0.1)
                    : AppTheme.primaryEmerald.withValues(alpha: 0.05),
                child: Row(
                  children: [
                    // Order Number
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryEmerald,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$index',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing3),
                    Text(
                      'الحديث ${hadith.idInBook}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryEmerald,
                      ),
                    ),
                    const Spacer(),
                    // Read Toggle Button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onToggleRead();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isRead
                              ? AppTheme.primaryEmerald
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isRead
                                ? AppTheme.primaryEmerald
                                : AppTheme.primaryEmerald.withValues(
                                    alpha: 0.3,
                                  ),
                          ),
                        ),
                        child: Row(
                          children: [
                            if (isRead)
                              const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              ),
                            const SizedBox(width: 4),
                            Text(
                              isRead ? 'تمت القراءة' : 'سأقرأه',
                              style: TextStyle(
                                fontSize: 10,
                                color: isRead
                                    ? Colors.white
                                    : AppTheme.primaryEmerald,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Hadith Text with Highlighting
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing4),
                child: HighlightedText(
                  text: hadith.textArabic,
                  query: searchQuery,
                  maxLines: 5,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.8,
                    fontFamily: 'Amiri',
                    wordSpacing: 2,
                  ),
                ),
              ),
              // Footer Action
              Padding(
                padding: const EdgeInsets.only(
                  left: AppTheme.spacing4,
                  right: AppTheme.spacing4,
                  bottom: AppTheme.spacing3,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'اقرأ المزيد',
                      style: TextStyle(
                        color: AppTheme.accentGold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: AppTheme.accentGold,
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
}

class HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final int? maxLines;

  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    required this.style,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    }

    final pattern = ArabicNormalization.searchPattern(query);
    if (pattern.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    }

    final regex = RegExp(pattern, caseSensitive: false);
    final List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    final matches = regex.allMatches(text);

    for (final match in matches) {
      // Text before the match
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }

      // The matched text (highlighted)
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: style.copyWith(
            backgroundColor: AppTheme.accentGold.withValues(alpha: 0.3),
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      lastMatchEnd = match.end;
    }

    // Remaining text after last match
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return RichText(
      text: TextSpan(children: spans, style: style),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
      textAlign: TextAlign.justify,
      textDirection: TextDirection.rtl,
    );
  }
}
