import 'package:flutter/material.dart';
import 'package:ramadan_project/core/utils/string_extensions.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/quran/presentation/bloc/quran_settings_cubit.dart';

class PageFooterWidget extends StatelessWidget {
  final int pageNumber;
  final bool isBookmarked;
  final VoidCallback? onBookmarkTap;

  final MushafReadingMode readingMode;

  const PageFooterWidget({
    super.key,
    required this.pageNumber,
    this.isBookmarked = false,
    this.onBookmarkTap,
    required this.readingMode,
  });

  String _getHizbQuarterText() {
    try {
      if (pageNumber == 1) return "الحزب ١ • الربع ١";
      if (pageNumber >= 604) return "الحزب ٦٠ • الربع ٤";

      // The standard Medina Mushaf aligns 1 Juz = 20 pages, 1 Hizb = 10 pages
      // Starting from page 2.
      int hizb = ((pageNumber - 2) / 10).floor() + 1;

      // Each Hizb is 4 Quarters, making each Quarter roughly 2.5 pages long
      double offsetInHizb = (pageNumber - 2) % 10;
      int quarter = (offsetInHizb / 2.5).floor() + 1;

      // Cap at 60 for safety
      if (hizb > 60) hizb = 60;

      return "الحزب ${hizb.toArabic()} • الربع ${quarter.toArabic()}";
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left Side: Rub (Hizb Quarter) info
          Positioned(
            left: 0,
            child: Text(
              _getHizbQuarterText(),
              style: TextStyle(
                fontFamily: 'UthmanTaha',
                fontSize: 16,
                color: textColor.withOpacity(0.5),
                fontWeight: FontWeight.normal,
              ),
            ),
          ),

          // Centered Page number
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 14,
                color: textColor.withOpacity(0.3),
              ),
              const SizedBox(width: 8),
              Text(
                pageNumber.toArabic(),
                style: TextStyle(
                  fontFamily: 'UthmanTaha',
                  fontSize: 18,
                  color: textColor.withOpacity(0.7),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),

          // Bookmark Toggle on the Far Right
          Positioned(
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onBookmarkTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 24,
                    color: isBookmarked
                        ? (readingMode == MushafReadingMode.navy
                              ? Colors.white
                              : AppTheme.accentGold)
                        : textColor.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
