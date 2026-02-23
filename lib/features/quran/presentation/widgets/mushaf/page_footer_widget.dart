import 'package:flutter/material.dart';
import '../../utils/arabic_digits_ext.dart';

class PageFooterWidget extends StatelessWidget {
  final int pageNumber;

  const PageFooterWidget({super.key, required this.pageNumber});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Bookmark / Page icon on the left of number
          Icon(
            Icons.menu_book_rounded,
            size: 16,
            color: textColor.withOpacity(0.4),
          ),
          const SizedBox(width: 8),
          // Page number
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
    );
  }
}
