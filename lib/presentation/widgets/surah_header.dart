import 'package:flutter/material.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
class SurahHeader extends StatelessWidget {
  final String surahName;
  final String revelationType;
  final int ayahCount;
  final int surahNumber;

  const SurahHeader({
    super.key,
    required this.surahName,
    required this.revelationType,
    required this.ayahCount,
    required this.surahNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacing6,
        horizontal: AppTheme.spacing4,
      ),
      width: double.infinity,
      child: Column(
        children: [
          // Upper Ornament
          const OrnamentalDivider(width: 80),
          const SizedBox(height: AppTheme.spacing4),

          // Surah Name (Arabic)
          Text(
            surahName,
            style: const TextStyle(
              fontFamily: 'UthmanTaha',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryEmerald,
            ),
          ),

          const SizedBox(height: AppTheme.spacing2),

          // Surah Metadata
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMetaItem(
                revelationType.toLowerCase().contains('mecc')
                    ? 'مكية'
                    : 'مدنية',
                revelationType.toLowerCase().contains('mecc')
                    ? Icons.mosque_outlined
                    : Icons.location_city_outlined,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing3,
                ),
                child: Text(
                  '•',
                  style: TextStyle(color: AppTheme.accentGold.withOpacity(0.4)),
                ),
              ),
              _buildMetaItem('$ayahCount آية', Icons.format_list_numbered_rtl),
            ],
          ),

          const SizedBox(height: AppTheme.spacing4),
          // Lower Ornament
          OrnamentalDivider(
            width: 80,
            color: AppTheme.accentGold.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.accentGold),
        const SizedBox(width: AppTheme.spacing2),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textGrey,
            ),
          ),
        ),
      ],
    );
  }
}
