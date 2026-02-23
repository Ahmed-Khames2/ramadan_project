import 'package:flutter/material.dart';
import 'package:ramadan_project/features/quran/domain/entities/quran_page.dart';
import '../../utils/arabic_digits_ext.dart';

class PageHeaderWidget extends StatelessWidget {
  final QuranPage page;
  final VoidCallback? onSearchTap;
  final VoidCallback? onMenuTap;
  final Color? backgroundColor;

  const PageHeaderWidget({
    super.key,
    required this.page,
    this.onSearchTap,
    this.onMenuTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black87;
    final containerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.04);
    final effectiveBgColor =
        backgroundColor ??
        (isDark
            ? const Color(0xFF1E1E2E) // Solid dark
            : theme.colorScheme.surface);

    return Container(
      decoration: BoxDecoration(
        color: effectiveBgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // 1. Menu Button (Right/Start)
              _buildRoundedButton(
                icon: Icons.menu_rounded,
                onTap: onMenuTap,
                color: containerColor,
                iconColor: iconColor,
              ),

              // 2. Surah Segment (Absolute Center)
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    page.surahName,
                    style: TextStyle(
                      fontFamily: 'UthmanTaha',
                      fontSize: 22,
                      fontWeight: FontWeight.normal,
                      color: iconColor,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // 3. Juz Segment (Left/End)
              Text(
                page.juzNumber.toJuzName(),
                style: TextStyle(
                  fontFamily: 'UthmanTaha',
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: iconColor.withOpacity(0.85),
                ),
              ),

              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedButton({
    required IconData icon,
    VoidCallback? onTap,
    required Color color,
    required Color iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22, color: iconColor),
        ),
      ),
    );
  }
}
