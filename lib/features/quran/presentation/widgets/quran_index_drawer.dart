import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/quran/presentation/bloc/quran_settings_cubit.dart';
import 'package:ramadan_project/core/utils/string_extensions.dart';
import '../utils/arabic_digits_ext.dart';

class QuranIndexDrawer extends StatelessWidget {
  final Function(int page) onPageSelected;
  final VoidCallback onReadingModeToggle;
  final Function(double scale) onFontScaleChanged;
  final VoidCallback onBookmarkListTap;
  final double currentFontScale;
  final MushafReadingMode readingMode;

  const QuranIndexDrawer({
    super.key,
    required this.onPageSelected,
    required this.onReadingModeToggle,
    required this.onFontScaleChanged,
    required this.onBookmarkListTap,
    required this.currentFontScale,
    required this.readingMode,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getThemeColors(context);

    return Drawer(
      backgroundColor: colors.background,
      child: Column(
        children: [
          _buildHeader(context, colors),
          _buildSettingsSection(context, colors),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: colors.primary,
                    unselectedLabelColor: colors.text.withOpacity(0.5),
                    indicatorColor: colors.primary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: const [
                      Tab(text: "السور"),
                      Tab(text: "الأجزاء"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildSurahList(context, colors),
                        _buildJuzList(context, colors),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _DrawerThemeColors _getThemeColors(BuildContext context) {
    switch (readingMode) {
      case MushafReadingMode.white:
        return _DrawerThemeColors(
          background: Colors.white,
          accent: AppTheme.primaryEmerald.withOpacity(0.05),
          primary: AppTheme.primaryEmerald,
          text: const Color(0xFF1E1E2E),
          card: Colors.grey.withOpacity(0.03),
        );
      case MushafReadingMode.beige:
        return _DrawerThemeColors(
          background: const Color(0xFFF4EAD5),
          accent: const Color(0xFF795548).withOpacity(0.1),
          primary: const Color(0xFF795548),
          text: const Color(0xFF3E2723),
          card: const Color(0xFF795548).withOpacity(0.05),
        );
      case MushafReadingMode.dark:
        return _DrawerThemeColors(
          background: const Color(0xFF121212),
          accent: AppTheme.primaryEmerald.withOpacity(0.1),
          primary: AppTheme.primaryEmerald,
          text: const Color(0xFFE0E0E0),
          card: Colors.white.withOpacity(0.03),
        );
      case MushafReadingMode.navy:
        return _DrawerThemeColors(
          background: const Color(0xFF1A1C2E),
          accent: Colors.indigo.withOpacity(0.2),
          primary: const Color(0xFF818CF8),
          text: Colors.white,
          card: Colors.white.withOpacity(0.05),
        );
    }
  }

  Widget _buildHeader(BuildContext context, _DrawerThemeColors colors) {
    return Container(
      padding: const EdgeInsets.only(top: 64, bottom: 20),
      decoration: BoxDecoration(
        color: colors.accent,
        border: Border(
          bottom: BorderSide(color: colors.primary.withOpacity(0.1)),
        ),
      ),
      width: double.infinity,
      child: Column(
        children: [
          Icon(Icons.grid_view_rounded, color: colors.primary, size: 36),
          const SizedBox(height: 12),
          Text(
            "فهرس القرآن",
            style: TextStyle(
              fontFamily: 'UthmanTaha',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    _DrawerThemeColors colors,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          bottom: BorderSide(color: colors.text.withOpacity(0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleBtn(
            context,
            icon: Icons.palette_rounded,
            onTap: onReadingModeToggle,
            colors: colors,
            label: "السمة",
          ),
          _buildZoomControls(context, colors),
          _buildCircleBtn(
            context,
            icon: Icons.bookmarks_rounded,
            onTap: onBookmarkListTap,
            colors: colors,
            label: "المفضلة",
          ),
        ],
      ),
    );
  }

  Widget _buildCircleBtn(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    required _DrawerThemeColors colors,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: colors.accent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: colors.primary, size: 22),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            color: colors.text.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildZoomControls(BuildContext context, _DrawerThemeColors colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.accent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _zoomBtn(
                Icons.remove,
                () => onFontScaleChanged(currentFontScale - 0.1),
                colors,
              ),
              Container(
                width: 45,
                alignment: Alignment.center,
                child: Text(
                  "${(currentFontScale * 100).toInt().toArabic()}%",
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
              ),
              _zoomBtn(
                Icons.add,
                () => onFontScaleChanged(currentFontScale + 0.1),
                colors,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "حجم الخط",
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            color: colors.text.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _zoomBtn(
    IconData icon,
    VoidCallback onTap,
    _DrawerThemeColors colors,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: colors.primary, size: 20),
      ),
    );
  }

  Widget _buildSurahList(BuildContext context, _DrawerThemeColors colors) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      itemCount: 114,
      itemBuilder: (context, index) {
        final surahNum = index + 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  surahNum.toArabic(),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ),
              title: Text(
                "سورة ${quran.getSurahNameArabic(surahNum)}",
                style: TextStyle(
                  fontFamily: 'UthmanTaha',
                  fontSize: 21,
                  color: colors.text,
                ),
              ),
              subtitle: Text(
                "${quran.getPlaceOfRevelation(surahNum) == 'Makkah' ? 'مكية' : 'مدنية'} • ${quran.getVerseCount(surahNum).toArabic()} آية",
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: colors.text.withOpacity(0.6),
                ),
              ),
              onTap: () {
                final page = quran.getPageNumber(surahNum, 1);
                onPageSelected(page);
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildJuzList(BuildContext context, _DrawerThemeColors colors) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNum = index + 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: colors.primary,
                  size: 20,
                ),
              ),
              title: Text(
                juzNum.toJuzName(),
                style: TextStyle(
                  fontFamily: 'UthmanTaha',
                  fontSize: 21,
                  color: colors.text,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colors.text.withOpacity(0.3),
              ),
              onTap: () {
                final page = context.read<QuranRepository>().getJuzStartPage(
                  juzNum,
                );
                onPageSelected(page);
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }
}

class _DrawerThemeColors {
  final Color background;
  final Color accent;
  final Color primary;
  final Color text;
  final Color card;

  _DrawerThemeColors({
    required this.background,
    required this.accent,
    required this.primary,
    required this.text,
    required this.card,
  });
}
