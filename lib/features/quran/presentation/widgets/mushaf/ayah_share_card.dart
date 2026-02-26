import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/quran/domain/entities/ayah.dart';
import 'package:ramadan_project/features/quran/presentation/bloc/quran_settings_cubit.dart';

class AyahShareCard extends StatelessWidget {
  final Ayah ayah;
  final MushafReadingMode readingMode;

  const AyahShareCard({
    super.key,
    required this.ayah,
    required this.readingMode,
  });

  @override
  Widget build(BuildContext context) {
    // Define colors based on reading mode
    final Color backgroundColor;
    final Color textColor;
    final Color accentColor;
    final Color secondaryTextColor;

    switch (readingMode) {
      case MushafReadingMode.dark:
        backgroundColor = const Color(0xFF121212); // Deeper black
        textColor = Colors.white;
        accentColor = AppTheme.accentGold;
        secondaryTextColor = Colors.white54;
        break;
      case MushafReadingMode.navy:
        backgroundColor = const Color(0xFF0D1117); // Darker navy/black
        textColor = Colors.white;
        accentColor = AppTheme.accentGold;
        secondaryTextColor = Colors.white54;
        break;
      case MushafReadingMode.beige:
        backgroundColor = AppTheme.mushafBeige;
        textColor = AppTheme.textDark;
        accentColor = AppTheme.accentGold;
        secondaryTextColor = AppTheme.textGrey;
        break;
      case MushafReadingMode.white:
        backgroundColor = AppTheme.surfaceWhite;
        textColor = AppTheme.textDark;
        accentColor = AppTheme.primaryEmerald;
        secondaryTextColor = AppTheme.textGrey;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 600,
        height: 600,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
        color: backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Quote Icon (Proper pair)
            Text(
              '”',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 100,
                color: accentColor.withOpacity(0.9),
                height: 0.8,
                decoration: TextDecoration.none,
              ),
            ),

            const SizedBox(height: 30),

            // Verse Text (Responsive)
            Expanded(
              child: Center(
                child: AutoSizeText(
                  ayah.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'UthmanTaha',
                    fontSize: 56,
                    height: 1.6,
                    color: textColor,
                    decoration: TextDecoration.none,
                  ),
                  maxLines: 40,
                  minFontSize: 8,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Divider Ornament
            _buildOrnament(accentColor),

            const SizedBox(height: 30),

            // Surah & Ayah Info
            Text(
              'سورة ${ayah.surahName} - آية ${ayah.ayahNumber}',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: accentColor,
                decoration: TextDecoration.none,
              ),
            ),

            const SizedBox(height: 20),

            // Footer / Brand
            Text(
              'تطبيق زاد المؤمن',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                color: secondaryTextColor,
                letterSpacing: 1.5,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrnament(Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
            ),
            // Inner decorative circle
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.5), width: 1),
              ),
            ),
            // Spokes/Lines
            for (var i = 0; i < 8; i++)
              Transform.rotate(
                angle: (i * 45) * 3.14159 / 180,
                child: Container(height: 48, width: 1.5, color: color),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 1.2,
          width: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0), color, color.withOpacity(0)],
            ),
          ),
        ),
      ],
    );
  }
}
