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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacing6,
        horizontal: AppTheme.spacing4,
      ),
      width: double.infinity,
      child: Column(
        children: [
          // Upper Ornament
          OrnamentalDivider(
            width: 80,
            color: theme.colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppTheme.spacing4),

          // Surah Name (Arabic)
          Text(
            surahName,
            style: TextStyle(
              fontFamily: 'UthmanTaha',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(height: AppTheme.spacing2),

          // Surah Metadata
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMetaItem(
                context,
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
                  style: TextStyle(
                    color: theme.colorScheme.secondary.withOpacity(0.4),
                  ),
                ),
              ),
              _buildMetaItem(
                context,
                '$ayahCount آية',
                Icons.format_list_numbered_rtl,
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacing4),
          // Lower Ornament
          OrnamentalDivider(
            width: 80,
            color: theme.colorScheme.secondary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(BuildContext context, String text, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.secondary),
        const SizedBox(width: AppTheme.spacing2),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }
}
