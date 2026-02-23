import 'package:flutter/material.dart';

import 'package:quran/quran.dart' as quran;
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'package:ramadan_project/domain/entities/surah_info.dart';
import 'package:ramadan_project/features/quran/presentation/pages/mushaf_page_view.dart';

class SurahTile extends StatelessWidget {
  final SurahInfo surah;
  final bool isLastRead;
  final int? initialPage;
  final VoidCallback? onReturn;

  const SurahTile({
    super.key,
    required this.surah,
    this.isLastRead = false,
    this.initialPage,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: IslamicCard(
        padding: EdgeInsets.zero,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MushafPageView(
                initialPage: initialPage ?? surah.startPage,
                initialSurah: surah.number,
              ),
            ),
          );
          if (onReturn != null) onReturn!();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildNumberIcon(context),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          surah.nameArabic,
                          style: TextStyle(
                            fontFamily: 'UthmanTaha',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
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
                          style: const TextStyle(
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
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
      return 'الأجزاء $start - $end';
    }
  }

  Widget _buildNumberIcon(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.star_rounded,
          size: 48,
          color: isLastRead
              ? AppTheme.accentGold.withValues(alpha: 0.9)
              : AppTheme.primaryEmerald.withValues(alpha: 0.1),
        ),
        if (isLastRead)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppTheme.primaryEmerald,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: const Icon(
                Icons.bookmark_rounded,
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
        Text(
          '${surah.number}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
            color: isLastRead
                ? AppTheme.primaryEmerald
                : AppTheme.primaryEmerald.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
