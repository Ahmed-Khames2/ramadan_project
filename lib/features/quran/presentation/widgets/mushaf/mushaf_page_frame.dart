import 'package:flutter/material.dart';
import 'package:ramadan_project/features/quran/domain/entities/quran_page.dart';
import 'package:ramadan_project/features/quran/presentation/bloc/quran_settings_cubit.dart';
import 'page_header_widget.dart';
import 'page_footer_widget.dart';

class MushafPageFrame extends StatelessWidget {
  final Widget child;
  final QuranPage page;
  final Color? backgroundColor;
  final VoidCallback? onSearchTap;
  final VoidCallback? onMenuTap;
  final bool showHeader;

  final bool isBookmarked;
  final VoidCallback? onBookmarkTap;
  final MushafReadingMode readingMode;

  const MushafPageFrame({
    super.key,
    required this.child,
    required this.page,
    this.backgroundColor,
    this.onSearchTap,
    this.onMenuTap,
    this.showHeader = true,
    this.isBookmarked = false,
    this.onBookmarkTap,
    required this.readingMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.surface;

    return Container(
      color: bg,
      child: Column(
        children: [
          // ─── Header ────────────────────────────────────────────────
          if (showHeader) ...[
            Padding(
              padding: const EdgeInsets.only(
                top: 8,
                left: 12,
                right: 12,
                bottom: 4,
              ),
              child: PageHeaderWidget(
                page: page,
                onSearchTap: onSearchTap,
                onMenuTap: onMenuTap,
                readingMode: readingMode,
              ),
            ),
            // ─── Thin Divider ──────────────────────────────────────────
            Divider(
              height: 1,
              thickness: 0.5,
              color: theme.colorScheme.onSurface.withOpacity(0.12),
              indent: 16,
              endIndent: 16,
            ),
          ],
          // ─── Main Content ─────────────────────────────────────────
          Expanded(child: child),
          // ─── Footer ───────────────────────────────────────────────
          Divider(
            height: 1,
            thickness: 0.5,
            color: theme.colorScheme.onSurface.withOpacity(0.12),
            indent: 16,
            endIndent: 16,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 2),
            child: PageFooterWidget(
              pageNumber: page.pageNumber,
              isBookmarked: isBookmarked,
              onBookmarkTap: onBookmarkTap,
              readingMode: readingMode,
            ),
          ),
        ],
      ),
    );
  }
}
