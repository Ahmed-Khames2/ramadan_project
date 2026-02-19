import 'package:flutter/material.dart';

import 'package:quran/quran.dart' as quran;
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'package:ramadan_project/features/quran/presentation/pages/mushaf_page_view.dart';

class JuzTile extends StatelessWidget {
  final int juzNumber;
  final String firstSurahName;

  const JuzTile({
    super.key,
    required this.juzNumber,
    required this.firstSurahName,
  });

  @override
  Widget build(BuildContext context) {
    final juzStartPage = quran.getPageNumber(
      quran.getSurahAndVersesFromJuz(juzNumber).keys.first,
      quran.getSurahAndVersesFromJuz(juzNumber).values.first[0],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: IslamicCard(
        padding: EdgeInsets.zero,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MushafPageView(initialPage: juzStartPage),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildJuzNumberBox(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الصفحة $juzStartPage',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'يبدأ من $firstSurahName',
                      style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
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

  Widget _buildJuzNumberBox() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryEmerald, Color(0xFF1A5E20)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('الجزء', style: TextStyle(fontSize: 10, color: Colors.white70)),
          Text(
            '$juzNumber',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
