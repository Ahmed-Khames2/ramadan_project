import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';
import 'package:ramadan_project/features/quran/presentation/pages/mushaf_page_view.dart';
import 'package:ramadan_project/core/utils/string_extensions.dart';

class BookmarksSheet extends StatefulWidget {
  const BookmarksSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RepositoryProvider.value(
        value: context.read<QuranRepository>(),
        child: const BookmarksSheet(),
      ),
    );
  }

  @override
  State<BookmarksSheet> createState() => _BookmarksSheetState();
}

class _BookmarksSheetState extends State<BookmarksSheet> {
  List<int> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() {
    final progress = context.read<QuranRepository>().getProgress();
    setState(() {
      _bookmarks = List<int>.from(progress?.bookmarks ?? []);
    });
  }

  Future<void> _removeBookmark(int page) async {
    await context.read<QuranRepository>().removeBookmark(page);
    setState(() {
      _bookmarks.remove(page);
    });
  }

  String _getPageLabel(int page) {
    try {
      final data = quran.getPageData(page);
      if (data.isNotEmpty) {
        final surah = data.first['surah'] as int;
        final juz = quran.getJuzNumber(surah, data.first['start'] as int? ?? 1);
        return 'سورة ${quran.getSurahNameArabic(surah)} — الجزء ${juz.toArabic()}';
      }
    } catch (_) {}
    return 'صفحة ${page.toArabic()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      maxChildSize: 0.85,
      minChildSize: 0.3,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmark_rounded,
                        color: AppTheme.accentGold,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الإشارات المرجعية',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_bookmarks.length.toArabic()} صفحة محفوظة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Divider(
                color: theme.colorScheme.onSurface.withOpacity(0.08),
                height: 1,
              ),
              // Bookmarks List
              Expanded(
                child: _bookmarks.isEmpty
                    ? _buildEmpty(theme)
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _bookmarks.length,
                        itemBuilder: (context, index) {
                          final page = _bookmarks[index];
                          return _BookmarkTile(
                            page: page,
                            subtitle: _getPageLabel(page),
                            isDark: isDark,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MushafPageView(initialPage: page),
                                ),
                              );
                            },
                            onDelete: () => _removeBookmark(page),
                          );
                        },
                      ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmark_border_rounded,
            size: 72,
            color: AppTheme.accentGold.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد إشارات مرجعية',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط زر العلامة 🔖 أثناء القراءة لحفظ صفحة',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppTheme.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  final int page;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BookmarkTile({
    required this.page,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.onSurface.withOpacity(0.04)
              : AppTheme.accentGold.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.accentGold.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Page badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  page.toArabic(),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'صفحة ${page.toArabic()}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            // Delete button
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              color: Colors.redAccent.withOpacity(0.7),
              iconSize: 20,
              tooltip: 'حذف',
            ),
          ],
        ),
      ),
    );
  }
}
