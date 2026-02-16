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
                fontSize: (28 * scale).clamp(22, 42),
                color: const Color(0xFF111111),
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
