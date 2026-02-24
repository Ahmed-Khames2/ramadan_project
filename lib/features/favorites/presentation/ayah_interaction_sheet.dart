import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran/quran.dart' as quran;
import 'package:share_plus/share_plus.dart';
import 'package:ramadan_project/features/khatmah/presentation/bloc/khatam_bloc.dart';
import 'package:ramadan_project/features/quran/presentation/pages/mushaf_page_view.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/quran/presentation/utils/arabic_digits_ext.dart';

class AyahInteractionSheet extends StatelessWidget {
  final int surahNumber;
  final int ayahNumber;
  final int ayahId;
  final MushafReadingMode readingMode;

  const AyahInteractionSheet({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
    required this.ayahId,
    required this.readingMode,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getThemeColors(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: colors.text.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header with Surah info and Favorite
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سورة ${quran.getSurahNameArabic(surahNumber)}',
                      style: TextStyle(
                        fontFamily: 'UthmanTaha',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                    Text(
                      'الآية الرقم $ayahNumber',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: colors.text.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tafsir Card
          _buildTafsirCard(context, colors),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildMainAction(
                  label: 'مشاركة',
                  onTap: () async {
                    final tafsirText = await context
                        .read<KhatamBloc>()
                        .quranRepository
                        .getTafsir(surahNumber, ayahNumber);

                    final surahName = quran.getSurahNameArabic(surahNumber);
                    final pageNum = quran.getPageNumber(
                      surahNumber,
                      ayahNumber,
                    );

                    final String cleanVerse = quran.getVerse(
                      surahNumber,
                      ayahNumber,
                      verseEndSymbol: false,
                    );
                    final String endSymbol = quran.getVerseEndSymbol(
                      ayahNumber,
                    );

                    final shareText =
                        '﴿ $cleanVerse $endSymbol ﴾\n\n'
                        'التفسير الميسر:\n'
                        '$tafsirText\n\n'
                        'سورة $surahName | الآية: ${ayahNumber.toArabicDigits()} | صفحة: ${pageNum.toArabicDigits()}';

                    Share.share(shareText);
                  },
                  colors: colors,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSecondaryAction(
                  label: 'إغلاق',
                  onTap: () => Navigator.pop(context),
                  colors: colors,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTafsirCard(BuildContext context, _SheetThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'التفسير الميسر',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<String>(
            future: context.read<KhatamBloc>().quranRepository.getTafsir(
              surahNumber,
              ayahNumber,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: LinearProgressIndicator(
                      backgroundColor: colors.text.withOpacity(0.05),
                      color: colors.primary,
                    ),
                  ),
                );
              }
              return Text(
                snapshot.data ?? 'تعذر تحميل التفسير',
                style: TextStyle(
                  fontFamily: 'UthmanTaha',
                  fontSize: 18,
                  height: 1.7,
                  color: colors.text,
                ),
                textAlign: TextAlign.justify,
                textDirection: TextDirection.rtl,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainAction({
    required String label,
    IconData? icon,
    required VoidCallback onTap,
    required _SheetThemeColors colors,
  }) {
    final buttonContent = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        : Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          );

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: buttonContent,
    );
  }

  Widget _buildSecondaryAction({
    required String label,
    required VoidCallback onTap,
    required _SheetThemeColors colors,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          color: colors.text.withOpacity(0.8),
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: colors.text.withOpacity(0.1)),
      ),
    );
  }

  _SheetThemeColors _getThemeColors(BuildContext context) {
    switch (readingMode) {
      case MushafReadingMode.white:
        return _SheetThemeColors(
          background: Colors.white,
          accent: AppTheme.primaryEmerald.withOpacity(0.05),
          primary: AppTheme.primaryEmerald,
          text: const Color(0xFF1E1E2E),
        );
      case MushafReadingMode.beige:
        return _SheetThemeColors(
          background: const Color(0xFFF4EAD5),
          accent: const Color(0xFF3E2723).withOpacity(0.05),
          primary: const Color(0xFF795548),
          text: const Color(0xFF3E2723),
        );
      case MushafReadingMode.dark:
        return _SheetThemeColors(
          background: const Color(0xFF1E1E1E),
          accent: Colors.white.withOpacity(0.03),
          primary: AppTheme.primaryEmerald,
          text: const Color(0xFFE0E0E0),
        );
      case MushafReadingMode.navy:
        return _SheetThemeColors(
          background: const Color(0xFF1A1C2E),
          accent: Colors.white.withOpacity(0.05),
          primary: const Color(0xFF818CF8),
          text: Colors.white,
        );
    }
  }
}

class _SheetThemeColors {
  final Color background;
  final Color accent;
  final Color primary;
  final Color text;

  _SheetThemeColors({
    required this.background,
    required this.accent,
    required this.primary,
    required this.text,
  });
}
