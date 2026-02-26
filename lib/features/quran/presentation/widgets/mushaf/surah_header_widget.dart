import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadan_project/features/quran/presentation/bloc/quran_settings_cubit.dart';
import 'islamic_frame_painter.dart';

class SurahHeaderWidget extends StatelessWidget {
  final int surahNumber;
  final double scale;
  final MushafReadingMode readingMode;

  const SurahHeaderWidget({
    super.key,
    required this.surahNumber,
    this.scale = 1.0,
    required this.readingMode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = readingMode == MushafReadingMode.navy
        ? Colors.white.withValues(alpha: 0.8)
        : (isDark ? const Color(0xFFC5A028) : const Color(0xFFD4AF37));

    final bgColor = readingMode == MushafReadingMode.navy
        ? const Color(0xFF35355F)
        : goldColor.withValues(alpha: 0.05);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      width: double.infinity,
      height: 60 * scale, // Fixed height proportional to scale
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The geometric painted frame
          Positioned.fill(
            child: CustomPaint(
              painter: IslamicFramePainter(
                color: goldColor.withValues(alpha: 0.6),
                strokeWidth: 1.5,
              ),
            ),
          ),

          // Side Ornaments (Static or Svg)
          // We can add symmetrical icons on the sides for balance
          Positioned(
            left: 24,
            child: Icon(
              Icons.star_half_rounded,
              color: goldColor.withValues(alpha: 0.5),
              size: 16 * scale,
            ),
          ),
          Positioned(
            right: 24,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159), // Flip horizontally
              child: Icon(
                Icons.star_half_rounded,
                color: goldColor.withValues(alpha: 0.5),
                size: 16 * scale,
              ),
            ),
          ),

          // The Surah Name overlay
          Padding(
            padding: const EdgeInsets.only(bottom: 6), // Optical centering
            child: Text(
              quran.getSurahNameArabic(surahNumber),
              style: TextStyle(
                fontFamily: 'UthmanTaha',
                fontFamilyFallback: const [
                  'KFGQPCUthmanTahaNaskhRegular',
                  'Amiri',
                ],
                fontSize: (26 * scale).clamp(20, 38),
                color: readingMode == MushafReadingMode.navy
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
