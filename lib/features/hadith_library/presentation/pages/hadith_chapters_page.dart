import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/hadith.dart';
import '../../../../core/utils/arabic_normalization.dart';
import '../cubits/hadith_chapters_cubit.dart';
import 'hadith_list_page.dart';

class HadithChaptersPage extends StatefulWidget {
  final HadithBook book;
  const HadithChaptersPage({super.key, required this.book});

  @override
  State<HadithChaptersPage> createState() => _HadithChaptersPageState();
}

class _HadithChaptersPageState extends State<HadithChaptersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<HadithChaptersCubit>().loadChapters(widget.book.key);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.book.nameArabic), elevation: 0),
      body: DecorativeBackground(
        child: BlocBuilder<HadithChaptersCubit, HadithChaptersState>(
          builder: (context, state) {
            if (state is HadithChaptersLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HadithChaptersLoaded) {
              final filteredChapters = state.chapters.where((chapter) {
                if (_searchQuery.isEmpty) return true;
                final normalizedQuery = ArabicNormalization.normalize(
                  _searchQuery,
                );
                final normalizedTitle = ArabicNormalization.normalize(
                  chapter.titleArabic,
                );
                return normalizedTitle.contains(normalizedQuery);
              }).toList();

              return Column(
                children: [
                  // Search Bar and Stats Section
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing4,
                      vertical: AppTheme.spacing2,
                    ),
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    child: Column(
                      children: [
                        // Search Field
                        TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'بحث في الأبواب...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
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
                                'إجمالي الأبواب: ${state.chapters.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryEmerald,
                                ),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              const SizedBox(width: AppTheme.spacing2),
                              Text(
                                'نتائج البحث: ${filteredChapters.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Chapters List
                  Expanded(
                    child: filteredChapters.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: AppTheme.spacing2),
                                const Text(
                                  'لا توجد أبواب تطابق بحثك',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppTheme.spacing4),
                            itemCount: filteredChapters.length,
                            itemBuilder: (context, index) {
                              final chapter = filteredChapters[index];
                              return _ChapterCard(
                                chapter: chapter,
                                index: index + 1,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HadithListPage(
                                        book: widget.book,
                                        chapter: chapter,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            } else if (state is HadithChaptersError) {
              return Center(child: Text('خطأ: ${state.message}'));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final HadithChapter chapter;
  final int index;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.chapter,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing3),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppTheme.primaryEmerald.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            child: Row(
              children: [
                // Index Circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryEmerald,
                        AppTheme.primaryEmerald.withValues(alpha: 0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryEmerald.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing4),
                // Chapter Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.titleArabic,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacing2),
                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppTheme.accentGold.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
