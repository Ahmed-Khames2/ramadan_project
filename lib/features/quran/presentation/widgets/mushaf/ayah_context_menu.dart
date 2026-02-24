import 'package:flutter/material.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/quran/presentation/bloc/quran_settings_cubit.dart';
import 'package:ramadan_project/features/quran/domain/entities/ayah.dart';

class AyahContextMenu extends StatefulWidget {
  final Ayah ayah;
  final VoidCallback onDismiss;
  final Function(Ayah) onTafsir;
  final Function(Ayah) onPlay;
  final Function(Ayah) onPlaySequential;
  final Function(Ayah) onPlaySurah;
  final Function(Ayah) onShare;

  const AyahContextMenu({
    super.key,
    required this.ayah,
    required this.onDismiss,
    required this.onTafsir,
    required this.onPlay,
    required this.onPlaySequential,
    required this.onPlaySurah,
    required this.onShare,
    required this.readingMode,
  });

  final MushafReadingMode readingMode;

  @override
  State<AyahContextMenu> createState() => _AyahContextMenuState();
}

class _AyahContextMenuState extends State<AyahContextMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readingMode = widget.readingMode;
    final isDark =
        theme.brightness == Brightness.dark ||
        readingMode == MushafReadingMode.dark ||
        readingMode == MushafReadingMode.navy;

    final surfaceColor = readingMode == MushafReadingMode.navy
        ? AppTheme.mushafNavyDeep
        : readingMode == MushafReadingMode.dark
        ? AppTheme.cardDark
        : isDark
        ? const Color(0xFF1E1E2E)
        : Colors.white;

    final textColor = readingMode == MushafReadingMode.navy
        ? Colors.white.withValues(alpha: 0.95)
        : isDark
        ? Colors.white
        : Colors.black87;

    final iconPrimary = readingMode == MushafReadingMode.navy
        ? Colors.white.withValues(alpha: 0.8)
        : readingMode == MushafReadingMode.dark
        ? AppTheme.accentGold
        : AppTheme.primaryEmerald;

    final accentColor = readingMode == MushafReadingMode.navy
        ? Colors.white.withValues(alpha: 0.15)
        : (readingMode == MushafReadingMode.dark
                  ? AppTheme.accentGold
                  : AppTheme.primaryEmerald)
              .withOpacity(0.1);

    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.65,
            constraints: const BoxConstraints(maxWidth: 240),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color:
                    (readingMode == MushafReadingMode.navy
                            ? Colors.white
                            : readingMode == MushafReadingMode.dark
                            ? AppTheme.accentGold
                            : AppTheme.primaryEmerald)
                        .withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildItem(
                      icon: Icons.menu_book_outlined,
                      label: 'تفسير',
                      onTap: () => widget.onTafsir(widget.ayah),
                      textColor: textColor,
                      iconColor: iconPrimary,
                      accentColor: accentColor,
                    ),
                    _buildDivider(readingMode, isDark),
                    _buildItem(
                      icon: Icons.hearing_rounded,
                      label: 'الاستماع للايه',
                      onTap: () => widget.onPlay(widget.ayah),
                      textColor: textColor,
                      iconColor: iconPrimary,
                      accentColor: accentColor,
                    ),
                    _buildDivider(readingMode, isDark),
                    _buildItem(
                      icon: Icons.play_circle_outline_rounded,
                      label: 'تشغيل متتابع',
                      onTap: () => widget.onPlaySequential(widget.ayah),
                      textColor: textColor,
                      iconColor: iconPrimary,
                      accentColor: accentColor,
                    ),
                    _buildDivider(readingMode, isDark),
                    _buildItem(
                      icon: Icons.auto_stories_rounded,
                      label: 'سماع السورة من البداية',
                      onTap: () => widget.onPlaySurah(widget.ayah),
                      textColor: textColor,
                      iconColor: iconPrimary,
                      accentColor: accentColor,
                    ),
                    _buildDivider(readingMode, isDark),
                    _buildItem(
                      icon: Icons.share_rounded,
                      label: 'المشاركة',
                      onTap: () => widget.onShare(widget.ayah),
                      textColor: textColor,
                      iconColor: iconPrimary,
                      accentColor: accentColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color textColor,
    required Color iconColor,
    required Color accentColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(MushafReadingMode readingMode, bool isDark) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: (readingMode == MushafReadingMode.navy)
          ? Colors.white.withValues(alpha: 0.08)
          : (isDark ? Colors.white : Colors.black).withOpacity(0.06),
      indent: 20,
      endIndent: 20,
    );
  }
}
