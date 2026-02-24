import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/hadith.dart';
import '../cubits/hadith_library_cubit.dart';
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
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadHadiths();
    _scrollController.addListener(_onScroll);
  }

  void _loadHadiths({bool isLoadMore = false}) {
    context.read<HadithLibraryCubit>().loadHadiths(
      bookKey: widget.book.key,
      chapterId: widget.chapter.chapterId,
      page: _currentPage,
      isLoadMore: isLoadMore,
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<HadithLibraryCubit>().state;
      if (state is HadithLibraryHadithsLoaded &&
          !state.hasReachedMax &&
          !state.isLoadingMore) {
        _currentPage++;
        _loadHadiths(isLoadMore: true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chapter.titleArabic)),
      body: DecorativeBackground(
        child: BlocBuilder<HadithLibraryCubit, HadithLibraryState>(
          builder: (context, state) {
            if (state is HadithLibraryLoading && _currentPage == 0) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HadithLibraryHadithsLoaded ||
                (state is HadithLibraryLoading && _currentPage > 0)) {
              final hadiths = state is HadithLibraryHadithsLoaded
                  ? state.hadiths
                  : (state as dynamic)
                        .hadiths; // Re-use old list while loading more

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppTheme.spacing4),
                itemCount:
                    hadiths.length +
                    (state is HadithLibraryHadithsLoaded && state.hasReachedMax
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
                  return _HadithCard(
                    hadith: hadith,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HadithDetailPage(hadith: hadith),
                        ),
                      );
                    },
                  );
                },
              );
            } else if (state is HadithLibraryError) {
              return Center(child: Text('خطأ: ${state.message}'));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  final Hadith hadith;
  final VoidCallback onTap;

  const _HadithCard({required this.hadith, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing3),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        side: BorderSide(
          color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing2,
                      vertical: AppTheme.spacing1 / 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Text(
                      'حديث رقم ${hadith.idInBook}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryEmerald,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing3),
              Text(
                hadith.textArabic,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.6,
                  fontFamily: 'Amiri',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
