import 'package:flutter/material.dart';

class QuranZoomPill extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const QuranZoomPill({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.cardColor.withOpacity(0.95),
      elevation: 4,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: (isDark ? const Color(0xFFC5A028) : const Color(0xFFD4AF37))
                .withOpacity(0.6),
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 20),
              color: theme.colorScheme.onSurface,
              onPressed: onZoomOut,
              tooltip: 'تصغير',
            ),
            Container(
              width: 1,
              height: 22,
              color:
                  (isDark ? const Color(0xFFC5A028) : const Color(0xFFD4AF37))
                      .withOpacity(0.4),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              color: theme.colorScheme.onSurface,
              onPressed: onZoomIn,
              tooltip: 'تكبير',
            ),
          ],
        ),
      ),
    );
  }
}
