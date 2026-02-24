import 'package:flutter/material.dart';
import '../../utils/arabic_digits_ext.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';

class PageFooterWidget extends StatelessWidget {
  final int pageNumber;
  final bool isBookmarked;
  final VoidCallback? onBookmarkTap;

  const PageFooterWidget({
    super.key,
    required this.pageNumber,
    this.isBookmarked = false,
    this.onBookmarkTap,
  });

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
                pageNumber.toArabicDigits(),
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
                        ? AppTheme.accentGold
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
