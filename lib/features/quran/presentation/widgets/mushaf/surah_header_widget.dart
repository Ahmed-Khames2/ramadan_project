import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The Islamic SVG Banner
          SvgPicture.asset(
            'assets/images/surah_name_banner.svg',
            width: MediaQuery.of(context).size.width * 0.85 * scale,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFFC5A028)
                  : const Color(0xFFD4AF37),
              BlendMode.srcIn,
            ),
          ),
          // The Surah Name overlay
          Padding(
            padding: const EdgeInsets.only(
              bottom: 4,
            ), // Slight adjustment for optical centering
            child: Text(
              quran.getSurahNameArabic(surahNumber),
              style: TextStyle(
                fontFamily: 'UthmanTaha',
                fontFamilyFallback: const [
                  'KFGQPCUthmanTahaNaskhRegular',
                  'Amiri',
                ],
                fontSize: (28 * scale).clamp(22, 42),
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                    color: Colors.black.withOpacity(0.05),
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
