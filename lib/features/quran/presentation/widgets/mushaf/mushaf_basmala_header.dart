import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadan_project/features/quran/presentation/bloc/quran_settings_cubit.dart';

class MushafBasmalaHeader extends StatelessWidget {
  final int surahNumber;
  final double scale;
  final double pageWidth;
  final TextStyle baseTextStyle;

  final MushafReadingMode readingMode;

  const MushafBasmalaHeader({
    super.key,
    required this.surahNumber,
    required this.scale,
    required this.pageWidth,
    required this.baseTextStyle,
    required this.readingMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: readingMode == MushafReadingMode.navy
                  ? Colors.white.withOpacity(0.5)
                  : const Color(0xFFD4AF37),
              width: 1.2,
            ),
          ),
          child: Text(
            'سورة ${quran.getSurahNameArabic(surahNumber)}',
            style: baseTextStyle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 20 * scale,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (surahNumber != 1 && surahNumber != 9)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
              style: baseTextStyle.copyWith(fontSize: 22 * scale),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
