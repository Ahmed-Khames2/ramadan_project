import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;

class AyahTextWidget extends StatelessWidget {
  final int surahNumber;
  final int ayahNumber;
  final bool isSelected;
  final VoidCallback onTap;

  const AyahTextWidget({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ayahText = quran.getVerse(
      surahNumber,
      ayahNumber,
      verseEndSymbol: false,
    );

    return GestureDetector(
      onLongPress: onTap,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2E7D32).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2E7D32)
                : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ayah number badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$ayahNumber',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Ayah text
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: ayahText,
                      style: GoogleFonts.amiri(
                        fontSize: 24,
                        height: 1.8,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: ' \u06DD$ayahNumber ',
                      style: GoogleFonts.amiri(
                        fontSize: 20,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
