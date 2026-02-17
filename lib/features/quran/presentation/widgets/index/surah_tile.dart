import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'package:ramadan_project/domain/entities/surah_info.dart';
import 'package:ramadan_project/features/quran/presentation/pages/mushaf_page_view.dart';

class SurahTile extends StatelessWidget {
  final SurahInfo surah;

  const SurahTile({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: IslamicCard(
        padding: EdgeInsets.zero,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MushafPageView(initialPage: surah.startPage),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildNumberIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          surah.nameArabic,
                          style: const TextStyle(
                            fontFamily: 'UthmanTaha',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        RevelationBadge(isMakki: surah.isMakki),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '${surah.ayahCount} آيات',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: AppTheme.textGrey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppTheme.textGrey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getJuzText(),
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: AppTheme.primaryEmerald,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: AppTheme.textGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getJuzText() {
    int start = quran.getJuzNumber(surah.number, 1);
    int end = quran.getJuzNumber(surah.number, surah.ayahCount);

    if (start == end) {
      return 'الجزء $start';
    } else {
      return 'الأجزاء $start - ${end - 1}';
    }
  }

  Widget _buildNumberIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.star_outline_rounded,
          size: 48,
          color: AppTheme.accentGold.withOpacity(0.3),
        ),
        Text(
          '${surah.number}',
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryEmerald,
          ),
        ),
      ],
    );
  }
}
