import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

class SurahHeaderWidget extends StatelessWidget {
  final int surahNumber;
  final double scale;

  const SurahHeaderWidget({
    super.key,
    required this.surahNumber,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'سورة ${quran.getSurahNameArabic(surahNumber)}',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontFamily: 'UthmanTaha',
          fontWeight: FontWeight.bold,
          fontSize: (22 * scale).clamp(18, 30),
          color: theme.colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
