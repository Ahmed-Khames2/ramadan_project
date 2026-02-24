import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/hadith.dart';
import '../cubits/hadith_library_cubit.dart';
import 'hadith_list_page.dart';

class HadithChaptersPage extends StatefulWidget {
  final HadithBook book;
  const HadithChaptersPage({super.key, required this.book});

  @override
  State<HadithChaptersPage> createState() => _HadithChaptersPageState();
}

class _HadithChaptersPageState extends State<HadithChaptersPage> {
  @override
  void initState() {
    super.initState();
    context.read<HadithLibraryCubit>().loadChapters(widget.book.key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.book.nameArabic)),
      body: DecorativeBackground(
        child: BlocBuilder<HadithLibraryCubit, HadithLibraryState>(
          builder: (context, state) {
            if (state is HadithLibraryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HadithLibraryChaptersLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(AppTheme.spacing4),
                itemCount: state.chapters.length,
                itemBuilder: (context, index) {
                  final chapter = state.chapters[index];
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
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryEmerald.withValues(alpha: 0.1),
          child: Text(
            '$index',
            style: const TextStyle(
              color: AppTheme.primaryEmerald,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          chapter.titleArabic,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}
